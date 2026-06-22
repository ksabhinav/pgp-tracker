// ==UserScript==
// @name         PGP Tracker Auto-Sync + Clip-to-Reader
// @namespace    pgp10-reading-tracker
// @version      2.0
// @description  (1) On OpenTakshashila LU pages, silently sync readings to the PGP Tracker. (2) On ANY page, an admin can clip the article (or a video) into the shared distraction-free reader with Alt+R or the “Clip” button.
// @match        *://*/*
// @run-at       document-idle
// @grant        GM_xmlhttpRequest
// @connect      hjpqbfzhjsxdxxbrvkvi.supabase.co
// @require      https://cdn.jsdelivr.net/npm/@mozilla/readability@0.5.0/Readability.js
// ==/UserScript==
(function () {
  'use strict';

  // --- Supabase target (publishable key — safe to be public; inbox insert only) ---
  var SUPA_URL = 'https://hjpqbfzhjsxdxxbrvkvi.supabase.co';
  var KEY = 'sb_publishable_4VnssfN1prmotvDYx7qWhg_yb6KQ8oz';
  var IS_OT = /(^|\.)opentakshashila\.net$/i.test(location.hostname);
  var IS_APP = /(^|\.)github\.io$/i.test(location.hostname) || /\/pgp-tracker\//.test(location.pathname);   // the tracker itself — no Clip button here

  function hash(s) { var h = 0; for (var i = 0; i < s.length; i++) { h = (h * 31 + s.charCodeAt(i)) | 0; } return h; }

  // ── status pills ──────────────────────────────────────────────────────────
  function makePill(side) {
    var p = document.createElement('div');
    p.style.cssText = 'position:fixed;z-index:99999;bottom:14px;' + side + ':14px;color:#fff;font:600 12px/1.3 system-ui,sans-serif;padding:7px 11px;border-radius:9px;box-shadow:0 4px 18px rgba(0,0,0,.28);cursor:pointer;opacity:.94;max-width:46vw';
    document.body.appendChild(p); return p;
  }
  var syncPill, clipPill;
  function setSyncPill(text, bg) { if (!syncPill) { syncPill = makePill('left'); syncPill.title = 'Click to force a re-sync of this page'; syncPill.addEventListener('click', function () { lastSig = null; syncIfNew(true); }); } syncPill.textContent = text; syncPill.style.background = bg || '#620D3C'; }
  function setClipPill(text, bg) { if (!clipPill) { clipPill = makePill('right'); clipPill.title = 'Clip this page into the PGP reader (Alt+R)'; clipPill.addEventListener('click', function () { captureCurrent(); }); } clipPill.textContent = text; clipPill.style.background = bg || '#620D3C'; }

  // ── generic POST to the inbox queue ───────────────────────────────────────
  function postInbox(payload, onok) {
    GM_xmlhttpRequest({
      method: 'POST',
      url: SUPA_URL + '/rest/v1/inbox',
      headers: { 'apikey': KEY, 'Authorization': 'Bearer ' + KEY, 'Content-Type': 'application/json', 'Prefer': 'return=minimal' },
      data: JSON.stringify({ payload: payload }),
      onload: function (res) {
        if (res.status >= 200 && res.status < 300) { onok && onok(); }
        else { console.warn('[PGP] insert HTTP', res.status, res.responseText); setClipPill('PGP: ⚠ failed (HTTP ' + res.status + ')', '#b00'); }
      },
      onerror: function (e) { console.warn('[PGP] request error', e); setClipPill('PGP: ⚠ network blocked', '#b00'); }
    });
  }

  // ══ (1) OpenTakshashila LU auto-sync (unchanged behaviour, OT only) ════════
  function scrapeLU() {
    if (!IS_OT || !/\/posts\//.test(location.pathname)) return null;
    var title = (document.querySelector('h1') || { innerText: '' }).innerText.trim();
    if (!title) return null;
    var o = [], m = [], r = [], s = null, sawSection = false;
    document.querySelectorAll('strong,b,h1,h2,h3,h4,li,p').forEach(function (el) {
      var tag = el.tagName, text = (el.innerText || '').trim();
      if (!text || text.length > 500) return;
      var head = (tag === 'STRONG' || tag === 'B' || /^H[1-4]$/.test(tag));
      if (head && /learning outcome/i.test(text)) { s = 'o'; return; }
      if (head && /mandatory read/i.test(text)) { s = 'm'; sawSection = true; return; }
      if (head && /recommended/i.test(text)) { s = 'r'; sawSection = true; return; }
      if (head && /^(notes|note)\b/i.test(text)) { s = null; return; }
      if (tag === 'LI') {
        var a = el.querySelector('a');
        var name = a ? a.innerText.trim() : text.split(/\s[-–]\s/)[0].trim();
        var desc = a ? text.replace(a.innerText, '').replace(/^[\s\-–—]+/, '').trim() : '';
        var url = a ? a.href : '';
        if (s === 'o') o.push(text);
        else if (s === 'm') m.push({ name: name, desc: desc, url: url });
        else if (s === 'r') r.push({ name: name, desc: desc, url: url });
      } else if (tag === 'P' && s === 'o' && /^\d+\./.test(text)) { o.push(text.replace(/^\d+\.\s*/, '')); }
    });
    if (!sawSection || (!m.length && !r.length)) return null;
    var hint = ''; var hm = (document.body.innerText || '').match(/PP\d{3}:\s*[^\n]{2,60}/); if (hm) hint = hm[0].trim();
    return { id: 'lu' + Date.now(), title: title, url: location.href, selfStudy: /self.?study/i.test(title), subjectHint: hint, outcomes: o, mandatory: m, recommended: r };
  }
  var lastSig = null;
  function syncIfNew(force) {
    var lu = scrapeLU();
    if (!lu) { if (IS_OT && /\/posts\//.test(location.pathname)) setSyncPill('PGP: no readings detected here', '#666'); return; }
    var sig = hash(JSON.stringify({ t: lu.title, m: lu.mandatory, r: lu.recommended }));
    var key = 'pgp_autosync_' + lu.url;
    if (!force && (lastSig === sig || (function () { try { return localStorage.getItem(key) == sig; } catch (e) { return false; } })())) { setSyncPill('PGP: ✓ up to date', '#1f8a3b'); return; }
    lastSig = sig;
    setSyncPill('PGP: syncing “' + lu.title.slice(0, 26) + '”…', '#8a5a00');
    postInbox(lu, function () { try { localStorage.setItem(key, sig); } catch (e) {} setSyncPill('PGP: ✓ synced ' + lu.mandatory.length + 'm + ' + lu.recommended.length + 'r', '#1f8a3b'); });
  }

  // ══ (2) Clip-to-Reader: capture this page as a shared reading copy ═════════
  function detectVideo() {
    try {
      var h = location.hostname.replace(/^www\./, '');
      if (/youtube\.com$/.test(h)) { var v = new URL(location.href).searchParams.get('v'); if (v) return 'https://www.youtube.com/embed/' + v; }
      if (h === 'youtu.be') { var id = location.pathname.slice(1).split('/')[0]; if (id) return 'https://www.youtube.com/embed/' + id; }
      if (h === 'vimeo.com') { var vid = location.pathname.split('/').filter(Boolean)[0]; if (/^\d+$/.test(vid)) return 'https://player.vimeo.com/video/' + vid; }
      var f = document.querySelector('iframe[src*="youtube.com/embed"],iframe[src*="player.vimeo.com"]');
      if (f && f.src) return f.src;
    } catch (e) {}
    return null;
  }
  function captureCurrent() {
    setClipPill('PGP: clipping…', '#8a5a00');
    var vid = detectVideo();
    if (vid) {
      postInbox({ type: 'content', kind: 'video', url: location.href, title: (document.title || '').trim(), embed_url: vid },
        function () { setClipPill('PGP: ✓ video clipped', '#1f8a3b'); });
      return;
    }
    try {
      if (typeof Readability === 'undefined') { setClipPill('PGP: reader lib not loaded', '#b00'); return; }
      var art = new Readability(document.cloneNode(true)).parse();
      if (!art || !art.content) { setClipPill('PGP: no article found here', '#b00'); return; }
      postInbox({ type: 'content', kind: 'article', url: location.href, title: (art.title || document.title || '').trim(), content_html: art.content, extracted_by: 'readability' },
        function () { setClipPill('PGP: ✓ clipped to reader', '#1f8a3b'); });
    } catch (e) { console.warn('[PGP] extract error', e); setClipPill('PGP: extract error', '#b00'); }
  }
  // Alt+R clips the current page (not on the tracker itself).
  if (!IS_APP) window.addEventListener('keydown', function (e) { if (e.altKey && (e.key === 'r' || e.key === 'R')) { e.preventDefault(); captureCurrent(); } }, true);

  // ── boot ──────────────────────────────────────────────────────────────────
  if (IS_OT) {
    var lastUrl = '';
    setInterval(function () { if (location.href !== lastUrl) { lastUrl = location.href; lastSig = null; } syncIfNew(false); }, 2500);
  }
  // Show the Clip button on real article pages — never on the tracker itself.
  if (/^https?:/.test(location.href) && !IS_APP) setTimeout(function () { setClipPill('PGP: Clip ✂', '#620D3C'); }, 1200);
})();
