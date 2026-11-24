"""The presentation page, top half: the hero, the room that fills, the carousel, the send."""
from src import config
from src.render.layout import store_badge
from src.render.parts import avatar, data, esc, phone
from src.render.home_more import appearance, compatibility, languages, privacy, receive, section

ROOM_GLYPH_SHOWN = 3


def body(language, copy, peers, shots):
    return "\n".join([
        hero(language, copy),
        room(language, copy, peers),
        choose(language, copy, peers, shots),
        send(language, copy, shots),
        receive(language, copy, shots),
        appearance(language, copy),
        languages(language, copy),
        privacy(language, copy),
        compatibility(copy),
    ])


def hero(language, copy):
    last = config.ROOM_STATES - 1
    return f"""<section class="hero" aria-labelledby="hero-title">
<div class="hero__text">
<p class="hero__name"><img class="app-icon app-icon--light" src="/assets/icons/icon-128.png" alt="" width="56" height="56"><img class="app-icon app-icon--dark" src="/assets/icons/icon-dark-128.png" alt="" width="56" height="56">RoomSend</p>
<h1 class="hero__title" id="hero-title">{esc(copy['hero.title'])}</h1>
<p class="hero__lead">{esc(copy['hero.lead'])}</p>
<div class="hero__store">{store_badge(copy)}<span class="hero__free">{esc(copy['store.free'])}</span></div>
</div>
{phone(language, {str(last): f'room-{last}'}, str(last), copy['hero.alt'], 'phone--hero', eager=True)}
</section>"""


def room(language, copy, peers):
    last = config.ROOM_STATES - 1
    base = [peer for peer in peers if peer["isBase"]]
    joining = [peer for peer in peers if not peer["isBase"]][:last]
    states = {str(count): f"room-{count}" for count in range(config.ROOM_STATES)}
    alts = {str(count): copy["room.alt"].format(count=len(base) + count) for count in range(config.ROOM_STATES)}
    faces = "".join(face(peer, 0, "room__face--base") for peer in base) + "".join(
        face(peer, index + 1) for index, peer in enumerate(joining)
    )
    content = f"""<div class="panel room__panel" data-room data-base="{len(base)}" data-alts="{data(alts)}" data-lang="{language}">
<div class="room__side">
<p class="room__count"><span class="room__number" data-room-number>{len(base) + last}</span>
<span class="room__unit" data-room-unit data-one="{esc(copy['room.unit.one'])}" data-other="{esc(copy['room.unit.other'])}">{esc(copy['room.unit.other'])}</span></p>
<ul class="room__faces" role="list">{faces}</ul>
<label class="slider">
<span class="slider__label">{esc(copy['room.control'])}</span>
<input class="slider__input" type="range" min="0" max="{last}" step="1" value="{last}" data-room-range>
</label>
<p class="hint" data-room-hint hidden>{esc(copy['room.hint'])}</p>
</div>
{phone(language, states, str(last), alts[str(last)], 'phone--room')}
</div>"""
    return section("room", copy["room.title"], copy["room.lead"], content)


def face(peer, index, extra=""):
    return (
        f'<li class="room__face is-in {extra}" data-index="{index}">{avatar(peer["pattern"])}'
        f'<span class="room__alias">{esc(peer["alias"])}</span></li>'
    )


def recipient(index, name, face, selected):
    pressed = "true" if selected else "false"
    return (
        f'<li class="recipient" data-index="{index}"><button class="recipient__button" type="button" '
        f'aria-pressed="{pressed}" data-name="{esc(name)}">{face}<span class="recipient__name">{esc(name)}</span>'
        "</button></li>"
    )


def choose(language, copy, peers, shots):
    order = shots["carousel"][language]
    names = [copy["choose.everyone"] if entry == "everyone" else entry for entry in order]
    by_alias = {peer["alias"]: peer for peer in peers}
    selected = shots["carouselInitial"][language]
    glyph = "".join(avatar(by_alias[alias]["pattern"]) for alias in order[1:ROOM_GLYPH_SHOWN + 1])
    items = "".join(
        recipient(index, name, f'<span class="glyph" aria-hidden="true">{glyph}</span>' if entry == "everyone"
                  else avatar(by_alias[entry]["pattern"], "avatar--recipient"), index == selected)
        for index, (entry, name) in enumerate(zip(order, names))
    )
    states = {str(index): f"choose-{index}" for index in range(len(order))}
    alts = {str(index): copy["choose.alt"].format(name=name) for index, name in enumerate(names)}
    content = f"""<div class="panel choose__panel">
<div class="choose__side">
<div class="carousel" data-carousel data-alts="{data(alts)}" data-status="{esc(copy['choose.selected'])}">
<ul class="carousel__track" role="list">{items}</ul>
</div>
<p class="carousel__status" data-carousel-status aria-live="polite">{esc(copy['choose.selected'].format(name=names[selected]))}</p>
</div>
{phone(language, states, str(selected), alts[str(selected)], 'phone--choose')}
</div>"""
    return section("choose", copy["choose.title"], copy["choose.lead"], content)


def send(language, copy, shots):
    frames = shots["sendFrames"]
    recipient = shots["sendRecipient"][language]
    alt = copy["send.alt"].format(name=shots["carousel"][language][recipient])
    states = {"ready": f"choose-{recipient}"}
    states.update({str(index + 1): f"send-{index + 1}" for index in range(len(frames))})
    states["done"] = "sent"
    content = f"""<div class="panel send__panel" data-send data-frames="{data(frames)}" data-done="{shots['sendDone']}">
<div class="send__side">
<button class="pill pill--primary" type="button" data-send-button data-again="{esc(copy['send.again'])}">{esc(copy['send.action'])}</button>
</div>
{phone(language, states, 'ready', alt, 'phone--send')}
</div>"""
    return section("send", copy["send.title"], copy["send.lead"], content)
