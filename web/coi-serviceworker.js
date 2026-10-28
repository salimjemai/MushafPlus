// Mushaf+: makes the page cross-origin isolated on hosts that cannot send
// response headers (GitHub Pages), so the voice model's wasm backend may use
// several CPU threads (SharedArrayBuffer) instead of one. Same-origin
// responses pass through with two headers added; cross-origin requests are
// not touched. COEP "credentialless" keeps cross-origin audio, fonts and API
// calls working. WebKit does not know "credentialless" and would stay
// single-threaded anyway, so index.html does not register this worker there.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => e.waitUntil(self.clients.claim()));
self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.cache === 'only-if-cached' && req.mode !== 'same-origin') return;
  if (new URL(req.url).origin !== self.location.origin) return;
  e.respondWith(fetch(req).then((res) => {
    if (res.status === 0 || res.type === 'opaque' || res.type === 'opaqueredirect') return res;
    const headers = new Headers(res.headers);
    headers.set('Cross-Origin-Embedder-Policy', 'credentialless');
    headers.set('Cross-Origin-Opener-Policy', 'same-origin');
    return new Response(res.body, { status: res.status, statusText: res.statusText, headers });
  }));
});
