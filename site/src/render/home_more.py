"""The presentation page, bottom half: receiving, light and dark, languages, privacy, LocalSend."""
from src import config
from src.copy import load as load_copy
from src.render.parts import data, esc, icon, phone, phone_from_urls, shot_pair

LANGUAGE_SHOT = f"room-{config.ROOM_STATES - 1}"


def section(name, title, lead, content):
    return f"""<section class="section {name}" id="{name}" aria-labelledby="{name}-title">
<div class="section__head">
<h2 class="title" id="{name}-title">{esc(title)}</h2>
<p class="lead">{esc(lead)}</p>
</div>
{content}
</section>"""


def receive(language, copy, shots):
    frames = shots["receiveFrames"]
    states = {"offer": "incoming"}
    states.update({str(index + 1): f"receive-{index + 1}" for index in range(len(frames))})
    states["done"] = "received"
    states["declined"] = LANGUAGE_SHOT
    content = f"""<div class="panel receive__panel" data-receive-panel data-frames="{data(frames)}" data-done="{shots['receiveDone']}">
<div class="receive__side">
<div class="pills" data-receive-choices>
<button class="pill pill--secondary" type="button" data-receive="decline">{esc(copy['receive.decline'])}</button>
<button class="pill pill--primary" type="button" data-receive="accept">{esc(copy['receive.accept'])}</button>
</div>
<button class="pill pill--secondary" type="button" data-receive="reset" hidden>{esc(copy['receive.reset'])}</button>
</div>
{phone(language, states, 'offer', copy['receive.alt'], 'phone--receive')}
</div>"""
    return section("receive", copy["receive.title"], copy["receive.lead"], content)


def appearance(language, copy):
    light, dark = shot_pair(language, LANGUAGE_SHOT)
    content = f"""<div class="compare" data-compare>
<div class="phone phone--compare"><div class="phone__frame"><div class="phone__screen">
<img class="compare__light" src="{esc(light)}" alt="{esc(copy['appearance.alt.light'])}" width="{config.SHOT_WIDTH}" height="{config.SHOT_HEIGHT}" loading="lazy" decoding="async">
<img class="compare__dark" src="{esc(dark)}" alt="{esc(copy['appearance.alt.dark'])}" width="{config.SHOT_WIDTH}" height="{config.SHOT_HEIGHT}" loading="lazy" decoding="async">
</div><span class="phone__island" aria-hidden="true"></span></div></div>
<div class="compare__line" aria-hidden="true"></div>
<div class="compare__handle" role="slider" tabindex="0" aria-label="{esc(copy['appearance.handle'])}" aria-valuemin="0" aria-valuemax="100" aria-valuenow="50" aria-valuetext="50%"></div>
</div>"""
    return section("appearance", copy["appearance.title"], copy["appearance.lead"], content)


def languages(language, copy):
    urls = {other: shot_pair(other, LANGUAGE_SHOT) for other in config.LANGUAGES}
    names = {other: load_copy(other)["lang.name"] for other in config.LANGUAGES}
    alts = {other: copy["languages.alt"].format(language=names[other]) for other in config.LANGUAGES}
    pills = "".join(
        f'<li><button class="choice" type="button" lang="{other}" data-language="{other}" '
        f'aria-pressed="{"true" if other == language else "false"}">{esc(names[other])}</button></li>'
        for other in config.LANGUAGES
    )
    content = f"""<div class="panel languages__panel" data-languages data-alts="{data(alts)}">
<div class="languages__side"><ul class="choices" role="list">{pills}</ul></div>
{phone_from_urls(urls, language, alts[language], 'phone--languages')}
</div>"""
    return section("languages", copy["languages.title"], copy["languages.lead"], content)


def privacy(language, copy):
    rows = "".join(
        f'<div class="facts__row"><dt>{esc(copy["privacy." + key])}</dt><dd>{esc(copy["privacy." + key + ".value"])}</dd></div>'
        for key in ("account", "server", "tracking", "encryption", "link")
    )
    content = f"""<div class="panel privacy__panel">
<dl class="facts">{rows}</dl>
<a class="more" href="{config.page_path(language, 'privacy')}">{esc(copy['privacy.more'])}{icon('chevron')}</a>
</div>"""
    return section("privacy", copy["privacy.title"], copy["privacy.lead"], content)


def compatibility(copy):
    content = f"""<p class="compat__link"><a class="more" href="{config.LOCALSEND_URL}" rel="noopener">{esc(copy['compat.link'])}{icon('arrow')}</a></p>"""
    return section("compat", copy["compat.title"], copy["compat.lead"], content)
