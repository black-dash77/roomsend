// The table of contents of a legal page marks the section being read.

export function setUpToc(nav) {
  const links = new Map([...nav.querySelectorAll("a[data-toc]")].map((link) => [link.dataset.toc, link]));
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        links.forEach((link) => link.classList.remove("is-current"));
        links.get(entry.target.id)?.classList.add("is-current");
      });
    },
    { rootMargin: "-20% 0px -70% 0px" },
  );
  links.forEach((_, id) => {
    const section = document.getElementById(id);
    if (section) observer.observe(section);
  });
}
