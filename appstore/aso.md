# RoomSend, mots-clés et titres (étude du 21.11.2026)

**Question.** Quels mots mettre dans le nom, le sous-titre et le champ mots-clés de chaque langue pour
qu'une personne qui cherche à envoyer des fichiers par Wi-Fi tombe sur RoomSend ?

**Sources.** Sonar, le 21.11.2026, App Store iOS : `sonar_keyword_metrics`, `sonar_keyword_search`,
`sonar_app_search`. La popularité (5 à 100) est la Search Popularity d'Apple quand Apple en donne une
(`apple`), sinon une estimation de Sonar plafonnée à 18 (`proxy`). La difficulté (0 à 100) est un
calcul de Sonar sur les dix premières apps. Ce sont des mesures d'un jour, pas une promesse de rang.

## Ce que disent les chiffres

| Marché | Requête | Popularité | Difficulté | Source |
|---|---|---|---|---|
| US | file transfer | 38 | 49 | apple |
| US | send files | 29 | 28 | apple |
| US | wifi file transfer | 26 | 21 | apple |
| US | wifi transfer | 25 | 25 | apple |
| US | photo transfer | 22 | 33 | apple |
| US | file sharing | 33 | 63 | apple |
| US | lan | 33 | 24 | apple |
| US | computer / laptop | 41 / 38 | 51 / 50 | apple |
| US | share / wifi | 48 / 52 | 50 / 72 | apple |
| FR | transfert | 42 | 50 | apple |
| FR | transfert photo | 38 | 53 | apple |
| FR | transfert fichier | 30 | 60 | apple |
| FR | wifi / partage | 45 / 30 | 39 / 47 | apple |
| DE | wlan | 41 | 46 | apple |
| DE | dateiübertragung | 11 | 24 | proxy |
| ES | wifi | 43 | 43 | apple |
| IT | file transfer (en anglais) | 27 | 36 | apple |
| IT | wifi | 43 | 35 | apple |
| PT | wifi | 34 | 23 | apple |
| PT | transferir | 18 | 25 | proxy |

Les requêtes en langue locale sont presque toutes sous le seuil d'Apple en DE, ES, IT et PT : les gens y
cherchent « wifi », « wlan » ou l'anglais « file transfer ». En Italie, « file transfer » en anglais pèse
plus que « trasferimento file ».

**Concurrence vue dans la recherche « file transfer wifi » (US).** Le gabarit « Marque: Wi-Fi File
Transfer » domine, souvent sur des apps à 0 avis : il marche pour l'indexation, il ne distingue pas.
LocalSend lui-même est sur l'App Store (« Cross-Platform File Sharing », 773 avis aux US) : RoomSend
arrive à côté d'un client établi, d'où l'importance des notes pour la règle 4.1.

## Décisions

- **Nom** : la marque, puis les deux ou trois mots les plus cherchés du marché. Apple indexe le nom plus
  fort que le reste ; « RoomSend » seul ne serait trouvé par personne.
- **Sous-titre** : ce qu'on envoie (photos, fichiers) et la promesse vérifiable (sans cloud), pour former
  avec le nom les requêtes « send files », « photo transfer », « transfert photo ».
- **Mots-clés** : pas un mot déjà dans le nom ou le sous-titre, chaque mot de plus de deux lettres
  (exigence d'Apple), aucun nom d'app ou de marque tierce (ni LocalSend, ni AirDrop, ni Nearby Share).
  « wifi » est répété en un mot, car le nom l'écrit « Wi-Fi » et rien ne garantit qu'Apple relie les deux.
- **Écartés** : « bluetooth file transfer » et « send files to tv » (populaires, mais RoomSend ne fait ni
  l'un ni l'autre) ; les noms de plateformes mobiles concurrentes (règle 2.3.10).

## Vérification prévue

Après la sortie : suivre dans Sonar (`sonar_track_keywords`) le rang de RoomSend sur « wifi file
transfer », « send files », « transfert photo », « wlan » et « file transfer » (IT), puis comparer au
bout de deux semaines et changer les mots-clés qui ne rapportent rien (le champ se modifie à chaque
nouvelle version).
