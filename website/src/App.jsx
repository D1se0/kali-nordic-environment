import React, { useState, useEffect } from 'react';
import { useReveal, useScrollProgress, useTyping } from './hooks.js';

const BASE = import.meta.env.BASE_URL; // '/kali-nordic/' en Pages
const S = (n) => `${BASE}screenshots/${n}`;

/* ───────────────────────── NAV ───────────────────────── */
function Nav() {
  const [solid, setSolid] = useState(false);
  const [open, setOpen] = useState(false);
  useEffect(() => {
    const f = () => setSolid(window.scrollY > 30);
    window.addEventListener('scroll', f, { passive: true });
    return () => window.removeEventListener('scroll', f);
  }, []);
  const links = [
    ['#features', 'Características'],
    ['#gallery', 'Galería'],
    ['#keys', 'Atajos'],
    ['#install', 'Instalación'],
    ['#arch', 'Arquitectura'],
  ];
  return (
    <header className={`nav ${solid ? 'solid' : ''}`}>
      <a className="brand" href="#top">
        <span className="brand-dragon">🐉</span>
        <span className="brand-name">kali<span className="frost">-nordic</span></span>
        <span className="brand-ver">v1.0</span>
      </a>
      <nav className={`nav-links ${open ? 'open' : ''}`}>
        {links.map(([h, t]) => <a key={h} href={h} onClick={() => setOpen(false)}>{t}</a>)}
        <a className="nav-cta" href="https://github.com/D1se0/kali-nordic" target="_blank" rel="noreferrer">
          GitHub ↗
        </a>
      </nav>
      <button className="nav-burger" onClick={() => setOpen(!open)} aria-label="menú">☰</button>
    </header>
  );
}

/* ───────────────────────── HERO ───────────────────────── */
function Hero() {
  const shotRef = useReveal();
  const { out } = useTyping('~/Desktop ❯ ./nordic-env-installer.sh', 42);
  const lines = [
    { t: '✔ zsh con autosugerencias y colores', d: 400 },
    { t: '✔ polybar: target · IPs · VPN en tiempo real', d: 900 },
    { t: '✔ lockscreen + greeter Nord habilitados', d: 1400 },
    { t: '✔ entorno montado. reinicia en "bspwm"', d: 1900 },
  ];
  return (
    <section id="top" className="hero">
      <div className="aurora" aria-hidden="true"><i/><i/><i/><i/></div>
      <div className="stars" aria-hidden="true">{Array.from({ length: 60 }, (_, i) => <i key={i} style={{ '--i': i }} />)}</div>
      <div className="hero-inner wrap">
        <p className="hero-kicker" data-reveal="true">
          <span className="pill-dot" /> bspwm · polybar · picom · kitty · zsh · rofi
        </p>
        <h1 className="hero-title" data-reveal="true">
          Tu Kali Linux con el alma de <span className="grad">Nord</span>
        </h1>
        <p className="hero-sub" data-reveal="true">
          Un entorno de escritorio <b>completamente diseñado</b> para pentesting con CTF:
          barra inteligente con target e IPs, menús glass, lockscreen, greeter y un
          shell que te escribe las IPs por ti. Un solo instalador, todo reproducible.
        </p>
        <div className="hero-cta" data-reveal="true">
          <a className="btn btn-primary" href="#install"> Instalar en 2 comandos</a>
          <a className="btn btn-ghost" href="#gallery">Ver capturas</a>
        </div>
        <div className="hero-shot" ref={shotRef} data-reveal="true">
          <img src={S('desktop-final.png')} alt="Escritorio kali-nordic completo" />
          <div className="shot-glow" aria-hidden="true" />
          <div className="shot-shadow" aria-hidden="true" />
        </div>
        <div className="hero-terminal" data-reveal="true">
          <div className="term-bar"><i/><i/><i/><span>bash — instalador</span></div>
          <pre className="term-body">
            <code><span className="c-prompt">{out}</span>{'\n'}</code>
            {lines.map((l, i) => (
              <code key={i} className="c-ok" style={{ animation: `fadeUp .4s both ${l.d}ms` }}>{l.t}{'\n'}</code>
            ))}
          </pre>
        </div>
      </div>
      <div className="hero-scroll" aria-hidden="true"><span/></div>
    </section>
  );
}

/* ─────────────────────── FEATURES ─────────────────────── */
const FEATURES = [
  { icon: '🎯',      t: 'Target inteligente', d: 'settarget fija la víctima y toda la barra, la shell ($TARGET) y el portapapeles se sincronizan al instante. "No Target" si está vacío, con nombre personalizado y /etc/hosts automático.' },
  { icon: '⌨️',      t: 'F1/F2 escriben IPs', d: 'F1 escribe tu IP (prioriza la VPN de HTB) y F2 la de la víctima exactamente donde está el cursor: widget zsh sobre las secuencias reales del terminal, con variantes NumLock incluidas.' },
  { icon: '🧞',      t: 'Sugerencias fish-like', d: 'El shell recuerda tus comandos: al teclear aparece el anterior con ese inicio como texto fantasma (→ lo acepta) y ↑ navega por prefijo.' },
  { icon: '🌈',      t: 'Sintaxis en vivo',   d: 'El comando se colorea MIENTRAS lo escribes: verde si existe, rojo negrita si no, violeta para opciones, cian para rutas, amarillo para strings y gris para comentarios.' },
  { icon: '🪟',      t: 'Barra con contexto', d: 'Polybar en una sola pieza: dragón Kali, IP objetivo, IP local, estado VPN, escritorios, CPU/RAM/disco y reloj con relleno Nord. Clic en cada píldora = acción.' },
  { icon: '🔮',      t: 'Menús glass',        d: 'Rofi 2.0 con temas propios apilables (launcher, power, confirm, target, tools…) y modi scripts propios: energía con confirmación y cerrado de ventanas seguro.' },
  { icon: '🌙',      t: 'Lockscreen + greeter', d: 'Login de LightDM y pantalla de bloqueo con el mismo wallpaper Nord, tipografía y teclado es. Al suspender se bloquea automáticamente (systemd hook).' },
  { icon: '📦',      t: 'Instalador autocontenido', d: 'Un único .sh con todo el entorno embebido (payload tar.gz + md5 verificado), validaciones previas y soporte root. Fuentes y temas incluidos.' },
  { icon: '🩺',      t: 'Doctor incluido',    d: 'nordic-doctor audita los 30+ componentes del entorno y notifica cualquier pieza ausente o rota, con sugerencia de reparación.' },
];

function Features() {
  const ref = useReveal();
  return (
    <section id="features" className="section">
      <div className="wrap" ref={ref}>
        <h2 className="sec-title" data-reveal="true">¿Qué trae <span className="grad">el entorno</span>?</h2>
        <p className="sec-sub" data-reveal="true">Cada pieza está pensada para fluir rápido en un CTF sin sacrificar la estética Nord.</p>
        <div className="feature-grid">
          {FEATURES.map((f, i) => (
            <article className="feat" key={f.t} data-reveal="true" style={{ '--d': `${(i % 3) * 90}ms` }}>
              <div className="feat-icon">{f.icon}</div>
              <h3>{f.t}</h3>
              <p>{f.d}</p>
              <span className="feat-line" aria-hidden="true" />
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ─────────────────────── GALERÍA ──────────────────────── */
const SHOTS = [
  { src: 'desktop-final.png', t: 'Escritorio completo', d: 'bspwm con dos terminales kitty + p10k, barra y wallpaper Nord.' },
  { src: 'bar-left.png',      t: 'Barra en detalle',   d: 'Target, IP local y VPN como píldoras independientes con aciones.' },
  { src: 'power-menu.png',    t: 'Menú de energía',   d: 'Rofi glass con modi script propio y confirmación previa.' },
  { src: 'confirm.png',       t: 'Confirmación Yes/No', d: 'Cerrar sesión o ventanas nunca sin preguntar (No por defecto).' },
  { src: 'zsh-syntax.png',    t: 'Shell con colores', d: 'Comando válido verde, inexistente rojo, opciones violeta, strings amarillo.' },
  { src: 'zsh-autosuggest.png', t: 'Autosugerencia',  d: 'Texto fantasma del comando anterior con ese inicio; → lo acepta.' },
];

function Gallery() {
  const ref = useReveal();
  const [zoom, setZoom] = useState(null);
  return (
    <section id="gallery" className="section alt">
      <div className="wrap" ref={ref}>
        <h2 className="sec-title" data-reveal="true">Galería de <span className="grad">capturas</span></h2>
        <p className="sec-sub" data-reveal="true">Fotogramas reales tomados sobre la VM de pruebas (Kali Rolling, 1920×1080).</p>
        <div className="gallery">
          {SHOTS.map((s, i) => (
            <figure key={s.src} className="shot" data-reveal="true" style={{ '--d': `${(i % 3) * 100}ms` }} onClick={() => setZoom(s)}>
              <img src={S(s.src)} alt={s.t} loading="lazy" />
              <figcaption><b>{s.t}</b><span>{s.d}</span></figcaption>
            </figure>
          ))}
        </div>
      </div>
      {zoom && (
        <div className="lightbox" onClick={() => setZoom(null)}>
          <img src={S(zoom.src)} alt={zoom.t} />
          <p>{zoom.t} — {zoom.d}</p>
        </div>
      )}
    </section>
  );
}

/* ──────────────────────── ATAJOS ──────────────────────── */
const KEYS = [
  ['Super +Enter', 'Abrir kitty'], ['Super + Espacio', 'Rofi launcher'], ['Super + w', 'Cerrar ventana (pregunta)'],
  ['Super + Esc', 'Menú de energía'], ['Super + Shift + l', 'Lockscreen'], ['Super + Shift + r', 'Recargar entorno'],
  ['F1', 'Escribir tu IP (VPN primero)'], ['F2', 'Escribir la IP de la víctima'], ['Super + t', 'Fijar target por rofi'],
  ['Super + 1…9, 0', 'Ir al escritorio N'], ['Super + f', 'Fullscreen'], ['Super + m', 'Monocle ↔ tiled'],
  ['Super + BackSpace', 'Scratchpad desplegable'], ['Super + v', 'Historial de portapapeles'], ['Super + Shift + s', 'Captura de pantalla'],
  ['Super + F1', 'Chuleta de atajos'], ['Super + Shift + F2', 'Menú de herramientas'], ['Super + Ctrl + b', 'Blur ON/OFF'],
];
function Keybinds() {
  const ref = useReveal();
  return (
    <section id="keys" className="section">
      <div className="wrap" ref={ref}>
        <h2 className="sec-title" data-reveal="true">Atajos de <span className="grad">teclado</span></h2>
        <p className="sec-sub" data-reveal="true">sxhkd con reglas claras; la chuleta vive en Super+F1 y en docs/CHEATSHEET.md del repo.</p>
        <div className="keys-grid" data-reveal="true">
          {KEYS.map(([k, d]) => (
            <div className="key-row" key={k}>
              <kbd>{k}</kbd><span>{d}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ────────────────────── INSTALACIÓN ────────────────────── */
function Install() {
  const ref = useReveal();
  const [steps, setSteps] = useState(0);
  useEffect(() => {
    const t = setInterval(() => setSteps((s) => (s + 1) % 3), 2600);
    return () => clearInterval(t);
  }, []);
  const code = [
    'curl -O https://github.com/D1se0/kali-nordic/releases/latest/download/nordic-env-installer.sh',
    'chmod +x nordic-env-installer.sh && ./nordic-env-installer.sh',
    '# cierra sesión → elige la sesión "bspwm" en el login Nord',
  ];
  return (
    <section id="install" className="section alt">
      <div className="wrap" ref={ref}>
        <h2 className="sec-title" data-reveal="true">Instalación en <span className="grad">dos comandos</span></h2>
        <p className="sec-sub" data-reveal="true">El instalador valida prerequisitos, instala paquetes, despliega configs y verifica el resultado. Idempotente: puedes lanzarlo las veces que quieras.</p>
        <div className="hero-terminal" data-reveal="true">
          <div className="term-bar"><i/><i/><i/><span>zsh — root@kali</span></div>
          <pre className="term-body">
            {code.map((c, i) => (
              <code key={i} className={i === 0 ? 'c-path' : i === 1 ? 'c-cmd' : 'c-com'} style={{ animation: `fadeUp .5s both ${i * 350}ms` }}>
                <span className="c-prompt">❯ </span>{c}{'\n'}
              </code>
            ))}
            <code className="c-ok" style={{ animation: 'fadeUp .5s both 1.1s' }}>{['', '', '✔ 30+ componentes verificados · entorno listo'][steps]}{'\n'}</code>
          </pre>
        </div>
        <div className="warn" data-reveal="true">⚠️  Diseñado y probado sobre <b>Kali Linux Rolling x86_64</b> con LightDM. Otros Debian/Ubuntu deberían funcionar con los mismos paquetes.</div>
      </div>
    </section>
  );
}

/* ──────────────────── ARQUITECTURA ──────────────────── */
const LAYERS = [
  { c: 'sesión', items: ['LightDM → bspwm.desktop', 'nordic-session (greeter-setup)', 'teclado es en 4 capas'] },
  { c: 'WM + atajos', items: ['bspwm: 10 escritorios, reglas por app', 'sxhkd: 40+ atajos, confirmaciones', 'balanceo automático del árbol'] },
  { c: 'shell + datos', items: ['kitty + p10k Nord Frost', 'zsh: autosuggest + syntax + F1/F2', 'settarget: estado compartido /run/nordic'] },
  { c: 'UI', items: ['polybar: scripts propios (barleft, workspaces…)', 'rofi: 6 temas glass + modi scripts', 'picom: perfiles glass/lite por GPU'] },
  { c: 'extras', items: ['nordic-lock + hook de suspensión', 'greeter Nord y fondo del login', 'nordic.nanorc, doctor, cheatsheet, CTF helpers'] },
];

function Arch() {
  const ref = useReveal();
  const p = useScrollProgress();
  return (
    <section id="arch" className="section">
      <div className="wrap" ref={ref}>
        <h2 className="sec-title" data-reveal="true">Arquitectura en <span className="grad">5 capas</span></h2>
        <p className="sec-sub" data-reveal="true">Nada mágico: cada capa es inspeccionable, reproducible y con decisiones documentadas en docs/DECISIONS.md.</p>
        <div className="stack" data-reveal="true" style={{ '--progress': p }}>
          {LAYERS.map((l, i) => (
            <div className={`layer l${i}`} key={l.c}>
              <span className="layer-tag">{String(i + 1).padStart(2, '0')} · {l.c}</span>
              <ul>{l.items.map((it) => <li key={it}>{it}</li>)}</ul>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ──────────────────────── FOOTER ──────────────────────── */
function Footer() {
  return (
    <footer className="footer">
      <div className="wrap">
        <div className="dragon-foot" aria-hidden="true">🐉</div>
        <p><b>kali-nordic</b> — diseñado con la paleta Nord (#2E3440 · #88C0D0 · #A3BE8C · #BF616A)</p>
        <p className="foot-links">
          <a href="https://github.com/D1se0/kali-nordic">GitHub</a> ·
          <a href="https://github.com/D1se0/kali-nordic/releases">Releases</a> ·
          <a href="https://www.nordtheme.com/docs/colors-and-palettes">Nord palette</a>
        </p>
        <p className="foot-copy">Made with ❄ by D1se0 · GPL-3.0</p>
      </div>
    </footer>
  );
}

export default function App() {
  return (
    <div className="page">
      <Nav />
      <Hero />
      <Features />
      <Gallery />
      <Keybinds />
      <Install />
      <Arch />
      <Footer />
    </div>
  );
}
