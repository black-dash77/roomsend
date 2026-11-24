# RoomSend, confidentialité App Store et classification par âge

Réponses à saisir dans App Store Connect, chacune justifiée par le code de ce dossier (lu le 21.11.2026).

Sources Apple : [App privacy details on the App Store](https://developer.apple.com/app-store/app-privacy-details/),
[Age ratings values and definitions](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions),
[App Review Guidelines 5.1.1](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage).

## 1. App Privacy (« Confidentialité de l'app »)

### Réponse : « Non, nous ne collectons pas de données depuis cette app »

Apple définit la collecte comme le fait de « transmitting data off the device in a way that allows you
and/or your third-party partners to access it for a period longer than what is necessary to service the
transmitted request in real time ». Rien dans RoomSend n'arrive chez l'éditeur ni chez un tiers :

| Vérification | Ce que montre le code |
|---|---|
| Serveur de l'éditeur | Aucun. Aucune URL internet dans `RoomSend/` ni `RoomSendShare/` ; ATS n'ouvre que le réseau local (`NSAllowsLocalNetworking`). |
| Kits tiers | `swift-certificates`, `swift-asn1` et `swift-crypto` (paquets open source d'Apple) : création du certificat TLS, aucune collecte. Pas de SDK d'analyse, de publicité ni de crash. |
| Journal | `Log.swift` écrit dans `OSLog`, sur l'appareil. |
| Transferts | De l'iPhone vers l'appareil choisi par la personne, sur le Wi-Fi local (`TransferService`, `HTTPServer`). L'éditeur n'y a jamais accès. |

### Suivi (« Tracking ») : non

Aucun identifiant publicitaire, aucune liaison avec des données tierces, aucun courtier. Pas de fenêtre
App Tracking Transparency à prévoir.

### Ce qui reste sur l'iPhone (à écrire dans la politique de confidentialité, pas dans App Privacy)

| Donnée | Où | Pourquoi |
|---|---|---|
| Nom affiché, empreinte, modèle (« iPhone ») | `UserDefaults` (`IdentityStore`) | Se présenter aux autres appareils |
| Clé privée et certificat TLS | Trousseau (`TLSIdentityStore`) | Chiffrer les transferts reçus |
| Historique (nom de l'autre appareil, nombre et taille des éléments, date) | `UserDefaults` (`HistoryStore`) | Onglet Historique |
| Favoris (infos de l'appareil et son adresse IP locale) | `UserDefaults` (`FavoritesStore`) | Retrouver un appareil ajouté à la main |
| Réglages, code PIN, langue, apparence | `UserDefaults` | Réglages |
| Fichiers reçus | Dossier Documents de l'app (visible dans Fichiers) | Réception |
| Photos et vidéos reçues | Photothèque, si « Photos dans Photos » est actif | Réception |
| Éléments partagés depuis l'extension | Conteneur du groupe d'apps, vidé à l'ouverture (`Inbox`) | Extension de partage |

Supprimer l'app efface tout cela, sauf ce qui a été rangé dans Photos ou déplacé ailleurs par la personne.

### Ce que voient les autres appareils du même Wi-Fi

À écrire aussi dans la politique : quand « Visible sur ce Wi-Fi » est actif, RoomSend annonce sur le réseau
local son nom affiché, son modèle (« iPhone »), son empreinte et son port (protocole LocalSend v2.2,
`DiscoveryService`). Le balayage de secours envoie cette même présentation à chaque adresse du /24. Le
partage par lien sert les fichiers choisis en HTTP simple à tout navigateur du Wi-Fi qui a l'adresse,
jusqu'à « Arrêter le partage » ou jusqu'à ce que l'app passe en arrière-plan (`ShareLink`, `AppModel.goOffline`). Ce ne sont pas des données collectées au sens d'Apple.

### Manifeste de confidentialité

L'app lit `UserDefaults`, une API à raison déclarée : il faut un `PrivacyInfo.xcprivacy` (raison `CA92.1`).
Brouillon prêt dans `handoff/PrivacyInfo.xcprivacy`, à ajouter à la cible RoomSend par la session du code.

## 2. Classification par âge

Questionnaire actuel d'App Store Connect (catégories d'Apple), réponses proposées :

| Catégorie | Élément | Réponse | Justification |
|---|---|---|---|
| In-App Controls | Parental Controls | Non | Aucun contrôle parental dans l'app |
| | Age Assurance | Non | Aucune vérification d'âge |
| Capabilities | Unrestricted Web Access | Non | Aucun navigateur intégré ; le lien est servi aux autres, pas ouvert dans l'app |
| | User-Generated Content | Non | Pas de diffusion large : un envoi part vers des appareils choisis du même Wi-Fi |
| | Social Media | Non | Ni fil, ni « j'aime », ni découverte de contenu |
| | Messaging and Chat | **Oui** | On peut envoyer un texte à un appareil proche, ce qui entre dans « directly communicate with one another… text » |
| | Shared Location | Non | Aucune localisation |
| | Advertising | Non | Aucune publicité |
| Mature Themes, Medical or Wellness, Sexuality or Nudity, Violence | tous les éléments | Aucun | L'app ne contient aucun contenu de ce type |
| Chance-Based Activities | tous les éléments | Aucun | Ni jeu, ni concours, ni coffre |

**Résultat attendu : 4+.** Dans le tableau d'Apple, « Messaging and chat » reste compatible avec 4+.
Made for Kids : non.

À savoir pour la revue : le contenu reçu vient d'autres appareils du même réseau. Les garde-fous existants
sont à citer si Apple pose la question de la règle 1.2 : chaque envoi de fichiers se refuse, « Visible sur ce
Wi-Fi » se coupe, un code PIN peut être exigé. Un message texte, lui, s'affiche sans demande préalable
(`ReceiveCoordinator`, cas `.message`).

## 3. Autres déclarations d'App Store Connect

| Question | Réponse proposée | Vérifié ? |
|---|---|---|
| Chiffrement (export) | `ITSAppUsesNonExemptEncryption = false` dans `Info.plist` : TLS du système et algorithmes standard. | Non vérifié juridiquement. À confirmer par l'éditeur avec la page d'Apple [Complying with encryption export regulations](https://developer.apple.com/documentation/security/complying-with-encryption-export-regulations). |
| Contenus de tiers (Content Rights) | Non : l'app ne contient ni ne montre de contenu tiers. | Oui, d'après le code. |
| Digital Services Act (UE) | Statut de commerçant ou non à déclarer par l'éditeur. Commerçant : adresse, téléphone et courriel s'affichent sur la fiche. | Décision de l'éditeur. |
