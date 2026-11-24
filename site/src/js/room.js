// « The room fills up by itself »: the slider lets devices in, the big number counts them in
// the app's words, and the phone shows the real Room screen with that many devices. The demo
// plays once when the panel comes into view, then hands the slider over.

import { Phone } from "./phone.js";
import { BEAT_MS, prefersReducedMotion, wait, whenVisible } from "./motion.js";

export function setUpRoom(panel) {
  const range = panel.querySelector("[data-room-range]");
  const number = panel.querySelector("[data-room-number]");
  const unit = panel.querySelector("[data-room-unit]");
  const hint = panel.querySelector("[data-room-hint]");
  const faces = [...panel.querySelectorAll(".room__face")];
  const alts = JSON.parse(panel.dataset.alts);
  const base = Number(panel.dataset.base);
  const plural = new Intl.PluralRules(panel.dataset.lang);
  const phone = new Phone(panel.querySelector(".phone"));
  let shown = Number(range.value);
  let isTouched = false;

  function render(count) {
    if (count !== shown) swapDigit(number, base + count, count > shown);
    shown = count;
    unit.textContent = plural.select(base + count) === "one" ? unit.dataset.one : unit.dataset.other;
    faces.forEach((face) => face.classList.toggle("is-in", Number(face.dataset.index) <= count));
    range.value = String(count);
    range.style.setProperty("--fill", `${(count / Number(range.max)) * 100}%`);
    phone.show(String(count), alts[String(count)]);
  }

  range.addEventListener("input", () => {
    isTouched = true;
    hint.hidden = true;
    render(Number(range.value));
  });
  range.addEventListener("pointerdown", () => {
    isTouched = true;
  });

  render(shown);
  phone.preload(Object.keys(alts));
  if (prefersReducedMotion()) return;
  whenVisible(panel, async () => {
    if (isTouched) return;
    render(0);
    for (let count = 1; count <= Number(range.max); count += 1) {
      await wait(BEAT_MS);
      if (isTouched) return;
      render(count);
    }
    hint.hidden = false;
  });
}

function swapDigit(container, value, isRising) {
  const digit = document.createElement("span");
  digit.className = isRising ? "room__digit" : "room__digit room__digit--down";
  digit.textContent = String(value);
  container.replaceChildren(digit);
}
