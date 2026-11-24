// A phone on the page shows one real capture at a time. `show` loads the light and the dark
// capture of a state, waits until they can be drawn, then lays them over the previous ones,
// so a change never flashes an empty screen. The last call always wins.

import { SETTLE_MS } from "./motion.js";

const THEMES = ["light", "dark"];

function activeTheme() {
  return document.documentElement.dataset.theme === "dark" ? "dark" : "light";
}

export class Phone {
  constructor(figure) {
    this.figure = figure;
    this.screen = figure.querySelector(".phone__screen");
    this.states = JSON.parse(figure.dataset.states);
    this.current = figure.dataset.state;
    this.images = new Map();
    this.layer = 1;
    this.request = 0;
    const initial = THEMES.map((theme) => this.screen.querySelector(`.shot--${theme}`));
    this.images.set(this.current, initial);
    this.size = { width: initial[0].getAttribute("width"), height: initial[0].getAttribute("height") };
  }

  /** Switches to `state`, and gives the figure the description of what it now shows. */
  async show(state, label) {
    if (label) this.figure.setAttribute("aria-label", label);
    if (state === this.current || !this.states[state]) return;
    const request = ++this.request;
    const pair = this.ensure(state);
    const visible = pair[THEMES.indexOf(activeTheme())];
    await visible.decode().catch(() => undefined);
    if (request !== this.request) return;
    const previous = this.images.get(this.current);
    this.layer += 1;
    pair.forEach((image) => {
      image.style.zIndex = String(this.layer);
      image.classList.add("is-current");
    });
    this.current = state;
    this.figure.dataset.state = state;
    window.setTimeout(() => {
      if (this.current === state) previous.forEach((image) => image.classList.remove("is-current"));
    }, SETTLE_MS);
  }

  /** Starts loading the captures of `states`, so the next change is instant. */
  preload(states) {
    states.forEach((state) => {
      if (this.states[state]) this.ensure(state);
    });
  }

  ensure(state) {
    if (this.images.has(state)) return this.images.get(state);
    const pair = THEMES.map((theme, index) => {
      const image = new Image();
      image.className = `shot shot--${theme}`;
      image.alt = "";
      image.decoding = "async";
      image.loading = theme === activeTheme() ? "eager" : "lazy";
      image.setAttribute("width", this.size.width);
      image.setAttribute("height", this.size.height);
      image.src = this.states[state][index];
      this.screen.append(image);
      return image;
    });
    this.images.set(state, pair);
    return pair;
  }
}
