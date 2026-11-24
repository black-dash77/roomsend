// « Six languages, right away »: each pill shows the real Room screen in its language, at once.

import { Phone } from "./phone.js";

export function setUpLanguages(panel) {
  const phone = new Phone(panel.querySelector(".phone"));
  const alts = JSON.parse(panel.dataset.alts);
  const choices = [...panel.querySelectorAll("[data-language]")];
  choices.forEach((choice) => {
    choice.addEventListener("click", () => {
      choices.forEach((other) => other.setAttribute("aria-pressed", String(other === choice)));
      phone.show(choice.dataset.language, alts[choice.dataset.language]);
    });
    choice.addEventListener("pointerenter", () => phone.preload([choice.dataset.language]), { once: true });
  });
}
