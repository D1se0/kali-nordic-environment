import { useEffect, useState, useRef } from 'react';

// useReveal: aplica la clase "in" cuando el elemento entra en pantalla,
// activando las animaciones CSS (fadeUp, scaleIn, slideLeft...).
export function useReveal(threshold = 0.15) {
  const ref = useRef(null);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
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
    // acepta un solo elemento o varios hijos marcados con .reveal-child
    const targets = el.querySelectorAll('[data-reveal]');
    if (targets.length) {
      targets.forEach((t) => obs.observe(t));
    } else {
      obs.observe(el);
    }
    return () => obs.disconnect();
  }, [threshold]);
  return ref;
}

// useParallax: número entre 0 y 1 con el progreso de scroll de la página.
export function useScrollProgress() {
  const [p, setP] = useState(0);
  useEffect(() => {
    const onScroll = () => {
      const h = document.documentElement.scrollHeight - window.innerHeight;
      setP(h > 0 ? window.scrollY / h : 0);
    };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);
  return p;
}

// useTyping: escribe el texto carácter a carácter, reinicia al reintentar.
export function useTyping(text, speed = 28, started = true) {
  const [out, setOut] = useState('');
  const [done, setDone] = useState(false);
  useEffect(() => {
    if (!started) return;
    setOut(''); setDone(false);
    let i = 0;
    const t = setInterval(() => {
      i += 1;
      setOut(text.slice(0, i));
      if (i >= text.length) { clearInterval(t); setDone(true); }
    }, speed);
    return () => clearInterval(t);
  }, [text, speed, started]);
  return { out, done };
}
