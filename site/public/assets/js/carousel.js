// The recipients' carousel: the one in the centre is the choice. Touch and trackpads scroll it
// natively; a mouse drags it 1:1 and a flick is projected to where it would come to rest.
// Each item shrinks and fades with its distance from the centre, and the phone follows the
// choice the moment it changes.

import { Phone } from "./phone.js";
import { clamp, prefersReducedMotion, project } from "./motion.js";

const SCROLL_END_MS = 140;
const DRAG_THRESHOLD = 6;

export function setUpCarousel(panel) {
  const carousel = panel.querySelector("[data-carousel]");
  const track = carousel.querySelector(".carousel__track");
  const items = [...track.querySelectorAll(".recipient")];
  const buttons = items.map((item) => item.querySelector("button"));
  const status = panel.querySelector("[data-carousel-status]");
  const alts = JSON.parse(carousel.dataset.alts);
  const phone = new Phone(panel.querySelector(".phone"));
  let selected = buttons.findIndex((button) => button.getAttribute("aria-pressed") === "true");
  let frame = 0;
  let endTimer = 0;
  let wasDragged = false;

  const offsetOf = (index) => items[index].offsetLeft + items[index].offsetWidth / 2 - track.clientWidth / 2;
  const behavior = () => (prefersReducedMotion() ? "auto" : "smooth");

  function nearest() {
    const centre = track.scrollLeft;
    let best = 0;
    items.forEach((_, index) => {
      if (Math.abs(offsetOf(index) - centre) < Math.abs(offsetOf(best) - centre)) best = index;
    });
    return best;
  }

  function paint() {
    frame = 0;
    const width = items[0].offsetWidth;
    items.forEach((item, index) => {
      const distance = Math.abs(offsetOf(index) - track.scrollLeft) / width;
      buttons[index].style.setProperty("--near", String(clamp(1 - distance, 0, 1)));
    });
    select(nearest());
  }

  function select(index) {
    if (index === selected) return;
    selected = index;
    buttons.forEach((button, position) => button.setAttribute("aria-pressed", String(position === index)));
    status.textContent = carousel.dataset.status.replace("{name}", buttons[index].dataset.name);
    phone.show(String(index), alts[String(index)]);
  }

  function centre(index, how) {
    track.scrollTo({ left: offsetOf(index), behavior: how });
  }

  track.addEventListener("scroll", () => {
    if (!frame) frame = requestAnimationFrame(paint);
    window.clearTimeout(endTimer);
    endTimer = window.setTimeout(() => carousel.classList.remove("is-dragging"), SCROLL_END_MS);
  }, { passive: true });

  buttons.forEach((button, index) => {
    button.addEventListener("click", (event) => {
      if (wasDragged) {
        event.preventDefault();
        return;
      }
      centre(index, behavior());
    });
  });

  track.addEventListener("keydown", (event) => {
    const step = { ArrowLeft: -1, ArrowRight: 1 }[event.key];
    if (!step) return;
    event.preventDefault();
    const next = clamp(selected + step, 0, items.length - 1);
    centre(next, behavior());
    buttons[next].focus({ preventScroll: true });
  });

  dragWithMouse(track, carousel, (velocity) => {
    const target = track.scrollLeft - project(velocity);
    let best = 0;
    items.forEach((_, index) => {
      if (Math.abs(offsetOf(index) - target) < Math.abs(offsetOf(best) - target)) best = index;
    });
    centre(best, behavior());
  }, (moved) => {
    wasDragged = moved;
  });

  const place = () => {
    centre(selected, "auto");
    paint();
  };
  requestAnimationFrame(place);
  window.addEventListener("resize", place, { passive: true });
  phone.preload(Object.keys(alts));
}

/** Mouse drags move the row 1:1 from where it was grabbed; touch keeps the native scroll. */
function dragWithMouse(track, carousel, onRelease, onMoved) {
  let start = null;
  track.addEventListener("pointerdown", (event) => {
    if (event.pointerType !== "mouse" || event.button !== 0) return;
    start = { x: event.clientX, left: track.scrollLeft, samples: [{ x: event.clientX, t: event.timeStamp }] };
    onMoved(false);
  });
  track.addEventListener("pointermove", (event) => {
    if (!start) return;
    const dx = event.clientX - start.x;
    if (Math.abs(dx) > DRAG_THRESHOLD && !carousel.classList.contains("is-dragging")) {
      carousel.classList.add("is-dragging");
      track.setPointerCapture(event.pointerId);
      onMoved(true);
    }
    if (!carousel.classList.contains("is-dragging")) return;
    track.scrollLeft = start.left - dx;
    start.samples = [...start.samples.slice(-4), { x: event.clientX, t: event.timeStamp }];
  });
  const release = () => {
    if (!start) return;
    const samples = start.samples;
    const first = samples[0];
    const last = samples[samples.length - 1];
    const velocity = last.t > first.t ? ((last.x - first.x) / (last.t - first.t)) * 1000 : 0;
    const wasDragging = carousel.classList.contains("is-dragging");
    start = null;
    if (wasDragging) onRelease(velocity);
  };
  track.addEventListener("pointerup", release);
  track.addEventListener("pointercancel", release);
}
