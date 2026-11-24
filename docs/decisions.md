# RoomSend, registre des décisions

## ADR 1 : une app iOS native, compatible avec LocalSend (21.11.2026)

- **Question.** Refaire le design de LocalSend dans son code Flutter, ou écrire une app iOS à part ?
- **Constats.** L'app officielle est en Flutter (Material sur iPhone). Quatre clients iOS natifs existent
  (LocalSend+, Filz!, Slip, localsend_ios) : testés au simulateur le 21.11, tous au design iOS de base,
  tous à 0 étoile, aucun sur l'App Store. La règle App Store 4.1(a) refuse une copie dont seuls le nom ou
  l'interface changent ; une app GPL publiée par un tiers a déjà été retirée (VLC, janvier 2011).
- **Décision.** SwiftUI pur, iOS 26 minimum, nom RoomSend (libre sur l'App Store américain le 21.11 ;
  marques et domaines non vérifiés). Le protocole LocalSend v2.2 est réécrit en Swift : découverte en
  multicast UDP, envoi par l'API Upload en HTTPS. Aucune ligne du code de LocalSend n'est reprise.
- **Vérification.** Le 21.11, envoi réel d'un texte vers Slip (second simulateur) : reçu, certificat
  vérifié contre l'empreinte annoncée.

## ADR 2 : la direction de design (21.11.2026)

- **Question.** Quel niveau et quel langage visuel, sans recopier une app existante ?
- **Sources.** Revolut sur Mobbin (8 accueils, 2 parcours d'envoi), MetaMask sur l'App Store (5 captures,
  absent de Mobbin), les jetons de 4.5 (`Core/Design`, palette « Breath »).
- **Principes retenus, pas les écrans.**
  - Un seul élément énorme par écran (le solde chez Revolut ; ici le nombre d'appareils autour), le reste
    sur trois niveaux de texte. Le chiffre et son unité dans une seule phrase localisée, le chiffre en
    SF Pro condensée très grasse.
  - Interface neutre ; la couleur vient du contenu. Chaque appareil a un avatar calculé depuis son
    empreinte, comme MetaMask le fait depuis une adresse.
  - Blocs opaques aux couleurs de 4.5, sans contour ni verre ; le verre reste sur les boutons (ADR 3 de 4.5).
  - Confirmation centrée sur l'objet (« Un message », « 3 photos »), détails groupés, deux pilules.
  - Barre d'onglets d'Apple.
- **Écarté.** Le grand champ de couleur en haut de Revolut : c'est sa signature, pas un principe.

## ADR 3 : apparence au choix (21.11.2026)

Auto, Clair ou Sombre dans Réglages, appliqué à la racine (`preferredColorScheme`) ; Auto suit l'iPhone.

## ADR 4 : recevoir avec un serveur à nous (21.11.2026)

- **Décision.** Serveur HTTP/1.1 minimal sur `NWListener`, une requête par connexion, TLS avec un
  certificat P-256 auto-signé créé une fois (swift-certificates, paquet d'Apple) et gardé dans le
  trousseau. L'empreinte annoncée est le SHA-256 du certificat. Sans trousseau (simulateur non signé),
  repli en HTTP, signalé par le cadenas ouvert chez les autres.
- **Vérifié le 21.11.** Texte reçu de Slip ; fichier reçu par une vraie requête LocalSend (proposition,
  acceptation, envoi, faux jeton refusé en 403) ; sur l'iPhone 15 Pro Max, `info` répond en HTTPS et le
  certificat présenté a exactement l'empreinte annoncée.

## ADR 5 : l'icône (21.11.2026)

Piste G retenue par Mateus après quatre séries : la pièce en cadre ouvert, une traînée de points, le disque
qui sort par le coin. Vert dégradé en clair (le vert « actif » de l'app, la couleur de communication
d'Apple), vert sur noir en sombre. Écartés : l'orange (sans lien avec la marque), les carrés superposés
(trop proches de Raccourcis), le camembert, la porte (lue comme un « n »). Source : `docs/icone-source.py`.

## ADR 6 : six langues dans le catalogue (21.11.2026)

Aucun texte d'interface en dur : clés dans `Localizable.xcstrings` et `InfoPlist.xcstrings`, générées par
`tools/strings.py` à partir de `tools/translations.py`, qui refuse une clé non traduite. Anglais (base),
français, allemand, espagnol, italien, portugais. Les mots des noms d'appareils et leur ordre sont dans le
catalogue ; chaque langue accorde ses adjectifs au genre de ses fruits.

## ADR 7 : la langue se choisit dans l'app, tout de suite (21.11.2026)

- **Question.** Où changer de langue ? Renvoyer vers Réglages › RoomSend ouvrait la racine des
  Réglages au simulateur, et iOS n'y montre la langue par app que si plusieurs langues sont ajoutées.
- **Décision.** Un bloc « Langue » dans Réglages : Auto et les six langues, chacune écrite dans sa
  langue. Le choix est rangé où iOS garde la langue d'une app (`AppleLanguages` dans les préférences de
  l'app) : dialogues système et lancements suivants le suivent, et Réglages › RoomSend reste d'accord.
  L'interface change à l'instant par `\.locale` à la racine ; le texte construit hors des vues (noms de
  photos, résumés, page du lien) passe par `Localized`, qui lit la table de la langue choisie.
- **Vérifié le 21.11.** Allemand appliqué à tout l'écran et à la barre d'onglets sans relancer, gardé
  après relance, retour au français avec Auto.

## ADR 8 : le partage par lien sur un port libre (21.11.2026)

Le second serveur demande un port au système au lieu de « port + 1 », et l'adresse n'apparaît qu'une
fois l'écoute prête. Vérifié : page servie, JPEG de 4,1 Mo téléchargé intact, 404 sur un chemin
inconnu, plus de réponse après « Arrêter le partage ».

## ADR 9 : l'ajout à la main marche dans les deux sens (21.11.2026)

La fenêtre « + » montre en haut l'adresse de cet appareil, avec Copier, puis le champ pour celle de
l'autre : deux personnes ouvrent la même fenêtre et se lisent l'une l'autre. L'adresse accepte un port
(« 192.168.1.20:53318 ») et ne montre le sien que s'il n'est pas 53317. Le réseau du partage de connexion
(`bridge100`) compte comme un Wi-Fi. Vérifié : ajout du premier simulateur par adresse et port depuis le
second, 13 cas de saisie (octet hors limite, port 0 ou 70000, signes) refusés ou acceptés à raison.
