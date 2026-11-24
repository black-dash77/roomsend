# Site de RoomSend

En ligne : **https://roomsend.netlify.app** (projet Netlify « roomsend », équipe kiye-mateus7).
Pages fixées pour la fiche App Store : `/privacy`, `/terms`, `/support` (anglais), et `/fr/privacy/`,
`/de/…`, `/es/…`, `/it/…`, `/pt/…`. Déployé le 21 novembre 2026.

## Ce qui est prêt

- Quatre pages en six langues (24 pages), plus une page 404. Le visiteur qui arrive sur une page
  anglaise est envoyé vers sa langue s'il n'a jamais choisi ; le sélecteur garde son choix.
- Clair et sombre selon le système, bouton pour basculer. Fond `#FFFFFF` ou `#000000`, blocs et textes
  aux couleurs de `RoomSend/Core/Design`, police du système (SF Pro sur les appareils Apple).
- Accueil, sept démonstrations, chacune pilotée par de vraies captures :
  - la pièce qui se remplit (curseur, grand chiffre, avatars, 5 captures) ;
  - le carrousel des destinataires qu'on fait glisser, le téléphone suit le centre ;
  - un envoi qui progresse, un envoi reçu à accepter ou refuser ;
  - clair et sombre côte à côte, ligne à faire glisser ;
  - les six langues de l'app, d'un toucher.
- Aide : vérification guidée « Personne dans la pièce ? », questions fréquentes, adresse de contact.
- Confidentialité et Conditions : le texte de `tools/legal/`, le même que dans l'app, avec la capture
  de l'écran de l'app qui le montre.
- `prefers-reduced-motion` : aucune démo ne joue seule, chaque changement est immédiat.
- Titre, description, image de partage et `hreflang` par page ; favicons ; `robots.txt` ;
  `sitemap.xml` ; `_headers` (CSP stricte sans `unsafe-inline`, HSTS, `nosniff`, pas d'iframe).
- Poids : page d'accueil 33 Ko de HTML, 29 Ko de CSS, 23 Ko de JS ; captures en WebP, 27 Ko en moyenne,
  chargées à la demande. Aucun cookie, aucune mesure d'audience, aucune ressource d'un autre site.

## Les captures

Toutes viennent de l'app compilée depuis ce dépôt, au simulateur iPhone 17 Pro (iOS 26.3) « RoomSend
Site », barre d'état fixée à 9:41. Aucune n'est retouchée, seulement réduite (`tools/shots.py`).

- Les appareils « Witty Peach », « Lucky Lime », « Bright Plum » et « Sunny Fig » sont de vrais pairs
  LocalSend v2.2 lancés sur le Mac (`tools/capture/peers.py`) : certificat, multicast, HTTPS, réception
  ralentie pour voir la progression. Les envois et la réception capturés ont eu lieu.
- « Abricot Brave » et « Melon Calme » sont les RoomSend des simulateurs de Mateus, laissés à sa demande.
- Les avatars du site sont calculés par le code de l'app (`tools/avatars/`, compilé pour le simulateur).

Refaire les captures : `tools/capture/capture.sh install <RoomSend.app>`, puis `tools/capture/rooms.sh`
(écran Pièce, automatique), puis `open.sh`, `step.sh` et `frames.sh` pour les feuilles (touchers au
simulateur). Mettre à jour `src/shots/manifest.json` (ordre du carrousel par langue), puis
`python3 tools/shots.py` et `tools/avatars/run.sh <udid>`.

## Construire et déployer

```bash
python3 build.py
```

Python 3.9+ et Pillow. Le build refuse une traduction manquante, un tiret cadratin, une identité
d'éditeur vide ou un lien vers un fichier absent. Sortie : `public/`.

```bash
python3 tools/serve.py public 8766
```

Déploiement : depuis `site/public`, avec l'outil Netlify (`deploy-site`, projet
`46369244-71fc-4db0-9a7c-9f53a709f17f`), qui publie le dossier tel quel. `public/` ne contient aucune
clé : les clés de test des pairs restent dans `tools/capture/.state/`.

## Ce qui manque

- **Le lien App Store.** Tant que l'app n'est pas publiée, le site dit « Bientôt sur l'App Store » sans
  bouton. Une fois en ligne : `ROOMSEND_APP_STORE_URL=… python3 build.py`, et remplacer la pilule par le
  badge officiel d'Apple (à télécharger sur Apple Marketing Tools).
- **Un domaine.** L'adresse netlify.app reste provisoire (choix de Mateus). Libres au 21.11.2026
  (registres RDAP) : `roomsend.app`, `roomsend.ch`, `roomsend.io` ; `roomsend.com` est pris depuis le
  2 août 2025. Après achat : `ROOMSEND_SITE_URL=https://… python3 build.py`, domaine ajouté dans
  Netlify, et l'adresse `siteAddress` de `RoomSend/Features/Settings/LegalText.swift` à changer.
- **L'adresse postale complète.** L'éditeur est « Kiye Mateus, Genève, Suisse » avec un e-mail. La loi
  suisse sur la concurrence déloyale (art. 3 al. 1 let. s LCD) demande une adresse de contact pour le
  commerce en ligne ; une rue et un numéro dans `tools/legal/publisher.py` la rendraient complète.
- **L'hébergeur.** Les pages de confidentialité nomment Netlify (journaux, durées, Data Privacy
  Framework, d'après l'accord de traitement de Netlify du 13 novembre 2026). Changer d'hébergeur
  demande de réécrire la section « Ce site » dans les six fichiers de `tools/legal/`.

## Contrôles

Liste 4 de `anti-ia.md` : 404 ✓, titres et descriptions ✓, image de partage ✓, favicons ✓, robots et
sitemap ✓, textes alternatifs ✓, 375 px vérifié ✓, images compressées ✓, confidentialité et
conditions remplies ✓, contact réel ✓. Sans objet : formulaires et confirmation (aucun formulaire),
bandeau cookies (aucun cookie). Écart voulu : pas de mesure d'audience, la promesse du produit est de
ne rien collecter. Le bouton d'action du premier écran attend le lien App Store.

Les 20 verrous de `securite-checklist.md` :

| # | Verrou | Statut |
|---|---|---|
| 1, 2, 7 | Clés et `.env` | Aucune clé dans `public/` (vérifié par recherche de clé privée) |
| 3, 5, 9, 16, 19 | Connexion, mots de passe, sessions, e-mail confirmé | Sans objet, aucun compte |
| 4, 20 | RLS, sauvegarde de base | Sans objet, aucune base |
| 6, 10, 11, 12, 13, 17 | Serveur, entrées, envois, CORS, webhooks | Sans objet, site statique |
| 8 | HTTPS, HSTS | Netlify force HTTPS, `Strict-Transport-Security` vérifié en ligne |
| 14 | Erreurs détaillées | Sans objet, aucun code serveur ; 404 propre |
| 15 | Journaux | Aucun `console.*` dans `src/js` |
| 18 | Dépendances | Aucune dépendance côté navigateur ; Pillow pour le build seulement |

## Décisions

| Question | Constat | Décision | Vérifié |
|---|---|---|---|
| Quel design ? | Mateus : « le design de RoomSend, Apple-like », pas celui de 4.5 | Jetons de l'app, une idée par section, un élément énorme, blocs opaques | Rendu 375 et 1440 px, clair et sombre |
| Démos sans démo inventée | Les écrans doivent être de vraies captures | Chaque interaction échange des captures réelles ; seuls le carrousel et les avatars sont redessinés, avec le code de l'app | Avatars identiques aux captures |
| Mentions légales | LPD art. 19 (identité, finalité, destinataires, pays) ; RGPD art. 13 ; LCD art. 3 s | Textes tirés du code : rien de collecté par l'app, journaux de l'hébergeur décrits | Relu dans les six langues, affiché dans l'app |
| Polices | Aucune ressource tierce promise | Police du système, aucune police chargée | CSP sans `font-src` externe |
