// Light or dark: the same capture in both appearances, split by a line that follows the finger
// from where it was grabbed. Arrow keys move it too. It sweeps once when first seen, then
// waits for the visitor.

import { clamp, prefersReducedMotion, whenVisible } from "./motion.js";

const KEY_STEP = 5;
const SWEEP = [50, 28, 72, 50];
const SWEEP_LEG_MS = 700;

export function setUpCompare(compare) {
  const handle = compare.querySelector(".compare__handle");
  const screen = compare.querySelector(".phone__screen");
  let split = 50;
  let isTouched = false;

  function set(value) {
    split = clamp(value, 0, 100);
    const box = screen.getBoundingClientRect();
    const x = box.left - compare.getBoundingClientRect().left + (box.width * split) / 100;
    compare.style.setProperty("--split", `${split}%`);
    compare.style.setProperty("--x", `${x}px`);
    handle.setAttribute("aria-valuenow", String(Math.round(split)));
    handle.setAttribute("aria-valuetext", `${Math.round(split)}%`);
  }

  function fromPointer(event) {
    const box = screen.getBoundingClientRect();
    set(((event.clientX - box.left) / box.width) * 100);
  }

  compare.addEventListener("pointerdown", (event) => {
    isTouched = true;
    compare.setPointerCapture(event.pointerId);
    compare.classList.add("is-dragging");
    fromPointer(event);
  });
  compare.addEventListener("pointermove", (event) => {
    if (compare.classList.contains("is-dragging")) fromPointer(event);
  });
  const release = () => compare.classList.remove("is-dragging");
  compare.addEventListener("pointerup", release);
  compare.addEventListener("pointercancel", release);

  handle.addEventListener("keydown", (event) => {
    const step = { ArrowLeft: -KEY_STEP, ArrowRight: KEY_STEP, Home: -100, End: 100 }[event.key];
    if (step === undefined) return;
    event.preventDefault();
    isTouched = true;
    set(split + step);
  });

  set(split);
  window.addEventListener("resize", () => set(split), { passive: true });
  if (prefersReducedMotion()) return;
  whenVisible(compare, () => sweep(set, () => isTouched));
}

function sweep(set, isTouched) {
  const legs = SWEEP.slice(1).map((to, index) => ({ from: SWEEP[index], to }));
  let leg = 0;
  let start = 0;
  const step = (time) => {
    if (isTouched() || leg >= legs.length) return;
    if (!start) start = time;
    const progress = Math.min(1, (time - start) / SWEEP_LEG_MS);
    const eased = 1 - (1 - progress) ** 3;
    set(legs[leg].from + (legs[leg].to - legs[leg].from) * eased);
    if (progress === 1) {
      leg += 1;
      start = 0;
    }
    requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
}
