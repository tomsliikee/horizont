// The reader view: Readability (Mozilla, Apache 2.0) finds the article, and
// it is shown in a layer over the page in the app's colours. Leaving it
// removes the layer; the page underneath is untouched.
(function () {
  'use strict';
  if (window.__horizontReader) return;
  var ID = '__horizont_reader';

  window.__horizontReader = function (on, style) {
    var existing = document.getElementById(ID);
    if (!on) {
      if (existing) existing.remove();
      document.documentElement.style.removeProperty('overflow');
      return true;
    }
    if (existing) return true;
    if (typeof Readability !== 'function') return false;
    var article;
    try {
      article = new Readability(document.cloneNode(true)).parse();
    } catch (e) {
      return false;
    }
    if (!article || !article.content || (article.length || 0) < 200) return false;

    var layer = document.createElement('div');
    layer.id = ID;
    var css =
      '#' + ID + '{position:fixed;inset:0;z-index:2147483647;overflow-y:auto;' +
      'background:' + style.background + ';color:' + style.text + ';' +
      '-webkit-text-size-adjust:none;font:' + Math.round(19 * style.zoom / 100) + 'px/1.6 Georgia,serif;}' +
      '#' + ID + ' .hz-in{max-width:680px;margin:0 auto;padding:72px 22px 160px;}' +
      '#' + ID + ' .hz-site{font:600 13px/18px system-ui,sans-serif;color:' + style.muted + ';letter-spacing:.02em;}' +
      '#' + ID + ' h1.hz-title{font:750 ' + Math.round(30 * style.zoom / 100) + 'px/1.2 system-ui,sans-serif;margin:8px 0 6px;}' +
      '#' + ID + ' .hz-by{font:400 14px/20px system-ui,sans-serif;color:' + style.muted + ';margin-bottom:28px;}' +
      '#' + ID + ' a{color:' + style.accent + ';}' +
      '#' + ID + ' img,#' + ID + ' video,#' + ID + ' figure{max-width:100%;height:auto;border-radius:16px;}' +
      '#' + ID + ' pre{overflow-x:auto;white-space:pre-wrap;}' +
      '#' + ID + ' h2,#' + ID + ' h3{font-family:system-ui,sans-serif;line-height:1.3;}' +
      '#' + ID + ' blockquote{margin:0;padding-left:16px;border-left:3px solid ' + style.accent + ';color:' + style.muted + ';}';
    var sheet = document.createElement('style');
    sheet.textContent = css;
    var inner = document.createElement('div');
    inner.className = 'hz-in';
    var site = document.createElement('div');
    site.className = 'hz-site';
    site.textContent = article.siteName || location.hostname.replace(/^www\./, '');
    var title = document.createElement('h1');
    title.className = 'hz-title';
    title.textContent = article.title || document.title;
    var by = document.createElement('div');
    by.className = 'hz-by';
    by.textContent = article.byline || '';
    var body = document.createElement('div');
    body.innerHTML = article.content;
    inner.appendChild(site);
    inner.appendChild(title);
    if (article.byline) inner.appendChild(by);
    inner.appendChild(body);
    layer.appendChild(sheet);
    layer.appendChild(inner);
    document.documentElement.appendChild(layer);
    document.documentElement.style.overflow = 'hidden';
    return true;
  };
})();
