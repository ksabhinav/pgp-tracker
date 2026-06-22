// supabase/functions/extract-pdf/index.ts
// The HARD-CASE route: scanned or multi-column PDFs the browser path flagged ('ocr' / 'parser').
// Downloads the original from the uploads bucket, sends it to a document parser, and writes the
// reflowed result into the same reading_content row the article path uses. Cost-per-document,
// which is fine for a curated catalog.
//
// Pick any parser that returns clean HTML/markdown plus per-page text. Good options:
//   - LlamaParse or Marker  : layout-aware, handle multi-column + tables well
//   - Mathpix               : strong OCR, keeps equations
//   - a vision model        : send page images, ask for clean markdown + page boundaries
// Set the secrets it needs:
//   supabase secrets set PARSER_URL=... PARSER_KEY=...
// Deploy:
//   supabase functions deploy extract-pdf

import { createClient } from 'jsr:@supabase/supabase-js@2';

Deno.serve(async (req) => {
  try {
    const { path, url, reading_id, title, route } = await req.json();

    const supa = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!   // service role: bypasses RLS to write content
    );

    // 1) pull the original PDF out of the uploads bucket
    const { data: file, error } = await supa.storage.from('uploads').download(path);
    if (error) return new Response(error.message, { status: 500 });
    const bytes = new Uint8Array(await file.arrayBuffer());

    // 2) hand it to your chosen parser. Adapt this block to that API's request/response shape.
    //    The expected result here is { html, pageMap:[{page,start,end}], text }.
    const form = new FormData();
    form.append('file', new Blob([bytes], { type: 'application/pdf' }), 'doc.pdf');
    const r = await fetch(Deno.env.get('PARSER_URL')!, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${Deno.env.get('PARSER_KEY')}` },
      body: form,
    });
    if (!r.ok) return new Response('parser failed: ' + (await r.text()), { status: 502 });
    const parsed = await r.json();

    // 3) store as the SAME reading_content row the reflow path writes -> reader treats it identically
    const sourceFile = supa.storage.from('uploads').getPublicUrl(path).data.publicUrl;
    const { error: upErr } = await supa.from('reading_content').upsert({
      url, reading_id, title,
      kind: 'pdf',
      content_html: parsed.html,
      page_map: parsed.pageMap ?? null,
      source_file: sourceFile,
      extracted_by: route === 'ocr' ? 'ocr' : 'parser',
      needs_review: route === 'ocr',            // OCR output is worth a human glance
    });
    if (upErr) return new Response(upErr.message, { status: 500 });

    return new Response(JSON.stringify({ ok: true }), { headers: { 'Content-Type': 'application/json' } });
  } catch (e) {
    return new Response(String(e), { status: 500 });
  }
});
