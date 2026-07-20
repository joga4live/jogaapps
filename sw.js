/* Joga Intelligence — Service Worker
   Estrategia:
   - Navegaciones (páginas): network-first → si no hay red, sirve desde caché (offline).
   - Estáticos mismo origen y fuentes: stale-while-revalidate (rápido + se actualiza solo).
   Sube CACHE_VERSION cada vez que quieras forzar refresco tras un deploy. */

const CACHE_VERSION = 'joga-v2';
const CACHE = `joga-cache-${CACHE_VERSION}`;

/* Shell mínimo que se precachea al instalar.
   Se mantiene corto a propósito: si un archivo faltara, addAll NO falla en bloque
   porque lo envolvemos en intentos individuales. El resto (las 6 apps) se cachea
   solo al visitarlas la primera vez con red. */
const CORE = [
  './',
  './index.html',
  './retos.html',
  './manifest.webmanifest',
  './icon-192.png',
  './icon-512.png',
  './icon-512-maskable.png',
  './apple-touch-icon.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    // cachea uno por uno para que un 404 no rompa toda la instalación
    await Promise.all(CORE.map(async (url) => {
      try { await cache.add(new Request(url, { cache: 'reload' })); }
      catch (e) { /* ignora el que falle */ }
    }));
    self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map((k) => k.startsWith('joga-cache-') && k !== CACHE ? caches.delete(k) : null));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  const sameOrigin = url.origin === self.location.origin;

  // Páginas (navegación): network-first con fallback a caché
  if (req.mode === 'navigate') {
    event.respondWith((async () => {
      try {
        const fresh = await fetch(req);
        const cache = await caches.open(CACHE);
        cache.put(req, fresh.clone());
        return fresh;
      } catch (e) {
        const cached = await caches.match(req);
        return cached || await caches.match('./index.html');
      }
    })());
    return;
  }

  // Estáticos mismo origen + Google Fonts: stale-while-revalidate
  const isFont = url.hostname.includes('fonts.googleapis.com') || url.hostname.includes('fonts.gstatic.com');
  if (sameOrigin || isFont) {
    event.respondWith((async () => {
      const cache = await caches.open(CACHE);
      const cached = await cache.match(req);
      const network = fetch(req).then((res) => {
        if (res && res.status === 200) cache.put(req, res.clone());
        return res;
      }).catch(() => null);
      return cached || (await network) || new Response('', { status: 504 });
    })());
  }
});
