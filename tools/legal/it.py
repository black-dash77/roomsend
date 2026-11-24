"""Informativa sulla privacy e condizioni d'uso, in italiano. Stesso contenuto di `fr.py`."""

PRIVACY = {
    "title": "Informativa sulla privacy",
    "updated": "Ultimo aggiornamento: 21 novembre 2026.",
    "intro": "RoomSend invia foto, file e testi ai dispositivi della stessa rete locale. Non ci sono account "
    "né server: ciò che invia va direttamente dal Suo dispositivo a quello che sceglie, e noi non riceviamo "
    "nulla. Questa pagina descrive cosa fa l'app con i Suoi dati, poi cosa registra questo sito.",
    "sections": [
        ("Titolare", [
            "{name}, {address}. Per qualsiasi domanda sui Suoi dati: [{email}](mailto:{email}).",
        ]),
        ("Cosa riceviamo dall'app", [
            "Nulla. RoomSend non contiene misurazione del pubblico, pubblicità, tracker né servizi di terzi. "
            "L'app non si collega a internet: parla solo con i dispositivi della Sua rete locale. Non chiede "
            "account, indirizzo e-mail né numero di telefono.",
            "Se in iOS ha accettato di condividere le analisi con gli sviluppatori, Apple può fornirci rapporti "
            "sugli arresti anomali e statistiche complessive, senza la Sua identità. Si imposta in "
            "Impostazioni, Privacy e sicurezza, Analisi e miglioramenti.",
        ]),
        ("Cosa vedono i dispositivi della Sua rete", [
            "Per essere trovato, RoomSend annuncia sulla rete locale il nome del Suo dispositivo (modificabile "
            "in Impostazioni), il modello («iPhone»), l'impronta del certificato e la porta su cui ascolta. "
            "Segue il protocollo LocalSend. I dispositivi compatibili della stessa rete vedono questi dati "
            "finché «Visibile su questa Wi-Fi» è attivo.",
            "Con «Scansiona la rete» attivo, RoomSend invia questi dati anche a ogni indirizzo della Sua "
            "sottorete, per trovare i dispositivi che la ricerca abituale non vede. Su una Wi-Fi pubblica, "
            "disattivi «Visibile su questa Wi-Fi» per non essere più visto.",
        ]),
        ("Cosa invia e riceve", [
            "Foto, file e testi passano direttamente da un dispositivo all'altro sulla Sua rete locale, mai "
            "attraverso di noi o internet. Per impostazione predefinita sono cifrati in HTTPS, e RoomSend "
            "verifica che il certificato dell'altro dispositivo corrisponda all'impronta annunciata. Se la "
            "cifratura è disattivata su uno dei due, il trasferimento avviene in HTTP semplice, senza "
            "cifratura, e un lucchetto aperto lo segnala.",
            "Ciò che Le inviano viene salvato solo dopo che lo accetta, salvo se attiva «Accetta "
            "automaticamente». Può anche richiedere un PIN. I file ricevuti finiscono nella cartella RoomSend "
            "dell'app File.",
            "Il dispositivo che riceve conserva ciò che gli invia e il suo proprietario ne fa ciò che vuole: "
            "invii solo a dispositivi che conosce.",
        ]),
        ("La condivisione con link", [
            "«Condividi con link» mette gli elementi scelti su una pagina web, in HTTP semplice, senza cifratura "
            "né password. Chiunque nella stessa rete apra l'indirizzo può scaricarli finché la condivisione resta "
            "attiva. Si ferma quando tocca «Interrompi la condivisione» o esce da RoomSend.",
        ]),
        ("I due permessi", [
            [
                "Rete locale: per trovare i dispositivi della Sua Wi-Fi e scambiare con loro. Senza, RoomSend "
                "non può né inviare né ricevere.",
                "Foto, solo aggiunta: per mettere nella Sua libreria le foto e i video ricevuti, se «Foto in "
                "Foto» è attivo. RoomSend non può leggere la Sua libreria. Quando sceglie le foto da inviare, il "
                "selettore di iOS gli consegna solo quelle che tocca.",
            ],
        ]),
        ("Cosa resta sul Suo iPhone", [
            [
                "Il nome del dispositivo e le Sue impostazioni.",
                "I preferiti: nome, impronta e indirizzo locale di ogni dispositivo segnato.",
                "La cronologia degli ultimi 200 trasferimenti: direzione, dispositivo, numero di elementi, "
                "dimensione e data. Non contiene né il nome né il contenuto dei file.",
                "Il certificato del dispositivo e la sua chiave privata, nel portachiavi di iOS.",
                "Gli elementi condivisi da un'altra app, finché RoomSend non si apre. Poi vengono cancellati.",
            ],
            "Nulla di tutto ciò ci viene inviato. Fa parte dei backup dell'iPhone se li ha attivati. Eliminare "
            "l'app cancella impostazioni, cronologia e file. iOS può conservare il certificato nel portachiavi "
            "dopo l'eliminazione: porta solo il nome «RoomSend». Le foto salvate in Foto restano lì.",
        ]),
        ("Questo sito", [
            "Il sito è ospitato da Netlify, Inc., 101 2nd Street, San Francisco, CA 94105, Stati Uniti. Quando "
            "apre una pagina, Netlify registra nei suoi log tecnici il Suo indirizzo IP, la pagina richiesta, "
            "data e ora, e ciò che invia il browser (tipo, sistema). Questi log servono a consegnare le pagine e "
            "a proteggere il sito dagli abusi. Senza, la pagina non può esserLe inviata. Base giuridica: il "
            "nostro legittimo interesse a un sito sicuro (art. 6, par. 1, lett. f GDPR).",
            "Secondo i suoi impegni contrattuali, Netlify conserva i log del traffico 30 giorni online e fino a "
            "13 mesi in archivio, e quelli di sicurezza fino a un anno online e sei anni in archivio. Questi "
            "dati sono trattati negli Stati Uniti. Netlify è certificata secondo il Data Privacy Framework tra "
            "UE e Stati Uniti e tra Svizzera e Stati Uniti, riconosciuti adeguati dalla Commissione europea il "
            "10 luglio 2023 e dal Consiglio federale svizzero il 14 agosto 2024.",
            "Il sito non usa cookie, misurazione del pubblico, font o script di altri siti. Conserva solo nel "
            "Suo browser la lingua e l'aspetto che sceglie, per riproporli alla visita successiva. Li cancella "
            "con i dati del sito, nel browser.",
            "Se ci scrive, usiamo il Suo indirizzo e il Suo messaggio per risponderLe. Restano presso il nostro "
            "fornitore di posta per il tempo necessario alla Sua richiesta.",
        ]),
        ("I Suoi diritti", [
            "Può chiedere l'accesso ai Suoi dati, la rettifica o la cancellazione, la limitazione del "
            "trattamento, opporsi e chiederne la portabilità (artt. 15-21 GDPR, artt. 25-32 della legge svizzera "
            "sulla protezione dei dati). Poiché l'app non ci invia nulla, di Lei abbiamo al massimo le e-mail; "
            "per i log del sito, inoltriamo la richiesta a Netlify. Scriva a [{email}](mailto:{email}).",
            "Nessuna decisione automatizzata viene presa su di Lei. Può presentare reclamo all'Incaricato "
            "federale della protezione dei dati e della trasparenza (IFPDT) a Berna o, se vive nell'Unione "
            "europea, all'autorità di protezione dei dati del Suo paese.",
        ]),
        ("Modifiche", [
            "Se l'app o il sito cambiano il modo in cui trattano i dati, aggiorniamo questa pagina, qui e "
            "nell'app, con la data.",
        ]),
    ],
}

TERMS = {
    "title": "Condizioni d'uso",
    "updated": "Ultimo aggiornamento: 21 novembre 2026.",
    "intro": "Queste condizioni valgono per l'app RoomSend e per questo sito. Usando RoomSend, le accetta.",
    "sections": [
        ("L'editore", [
            "{name}, {address}. Contatto: [{email}](mailto:{email}).",
        ]),
        ("Il servizio", [
            "RoomSend è un'app gratuita per iPhone che invia foto, file e testi ai dispositivi della stessa rete "
            "locale. Segue il protocollo pubblico LocalSend e funziona con le app LocalSend per Android, "
            "Windows, macOS e Linux. Non ha account, abbonamento, acquisti in-app né pubblicità.",
        ]),
        ("Licenza", [
            "RoomSend Le è concessa secondo il [contratto di licenza standard di Apple]"
            "(https://www.apple.com/legal/internet-services/itunes/dev/stdeula/). Queste condizioni lo "
            "completano. In caso di contrasto, prevale il contratto di Apple.",
        ]),
        ("Il Suo uso", [
            "Lei è responsabile di ciò che invia e dei dispositivi a cui lo invia. Invii solo ciò che ha il "
            "diritto di condividere. Non usi RoomSend per trasmettere contenuti illeciti, molestare qualcuno o "
            "raggiungere un dispositivo senza il consenso del proprietario.",
            "Su una rete che non conosce, meglio disattivare «Visibile su questa Wi-Fi» e «Accetta "
            "automaticamente».",
        ]),
        ("Rete e sicurezza", [
            "RoomSend dipende dalla Sua rete locale: una rete che isola i dispositivi, o un firewall, può "
            "impedire la ricerca o i trasferimenti. I trasferimenti sono cifrati per impostazione predefinita. "
            "La condivisione con link usa HTTP semplice ed è leggibile dalle persone della stessa rete.",
            "Un trasferimento può fallire o interrompersi: conservi una copia dei file importanti.",
        ]),
        ("LocalSend", [
            "RoomSend è un'app indipendente. Non è pubblicata, approvata né sostenuta dal progetto LocalSend, il "
            "cui nome è citato solo per indicare la compatibilità. Le altre app evolvono: non garantiamo la "
            "compatibilità con ognuna delle loro versioni.",
        ]),
        ("Disponibilità e garanzia", [
            "L'app è fornita gratis, così com'è. La correggiamo e la miglioriamo, senza garantire che funzioni "
            "senza interruzioni o errori, né che sia adatta a un uso particolare. Possiamo modificarla o "
            "smettere di distribuirla.",
        ]),
        ("Responsabilità", [
            "Nei limiti consentiti dalla legge, escludiamo ogni responsabilità per danni legati all'uso di "
            "RoomSend, in particolare perdite di dati o contenuti ricevuti da un altro dispositivo. Questo limite "
            "non vale per i danni causati intenzionalmente o per colpa grave (art. 100 del Codice delle "
            "obbligazioni svizzero), né dove la legge lo vieta.",
        ]),
        ("Proprietà intellettuale", [
            "Il nome RoomSend, la sua icona, il design e il codice appartengono all'editore. Ciò che invia resta "
            "Suo: non vi abbiamo mai accesso.",
        ]),
        ("Modifiche", [
            "Possiamo modificare queste condizioni. La versione in vigore è pubblicata qui e nell'app, con la "
            "data. Se rifiuta una nuova versione, smetta di usare l'app e la elimini.",
        ]),
        ("Legge applicabile e foro", [
            "Queste condizioni sono regolate dal diritto svizzero. Il foro è il domicilio dell'editore. Se è un "
            "consumatore, conserva la protezione delle norme imperative del Suo paese di residenza e può "
            "rivolgersi ai suoi tribunali.",
        ]),
    ],
}
