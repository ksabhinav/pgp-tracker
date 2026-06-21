// ==UserScript==
// @name         PGP10 Tracker Auto-Sync
// @namespace    pgp10-reading-tracker
// @version      1.0
// @description  As you read PGP10 LU pages on OpenTakshashila, silently sync their readings (with links) to the PGP10 Reading Tracker. Install once; no clicking.
// @match        https://opentakshashila.net/*
// @run-at       document-idle
// @grant        none
// ==/UserScript==
(function () {
  'use strict';

  // --- Supabase target (publishable key — safe to be public; inbox insert only) ---
  var SUPA_URL = 'https://hjpqbfzhjsxdxxbrvkvi.supabase.co';
  var KEY = 'sb_publishable_4VnssfN1prmotvDYx7qWhg_yb6KQ8oz';

  function hash(s) { var h = 0; for (var i = 0; i < s.length; i++) { h = (h * 31 + s.charCodeAt(i)) | 0; } return h; }

  // Scrape the current page into an LU object, or null if it isn't a loaded LU page.
  function scrapeLU() {
    if (!/\/posts\//.test(location.pathname)) return null;
    var title = (document.querySelector('h1') || { innerText: '' }).innerText.trim();
    if (!title) return null;

    var o = [], m = [], r = [], s = null, sawSection = false;
    var els = document.querySelectorAll('strong,b,h1,h2,h3,h4,li,p');
    els.forEach(function (el) {
      var tag = el.tagName, text = (el.innerText || '').trim();
      if (!text || text.length > 500) return;
      var head = (tag === 'STRONG' || tag === 'B' || /^H[1-4]$/.test(tag));
      if (head && /learning outcome/i.test(text)) { s = 'o'; return; }
      if (head && /mandatory reading/i.test(text)) { s = 'm'; sawSection = true; return; }
      if (head && /recommended/i.test(text)) { s = 'r'; sawSection = true; return; }
      if (head && /^notes/i.test(text)) { s = null; return; }
      if (tag === 'LI') {
        var a = el.querySelector('a');
        var name = a ? a.innerText.trim() : text.split(/\s[-–]\s/)[0].trim();
        var desc = a ? text.replace(a.innerText, '').replace(/^[\s\-–—]+/, '').trim() : '';
        var url = a ? a.href : '';
        if (s === 'o') o.push(text);
        else if (s === 'm') m.push({ name: name, desc: desc, url: url });
        else if (s === 'r') r.push({ name: name, desc: desc, url: url });
      } else if (tag === 'P' && s === 'o' && /^\d+\./.test(text)) {
        o.push(text.replace(/^\d+\.\s*/, ''));
      }
    });
    if (!sawSection || (!m.length && !r.length)) return null;   // not a (loaded) LU page

    // best-effort subject hint, e.g. "PP231: Microeconomics I" somewhere on the page
    var hint = '';
    var bodyText = document.body.innerText || '';
    var hm = bodyText.match(/PP\d{3}:\s*[^\n]{2,60}/);
    if (hm) hint = hm[0].trim();

    return {
      id: 'lu' + Date.now(), title: title, url: location.href,
      selfStudy: /self.?study/i.test(title), subjectHint: hint,
      outcomes: o, mandatory: m, recommended: r
    };
  }

  function toast(msg) {
    var d = document.createElement('div');
    d.textContent = msg;
    d.style.cssText = 'position:fixed;z-index:99999;right:16px;bottom:16px;background:#620D3C;color:#fff;font:600 13px/1.3 system-ui,sans-serif;padding:10px 14px;border-radius:10px;box-shadow:0 6px 24px rgba(0,0,0,.3);opacity:0;transition:opacity .25s';
    document.body.appendChild(d);
    requestAnimationFrame(function () { d.style.opacity = '1'; });
    setTimeout(function () { d.style.opacity = '0'; setTimeout(function () { d.remove(); }, 300); }, 2600);
  }

  function syncIfNew() {
    var lu = scrapeLU();
    if (!lu) return;
    var sig = hash(JSON.stringify({ t: lu.title, m: lu.mandatory, r: lu.recommended }));
    var key = 'pgp_autosync_' + lu.url;
    if (localStorage.getItem(key) == sig) return;   // already synced this exact content
    fetch(SUPA_URL + '/rest/v1/inbox', {
      method: 'POST',
      headers: { 'apikey': KEY, 'Authorization': 'Bearer ' + KEY, 'Content-Type': 'application/json', 'Prefer': 'return=minimal' },
      body: JSON.stringify({ payload: lu })
    }).then(function (res) {
      if (res.ok) { localStorage.setItem(key, sig); toast('✓ Synced “' + lu.title.slice(0, 40) + '” to PGP Tracker'); }
      else { console.warn('[PGP autosync] insert failed', res.status); }
    }).catch(function (e) { console.warn('[PGP autosync] error', e); });
  }

  // OpenTakshashila is a single-page app: content loads late and navigation is
  // client-side. Poll, and re-check on URL change, so each LU gets synced once.
  var lastUrl = '';
  setInterval(function () {
    if (location.href !== lastUrl) { lastUrl = location.href; }
    syncIfNew();
  }, 2000);
})();
