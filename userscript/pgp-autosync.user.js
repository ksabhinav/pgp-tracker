// ==UserScript==
// @name         PGP10 Tracker Auto-Sync
// @namespace    pgp10-reading-tracker
// @version      1.2
// @description  As you read PGP10 LU pages on OpenTakshashila, silently sync their readings (with links) to the PGP10 Reading Tracker. Install once; no clicking.
// @match        https://opentakshashila.net/*
// @run-at       document-idle
// @grant        GM_xmlhttpRequest
// @connect      hjpqbfzhjsxdxxbrvkvi.supabase.co
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
      } else if (tag === 'P' && s === 'o' && /^\d+\./.test(text)) {
        o.push(text.replace(/^\d+\.\s*/, ''));
      }
    });
    if (!sawSection || (!m.length && !r.length)) return null;   // not a (loaded) LU page

    var hint = '';
    var hm = (document.body.innerText || '').match(/PP\d{3}:\s*[^\n]{2,60}/);
    if (hm) hint = hm[0].trim();

    return {
      id: 'lu' + Date.now(), title: title, url: location.href,
      selfStudy: /self.?study/i.test(title), subjectHint: hint,
      outcomes: o, mandatory: m, recommended: r
    };
  }

  // --- status pill (so you can see it's working) ---
  var pill;
  function setPill(text, bg) {
    if (!pill) {
      pill = document.createElement('div');
      pill.title = 'Click to force a re-sync of this page';
      pill.style.cssText = 'position:fixed;z-index:99999;left:14px;bottom:14px;color:#fff;font:600 12px/1.3 system-ui,sans-serif;padding:7px 11px;border-radius:9px;box-shadow:0 4px 18px rgba(0,0,0,.28);cursor:pointer;opacity:.92';
      pill.addEventListener('click', function () { lastSig = null; syncIfNew(true); });
      document.body.appendChild(pill);
    }
    pill.textContent = text;
    pill.style.background = bg || '#620D3C';
  }

  function postInbox(lu, sig, key) {
    setPill('PGP: syncing “' + lu.title.slice(0, 28) + '”…', '#8a5a00');
    GM_xmlhttpRequest({
      method: 'POST',
      url: SUPA_URL + '/rest/v1/inbox',
      headers: { 'apikey': KEY, 'Authorization': 'Bearer ' + KEY, 'Content-Type': 'application/json', 'Prefer': 'return=minimal' },
      data: JSON.stringify({ payload: lu }),
      onload: function (res) {
        if (res.status >= 200 && res.status < 300) {
          try { localStorage.setItem(key, sig); } catch (e) {}
          console.log('[PGP autosync] queued', lu.title, lu.mandatory.length + 'm/' + lu.recommended.length + 'r');
          setPill('PGP: ✓ synced ' + lu.mandatory.length + 'm + ' + lu.recommended.length + 'r', '#1f8a3b');
        } else {
          console.warn('[PGP autosync] insert HTTP', res.status, res.responseText);
          setPill('PGP: ⚠ insert failed (HTTP ' + res.status + ')', '#b00');
        }
      },
      onerror: function (e) { console.warn('[PGP autosync] request error', e); setPill('PGP: ⚠ network blocked', '#b00'); }
    });
  }

  var lastSig = null;
  function syncIfNew(force) {
    var lu = scrapeLU();
    if (!lu) { if (/\/posts\//.test(location.pathname)) setPill('PGP: no readings detected here', '#666'); return; }
    var sig = hash(JSON.stringify({ t: lu.title, m: lu.mandatory, r: lu.recommended }));
    var key = 'pgp_autosync_' + lu.url;
    if (!force && (lastSig === sig || (function () { try { return localStorage.getItem(key) == sig; } catch (e) { return false; } })())) {
      setPill('PGP: ✓ up to date', '#1f8a3b'); return;
    }
    lastSig = sig;
    postInbox(lu, sig, key);
  }

  // OpenTakshashila is a single-page app: content loads late, navigation is client-side.
  var lastUrl = '';
  setInterval(function () {
    if (location.href !== lastUrl) { lastUrl = location.href; lastSig = null; }
    syncIfNew(false);
  }, 2500);
})();
