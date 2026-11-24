"""The legal pages, the help page and the missing page."""
from src import config, sources
from src.render.parts import esc, inline, phone

TROUBLE_STEPS = 3


def legal(language, copy, document, name):
    """A legal document from `tools/legal`, with its table of contents and the same text in the app."""
    sections = "".join(
        f'<section class="doc__section" id="s{index}" aria-labelledby="s{index}-title">'
        f'<h2 id="s{index}-title">{esc(heading)}</h2>{blocks(items)}</section>'
        for index, (heading, items) in enumerate(document["sections"], start=1)
    )
    toc = "".join(
        f'<li><a href="#s{index}" data-toc="s{index}">{esc(heading)}</a></li>'
        for index, (heading, _) in enumerate(document["sections"], start=1)
    )
    app = phone(language, {"app": f"legal-{name}"}, "app", copy["legal.inapp"], "phone--doc")
    return f"""<article class="doc">
<header class="doc__head">
<h1 class="doc__title">{esc(document['title'])}</h1>
<p class="doc__date">{esc(document['updated'])}</p>
<p class="doc__intro">{inline(document['intro'])}</p>
</header>
<div class="doc__layout">
<aside class="doc__aside">
<nav class="toc" aria-labelledby="toc-title"><p class="toc__label" id="toc-title">{esc(copy['legal.toc'])}</p><ol role="list">{toc}</ol></nav>
<div class="doc__app">{app}<p class="doc__caption">{esc(copy['legal.inapp'])}</p></div>
</aside>
<div class="doc__body">{sections}</div>
</div>
</article>"""


def blocks(items):
    return "".join(
        f'<ul class="doc__list" role="list">{"".join(f"<li>{inline(item)}</li>" for item in block)}</ul>'
        if isinstance(block, list) else f"<p>{inline(block)}</p>"
        for block in items
    )


def support(language, copy):
    email = sources.PUBLISHER["email"]
    steps = "".join(
        f"""<li class="step" data-step="{index}">
<p class="step__question">{esc(copy[f'trouble.q{index}'])}</p>
<div class="step__choices pills"><button class="pill pill--secondary" type="button" data-answer="no">{esc(copy['trouble.no'])}</button><button class="pill pill--primary" type="button" data-answer="yes">{esc(copy['trouble.yes'])}</button></div>
<p class="step__answer" data-answer-text>{esc(copy[f'trouble.a{index}'])}</p>
</li>"""
        for index in range(1, TROUBLE_STEPS + 1)
    )
    faq = "".join(
        f'<details class="faq__item"><summary>{esc(copy[f"faq.{key}.q"])}</summary><p>{esc(copy[f"faq.{key}.a"])}</p></details>'
        for key in ("files", "apps", "pin", "secure", "link", "room", "name")
    )
    empty_room = phone(language, {"empty": "room-0"}, "empty", copy["trouble.title"], "phone--support")
    return f"""<div class="page">
<header class="page__head">
<h1 class="page__title">{esc(copy['support.title'])}</h1>
<p class="lead">{esc(copy['support.lead'])}</p>
</header>
<section class="panel trouble" aria-labelledby="trouble-title" data-trouble>
<div class="trouble__side">
<h2 class="trouble__title" id="trouble-title">{esc(copy['trouble.title'])}</h2>
<ol class="steps" role="list">{steps}
<li class="step step--end" data-step="end"><p class="step__answer">{esc(copy['trouble.end'])}</p></li>
</ol>
<button class="pill pill--secondary trouble__restart" type="button" data-trouble-restart hidden>{esc(copy['trouble.restart'])}</button>
</div>
{empty_room}
</section>
<section class="faq" aria-labelledby="faq-title">
<h2 class="subtitle" id="faq-title">{esc(copy['faq.title'])}</h2>
<div class="panel faq__list">{faq}</div>
</section>
<section class="panel contact" aria-labelledby="contact-title">
<h2 class="subtitle" id="contact-title">{esc(copy['contact.title'])}</h2>
<p class="contact__email"><a href="mailto:{esc(email)}">{esc(email)}</a></p>
<p class="contact__lead">{esc(copy['contact.lead'])}</p>
</section>
</div>"""


def not_found(copy):
    return f"""<div class="page page--missing">
<p class="missing__code" aria-hidden="true">404</p>
<h1 class="page__title">{esc(copy['notfound.title'])}</h1>
<p><a class="pill pill--primary" href="{config.page_path(config.DEFAULT_LANGUAGE, 'home')}">{esc(copy['notfound.back'])}</a></p>
</div>"""
