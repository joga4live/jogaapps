# AGENTS.md — Joga Intelligence PWA

Guía para cualquier agente de IA (Claude, etc.) que trabaje en este repo.
Guide for any AI agent working on this repo.

---

## 1. Qué es el proyecto / What this is

Joga Intelligence es una **PWA (Progressive Web App)** compuesta por varias mini-apps,
hospedada en **GitHub Pages**. Se distribuye por código de licencia y se vende vía
Gumroad / Stripe.

**Stack:** HTML + CSS + JavaScript puro. Sin frameworks, sin build step, sin bundler.
Lo que hay en el repo es lo que se sirve. Mantenerlo así.

**Mini-apps:** SUBMENT · JOGA TIME · PROTONEUTRÓN · PASLEY · MONEXIUM · VENTEMEX
**Tracker:** Retos JOGA (reto 30 días, 6 etapas × 5 días, persistencia en localStorage).

---

## 2. Reglas de oro / Golden rules

El agente **NUNCA** debe romper ninguno de estos cuatro sistemas. Si un cambio los toca,
verificar que sigan funcionando antes de dar por cerrado el trabajo.

1. **Licencias (`gate.js`)** — validación SHA-256 con los 50 códigos privados.
   Puede editarse libremente, pero **jamás** debe quedar el gate abierto (bypass) ni
   filtrarse la lista de códigos en texto plano en un archivo público.
2. **Service Worker / PWA offline** — la app debe seguir cargando sin conexión.
   No romper el registro del SW ni la lista de archivos cacheados.
3. **i18n (traducciones)** — el toggle de idioma y los atributos `data-i18n` deben
   seguir funcionando. **Nota:** i18n está ROTO en `Monexium`, `VentMex` y `Retos` →
   ver sección 5.
4. **Diseño / branding JOGA** — logo, colores y estilo visual no se alteran sin permiso.

---

## 3. Service Worker — regla de versión / SW version rule

**Cada bugfix o cambio de archivos servidos → subir la versión del cache del SW.**

- `joga-v2` → `joga-v3` → `joga-v4` ...
- Actualizar el nombre del cache Y la lista de archivos si se agregó/renombró algo.
- Esto evita que los usuarios queden atorados con archivos viejos en caché.

Si no se sube la versión, el fix no llega al usuario. No lo olvides.

---

## 4. Archivos sensibles / Sensitive files

| Archivo | Regla |
|---|---|
| `gate.js` | Editable libre. No abrir el gate. No exponer códigos en claro. |
| Códigos de licencia | Editable libre. Mantener SHA-256, nunca en texto plano público. |
| Service worker | Editable, pero **siempre** subir versión (ver sección 3). |
| Logo / branding | No tocar sin pedir permiso. |

---

## 5. Estado conocido / Known issues

- **i18n roto** en `Monexium`, `VentMex` y `Retos`. Si trabajas ahí, revisa los
  atributos `data-i18n` y el toggle de idioma. Pendiente: pase de i18n completo para
  expandir a mercado en inglés.
- Retos usa `localStorage` para persistencia — no borrar ni renombrar las llaves
  existentes o los usuarios pierden su progreso.

---

## 6. Convenciones / Conventions

- **Comentarios y commits: bilingües** (español + inglés). Ej:
  `fix: gate.js valida código vacío / validate empty code`
- **Máximo 200 líneas por archivo.** Si un archivo se pasa, dividirlo en módulos
  más chicos. No entregar archivos de más de 200 líneas / no file over 200 lines.
- HTML/CSS/JS puro: nada de dependencias nuevas sin pedir permiso.
- Mantener metadata PWA para iOS (íconos, `apple-mobile-web-app-*`, viewport).
- Audio embebido en base64 (ej. botón "Empezar el reto") — no romper esos data URIs.
- Cambios pequeños y verificables. No refactors masivos sin avisar.

---

## 7. Deploy

- Deploy = push a GitHub → GitHub Pages publica automático.
- **Antes de dar por listo un cambio:**
  1. ¿Subiste la versión del service worker? (si aplica)
  2. ¿Sigue cargando offline?
  3. ¿El gate sigue cerrado y validando?
  4. ¿El toggle de idioma no se rompió?

---

## 8. Flujo de trabajo / Workflow

> **OBLIGATORIO / MANDATORY:** Corre `./init.sh` ANTES de hacer cualquier cambio.
> Run `./init.sh` BEFORE making any change.
> **Si falla (exit ≠ 0): DETENTE. No continúes. Pide ayuda al humano.**
> **If it fails: STOP. Do not continue. Ask the human for help.**

1. Corre `./init.sh`. Si sale rojo/error → **para y avisa**. No toques nada.
   Run `./init.sh`. If it errors → **stop and report**. Change nothing.
2. Lee esta guía antes de tocar código.
3. Haz el cambio mínimo necesario.
4. Verifica las 4 reglas de oro (sección 2).
5. Sube versión del SW si tocaste archivos servidos.
6. Corre `./init.sh` otra vez para confirmar que sigue verde.
   Run `./init.sh` again to confirm it's still green.
7. Commit bilingüe, claro y corto.
