// Wires each part of the page that is present; every module works on its own panel.

import { setUpBar, setUpLanguageMenus, setUpTheme } from "./chrome.js";
import { setUpCarousel } from "./carousel.js";
import { setUpCompare } from "./compare.js";
import { setUpLanguages } from "./languages.js";
import { setUpRoom } from "./room.js";
import { setUpReceive, setUpSend } from "./sequences.js";
import { setUpToc } from "./toc.js";
import { setUpTrouble } from "./trouble.js";

const PARTS = [
  ["[data-room]", setUpRoom],
  [".choose__panel", setUpCarousel],
  ["[data-send]", setUpSend],
  ["[data-receive-panel]", setUpReceive],
  ["[data-compare]", setUpCompare],
  ["[data-languages]", setUpLanguages],
  ["[data-trouble]", setUpTrouble],
  [".toc", setUpToc],
];

setUpTheme();
setUpLanguageMenus();
setUpBar();
PARTS.forEach(([selector, setUp]) => {
  document.querySelectorAll(selector).forEach((element) => setUp(element));
});
