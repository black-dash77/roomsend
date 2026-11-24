// Timing shared by every demo: the app's two curves, the pause between beats, and the rules
// that keep motion polite (Reduce Motion shows the end state, a demo plays once, when seen).

export const SETTLE_MS = 380;
export const BEAT_MS = 650;
const VISIBLE_SHARE = 0.45;

const reducedQuery = window.matchMedia("(prefers-reduced-motion: reduce)");

export function prefersReducedMotion() {
  return reducedQuery.matches;
}

export function wait(milliseconds) {
  return new Promise((resolve) => {
    window.setTimeout(resolve, milliseconds);
  });
}

/** Calls `onVisible` once, the first time most of `element` is on screen. */
export function whenVisible(element, onVisible) {
  const observer = new IntersectionObserver(
    (entries) => {
      if (!entries.some((entry) => entry.isIntersecting)) return;
      observer.disconnect();
      onVisible();
    },
    { threshold: VISIBLE_SHARE },
  );
  observer.observe(element);
}

/** Apple's momentum projection: where a flick released at `velocity` px/s comes to rest. */
export function project(velocity, decelerationRate = 0.998) {
  return ((velocity / 1000) * decelerationRate) / (1 - decelerationRate);
}

export function clamp(value, low, high) {
  return Math.min(high, Math.max(low, value));
}
