// What every page shares: the appearance button, the language menu, the bar's soft edge.
// Choices are kept in this browser only (localStorage), and only when the visitor makes them.

const root = document.documentElement;
const darkQuery = window.matchMedia("(prefers-color-scheme: dark)");

function remember(key, value) {
  try {
    window.localStorage.setItem(key, value);
  } catch {
    // Storage refused (private mode, blocked site data): the choice holds for this page only.
  }
}

function stored(key) {
  try {
    return window.localStorage.getItem(key);
  } catch {
    return null;
  }
}

function applyTheme(theme) {
  root.dataset.theme = theme;
  document.querySelectorAll(".theme").forEach((button) => {
    button.setAttribute("aria-label", theme === "dark" ? button.dataset.labelLight : button.dataset.labelDark);
  });
}

export function setUpTheme() {
  applyTheme(root.dataset.theme === "dark" ? "dark" : "light");
  document.querySelectorAll(".theme").forEach((button) => {
    button.addEventListener("click", () => {
      const next = root.dataset.theme === "dark" ? "light" : "dark";
      remember("theme", next);
      applyTheme(next);
    });
  });
  darkQuery.addEventListener("change", (event) => {
    if (!stored("theme")) applyTheme(event.matches ? "dark" : "light");
  });
}

export function setUpLanguageMenus() {
  const menus = [...document.querySelectorAll(".lang")];
  menus.forEach((menu) => {
    menu.querySelectorAll("a[data-lang]").forEach((link) => {
      link.addEventListener("click", () => remember("lang", link.dataset.lang));
    });
  });
  document.addEventListener("click", (event) => {
    menus.forEach((menu) => {
      if (menu.open && !menu.contains(event.target)) menu.open = false;
    });
  });
  document.addEventListener("keydown", (event) => {
    if (event.key !== "Escape") return;
    menus.forEach((menu) => {
      if (!menu.open) return;
      menu.open = false;
      menu.querySelector("summary").focus();
    });
  });
}

export function setUpBar() {
  const bar = document.querySelector(".bar");
  if (!bar) return;
  const update = () => bar.classList.toggle("is-scrolled", window.scrollY > 2);
  window.addEventListener("scroll", update, { passive: true });
  update();
}
