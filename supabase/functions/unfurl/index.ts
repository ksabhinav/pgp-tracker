// Unfurl a URL: fetch it server-side, parse OpenGraph/meta, cache in link_previews, return the card data.
// Deployed with: npx supabase@latest functions deploy unfurl --project-ref hjpqbfzhjsxdxxbrvkvi
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const resp = (b: unknown, s = 200) =>
  new Response(JSON.stringify(b), { status: s, headers: { ...CORS, "Content-Type": "application/json" } });

function decodeEntities(s: string): string {
  return s
    .replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"').replace(/&#0?39;/g, "'").replace(/&apos;/g, "'")
    .replace(/&#(\d+);/g, (_, n) => { try { return String.fromCodePoint(+n); } catch { return ""; } })
    .replace(/&#x([0-9a-f]+);/gi, (_, n) => { try { return String.fromCodePoint(parseInt(n, 16)); } catch { return ""; } });
}
function meta(html: string, ...names: string[]): string {
  for (const n of names) {
    const esc = n.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const tag = html.match(new RegExp(`<meta[^>]+(?:property|name)=["']${esc}["'][^>]*>`, "i"));
    if (!tag) continue;
    const c = tag[0].match(/content=["']([^"']*)["']/i);
    if (c && c[1].trim()) return decodeEntities(c[1].trim());
  }
  return "";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  try {
    const { url, key } = await req.json();
    if (!url || !/^https?:\/\//i.test(url)) return resp({ error: "bad url" }, 400);

    const ac = new AbortController();
    const timer = setTimeout(() => ac.abort(), 8000);
    let title = "", description = "", image = "", site = "";
    try {
      const r = await fetch(url, {
        headers: { "User-Agent": "Mozilla/5.0 (compatible; PGPTrackerBot/1.0; +link-preview)", "Accept": "text/html,*/*" },
        redirect: "follow", signal: ac.signal,
      });
      const ct = r.headers.get("content-type") || "";
      if (ct.includes("text/html")) {
        const html = (await r.text()).slice(0, 600000);
        title = meta(html, "og:title", "twitter:title") ||
          decodeEntities((html.match(/<title[^>]*>([\s\S]*?)<\/title>/i)?.[1] || "").replace(/\s+/g, " ").trim());
        description = meta(html, "og:description", "twitter:description", "description");
        image = meta(html, "og:image", "og:image:url", "og:image:secure_url", "twitter:image", "twitter:image:src");
        site = meta(html, "og:site_name");
      }
    } finally { clearTimeout(timer); }

    try { const u = new URL(url); if (image) image = new URL(image, u).href; if (!site) site = u.hostname.replace(/^www\./, ""); } catch { /* keep as-is */ }
    const row = {
      url: key || url,
      title: title.slice(0, 300),
      description: description.slice(0, 500),
      image: image.slice(0, 1000),
      site: site.slice(0, 120),
      fetched_at: new Date().toISOString(),
    };

    const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
    await admin.from("link_previews").upsert(row, { onConflict: "url" });
    return resp(row);
  } catch (e) {
    return resp({ error: String((e as Error)?.message || e) }, 200);
  }
});
