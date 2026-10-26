// Runs in every page at document start (bridge) or on page start (fallback).
// Reports the colour at the top of the page and the scroll state to the app
// through the `HorizontPage` channel. Pages can call that channel too, so the
// app validates every message.
(function () {
  'use strict';
  if (window.__horizontPage) return;
  var channel = window.HorizontPage;
  if (!channel || typeof channel.postMessage !== 'function') return;

  var lastColor = '';
  var lastSource = '';
  var source = 'unknown';
  var scroller = null;
  var scrolled = false;
  var atEnd = false;
  var dir = 'up';
  var pivot = 0;

  function send(message) {
    try { channel.postMessage(JSON.stringify(message)); } catch (e) {}
  }

  function parseRgb(value) {
    var m = /^rgba?\(([^)]*)\)$/.exec(value || '');
    if (!m) return null;
    var p = m[1].split(/[\s,\/]+/).filter(Boolean);
    if (p.length < 3) return null;
    var a = p.length > 3 ? parseFloat(p[3]) : 1;
    return { r: parseFloat(p[0]), g: parseFloat(p[1]), b: parseFloat(p[2]), a: a };
  }

  function metaColor() {
    var metas = document.querySelectorAll('meta[name="theme-color" i]');
    var plain = null;
    for (var i = 0; i < metas.length; i++) {
      var media = metas[i].getAttribute('media');
      var content = metas[i].getAttribute('content');
      if (!content) continue;
      if (media) {
        try { if (window.matchMedia(media).matches) return content; } catch (e) {}
      } else if (!plain) {
        plain = content;
      }
    }
    return plain;
  }

  // The first opaque background at (x, 1), top-most first. 'image' when a
  // gradient or photo is on top of it, which is no single colour.
  function pointColor(x) {
    var stack = document.elementsFromPoint(x, 1);
    for (var i = 0; i < stack.length; i++) {
      var style = getComputedStyle(stack[i]);
      var c = parseRgb(style.backgroundColor);
      var hasImage = style.backgroundImage && style.backgroundImage !== 'none';
      if (hasImage) return 'image';
      if (c && c.a >= 0.99) return c.r + ',' + c.g + ',' + c.b;
    }
    return null;
  }

  function elementColor(el) {
    if (!el) return null;
    var c = parseRgb(getComputedStyle(el).backgroundColor);
    return c && c.a >= 0.99 ? c.r + ',' + c.g + ',' + c.b : null;
  }

  function domColor() {
    var w = window.innerWidth;
    var points = [pointColor(8), pointColor(Math.floor(w / 2)), pointColor(Math.max(w - 8, 0))];
    var winner = null;
    if (points[0] !== null && (points[0] === points[1] || points[0] === points[2])) winner = points[0];
    else if (points[1] !== null && points[1] === points[2]) winner = points[1];
    else winner = points[1];
    if (winner === null) winner = elementColor(document.body) || elementColor(document.documentElement);
    return winner;
  }

  // Any CSS colour as 'r,g,b' (the browser parses names, hex, hsl, ...).
  function normalise(css) {
    try {
      var probe = document.createElement('span');
      probe.style.color = css;
      if (!probe.style.color) return null;
      (document.body || document.documentElement).appendChild(probe);
      var c = parseRgb(getComputedStyle(probe).color);
      probe.remove();
      return c ? c.r + ',' + c.g + ',' + c.b : null;
    } catch (e) { return null; }
  }

  function luminance(rgb) {
    var p = rgb.split(',');
    return (0.2126 * p[0] + 0.7152 * p[1] + 0.0722 * p[2]) / 255;
  }

  function report() {
    var color, src;
    var meta = metaColor();
    var d = domColor();
    if (meta) {
      color = meta; src = 'meta';
      // A theme-color that is not what the top of the page shows (a static
      // white tag on a page with its own dark mode) tints the bar wrongly:
      // trust what is visible when the two are far apart.
      var m = normalise(meta);
      if (m && d && d !== 'image' && Math.abs(luminance(m) - luminance(d)) > 0.35) {
        color = 'rgb(' + d + ')'; src = 'dom';
      }
    } else {
      if (d === 'image' || d === null) { color = ''; src = 'unknown'; }
      else { color = 'rgb(' + d + ')'; src = 'dom'; }
    }
    source = src;
    rest();
    // An unknown colour is reported again so the app can sample the top of the
    // page once more as it scrolls.
    if (src !== 'unknown' && color === lastColor && src === lastSource) return;
    lastColor = color; lastSource = src;
    send({ type: 'color', source: src, rgba: color });
  }

  var timers = {};
  function later(key, ms, fn) {
    clearTimeout(timers[key]);
    timers[key] = setTimeout(fn, ms);
  }

  // The page came to rest: the app captures its top again, which shows the
  // colours the page really has there.
  function rest() { later('restMsg', 400, function () { send({ type: 'rest' }); }); }

  // Scrolling. The document, or an inner element that fills the page.
  // scrollHeight forces a layout when the page changed, so it is read when
  // scrolling comes to rest, not on every frame.
  var contentHeight = 0;
  function readContentHeight() {
    var el = scroller || document.scrollingElement || document.documentElement;
    contentHeight = el.scrollHeight;
  }
  function metrics() {
    if (!contentHeight) readContentHeight();
    if (scroller) {
      return { y: scroller.scrollTop, end: scroller.scrollTop + scroller.clientHeight >= contentHeight - 2 };
    }
    return { y: window.scrollY, end: window.scrollY + window.innerHeight >= contentHeight - 2 };
  }

  var frame = 0;
  var lastRestReport = 0;
  function onScroll(event) {
    var t = event.target;
    if (t && t.nodeType === 1 && t !== document.documentElement && t !== document.body) {
      if (t.clientWidth >= window.innerWidth * 0.8 && t.clientHeight >= window.innerHeight * 0.5) scroller = t;
      else return;
    } else {
      scroller = null;
    }
    if (!frame) {
      frame = requestAnimationFrame(function () {
        frame = 0;
        var m = metrics();
        var nowScrolled = m.y > 6;
        // The direction turns only after 24 px against it, so a finger at
        // rest does not flip the bar back and forth.
        var nowDir = dir;
        if (dir === 'down') {
          if (m.y > pivot) pivot = m.y;
          else if (m.y < pivot - 24) { nowDir = 'up'; pivot = m.y; }
        } else {
          if (m.y < pivot) pivot = m.y;
          else if (m.y > pivot + 24) { nowDir = 'down'; pivot = m.y; }
        }
        if (nowScrolled !== scrolled || m.end !== atEnd || nowDir !== dir) {
          scrolled = nowScrolled; atEnd = m.end; dir = nowDir;
          send({ type: 'scroll', y: m.y, end: m.end, dir: dir });
        }
      });
    }
    later('height', 250, function () { readContentHeight(); });
    // The colour at the top can change as the page scrolls.
    rest();
    if (source !== 'meta') {
      later('rest', 250, function () {
        var now = Date.now();
        if (now - lastRestReport < 500) return;
        lastRestReport = now;
        report();
      });
    }
  }

  window.__horizontPage = {
    scrollToTop: function () {
      var target = scroller || window;
      try { target.scrollTo({ top: 0, behavior: 'smooth' }); }
      catch (e) { target.scrollTo(0, 0); }
    },
    // Where the page is scrolled to, for restoring a tab later.
    scrollY: function () {
      return scroller ? scroller.scrollTop : window.scrollY;
    },
    // Words and how far down the page is read, for the reading list.
    info: function () {
      var el = scroller || document.scrollingElement || document.documentElement;
      var max = Math.max(1, el.scrollHeight - (scroller ? scroller.clientHeight : window.innerHeight));
      var y = scroller ? scroller.scrollTop : window.scrollY;
      var text = (document.body && document.body.innerText) || '';
      var words = text.split(/\s+/).filter(Boolean).length;
      return JSON.stringify({ w: words, f: Math.min(1, Math.max(0, y / max)) });
    },
    report: report,
  };

  window.addEventListener('scroll', onScroll, { capture: true, passive: true });

  function whenReady() {
    report();
    var head = document.head || document.documentElement;
    new MutationObserver(function () { later('meta', 100, report); })
      .observe(head, { childList: true, subtree: true, attributes: true, attributeFilter: ['content', 'name', 'media'] });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', whenReady);
  else whenReady();
  window.addEventListener('load', function () { report(); rest(); });

  try {
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function () { later('scheme', 100, report); });
  } catch (e) {}

  // Single-page apps change the page without loading one.
  ['pushState', 'replaceState'].forEach(function (name) {
    var original = history[name];
    history[name] = function () {
      var result = original.apply(this, arguments);
      later('route', 300, report);
      return result;
    };
  });
  window.addEventListener('popstate', function () { later('route', 300, report); });
})();
