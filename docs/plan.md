# RoomSend, plan des fonctions restantes (21.11.2026) : tout est fait, voir decisions.md

Demande : « fais tout ce qui n'est pas encore fait ». Ordre de travail, chaque étape compilée et vérifiée
au simulateur avant la suivante.

1. **Icône** : piste G (pièce en cadre ouvert, toi dedans, trajet en points, disque qui sort), vert sur
   fond vert dégradé, noir en sombre. Source : `docs/icone-source.py`, rendus `docs/icone-*.png`.
   En attente du verdict de Mateus.
2. **Recevoir** (`Core/Server`, `Features/Receive`)
   - Certificat auto-signé P-256 créé une fois (swift-certificates, paquet d'Apple), clé et certificat
     dans le trousseau, `SecIdentity` pour TLS. Empreinte = SHA-256 du certificat DER.
   - Serveur HTTP/1.1 minimal sur `NWListener` (TLS ou non), une requête par connexion.
   - Routes v2 : `register`, `info`, `prepare-upload`, `upload`, `cancel`.
   - Fenêtre d'arrivée façon MetaMask : l'objet au centre, l'expéditeur, Refuser / Accepter.
   - Réglages : réception automatique, code PIN exigé, photos dans Photos. Fichiers dans `Documents/`
     (visibles dans l'app Fichiers). Message texte : feuille avec Copier.
   - Historique : envois et réceptions.
3. **Découverte** : réponse aux annonces par `POST /register` ; balayage HTTP du sous-réseau /24 en
   secours (protocole 3.2) au rafraîchissement et quand le multicast échoue.
4. **Envoi** : code PIN demandé sur 401, annulation (`/cancel`), progression en octets, « Toute la
   pièce » dans le carrousel.
5. **Favoris** : étoile sur un appareil, favoris en tête ; ajout par adresse IP.
6. **Partage** : extension de partage (groupe d'apps, boîte d'arrivée lue à l'ouverture) ; partage par
   lien (page web servie par RoomSend).
7. **Réglages avancés** : nom modifiable, port, chiffrement, découverte de secours ; langues de, es, it, pt.
8. Vérification complète au simulateur (paire « RoomSend Pair » avec Slip), puis installation iPhone.
