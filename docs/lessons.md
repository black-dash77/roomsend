# RoomSend, leçons

## 21.11.2026 : un `Menu` en ligne de liste plante sous Swift 6

- **Erreur.** Chaque appareil de la liste était un `Menu`. Avec l'isolation par défaut sur le MainActor,
  SwiftUI a évalué le contenu du `ForEach` sur son fil `AsyncRenderer` : l'app s'est arrêtée
  (`_dispatch_assert_queue_fail`).
- **Règle.** Une ligne de liste est un `Button` ; les choix qui suivent s'ouvrent dans une feuille à nous.

## 21.11.2026 : deux présentations ne se superposent pas

- **Erreur.** La feuille d'envoi s'ouvrait pendant que celle du message se fermait encore : iOS l'ignorait.
- **Règle.** Ce qu'une feuille produit est remis dans son `onDismiss`, jamais pendant sa fermeture.

## 21.11.2026 : tester sur un port libre

- **Erreur.** Un autre client LocalSend resté en arrière-plan dans un simulateur tenait le port 53317 :
  l'envoi attendait une réponse qui ne venait jamais.
- **Règle.** Avant un test d'envoi, fermer les autres clients LocalSend des simulateurs.

## 21.11.2026 : une conformité `Codable` coupée en deux fichiers fait planter le compilateur

- **Erreur.** `PrepareUploadResponse` était `Decodable` dans un fichier et `Encodable` (avec ses
  `CodingKeys` privées) dans un autre : Swift 6.2 s'arrête en « Global is external ».
- **Règle.** Une conformité Codable se déclare en entier, au même endroit.

## 21.11.2026 : deux serveurs sur un même Mac partagent le port

- **Constat.** Les simulateurs partagent la carte réseau du Mac : deux apps ne peuvent pas écouter 53317.
- **Règle.** Pour tester la réception au simulateur, donner un autre port à RoomSend (réglage Port).

## 21.11.2026 : `URL.path()` est encodé, le système de fichiers ne l'est pas

- **Erreur.** Un fichier reçu nommé « test-photo 2.jpg » était créé sous « test-photo%202.jpg » :
  `createFile(atPath: url.path())` recevait le chemin encodé, puis l'écriture par URL ne trouvait pas
  le fichier. Tout nom avec une espace ou un accent finissait en 500.
- **Règle.** Un chemin passé à `FileManager` est `url.path(percentEncoded: false)`. Tester la
  réception avec un nom comme « Été au lac 2026.jpg ».

## 21.11.2026 : une réponse réseau n'attend jamais une décision de la personne

- **Erreur.** Après le dernier fichier, la réponse au `upload` attendait le rangement dans Photos, donc
  la fenêtre d'autorisation : l'expéditeur restait bloqué puis échouait alors que tout était arrivé.
- **Règle.** On répond d'abord ; ce qui peut attendre un geste (autorisation, choix) part dans sa
  propre tâche.

## 21.11.2026 : un défilement demandé avant la mise en page est ignoré

- **Erreur.** Le carrousel des destinataires, créé avec un choix déjà fait (appareil touché, premier
  appareil trouvé), restait centré sur un autre : `scrollPosition` et `scrollTo` arrivaient avant que les
  éléments aient leur place, avec des marges qui dépendent de la largeur.
- **Règle.** Centrer après la mise en page en cours (`Task`), à l'apparition, au changement de largeur
  et quand un choix arrive après coup ; vérifier le centre à l'écran, pas seulement l'état.

## 21.11.2026 : ce qui n'est connu que par son adresse doit être redemandé

- **Erreur.** « Rafraîchir » vidait la pièce : un appareil ajouté par adresse IP ne répond ni au
  multicast ni au balayage, il disparaissait jusqu'au retour sur l'écran.
- **Règle.** Chaque rafraîchissement redemande aussi les favoris directement.

## 21.11.2026 : un second serveur prend un port choisi par le système

- **Erreur.** Le partage par lien écoutait sur « port + 1 » ; ce port était pris (ici par l'autre
  simulateur) et la feuille montrait quand même une adresse qui ne répondait pas.
- **Règle.** Port `.any`, adresse affichée seulement quand le serveur écoute, message si l'écoute échoue.

## 21.11.2026 : le banc de test a ses propres pièges

- **Constat.** Au simulateur, un toucher instantané ne bascule pas un interrupteur d'iOS 26 (il faut
  ~0,2 s) ; `simctl pbcopy` encode en Mac Roman ; l'outil de saisie laisse un presse-papiers illisible
  par `UIPasteboard.string` ; deux simulateurs partagent l'IP du Mac.
- **Règle.** Avant de conclure à un bug d'interface, refaire le geste avec un appui réel et un
  presse-papiers rempli par l'app elle-même.

## 21.11.2026 : `simctl spawn defaults write <bundle id>` n'atteint pas l'app

- **Erreur.** Pour préparer les captures App Store, l'apparence et le code PIN étaient écrits avec
  `xcrun simctl spawn <udid> defaults write app.roomsend.ios …` : l'app ne les voyait pas, elle lit les
  préférences de son propre conteneur.
- **Règle.** Écrire dans `$(xcrun simctl get_app_container <udid> app.roomsend.ios data)/Library/Preferences/app.roomsend.ios`,
  app arrêtée, ou passer par les Réglages de l'app (`appstore/tools/sim-setup.sh` le fait).
