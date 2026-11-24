// Sending and receiving, replayed from real captures. Each frame was taken during a real
// transfer; `frames` holds how long after the previous one it was on screen.

import { Phone } from "./phone.js";
import { BEAT_MS, prefersReducedMotion, wait } from "./motion.js";

async function play(phone, frames, doneDelay, isCurrent) {
  if (!prefersReducedMotion()) {
    for (const [index, delay] of frames.entries()) {
      await wait(delay);
      if (!isCurrent()) return;
      await phone.show(String(index + 1));
    }
    await wait(doneDelay);
  }
  if (isCurrent()) await phone.show("done");
}

export function setUpSend(panel) {
  const phone = new Phone(panel.querySelector(".phone"));
  const button = panel.querySelector("[data-send-button]");
  const frames = JSON.parse(panel.dataset.frames);
  const doneDelay = Number(panel.dataset.done);
  const label = button.textContent;
  let run = 0;

  button.addEventListener("click", async () => {
    const current = ++run;
    button.disabled = true;
    if (phone.current === "done") {
      await phone.show("ready");
      button.textContent = label;
      await wait(BEAT_MS);
    }
    await play(phone, frames, doneDelay, () => current === run);
    button.disabled = false;
    button.textContent = button.dataset.again;
  });
  phone.preload(Object.keys(phone.states));
}

export function setUpReceive(panel) {
  const phone = new Phone(panel.querySelector(".phone"));
  const frames = JSON.parse(panel.dataset.frames);
  const doneDelay = Number(panel.dataset.done);
  const choices = panel.querySelector("[data-receive-choices]");
  const reset = panel.querySelector('[data-receive="reset"]');
  let run = 0;

  const finish = () => {
    choices.hidden = true;
    reset.hidden = false;
    reset.focus({ preventScroll: true });
  };

  panel.querySelector('[data-receive="accept"]').addEventListener("click", async () => {
    const current = ++run;
    choices.hidden = true;
    await play(phone, frames, doneDelay, () => current === run);
    if (current === run) finish();
  });
  panel.querySelector('[data-receive="decline"]').addEventListener("click", async () => {
    run += 1;
    await phone.show("declined");
    finish();
  });
  reset.addEventListener("click", async () => {
    run += 1;
    await phone.show("offer");
    reset.hidden = true;
    choices.hidden = false;
  });
  phone.preload(Object.keys(phone.states));
}
