# RoomSend, notes pour la revue d'Apple

À coller dans App Store Connect › la version › App Review Information › Notes. Les relecteurs lisent
l'anglais : le bloc est en anglais (3 066 caractères, limite 4 000).

- **Sign-in required** : décocher. RoomSend n'a pas de compte.
- **Contact** : prénom, nom, téléphone et courriel de l'éditeur, à remplir (voir README, « Ce qui manque »).
- **Pièce jointe** : aucune nécessaire ; une courte vidéo d'un envoi entre deux iPhone aiderait si la revue
  bloque sur « impossible de tester ».

Règles visées : 2.1 (app complète et testable), 2.3.1 (fonctions décrites précisément), 4.1 (Copycats),
5.1.1 (autorisations expliquées). Texte des règles lu le 21.11.2026 sur
[App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/).

```text
RoomSend sends photos, videos, files and text between devices on the same Wi-Fi network. There is no account, no sign-in and no server: transfers go directly from one device to the other over the local network.

HOW TO TEST
Option 1, two iOS devices: install RoomSend on both, join the same Wi-Fi, open the app on both. Each device appears in the other's Room tab. Tap a device, choose Photos, Files, Text or Paste, then Send. The receiving device shows who is sending and what, with Decline and Accept.
Option 2, one iOS device and a computer: install the free open-source LocalSend app on a Mac or PC on the same Wi-Fi (localsend.org). RoomSend implements the same public protocol, so the two find each other and can exchange files in both directions.
Option 3, one iOS device only: choose something to send, tap "Share by link", and open the address or the QR code in Safari on any other device of the same Wi-Fi. A download page served by RoomSend appears.
If the network blocks multicast (some office or guest networks do), RoomSend also scans the local subnet; you can add a device by IP address with the "+" button, which also shows this device's own address.
RoomSend sends and receives while it is open on screen. Both devices must be on the same network.

PERMISSIONS
Local Network: asked at first launch. It is needed to find nearby devices (multicast announcements and a scan of the local subnet) and to send and receive files. Without it, the room stays empty.
Photo Library (add only): asked the first time photos or videos are received while "Photos to Photos" is on in Settings. Received media are added to the library. To pick photos to send, RoomSend uses the system photo picker and has no access to the rest of the library.
No other permission is used: no camera, microphone, location, contacts or tracking.

SECURITY
Transfers use HTTPS. Each device creates its own self-signed certificate; RoomSend checks that the certificate presented by the other device matches the fingerprint that device announced. Devices that do not encrypt are labeled "not encrypted". Receivers can require a PIN.

ABOUT GUIDELINE 4.1
RoomSend is an original app, written from scratch in Swift and SwiftUI by its developer. It is not a copy, a fork or a re-skin of another app: it contains no code, icon, artwork, name or interface from LocalSend or any other app. It implements the publicly documented LocalSend protocol (version 2.2) only so that it can exchange files with devices that run LocalSend. RoomSend is not affiliated with LocalSend; the description mentions LocalSend once, to state this compatibility. Its own design includes the room with a live device count, avatars computed from each device's certificate fingerprint, sending to the whole room at once, sharing by link with a QR code, a share extension, a history kept on the device, and six languages selectable inside the app.

PRIVACY
RoomSend collects no data, has no analytics, no advertising and no third-party SDK that collects data. History, favorites and the device name stay on the device.
```

## Notes pour l'éditeur (ne pas coller)

- **Droit multicast.** Si Apple a accordé `com.apple.developer.networking.multicast` avant la soumission,
  la découverte marche comme décrit. Sinon, la découverte passe par le balayage du réseau : le texte reste
  vrai, mais l'option 2 (LocalSend sur un ordinateur) trouvera RoomSend plus lentement. Voir
  `README.md`, « Ce qui manque ».
- **Option 3 vérifiée** : le 21.11.2026 dans cette session, la page du lien a répondu au Mac (curl) ;
  le téléchargement intact d'un JPEG est dans l'ADR 8 de `docs/decisions.md`. Les options 1 et 2 l'ont été pendant le développement (ADR 1, ADR 4, passe de tests
  du 21.11 au soir), pas refaites dans cette session.
- Si la revue demande une démonstration, la vidéo la plus simple : deux iPhone, un envoi de trois photos,
  l'acceptation, l'arrivée dans Photos.
