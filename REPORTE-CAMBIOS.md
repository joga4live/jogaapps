# Reporte — Joga Intelligence (brief del 2026-07)

El ZIP adjunto (`joga-intelligence-final.zip`) contiene **el root FINAL y completo del sitio**,
con las 6 tareas del brief aplicadas y verificadas. No se pudo subir a GitHub desde esta sesión:
el acceso de Claude a ambos repos resultó ser de **solo lectura** (git push y API dan 403).
Ver "Cómo desplegar" al final.

---

## TAREA 1 — Limpieza ✅
Se borraron **21 archivos .html basura** del root de joga-intelligence:
`MONEXIUM.html`, `monexium (14).html`, `goalium.html`, `huatulco.html`, `mosaico-final.html`,
`index (2).html`, `index (12).html`, `index (22).html`, `index (24).html`, `index (29).html`,
`jogatime (3).html`, `metodoexito (32).html`, `metodoexito .html`, `protoneutron (24).html`,
`retos (2).html`, `retos .html`, `subment (13).html`, `subment (16).html`, `subment .html`,
`ventmex (10).html`, `ventmex .html`.
Ningún archivo NO-.html fue borrado (favicons, iconos, .mp3, manifest, sw.js intactos).

**Hallazgo importante:** en joga-intelligence NO existía `index.html` (el hub con el candado) —
solo las copias `index (n).html`, y ninguna tenía el sistema de códigos. El hub oficial estaba en
`jogaapps` como `app.html` (versión más reciente, 11-jul). Se copió como `index.html` (con
`JOGA7K2M9` + 50 códigos `JOGA-XXXXX` + `localStorage.jiPaid`, verificado).

**Archivos agregados** (venían de jogaapps, el hub los necesita):
- `index.html` (hub, antes app.html) · `jogaflow.html` (11-jul, el que faltaba) · `onboarding.html`
  (el hub tiene 4 botones "Empezar el reto" que apuntan ahí; su enlace de regreso se corrigió de
  `app.html` → `index.html`) · `support.js` (lo usa onboarding)
- Audio del hub: `musica-bienvenida.mp3`, `voz-bienvenida.mp3`, `voz-bienvenida-en.mp3`
- Audio de JogaBody: `musicajogaflow.mp3`, `vozjogaflow.mp3`, `vozjogaflowen.mp3`
- Iconos del hub: `jogaappletouchicon.png`, `jogafavicon.svg`
- `assets/logo-joga*.png` (7 logos que usa onboarding)

Quedan **11 .html**: los 10 canónicos + `onboarding.html`. Verificado con barrido automático:
**cero referencias rotas** entre archivos.

## TAREA 2 — Mapa oficial ✅
Verificado en las tarjetas del hub: JogaMind→subment, JogaTime→jogatime, JogaBit→protoneutron,
JogaPath→metodoexito, JogaCapital→monexium, JogaVentix→ventmex, JogaBody→jogaflow (gratis).
La lógica del hub ya tenía `FREE_FILE="jogaflow.html"` (solo JogaBody libre) ✓.

## TAREA 3 — Candado ✅
Guard agregado al inicio de los 6 premium (subment, jogatime, protoneutron, metodoexito,
monexium, ventmex), antes de cualquier otro script:
```js
if (localStorage.getItem("jiPaid") !== "1") { window.location.replace("index.html"); }
```
Nota: `protoneutron.html` no tiene `<head>`; su guard va en la primera línea del archivo.
`jogaflow.html` quedó SIN guard (es el gratis) ✓.

## TAREA 4 — Renombres ✅
- `metodoexito.html`: título y textos visibles PASLEY → **JogaPath** (título, mensajes de logro,
  alt de logos, animación de letras). NO se tocaron `POWER="PASLEY"` ni `LANGKEY="pasley_idioma"`
  (son llaves de progreso en localStorage — cambiarlas borraría el avance de los usuarios).
  El mensaje "MONEXIUM te espera" ahora dice "JogaCapital te espera".
  Se conservó la atribución de citas "— inspirado en Brian Tracy" (crédito de las frases, no marca).
- `jogaflow.html`: título y encabezado JogaFlow → **JogaBody** (los .mp3 conservan su nombre).
- `index.html` (hub): tarjeta y descripciones JOGAFLOW → **JOGABODY**, y el modal decía
  "JogaMind es gratis / las otras 5 apps" → ahora "JogaBody es gratis / las otras 6 apps" (ES y EN),
  acorde a la lógica real del candado.

## TAREA 5 — Landing ✅
`jogaintelligencelanding.html`: "…Ventix y Flow" → "…Ventix y **Body**" (2 en ES, 1 en EN).

## TAREA 6 — Service worker ✅
`sw.js`: `CACHE_VERSION` **joga-v1 → joga-v2** (el brief suponía v2→v3; el repo estaba en v1).

---

## Pendientes / avisos
- `init.sh` del repo falla desde ANTES de estos cambios: pide un `gate.js` que nunca existió en el
  repo y una regla de máx. 200 líneas imposible con apps de un solo archivo. Con los cambios ya
  pasa las verificaciones de index.html y versión de SW; lo de gate.js queda a decisión del dueño.
- Nadie enlaza a `jogaintelligencelanding.html` desde el sitio (dato, por si era intencional).
- El botón "atrás" de la vista de bienvenida del hub recarga `index.html` (antes iba de app.html a
  index.html); es inofensivo.

## Cómo desplegar a joga-intelligence

**Opción A — a mano con el ZIP (funciona hoy mismo):**
1. Descomprime `joga-intelligence-final.zip` en tu compu (no subas el .zip tal cual).
2. En GitHub → `joga4live/joga-intelligence`: **borra los 21 duplicados** listados en Tarea 1
   (abrir cada archivo → botón de basura → commit). Subir archivos NO borra los viejos,
   por eso este paso va primero.
3. "Add files via upload" → arrastra TODO el contenido descomprimido (incluida la carpeta
   `assets/`) al root → commit.
4. Listo: GitHub Pages publica solo, y el `sw.js` en `joga-v2` fuerza a que todos vean lo nuevo.

**Opción B — que Claude lo suba en una próxima sesión:**
Dale permiso de escritura a la app de GitHub de Claude sobre `joga4live/joga-intelligence`
(github.com → Settings → Integrations/Applications → Claude → Repository access + permiso
Read & write en Contents). Luego abre una sesión de Claude Code sobre ese repo, pásale este
mismo ZIP o el brief, y que aplique/suba los cambios por git.
