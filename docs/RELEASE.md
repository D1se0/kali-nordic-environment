# kali-nordic v1.0.0 — "Frost Awakening"

Primera release del entorno de escritorio **kali-nordic**: bspwm + polybar + picom + kitty + zsh, con la paleta Nord y herramientas propias para CTF/pentesting. Un instalador autocontenido monta el 100% del entorno, lo valida pantalla por pantalla y lo deja reproducible.

## ✨ Lo que incluye esta release

### Shell inteligente (zsh + autosugerencias + sintaxis en vivo)
- **Autosugerencias fish-like**: al teclear, el shell recuerda el comando anterior con ese inicio y lo ofrece como texto fantasma gris; `→` (o `Fin`) lo acepta.
- **Navegación por prefijo**: `↑` recupera el último comando que empieza exactamente igual.
- **Resaltado de sintaxis mientras escribes**: comando válido → verde Frost; comando inexistente → rojo Aurora (negrita); opciones (`-sV`, `--flag`) → violeta Aurora; rutas → cian; strings → amarillo; comentarios → gris.
- **F1/F2 escriben IPs en el cursor**: F1 escribe tu IP propia priorizando la VPN de HTB si está activa; F2 escribe la IP de la máquina víctima. Implementado como widget zsh sobre las secuencias de terminfo reales (kitty `\EO*` + variante NumLock `\E[1;3*`), sin depender de xdotool.

### Target inteligente
- `settarget <IP> [nombre]` fija la víctima y sincroniza en tiempo real: la barra, las nuevas shells (`$TARGET`, `$TARGET_NAME`) y el portapapeles (`settarget --copy`).
- Estado vacío = **"No Target"** en la barra en gris atenuado (clic → copiar o fijar con Super+T).
- `settarget --hosts <IP> <nombre>` añade la entrada a `/etc/hosts` con sudo.

### Barra (polybar) de una sola pieza
- Zona izquierda combinada: dragón Kali → **No Target/IP víctima** → **IP local** → **estado VPN** (verde, con etiqueta HTB si es 10.10.x.x).
- Centro: 10 escritorios bspwm con iconos; derecha: CPU, RAM, disco, reloj y botón de energía.
- Clic en cada píldora ejecuta su acción (netmenu, settarget, rofi…).

### Menús glass (rofi 2.0)
- Temas propios intercambiables en caliente: launcher, power, confirm, target, tools, cheatsheet, clipboard.
- Modi scripts propios: **menú de energía** (Apagar/Reiniciar/Suspender/Hibernar/Bloquear/Cerrar sesión) y **confirmación Yes/No** (No por defecto) para acciones destructivas, incluido el cierre de ventanas (`Super+w`).

### Lockscreen, greeter y energía
- **Login de LightDM Nord**: fondo propio del greeter, tema GTK Nordic y teclado español.
- **Lockscreen** (`Super+Shift+L`): fondo Nord personalizado + i3lock.
- **Bloqueo automático al suspender** mediante servicio `nordic-lock-before-sleep.service`.

### Instalador autocontenido y validado
- `nordic-env-installer.sh`: un único script con **todo el entorno embebido** (payload tar.gz + MD5 verificado antes de instalar).
- Validaciones previas: permisos de sudo, paquetes, directorios; **idempotente** (puede relanzarse sin romper nada).
- Blindaje de permisos: 755 forzado en todos los scripts de polybar, bspwm y rofi (los modi de rofi ya no fallan con "Permission denied").
- `nordic-doctor` audita los 30+ componentes tras instalar.

## 📸 Capturas
Ver la galería en la web del proyecto (GitHub Pages) o en `docs/screenshots/` del repositorio.

## 🚀 Instalación
```bash
curl -O https://github.com/D1se0/kali-nordic/releases/latest/download/nordic-env-installer.sh
chmod +x nordic-env-installer.sh && ./nordic-env-installer.sh
# cierra sesión y elige la sesión "bspwm" en el login Nord
```

## 🔄 Cambios técnicos
- Corregido: rutas de carga de `zsh-autosuggestions`/`zsh-syntax-highlighting` en Debian (viven en `/usr/share/zsh-*/`, no en `/usr/share/zsh/plugins/`).
- Corregido: indicador de sintaxis en apps que fabrican patrones con `\E[1;3P/Q` (NumLock) — los bindkey ya lo cubren.
- Corregido: `barleft.sh` tolera la ausencia del fichero de target (la barra ya no muestra errores en bruto).
- Corregido: permisos de ejecución en `config/rofi/modi/*.sh`.
- Añadido: paquetes `zsh-autosuggestions` y `zsh-syntax-highlighting` a la lista de apt del instalador.

## 📝 Notas
- Probado sobre Kali Rolling x86_64 con LightDM y VM sin aceleración 3D (perfil picom `lite` automático; `glass` si hay GPU).
- Licencia GPL-3.0. La paleta Nord es de su autoría ([nordtheme.com](https://www.nordtheme.com)).
