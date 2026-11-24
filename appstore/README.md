# RoomSend, dossier de publication App Store

Préparé le 21.11.2026. Rien n'a été soumis à App Store Connect ni publié. App gratuite, iPhone,
iOS 26, bundle `app.roomsend.ios`, équipe 4HTQ3SHZ5C.

## Ce qui est prêt

| Élément | Fichier | État |
|---|---|---|
| Textes en, fr, de, es, it, pt | `metadata/<langue>.md` | Limites contrôlées par `tools/check-metadata.py` : tout passe |
| Étude des mots-clés (Sonar) | `aso.md` | Mesures du 21.11.2026, décisions et suivi prévu |
| Captures des six langues, 6 par langue | `screenshots/<langue>/6.9-inch-1320x2868/` et `6.3-inch-1206x2622/` | Relues image par image, PNG RGB opaques |
| Écrans bruts de l'app | `screenshots/raw/<langue>/` | Captures pleine résolution du simulateur, en sombre |
| Visuels En-tête, Résultats de recherche, universel ; bannières | `banner/` | Voir plus bas |
| Confidentialité et âge | `privacy-and-rating.md` | « Aucune donnée collectée », 4+ attendu |
| Notes pour la revue | `review-notes.md` | Bloc anglais de 3 066 caractères (limite 4 000) |
| Manifeste de confidentialité | `handoff/PrivacyInfo.xcprivacy` | Brouillon validé par `plutil`, à poser dans la cible par la session du code |

### Les captures

Ordre : 01 la pièce (13 appareils), 02 envoi à toute la pièce, 03 réception avec Refuser / Accepter,
04 transfert en cours (575 Mo), 05 historique, 06 partage par lien et QR code. Les trois premières font
la carte des résultats de recherche : ce qu'on voit, comment on envoie, comment on reçoit.

Formats, d'après [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
lu le 21.11.2026 : Apple exige au moins une capture « iPhone with Dynamic Island (medium display) »
(1206 × 2622 accepté) ; « large display » (1320 × 2868) est fourni aussi ; le format 6,5 pouces n'est demandé
que si le « large display » manque, il n'est donc pas fourni. iPhone Duo n'est exigé qu'à partir d'avril 2027.

### Les bannières et les visuels « En-tête » et « Résultats de recherche »

D'après [Creative assets specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/creative-assets-specifications/),
faits par `tools/compose-creative.py` : cartes sombres sur le vert de l'icône, chacune avec une phrase en deux
temps (blanc puis gris) et un vrai écran de l'app.

| Fichier | Onglet d'App Store Connect | Contenu |
|---|---|---|
| `app-store-search-3840x2560-<langue>.png` | Résultats de recherche (3:2) | La pièce, l'envoi à toute la pièce |
| `app-store-header-3840x1646-<langue>.png` | En-tête (21:9) | La pièce, l'envoi, la réception |
| `app-store-universal-5244x2950-<langue>.png` | Image universelle (16:9, PNG) | Les mêmes trois cartes |

Apple donne une « zone sûre » centrale pour ces formats (3:2 : 2168 × 1030 à x 836, y 765). Les phrases
des cartes sont au-dessus de cette zone, comme sur le visuel déjà utilisé pour l'autre app : vérifier avec
le bouton « Aperçu » d'App Store Connect qu'elles ne sont pas coupées.

`tools/compose-banner.py` fait en plus `card-16x9-1920x1080` (carte d'événement intégré ou visuel 16:9) et
`link-1200x630` (image de partage du site).

## Ce qui manque avant de soumettre

Bloquant, à faire dans le code (détail dans la note partagée `appstore-constats-pour-le-code.md`) :

1. ~~Lien vers la politique de confidentialité dans l'app~~ : fait par la session du site (Réglages › À propos,
   « Confidentialité » et « Conditions d'utilisation », vu dans `AboutSection.swift`).
2. **`PrivacyInfo.xcprivacy`** dans la cible RoomSend (UserDefaults, raison CA92.1), sinon avertissement
   ITMS-91053 à l'envoi du build.
3. **Version 1.0** : `MARKETING_VERSION` vaut 0.1.0.
4. **Droit multicast** `com.apple.developer.networking.multicast` à demander à Apple
   ([page du droit](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.networking.multicast)).
   Sans lui, sur un vrai iPhone, la découverte passe seulement par le balayage du réseau.

À fournir par l'éditeur (rien n'a été inventé) :

| Information | Où elle sert | Ce que j'ai |
|---|---|---|
| Nom légal de l'éditeur, nom du vendeur | Compte développeur, copyright | **Kiye Mateus, Genève, Suisse**, confirmé par Mateus le 21.11.2026. Copyright : « 2026 Kiye Mateus » |
| Courriel et téléphone de contact | Fiche d'assistance, contact App Review | Courriel **mateus@kiye-mateus.com**, confirmé le 21.11.2026 ; téléphone à fournir |
| Domaine | Les quatre URL ci-dessous | **À choisir.** Le site est en ligne sur `roomsend.netlify.app` (/privacy, /terms, /support répondent 200 le 21.11.2026) ; utilisable pour soumettre, mais une adresse en netlify.app ne devrait pas rester l'adresse finale |
| Statut DSA (UE) | App Store Connect › Informations sur l'app | Commerçant ou non : décision de l'éditeur |
| Chiffrement (export) | Questionnaire de conformité | `ITSAppUsesNonExemptEncryption` vaut false dans `Info.plist` ; à confirmer par l'éditeur |

## URL

| Champ App Store Connect | Adresse | Obligatoire |
|---|---|---|
| Marketing URL | `https://<domaine à choisir>/` | Non |
| Privacy Policy URL | `https://<domaine à choisir>/privacy` | Oui |
| Support URL | `https://<domaine à choisir>/support` | Oui, et la page doit donner un vrai contact |
| Conditions (EULA personnalisée, facultatif) | `https://<domaine à choisir>/terms` | Non : sans EULA à soi, celle d'Apple s'applique |

Les pages sont construites par la session du site, avec exactement ces chemins. Elles doivent être en ligne
avant la soumission (règle 2.1 : « fully functional URLs »).

## Ce qui n'est pas vérifié

- **La pièce des captures est en partie mise en scène.** Sur les 13 appareils : 4 sont de vrais RoomSend
  (simulateurs « Ananas Sage », « Witty Melon », et deux simulateurs d'autres sessions, « Abricot Brave »
  et « Melon Calme »), 9 sont des pairs LocalSend émulés sur le Mac par `tools/room-peers.py`. Ils parlent le
  vrai protocole et RoomSend vérifie leur certificat, mais ce ne sont pas des appareils physiques. Les
  transferts, l'historique et la progression sont réels ; les messages, noms de fichiers et photos
  (dégradés dessinés par `tools/make-media.py`) sont du contenu de démonstration.
- **« 1 photo » pour une vidéo** sur la capture 04 : c'est ce que l'app affiche aujourd'hui (bug signalé).
- L'heure de la barre d'état est fixée à 09:41, sauf sur l'historique (heure réelle, pour que les heures
  des envois restent cohérentes).
- Captures faites au simulateur (iPhone 17 Pro Max et iPhone 17, iOS 26.3), pas sur un iPhone réel.
- Textes de, es, it, pt : relus et corrigés le 21.11.2026 par un modèle de langue (un relecteur par langue,
  contre les mots de l'interface de l'app), pas par une personne de langue maternelle.
- Captures et visuels de, es, it, pt : faits le 21.11.2026 au soir, depuis l'app recompilée avec le code
  du moment, dans la même pièce (11 ou 12 appareils selon les simulateurs des autres sessions allumés).
- Effet des mots-clés : inconnu avant la sortie (voir le suivi prévu dans `aso.md`).
- L'icône des bannières est redessinée à plat (`tools/icon.py`), sans l'effet Liquid Glass de la vraie icône.
- Le champ « Nouveautés » n'existe pas pour la première version : les textes sont gardés pour la 1.0.1.

## Pas-à-pas dans App Store Connect

1. **Apps › + › Nouvelle app** : iOS, nom « RoomSend: Wi-Fi File Transfer », langue principale
   English (U.S.), bundle ID `app.roomsend.ios`, SKU au choix (par exemple `roomsend-ios`), accès complet.
2. **Informations sur l'app** : sous-titre (en), catégorie principale Utilitaires, secondaire Productivité,
   droits sur le contenu « non », URL de confidentialité, classification par âge (questionnaire de
   `privacy-and-rating.md`), statut DSA.
3. **Localisations** : ajouter French (France), German, Spanish (Spain), Italian, Portuguese (Portugal),
   puis coller nom et sous-titre de chaque `metadata/<langue>.md`.
4. **Prix et disponibilité** : gratuit, pays au choix.
5. **Confidentialité de l'app** : « Non, nous ne collectons pas de données ». Publier.
6. **Version 1.0** (une fois par langue) : captures (glisser `6.9-inch-1320x2868` dans « iPhone with Dynamic
   Island, large display » et `6.3-inch-1206x2622` dans « medium display », le dossier de chaque langue dans
   sa localisation), texte promotionnel, description, mots-clés, URL d'assistance et de marketing. Visuels
   « En-tête » et « Résultats de recherche » : `banner/app-store-header-…` et `banner/app-store-search-…` de
   la même langue, vérifiés avec le bouton « Aperçu ». Copyright : « 2026 Kiye Mateus ».
7. **Build** : dans Xcode, Product › Archive sur « Any iOS Device », puis Distribute App › App Store Connect.
   Le build apparaît dans TestFlight après traitement ; le choisir dans la version.
8. **Conformité export** : répondre selon l'`Info.plist` une fois la question confirmée.
9. **Informations pour la revue** : « connexion requise » décochée, contact, notes de `review-notes.md`.
10. **Ajouter pour la revue**, puis soumettre. Choisir la publication manuelle pour garder la main sur la date.

## Refaire le dossier

```bash
python3 appstore/tools/check-metadata.py
```

```bash
python3 appstore/tools/compose.py
```

```bash
python3 appstore/tools/compose-creative.py
```

```bash
python3 appstore/tools/compose-banner.py
```

Pour refaire les écrans bruts : `appstore/tools/sim-setup.sh build`, `create`, puis `lang <code> dark` ;
lancer `room-peers.py serve` pour remplir la pièce et `room-activity.sh 127.0.0.1:53317` pour l'historique ;
faire chaque geste dans l'app (taper un nom, choisir les photos, etc.) et prendre l'écran avec
`sim-setup.sh shot <nom>`. Les gestes restent à la main : aucune cible de test d'interface n'existe dans le
projet, et `RoomSend/` n'est pas modifié ici. Fermer les pairs et les simulateurs après coup : tous les
simulateurs partagent le réseau du Mac et se voient entre eux.
