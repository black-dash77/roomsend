import json, sys
out_dir = sys.argv[1]
S = {  # key: (en, fr) ; plural: key: ({"one":..,"other":..}, {"one":..,"other":..})
 "tab.room": ("Room", "Pièce"),
 "tab.history": ("History", "Historique"),
 "tab.settings": ("Settings", "Réglages"),
 "room.identity.shuffle": ("New name", "Nouveau nom"),
 "room.refresh": ("Look again", "Chercher à nouveau"),
 "room.status.failed": ("Wi-Fi unavailable", "Wi-Fi indisponible"),
 "room.status.hidden": ("Hidden from the others", "Invisible pour les autres"),
 "room.status.listening": ("Listening on this Wi-Fi", "À l'écoute sur ce Wi-Fi"),
 "room.status.starting": ("Joining the Wi-Fi", "Connexion au Wi-Fi"),
 "room.nearby.title": ("In the room", "Dans la pièce"),
 "room.nearby.empty.title": ("Nobody yet", "Personne pour l'instant"),
 "room.nearby.empty.detail": ("Open RoomSend or LocalSend on another device on this Wi-Fi.", "Ouvre RoomSend ou LocalSend sur un autre appareil du même Wi-Fi."),
 "room.device.secure %@": ("%@ · encrypted", "%@ · chiffré"),
 "room.device.open %@": ("%@ · not encrypted", "%@ · non chiffré"),
 "source.photos": ("Photos", "Photos"),
 "source.files": ("Files", "Fichiers"),
 "source.text": ("Text", "Texte"),
 "source.paste": ("Paste", "Coller"),
 "text.title": ("A message", "Un message"),
 "text.placeholder": ("Type what to send", "Écris ce que tu veux envoyer"),
 "text.next": ("Next", "Suivant"),
 "send.summary.text": ("A message", "Un message"),
 "send.progress %lld %lld": ("Sending %1$lld of %2$lld", "Envoi %1$lld sur %2$lld"),
 "send.done %@": ("Sent to %@", "Envoyé à %@"),
 "send.done.everyone": ("Sent to the whole room", "Envoyé à toute la pièce"),
 "send.size.caption %@": ("%@ in all", "%@ en tout"),
 "send.noRecipient": ("Nobody to send to yet. Open RoomSend or LocalSend on another device on this Wi-Fi.", "Personne à qui envoyer pour l'instant. Ouvre RoomSend ou LocalSend sur un autre appareil du même Wi-Fi."),
 "send.size": ("Size", "Taille"),
 "send.security": ("Encryption", "Chiffrement"),
 "send.security.https": ("HTTPS, certificate checked", "HTTPS, certificat vérifié"),
 "send.security.http": ("None, plain HTTP", "Aucun, HTTP simple"),
 "send.cancel": ("Cancel", "Annuler"),
 "send.action": ("Send", "Envoyer"),
 "send.done.action": ("Done", "Terminé"),
 "send.retry": ("Try again", "Réessayer"),
 "error.unreachable": ("The device didn't answer.", "L'appareil n'a pas répondu."),
 "error.rejected": ("The device declined.", "L'appareil a refusé."),
 "error.pinRequired": ("This device asks for a PIN, which RoomSend doesn't support yet.", "Cet appareil demande un code PIN, que RoomSend ne gère pas encore."),
 "error.busy": ("The device is busy with another transfer.", "L'appareil est occupé par un autre transfert."),
 "error.invalidResponse": ("The device sent an unexpected answer.", "L'appareil a renvoyé une réponse inattendue."),
 "error.receiver %lld": ("The device ran into an error (%lld).", "L'appareil a rencontré une erreur (%lld)."),
 "history.title": ("History", "Historique"),
 "history.empty.title": ("Nothing sent yet", "Rien d'envoyé pour l'instant"),
 "history.empty.detail": ("What you send shows up here.", "Tes envois apparaîtront ici."),
 "settings.title": ("Settings", "Réglages"),
 "settings.identity.detail": ("This is how the others see you.", "C'est ainsi que les autres te voient."),
 "settings.visible": ("Visible on this Wi-Fi", "Visible sur ce Wi-Fi"),
 "settings.visible.detail": ("Nearby devices can see you and send to you.", "Les appareils proches te voient et peuvent t'envoyer."),
 "settings.about": ("About", "À propos"),
 "settings.fingerprint": ("Fingerprint", "Empreinte"),
 "settings.protocol": ("Protocol", "Protocole"),
 "settings.version": ("Version", "Version"),
 "settings.language": ("Language", "Langue"),
 "settings.language.detail": ("Applies to the whole app at once. Auto follows the iPhone.", "S'applique tout de suite à toute l'app. Auto suit l'iPhone."),
 "alias.adjectives": ("Calm,Swift,Bright,Clever,Gentle,Lucky,Brave,Sunny,Quiet,Happy,Bold,Witty", "Calme,Rapide,Brillant,Malin,Doux,Chanceux,Brave,Joyeux,Discret,Vif,Sage,Fier"),
 "alias.nouns": ("Kiwi,Mango,Lemon,Melon,Fig,Plum,Peach,Lime,Cherry,Apricot,Coconut,Papaya", "Kiwi,Citron,Melon,Abricot,Ananas,Litchi,Raisin,Coco,Marron,Pamplemousse,Avocat,Brugnon"),
 "alias.format %@ %@": ("%1$@ %2$@", "%2$@ %1$@"),
 "file.photo %lld": ("Photo %lld", "Photo %lld"),
 "room.add": ("Add by address", "Ajouter par adresse"),
 "room.favorite": ("Favorite", "Favori"),
 "room.makeFavorite": ("Add to favorites", "Ajouter aux favoris"),
 "room.unfavorite": ("Remove from favorites", "Retirer des favoris"),
 "add.title": ("Add a device", "Ajouter un appareil"),
 "add.placeholder": ("192.168.1.20", "192.168.1.20"),
 "add.detail": ("On RoomSend, it is shown at the top of this same window.", "Sur RoomSend, elle s'affiche en haut de cette même fenêtre."),
 "add.yours": ("Your address", "Ton adresse"),
 "add.yours.detail": ("To add you, the other person types it in LocalSend or RoomSend.", "Pour t'ajouter, l'autre la tape dans LocalSend ou RoomSend."),
 "add.yours.none": ("Connect to a Wi-Fi to get an address.", "Connecte-toi à un Wi-Fi pour avoir une adresse."),
 "add.theirs": ("The other device's address", "L'adresse de l'autre appareil"),
 "add.notFound": ("No LocalSend device answered at this address.", "Aucun appareil LocalSend n'a répondu à cette adresse."),
 "add.action": ("Add", "Ajouter"),
 "add.searching": ("Searching…", "Recherche…"),
 "send.everyone": ("The whole room", "Toute la pièce"),
 "send.to": ("To", "À"),
 "send.progress.bytes %@ %@ %@": ("To %1$@ · %2$@ of %3$@", "Vers %1$@ · %2$@ sur %3$@"),
 "send.pin.ask %@": ("%@ asks for a PIN", "%@ demande un code PIN"),
 "send.pin.wrong %@": ("Wrong PIN for %@, try again", "Code PIN refusé par %@, réessaie"),
 "send.pin.label": ("PIN", "Code PIN"),
 "send.pin.placeholder": ("123456", "123456"),
 "send.stop": ("Stop", "Arrêter"),
 "error.cancelled": ("Stopped.", "Arrêté."),
 "share.action": ("Share by link", "Partager par lien"),
 "share.title": ("Share by link", "Partager par lien"),
 "share.code": ("QR code of the link", "QR code du lien"),
 "share.detail": ("Open it in a browser on the same Wi-Fi. The link works while RoomSend stays open.", "Ouvre-le dans un navigateur du même Wi-Fi. Le lien marche tant que RoomSend reste ouvert."),
 "share.unavailable": ("Connect to a Wi-Fi to share by link.", "Connecte-toi à un Wi-Fi pour partager par lien."),
 "share.failed": ("The link could not start. Try again in a moment.", "Le lien n'a pas pu démarrer. Réessaie dans un instant."),
 "share.stop": ("Stop sharing", "Arrêter le partage"),
 "share.page.title %@": ("Shared by %@", "Partagé par %@"),
 "share.page.detail": ("Tap a file to download it.", "Touche un fichier pour le télécharger."),
 "extension.title": ("Ready in RoomSend", "Prêt dans RoomSend"),
 "extension.detail": ("Open RoomSend to choose who receives it.", "Ouvre RoomSend pour choisir à qui l'envoyer."),
 "receive.from %@": ("%@ is sending you", "%@ t'envoie"),
 "receive.progress %lld %lld": ("Receiving %1$lld of %2$lld", "Réception %1$lld sur %2$lld"),
 "receive.done %@": ("Received from %@", "Reçu de %@"),
 "receive.decline": ("Decline", "Refuser"),
 "receive.accept": ("Accept", "Accepter"),
 "receive.openFiles": ("Open in Files", "Ouvrir Fichiers"),
 "receive.openPhotos": ("Open in Photos", "Ouvrir Photos"),
 "receive.copy": ("Copy", "Copier"),
 "receive.more %lld": ("and %lld more", "et %lld de plus"),
 "history.sent %@": ("Sent · %@", "Envoyé · %@"),
 "history.received %@": ("Received · %@", "Reçu · %@"),
 "settings.name.placeholder": ("Your name", "Ton nom"),
 "settings.receive": ("Receiving", "Réception"),
 "settings.quickSave": ("Accept automatically", "Accepter automatiquement"),
 "settings.quickSave.detail": ("What is sent to you is saved without asking.", "Ce qu'on t'envoie est enregistré sans te demander."),
 "settings.photos": ("Photos to Photos", "Photos dans Photos"),
 "settings.photos.detail": ("Received photos and videos go to your library.", "Les photos et vidéos reçues vont dans ta photothèque."),
 "settings.pin": ("Ask for a PIN", "Demander un code PIN"),
 "settings.pin.detail": ("Senders must type it before sending.", "L'expéditeur doit le taper avant d'envoyer."),
 "settings.pin.code": ("Your PIN", "Ton code"),
 "settings.network": ("Network", "Réseau"),
 "settings.encryption": ("Encryption", "Chiffrement"),
 "settings.encryption.detail": ("Transfers to this iPhone use HTTPS.", "Les transferts vers cet iPhone passent en HTTPS."),
 "settings.scan": ("Scan the network", "Balayer le réseau"),
 "settings.scan.detail": ("Finds devices when the Wi-Fi blocks the usual search.", "Trouve les appareils quand le Wi-Fi bloque la recherche habituelle."),
 "settings.port": ("Port", "Port"),
 "room.sendTo %@": ("Send to %@", "Envoyer à %@"),
 "settings.appearance": ("Appearance", "Apparence"),
 "settings.appearance.system": ("Auto", "Auto"),
 "settings.appearance.light": ("Light", "Clair"),
 "settings.appearance.dark": ("Dark", "Sombre"),
 "settings.privacy": ("Privacy", "Confidentialité"),
 "settings.terms": ("Terms of Use", "Conditions d'utilisation"),
 "legal.close": ("Close", "Fermer"),
 "legal.openSite": ("Read on the website", "Lire sur le site"),
}
P = {
 "room.count %lld": ({"one": "%lld device around", "other": "%lld devices around"}, {"one": "%lld appareil autour", "other": "%lld appareils autour"}),
 "send.summary.photos %lld": ({"one": "%lld photo", "other": "%lld photos"}, {"one": "%lld photo", "other": "%lld photos"}),
 "send.summary.files %lld": ({"one": "%lld file", "other": "%lld files"}, {"one": "%lld fichier", "other": "%lld fichiers"}),
 "send.devices %lld": ({"one": "%lld device", "other": "%lld devices"}, {"one": "%lld appareil", "other": "%lld appareils"}),
 "send.summary.items %lld": ({"one": "%lld item", "other": "%lld items"}, {"one": "%lld élément", "other": "%lld éléments"}),
}
unit = lambda v: {"stringUnit": {"state": "translated", "value": v}}
import os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from translations import TR, TRP, INFO, LANGS
strings = {}
for k, (en, fr) in S.items():
    strings[k] = {"localizations": {"en": unit(en), "fr": unit(fr)}}
    for lang, value in zip(LANGS, TR[k]):
        strings[k]["localizations"][lang] = unit(value)
for k, (en, fr) in P.items():
    plural = lambda d: {"variations": {"plural": {c: unit(v) for c, v in d.items()}}}
    strings[k] = {"localizations": {"en": plural(en), "fr": plural(fr)}}
    for lang, forms in zip(LANGS, TRP[k]):
        strings[k]["localizations"][lang] = plural(forms)
for k, (en, fr) in list(S.items()) + [(k, (v[0]["other"], v[1]["other"])) for k, v in P.items()]:
    for text in (en, fr):
        assert "—" not in text, f"em dash in {k}"
from legal import DOCUMENTS, LANGUAGES as LEGAL_LANGUAGES, load as load_legal, to_markdown
legal_texts = {lang: load_legal(lang) for lang in LEGAL_LANGUAGES}
for name in DOCUMENTS:
    for field, read in (("title", lambda d: d["title"]), ("updated", lambda d: d["updated"]), ("body", to_markdown)):
        strings[f"legal.{name}.{field}"] = {"localizations": {lang: unit(read(legal_texts[lang][name])) for lang in LEGAL_LANGUAGES}}
json.dump({"sourceLanguage": "en", "strings": strings, "version": "1.0"},
          open(f"{out_dir}/Localizable.xcstrings", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
info = {"NSPhotoLibraryAddUsageDescription": ("RoomSend adds the photos and videos you receive to your library.", "RoomSend ajoute à ta photothèque les photos et vidéos que tu reçois."),
        "NSLocalNetworkUsageDescription": ("RoomSend finds the devices on your Wi-Fi to send them files.", "RoomSend trouve les appareils de ton Wi-Fi pour leur envoyer des fichiers."),
        "CFBundleDisplayName": ("RoomSend", "RoomSend")}
info_strings = {}
for k, (en, fr) in info.items():
    info_strings[k] = {"localizations": {"en": unit(en), "fr": unit(fr)}}
    for lang, value in zip(LANGS, INFO[k]):
        info_strings[k]["localizations"][lang] = unit(value)
missing = [k for k in S if k not in TR] + [k for k in P if k not in TRP]
assert not missing, f"untranslated: {missing}"
json.dump({"sourceLanguage": "en", "strings": info_strings, "version": "1.0"},
          open(f"{out_dir}/InfoPlist.xcstrings", "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("strings:", len(strings))
