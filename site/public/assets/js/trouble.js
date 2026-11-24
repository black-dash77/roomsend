// « Nobody in the room? »: one question at a time. « Yes » opens the next one, « No » shows what
// to do. Without scripts every question and answer stays visible as a plain list.

export function setUpTrouble(panel) {
  const steps = [...panel.querySelectorAll(".step[data-step]")].filter((step) => step.dataset.step !== "end");
  const end = panel.querySelector('.step[data-step="end"]');
  const restart = panel.querySelector("[data-trouble-restart]");

  function reset() {
    steps.forEach((step, index) => {
      step.classList.remove("is-answered", "is-no");
      step.classList.toggle("is-waiting", index > 0);
    });
    end.classList.remove("is-shown");
    restart.hidden = true;
  }

  function finish(focusTarget) {
    restart.hidden = false;
    focusTarget.setAttribute("tabindex", "-1");
    focusTarget.focus({ preventScroll: true });
  }

  steps.forEach((step, index) => {
    step.querySelector('[data-answer="yes"]').addEventListener("click", () => {
      step.classList.add("is-answered");
      const next = steps[index + 1];
      if (next) {
        next.classList.remove("is-waiting");
        next.querySelector("button").focus({ preventScroll: true });
        return;
      }
      end.classList.add("is-shown");
      finish(end);
    });
    step.querySelector('[data-answer="no"]').addEventListener("click", () => {
      step.classList.add("is-answered", "is-no");
      finish(step.querySelector("[data-answer-text]"));
    });
  });
  restart.addEventListener("click", () => {
    reset();
    steps[0].querySelector("button").focus();
  });

  panel.classList.add("is-live");
  reset();
}
