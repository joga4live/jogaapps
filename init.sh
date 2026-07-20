#!/usr/bin/env bash
# init.sh — Joga Intelligence PWA
# Verifica estado del proyecto y valida las reglas del AGENTS.md
# Checks project health and validates AGENTS.md rules
# Uso / Usage:  ./init.sh   (correr desde la raíz del repo / run from repo root)

set -uo pipefail

# ---- Colores / Colors ----
G="\033[0;32m"; R="\033[0;31m"; Y="\033[0;33m"; B="\033[0;34m"; N="\033[0m"
ok(){ echo -e "${G}✔${N} $1"; }
bad(){ echo -e "${R}x${N} $1"; ERR=$((ERR+1)); }
warn(){ echo -e "${Y}!${N} $1"; WARN=$((WARN+1)); }
section(){ echo -e "\n${B}== $1 ==${N}"; }

ERR=0; WARN=0
MAX_LINES=200

echo -e "${B}Joga Intelligence — init.sh${N}"
echo "Fecha / Date: $(date '+%Y-%m-%d %H:%M')"

# ---- 1. AGENTS.md existe / exists ----
section "AGENTS.md"
if [ -f "AGENTS.md" ]; then
  ok "AGENTS.md encontrado / found"
else
  bad "Falta AGENTS.md / AGENTS.md missing"
fi

# ---- 2. Estructura básica / Basic structure ----
section "Estructura / Structure"
for f in index.html manifest.json; do
  [ -f "$f" ] && ok "$f" || warn "Falta / missing: $f"
done

# Service worker (nombre flexible / flexible name)
SW=""
for cand in sw.js service-worker.js serviceworker.js; do
  [ -f "$cand" ] && SW="$cand" && break
done
if [ -n "$SW" ]; then
  ok "Service worker: $SW"
else
  bad "No se encontró service worker / no service worker found"
fi

# gate.js
if [ -f "gate.js" ]; then
  ok "gate.js"
else
  bad "Falta gate.js / gate.js missing"
fi

# ---- 3. Regla 1: Licencias / Gate ----
section "Regla 1 — Gate / Licencias"
if [ -f "gate.js" ]; then
  # SHA-256 presente / present
  if grep -qi "sha-256\|sha256\|subtle.digest" gate.js; then
    ok "Validación SHA-256 presente / SHA-256 present"
  else
    warn "No detecto SHA-256 en gate.js / SHA-256 not detected"
  fi
  # Posible bypass / open gate
  if grep -qiE "return true;.*//.*bypass|DISABLE_GATE|gate.*=.*false" gate.js; then
    bad "Posible BYPASS del gate / possible gate bypass"
  else
    ok "Sin bypass evidente / no obvious bypass"
  fi
fi

# Códigos en texto plano en archivos públicos / plaintext codes in public files
LEAK=$(grep -rilE "license.?code|codigo.?licencia" --include="*.html" --include="*.json" . 2>/dev/null | grep -v node_modules || true)
if [ -n "$LEAK" ]; then
  warn "Revisar posibles códigos expuestos en: $LEAK"
else
  ok "Sin códigos en claro en HTML/JSON / no plaintext codes"
fi

# ---- 4. Regla 2: Service Worker versión / SW version ----
section "Regla 2 — Service Worker offline"
if [ -n "$SW" ]; then
  VER=$(grep -oiE "joga-v[0-9]+" "$SW" | head -1)
  if [ -n "$VER" ]; then
    ok "Versión de cache / cache version: $VER"
    echo "   Recordatorio: sube versión en cada bugfix / bump version each bugfix"
  else
    warn "No detecto versión joga-vN en $SW / no joga-vN version found"
  fi
  grep -qi "addEventListener" "$SW" 2>/dev/null && grep -qi "fetch" "$SW" 2>/dev/null \
    && ok "Handler fetch (offline) presente" \
    || warn "No detecto handler fetch / no fetch handler"
fi

# ---- 5. Regla 3: i18n ----
section "Regla 3 — i18n"
for f in monexium ventmex retos; do
  hit=$(ls | grep -i "^${f}" | head -1 || true)
  if [ -n "$hit" ]; then
    if grep -qi "data-i18n" "$hit" 2>/dev/null; then
      warn "$hit tiene data-i18n pero i18n está ROTO aquí / known broken"
    else
      warn "$hit sin data-i18n / missing i18n (conocido / known)"
    fi
  fi
done

# ---- 6. Regla: máx 200 líneas / max 200 lines ----
section "Regla — Máx ${MAX_LINES} líneas por archivo"
BIG=0
while IFS= read -r file; do
  n=$(wc -l < "$file")
  if [ "$n" -gt "$MAX_LINES" ]; then
    bad "$file — $n líneas (>$MAX_LINES)"
    BIG=$((BIG+1))
  fi
done < <(find . -type f \( -name "*.js" -o -name "*.html" -o -name "*.css" \) \
          -not -path "*/node_modules/*" 2>/dev/null)
[ "$BIG" -eq 0 ] && ok "Todos los archivos ≤ ${MAX_LINES} líneas / all within limit"

# ---- 7. PWA iOS metadata ----
section "PWA iOS"
if [ -f "index.html" ]; then
  grep -qi "apple-mobile-web-app" index.html \
    && ok "Metadata iOS presente" \
    || warn "Falta metadata apple-mobile-web-app / missing iOS metadata"
fi

# ---- Resumen / Summary ----
section "Resumen / Summary"
echo -e "Errores / Errors:   ${R}${ERR}${N}"
echo -e "Avisos / Warnings:  ${Y}${WARN}${N}"
if [ "$ERR" -eq 0 ]; then
  echo -e "${G}Proyecto en buen estado. Listo para deploy.${N}"
  echo -e "${G}Project healthy. Ready to deploy.${N}"
  exit 0
else
  echo -e "${R}Hay errores que arreglar antes de deploy.${N}"
  echo -e "${R}Fix errors before deploying.${N}"
  exit 1
fi
