"""Politique de confidentialité et conditions d'utilisation, en français.

Écrites d'après le code de RoomSend 0.1.0 : découverte et transferts sur le réseau local,
aucun serveur, aucune connexion à Internet. Toute nouvelle fonction qui touche aux données
doit être reportée ici, puis dans les cinq autres langues.
"""

PRIVACY = {
    "title": "Politique de confidentialité",
    "updated": "Dernière mise à jour : 21 novembre 2026.",
    "intro": "RoomSend envoie des photos, des fichiers et des textes aux appareils du même réseau local. "
    "Il n'y a ni compte ni serveur : ce que vous envoyez va directement de votre appareil à celui que vous "
    "choisissez, et nous n'en recevons rien. Cette page décrit ce que l'app fait de vos données, puis ce que "
    "ce site enregistre.",
    "sections": [
        ("Qui est responsable", [
            "{name}, {address}. Pour toute question sur vos données : [{email}](mailto:{email}).",
        ]),
        ("Ce que nous recevons de l'app", [
            "Rien. RoomSend ne contient ni mesure d'audience, ni publicité, ni traceur, ni service tiers. "
            "L'app ne se connecte pas à Internet : elle ne parle qu'aux appareils de votre réseau local. "
            "Elle ne demande ni compte, ni adresse e-mail, ni numéro de téléphone.",
            "Si vous avez accepté dans iOS de partager vos analyses avec les développeurs, Apple peut nous "
            "fournir des rapports de plantage et des statistiques globales, sans votre identité. Ce choix se "
            "règle dans Réglages, Confidentialité et sécurité, Analyses et améliorations.",
        ]),
        ("Ce que voient les appareils de votre réseau", [
            "Pour être trouvé, RoomSend annonce sur le réseau local le nom de votre appareil (modifiable dans "
            "Réglages), son modèle (« iPhone »), l'empreinte de son certificat et le port qu'il écoute. Ces "
            "informations suivent le protocole LocalSend. Les appareils compatibles du même réseau les voient "
            "tant que « Visible sur ce Wi-Fi » est activé.",
            "Quand « Balayer le réseau » est activé, RoomSend envoie aussi ces informations à chaque adresse de "
            "votre sous-réseau, pour trouver les appareils que la recherche habituelle ne voit pas. Sur un Wi-Fi "
            "public, désactivez « Visible sur ce Wi-Fi » pour ne plus être vu.",
        ]),
        ("Ce que vous envoyez et recevez", [
            "Les photos, fichiers et textes passent directement d'un appareil à l'autre sur votre réseau local, "
            "sans passer par nous ni par Internet. Par défaut, ils sont chiffrés en HTTPS, et RoomSend vérifie "
            "que le certificat de l'autre appareil correspond à l'empreinte qu'il a annoncée. Si le chiffrement "
            "est désactivé sur l'un des deux appareils, le transfert se fait en HTTP simple, sans chiffrement, "
            "et un cadenas ouvert le signale.",
            "Ce qu'on vous envoie n'est enregistré qu'après votre accord, sauf si vous activez « Accepter "
            "automatiquement ». Vous pouvez aussi exiger un code PIN. Les fichiers reçus sont rangés dans le "
            "dossier RoomSend de l'app Fichiers.",
            "L'appareil qui reçoit garde ce que vous lui envoyez et en fait ce que son propriétaire veut : "
            "n'envoyez qu'à des appareils que vous connaissez.",
        ]),
        ("Le partage par lien", [
            "« Partager par lien » sert les éléments choisis sur une page web, en HTTP simple, sans chiffrement "
            "ni mot de passe. Toute personne du même réseau qui ouvre l'adresse peut les télécharger tant que le "
            "partage reste ouvert. Il s'arrête quand vous touchez « Arrêter le partage » ou quand vous quittez "
            "RoomSend.",
        ]),
        ("Les deux autorisations", [
            [
                "Réseau local : pour trouver les appareils de votre Wi-Fi et échanger avec eux. Sans elle, "
                "RoomSend ne peut ni envoyer ni recevoir.",
                "Photos, en ajout seulement : pour ranger dans votre photothèque les photos et vidéos reçues, si "
                "« Photos dans Photos » est activé. RoomSend ne peut pas lire votre photothèque. Quand vous "
                "choisissez des photos à envoyer, le sélecteur d'iOS ne lui donne que celles que vous touchez.",
            ],
        ]),
        ("Ce qui reste sur votre iPhone", [
            [
                "Le nom de l'appareil et vos réglages.",
                "Vos favoris : le nom, l'empreinte et l'adresse locale de chaque appareil mis en favori.",
                "L'historique des 200 derniers transferts : le sens, l'appareil, le nombre d'éléments, la taille "
                "et la date. Ni le nom ni le contenu des fichiers n'y figurent.",
                "Le certificat de l'appareil et sa clé privée, dans le trousseau d'iOS.",
                "Les éléments partagés depuis une autre app, le temps que RoomSend s'ouvre. Ils sont effacés "
                "ensuite.",
            ],
            "Rien de tout cela ne nous est transmis. Ces données font partie des sauvegardes de l'iPhone si "
            "vous les avez activées. Supprimer l'app efface ses réglages, son historique et ses fichiers. iOS "
            "peut garder le certificat dans le trousseau après la suppression : il ne porte que le nom "
            "« RoomSend ». Les photos rangées dans Photos y restent.",
        ]),
        ("Ce site", [
            "Le site est hébergé par Netlify, Inc., 101 2nd Street, San Francisco, CA 94105, États-Unis. "
            "Quand vous ouvrez une page, Netlify enregistre dans ses journaux techniques votre adresse IP, la "
            "page demandée, la date et l'heure, et ce que votre navigateur envoie (son type, votre système). "
            "Ces journaux servent à livrer les pages et à protéger le site contre les abus. Sans eux, la page "
            "ne peut pas vous être envoyée. Base légale : notre intérêt légitime à faire fonctionner un site "
            "sûr (art. 6, par. 1, let. f RGPD).",
            "D'après ses engagements contractuels, Netlify garde les journaux de trafic 30 jours en ligne et "
            "jusqu'à 13 mois en archive, et les journaux de sécurité jusqu'à un an en ligne et six ans en "
            "archive. Ces données sont traitées aux États-Unis. Netlify est certifiée selon le Data Privacy "
            "Framework entre les États-Unis et l'Union européenne et entre les États-Unis et la Suisse, jugés "
            "adéquats par la Commission européenne le 10 juillet 2023 et par le Conseil fédéral le 14 août 2024.",
            "Le site n'utilise ni cookie, ni mesure d'audience, ni police ou script venus d'autres sites. Il "
            "garde seulement dans votre navigateur la langue et l'apparence que vous choisissez, pour vous les "
            "rendre à la visite suivante. Vous les effacez avec les données du site, dans votre navigateur.",
            "Si vous nous écrivez, nous utilisons votre adresse et votre message pour vous répondre. Ils restent "
            "chez notre fournisseur de messagerie le temps nécessaire pour traiter votre demande.",
        ]),
        ("Vos droits", [
            "Vous pouvez demander l'accès à vos données, leur rectification ou leur effacement, la limitation "
            "de leur traitement, vous y opposer et demander leur portabilité (art. 15 à 21 RGPD, art. 25 à 32 "
            "LPD). Comme l'app ne nous envoie rien, nous ne détenons sur vous que vos éventuels e-mails ; pour "
            "les journaux du site, nous transmettons votre demande à Netlify. Écrivez à [{email}](mailto:{email}).",
            "Aucune décision automatisée n'est prise à votre sujet. Vous pouvez porter plainte auprès du "
            "Préposé fédéral à la protection des données et à la transparence (PFPDT), à Berne, ou, si vous "
            "vivez dans l'Union européenne, auprès de l'autorité de protection des données de votre pays.",
        ]),
        ("Modifications", [
            "Si l'app ou le site changent leur façon de traiter les données, nous mettons cette page à jour, "
            "ici et dans l'app, avec sa date.",
        ]),
    ],
}

TERMS = {
    "title": "Conditions d'utilisation",
    "updated": "Dernière mise à jour : 21 novembre 2026.",
    "intro": "Ces conditions s'appliquent à l'app RoomSend et à ce site. En utilisant RoomSend, vous les "
    "acceptez.",
    "sections": [
        ("L'éditeur", [
            "{name}, {address}. Contact : [{email}](mailto:{email}).",
        ]),
        ("Le service", [
            "RoomSend est une app gratuite pour iPhone qui envoie des photos, des fichiers et des textes aux "
            "appareils du même réseau local. Elle suit le protocole public LocalSend et fonctionne avec les "
            "apps LocalSend d'Android, de Windows, de macOS et de Linux. Elle n'a ni compte, ni abonnement, ni "
            "achat intégré, ni publicité.",
        ]),
        ("Licence", [
            "RoomSend vous est concédée selon le [contrat de licence standard d'Apple]"
            "(https://www.apple.com/legal/internet-services/itunes/dev/stdeula/). Ces conditions le "
            "complètent. En cas de contradiction, le contrat d'Apple l'emporte.",
        ]),
        ("Votre usage", [
            "Vous êtes responsable de ce que vous envoyez et des appareils à qui vous l'envoyez. N'envoyez que "
            "ce que vous avez le droit de partager. N'utilisez pas RoomSend pour transmettre des contenus "
            "illicites, importuner quelqu'un ou atteindre un appareil sans l'accord de son propriétaire.",
            "Sur un réseau que vous ne connaissez pas, désactivez plutôt « Visible sur ce Wi-Fi » et « Accepter "
            "automatiquement ».",
        ]),
        ("Réseau et sécurité", [
            "RoomSend dépend de votre réseau local : un réseau qui isole les appareils ou un pare-feu peut "
            "empêcher la découverte ou les transferts. Les transferts sont chiffrés par défaut. Le partage par "
            "lien passe en HTTP simple et reste lisible par les personnes du même réseau.",
            "Un transfert peut échouer ou être interrompu : gardez une copie de vos fichiers importants.",
        ]),
        ("LocalSend", [
            "RoomSend est une app indépendante. Elle n'est ni éditée, ni approuvée, ni soutenue par le projet "
            "LocalSend, dont le nom n'est cité que pour indiquer la compatibilité. Les autres apps peuvent "
            "évoluer : nous ne garantissons pas la compatibilité avec chacune de leurs versions.",
        ]),
        ("Disponibilité et garantie", [
            "L'app est fournie gratuitement, en l'état. Nous la corrigeons et l'améliorons, sans garantir "
            "qu'elle fonctionne sans interruption ni erreur, ni qu'elle convienne à un usage particulier. Nous "
            "pouvons la modifier ou cesser de la distribuer.",
        ]),
        ("Responsabilité", [
            "Dans la mesure permise par la loi, nous déclinons toute responsabilité pour les dommages liés à "
            "l'usage de RoomSend, notamment une perte de données ou un contenu reçu d'un autre appareil. Cette "
            "limite ne vaut pas pour un dommage causé intentionnellement ou par négligence grave (art. 100 du "
            "Code des obligations), ni là où la loi l'interdit.",
        ]),
        ("Propriété intellectuelle", [
            "Le nom RoomSend, son icône, son design et son code appartiennent à l'éditeur. Ce que vous envoyez "
            "reste à vous : nous n'y avons jamais accès.",
        ]),
        ("Modifications", [
            "Nous pouvons modifier ces conditions. La version en vigueur est publiée ici et dans l'app, avec sa "
            "date. Si vous refusez une nouvelle version, cessez d'utiliser l'app et supprimez-la.",
        ]),
        ("Droit applicable et for", [
            "Ces conditions sont soumises au droit suisse. Le for est au domicile de l'éditeur. Si vous êtes "
            "un consommateur, vous gardez la protection des règles impératives de votre pays de résidence et "
            "pouvez saisir ses tribunaux.",
        ]),
    ],
}
