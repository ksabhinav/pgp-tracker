// supabase/functions/extract-pdf/index.ts
// Table-quality PDF extraction via LlamaParse (LlamaCloud), for dense/working-paper
// PDFs where the in-browser pdf.js reflow flattens tables. Writes the result into the
// same reading_content row the fast path uses, so the reader treats it identically.
//
// Setup (one time):
//   1. Get a key at https://cloud.llamaindex.ai  (free tier ~1000 pages/day)
//   2. supabase secrets set LLAMA_CLOUD_API_KEY=llx-...
//   3. supabase functions deploy extract-pdf
// The app's admin "better tables" action calls this with { file_url, url, reading_id, title }.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { marked } from 'https://esm.sh/marked@12';

const LLAMA = 'https://api.cloud.llamaindex.ai/api/parsing';
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
function resp(body: string, status = 200, json = false) {
  return new Response(body, { status, headers: { ...CORS, 'Content-Type': json ? 'application/json' : 'text/plain' } });
}

function stripTags(html: string) { return html.replace(/<[^>]+>/g, '').replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>'); }
const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });   // browser preflight
  try {
    const { file_url, url, reading_id, title } = await req.json();
    const KEY = Deno.env.get('LLAMA_CLOUD_API_KEY');
    if (!KEY) return resp('LLAMA_CLOUD_API_KEY not set', 500);
    if (!file_url || !url) return resp('file_url and url are required', 400);

    // 1) fetch the original PDF (public uploads-bucket URL)
    const pdf = await fetch(file_url);
    if (!pdf.ok) return resp('could not fetch PDF: ' + pdf.status, 502);
    const bytes = new Uint8Array(await pdf.arrayBuffer());

    // 2) submit to LlamaParse
    const form = new FormData();
    form.append('file', new Blob([bytes], { type: 'application/pdf' }), 'doc.pdf');
    const up = await fetch(LLAMA + '/upload', { method: 'POST', headers: { Authorization: 'Bearer ' + KEY, accept: 'application/json' }, body: form });
    if (!up.ok) return resp('llamaparse upload failed: ' + (await up.text()), 502);
    const job = await up.json();
    const jobId = job.id;

    // 3) poll until done (keep bounded so we stay within the function timeout)
    let status = job.status;
    for (let i = 0; i < 40 && status !== 'SUCCESS'; i++) {
      if (status === 'ERROR' || status === 'CANCELED') return resp('llamaparse job ' + status, 502);
      await sleep(3000);
      const st = await fetch(LLAMA + '/job/' + jobId, { headers: { Authorization: 'Bearer ' + KEY, accept: 'application/json' } });
      status = (await st.json()).status;
    }
    if (status !== 'SUCCESS') return resp('llamaparse timed out', 504);

    // 4) per-page markdown -> HTML (tables preserved), build a matching page map
    const res = await fetch(LLAMA + '/job/' + jobId + '/result/json', { headers: { Authorization: 'Bearer ' + KEY, accept: 'application/json' } });
    if (!res.ok) return resp('llamaparse result failed: ' + (await res.text()), 502);
    const data = await res.json();
    const pages = data.pages || [];
    let html = '', text = '';
    const pageMap: Array<{ page: number; start: number; end: number }> = [];
    for (const p of pages) {
      const pageNo = p.page ?? (pageMap.length + 1);
      const inner = marked.parse(p.md || p.text || '', { async: false }) as string;
      const start = text.length;
      text += stripTags(inner);                 // approximates the reader's textContent for offset->page mapping
      pageMap.push({ page: pageNo, start, end: text.length });
      html += `<section data-page="${pageNo}">${inner}</section>`;
    }
    if (!html) return resp('llamaparse returned no pages', 502);

    // 5) store into the same reading_content row (service role bypasses RLS)
    const supa = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const { error } = await supa.from('reading_content').upsert({
      url, reading_id: reading_id ?? null, title: title ?? null,
      kind: 'pdf', content_html: html, page_map: pageMap, source_file: file_url,
      extracted_by: 'llamaparse', needs_review: false,
    }, { onConflict: 'url' });
    if (error) return resp(error.message, 500);

    return resp(JSON.stringify({ ok: true, pages: pages.length }), 200, true);
  } catch (e) {
    return resp(String(e), 500);
  }
});
