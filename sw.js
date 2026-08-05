/* Memo List — Web · Service Worker per le notifiche push.
 * Va servito dalla RADICE del sito (accanto a index.html), es. https://app.memolistapp.com/sw.js
 * Riceve l'evento "push" e mostra la notifica; al clic apre/mette a fuoco il sito. */

self.addEventListener('push', function (event) {
  let dati = {};
  try {
    dati = event.data ? event.data.json() : {};
  } catch (e) {
    dati = { title: 'Memo List', body: event.data ? event.data.text() : '' };
  }
  const titolo = dati.title || 'Memo List';
  const opzioni = {
    body: dati.body || '',
    tag: dati.tag || undefined,
    data: dati.data || { url: dati.url || '/' },
    requireInteraction: false
  };
  if (dati.icon) opzioni.icon = dati.icon;
  if (dati.badge) opzioni.badge = dati.badge;
  event.waitUntil(self.registration.showNotification(titolo, opzioni));
});

self.addEventListener('notificationclick', function (event) {
  event.notification.close();
  const url = (event.notification.data && event.notification.data.url) || '/';
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (lista) {
      for (const c of lista) {
        if ('focus' in c) {
          c.focus();
          if (url && url !== '/' && 'navigate' in c) { try { c.navigate(url); } catch (e) {} }
          return;
        }
      }
      if (self.clients.openWindow) return self.clients.openWindow(url);
    })
  );
});
