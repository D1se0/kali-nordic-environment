import { useEffect, useRef, useState } from 'react';

/* ───────────────────────── REVELADO ─────────────────────────
   Un único observador por instancia que añade la clase "in" a los
   elementos marcados con [data-reveal] UNA sola vez (dispara las
   animaciones CSS de entrada y deja de vigilarlos: nunca re-animan,
   que es la causa clásica del parpadeo). */

function observeReveals(nodes, threshold = 0.15) {
  // Fallback: sin IntersectionObserver se muestra TODO directamente (nunca
  // puede quedar la página en opacity 0 para siempre).
  if (typeof IntersectionObserver === 'undefined') {
    nodes.forEach((n) => n && n.classList.add('in'));
    return { disconnect() {}, unobserve() {}, observe() {} };
  }
  const obs = new IntersectionObserver(
    (entries) => {
      entries.forEach((e) => {
        if (e.isIntersecting) {
          e.target.classList.add('in');
          obs.unobserve(e.target);
        }
      });
    },
    { threshold, rootMargin: '0px 0px -40px 0px' }
  );
  nodes.forEach((n) => {
    if (n && !n.classList.contains('in')) obs.observe(n);
  });
  return obs;
}

// useGlobalReveal: UN observador para TODA la página. Antes cada sección
// vigilaba su subárbol y los [data-reveal] del Hero quedaban huérfanos
// (opacity 0 + flashes al montar). Ahora todo se revela y deja de
// reanimarse en el segundo render.
export function useGlobalReveal(threshold = 0.15) {
  useEffect(() => {
    const obs = observeReveals([...document.querySelectorAll('[data-reveal]')], threshold);
    return () => obs.disconnect();
  }, [threshold]);
}

// useReveal (por sección): sigue disponible para casos puntuales.
// Observa el nodo si él mismo es revelable, además de sus hijos con
// [data-reveal] (querySelectorAll no incluye al propio nodo).
export function useReveal(threshold = 0.15) {
  const ref = useRef(null);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const targets = [...el.querySelectorAll('[data-reveal]')];
    if (el.matches('[data-reveal]')) targets.unshift(el);
    const obs = observeReveals(targets, threshold);
    return () => obs.disconnect();
  }, [threshold]);
  return ref;
}

/* ───────────────────────── SCROLL ─────────────────────────
   useScrollProgressVar: escribe la variable CSS --progress DIRECTAMENTE
   en el nodo (setProperty) dentro de un requestAnimationFrame. Antes se
   hacía setP(...) en cada evento de scroll → React re-renderizaba la app
   completa decenas de veces por segundo (jank + parpadeo). Ahora: cero
   re-renders, un solo estilo por frame como máximo.
*/
export function useScrollProgressVar() {
  const ref = useRef(null);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    let raf = 0;
    const update = () => {
      raf = 0;
      const h = document.documentElement.scrollHeight - window.innerHeight;
      const v = h > 0 ? Math.min(1, Math.max(0, window.scrollY / h)) : 0;
      el.style.setProperty('--progress', v.toFixed(4));
    };
    const onScroll = () => {
      if (!raf) raf = requestAnimationFrame(update);
    };
    update();
    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll, { passive: true });
    return () => {
      if (raf) cancelAnimationFrame(raf);
      window.removeEventListener('scroll', onScroll);
      window.removeEventListener('resize', onScroll);
    };
  }, []);
  return ref;
}

/* ───────────────────────── TYPING ─────────────────────────
   useTyping: escribe carácter a carácter. Ahora para SIEMPRE al terminar
   (antes el interval se limpia igual, pero el estado extra done y los
   re-inicios en montajes duplicados de StrictMode provocaban flashes del
   terminal en desarrollo); en producción además ya no reinicia nunca.
*/
export function useTyping(text, speed = 28, started = true) {
  const [out, setOut] = useState('');
  useEffect(() => {
    if (!started) return;
    let raf = 0;
    let i = 0;
    let last = 0;
    const tick = (t) => {
      if (!last) last = t;
      if (t - last >= speed) {
        last = t;
        i = Math.min(i + 1, text.length);
        setOut(text.slice(0, i));
        if (i >= text.length) return; // termina del todo: cero animación residual
      }
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [text, speed, started]);
  return { out };
}
