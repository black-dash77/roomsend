"""Datenschutzerklärung und Nutzungsbedingungen, auf Deutsch. Gleicher Inhalt wie `fr.py`."""

PRIVACY = {
    "title": "Datenschutzerklärung",
    "updated": "Zuletzt aktualisiert: 21. November 2026.",
    "intro": "RoomSend sendet Fotos, Dateien und Texte an die Geräte im selben lokalen Netzwerk. Es gibt "
    "weder ein Konto noch einen Server: Was Sie senden, geht direkt von Ihrem Gerät zu dem Gerät, das Sie "
    "wählen, und wir erhalten nichts davon. Diese Seite beschreibt, was die App mit Ihren Daten macht, und "
    "danach, was diese Website aufzeichnet.",
    "sections": [
        ("Verantwortlich", [
            "{name}, {address}. Für Fragen zu Ihren Daten: [{email}](mailto:{email}).",
        ]),
        ("Was wir von der App erhalten", [
            "Nichts. RoomSend enthält keine Reichweitenmessung, keine Werbung, keine Tracker und keine "
            "Dienste Dritter. Die App verbindet sich nicht mit dem Internet: Sie spricht nur mit den Geräten "
            "in Ihrem lokalen Netzwerk. Sie verlangt kein Konto, keine E-Mail-Adresse und keine Telefonnummer.",
            "Wenn Sie in iOS zugestimmt haben, Analysedaten mit App-Entwicklern zu teilen, kann Apple uns "
            "Absturzberichte und Gesamtstatistiken ohne Ihre Identität liefern. Das stellen Sie unter "
            "Einstellungen, Datenschutz & Sicherheit, Analyse & Verbesserungen ein.",
        ]),
        ("Was die Geräte in Ihrem Netzwerk sehen", [
            "Damit es gefunden wird, gibt RoomSend im lokalen Netzwerk den Namen Ihres Geräts bekannt (in den "
            "Einstellungen änderbar), sein Modell („iPhone“), den Fingerabdruck seines Zertifikats und den "
            "Port, auf dem es lauscht. Das folgt dem LocalSend-Protokoll. Kompatible Geräte im selben Netzwerk "
            "sehen diese Angaben, solange „In diesem WLAN sichtbar“ aktiviert ist.",
            "Ist „Netzwerk durchsuchen“ aktiviert, sendet RoomSend diese Angaben zusätzlich an jede Adresse "
            "Ihres Subnetzes, um Geräte zu finden, die die übliche Suche übersieht. In einem öffentlichen WLAN "
            "deaktivieren Sie „In diesem WLAN sichtbar“, um nicht mehr gesehen zu werden.",
        ]),
        ("Was Sie senden und empfangen", [
            "Fotos, Dateien und Texte gehen über Ihr lokales Netzwerk direkt von einem Gerät zum anderen, nie "
            "über uns oder das Internet. Standardmässig sind sie per HTTPS verschlüsselt, und RoomSend prüft, "
            "ob das Zertifikat des anderen Geräts zum angekündigten Fingerabdruck passt. Ist die "
            "Verschlüsselung auf einem der beiden Geräte aus, läuft die Übertragung über einfaches HTTP, ohne "
            "Verschlüsselung, und ein offenes Schloss zeigt das an.",
            "Was man Ihnen sendet, wird erst gespeichert, wenn Sie es annehmen, ausser Sie aktivieren "
            "„Automatisch annehmen“. Sie können auch eine PIN verlangen. Empfangene Dateien landen im Ordner "
            "RoomSend der App Dateien.",
            "Das empfangende Gerät behält, was Sie ihm senden, und sein Besitzer macht damit, was er will: "
            "Senden Sie nur an Geräte, die Sie kennen.",
        ]),
        ("Teilen per Link", [
            "„Per Link teilen“ stellt die gewählten Inhalte auf einer Webseite bereit, über einfaches HTTP, "
            "ohne Verschlüsselung und ohne Passwort. Wer im selben Netzwerk die Adresse öffnet, kann sie "
            "herunterladen, solange das Teilen läuft. Es endet, wenn Sie „Teilen beenden“ tippen oder "
            "RoomSend verlassen.",
        ]),
        ("Die zwei Berechtigungen", [
            [
                "Lokales Netzwerk: um die Geräte in Ihrem WLAN zu finden und mit ihnen auszutauschen. Ohne sie "
                "kann RoomSend weder senden noch empfangen.",
                "Fotos, nur Hinzufügen: um empfangene Fotos und Videos in Ihre Mediathek zu legen, wenn "
                "„Fotos in Fotos“ aktiviert ist. RoomSend kann Ihre Mediathek nicht lesen. Wenn Sie Fotos zum "
                "Senden auswählen, gibt die Auswahl von iOS nur die getippten weiter.",
            ],
        ]),
        ("Was auf Ihrem iPhone bleibt", [
            [
                "Der Name Ihres Geräts und Ihre Einstellungen.",
                "Ihre Favoriten: Name, Fingerabdruck und lokale Adresse jedes markierten Geräts.",
                "Der Verlauf der letzten 200 Übertragungen: Richtung, Gerät, Anzahl der Inhalte, Grösse und "
                "Datum. Dateinamen und Inhalte gehören nicht dazu.",
                "Das Zertifikat des Geräts und sein privater Schlüssel, im iOS-Schlüsselbund.",
                "Aus einer anderen App geteilte Inhalte, bis RoomSend sich öffnet. Danach werden sie gelöscht.",
            ],
            "Nichts davon wird an uns gesendet. Es ist Teil Ihrer iPhone-Backups, wenn Sie diese aktiviert "
            "haben. Wer die App löscht, löscht ihre Einstellungen, ihren Verlauf und ihre Dateien. iOS kann das "
            "Zertifikat nach dem Löschen im Schlüsselbund behalten: Es trägt nur den Namen „RoomSend“. In Fotos "
            "gesicherte Fotos bleiben dort.",
        ]),
        ("Diese Website", [
            "Die Website wird von Netlify, Inc., 101 2nd Street, San Francisco, CA 94105, USA, gehostet. Wenn "
            "Sie eine Seite öffnen, zeichnet Netlify in seinen technischen Protokollen Ihre IP-Adresse, die "
            "aufgerufene Seite, Datum und Uhrzeit sowie die Angaben Ihres Browsers (Typ, System) auf. Diese "
            "Protokolle dienen dazu, die Seiten auszuliefern und die Website vor Missbrauch zu schützen. Ohne "
            "sie kann Ihnen die Seite nicht gesendet werden. Rechtsgrundlage: unser berechtigtes Interesse an "
            "einer sicheren Website (Art. 6 Abs. 1 lit. f DSGVO).",
            "Laut seinen vertraglichen Zusagen bewahrt Netlify Verkehrsprotokolle 30 Tage online und bis zu 13 "
            "Monate im Archiv auf, Sicherheitsprotokolle bis zu ein Jahr online und sechs Jahre im Archiv. "
            "Diese Daten werden in den USA verarbeitet. Netlify ist nach dem Data Privacy Framework zwischen der "
            "EU und den USA sowie zwischen der Schweiz und den USA zertifiziert, das die Europäische Kommission "
            "am 10. Juli 2023 und der Bundesrat am 14. August 2024 als angemessen anerkannt haben.",
            "Die Website verwendet keine Cookies, keine Reichweitenmessung und keine Schriften oder Skripte "
            "fremder Websites. Sie speichert in Ihrem Browser nur die Sprache und das Erscheinungsbild, die Sie "
            "wählen, um sie beim nächsten Besuch wiederherzustellen. Sie löschen sie mit den Website-Daten in "
            "Ihrem Browser.",
            "Wenn Sie uns schreiben, verwenden wir Ihre Adresse und Ihre Nachricht, um Ihnen zu antworten. Sie "
            "bleiben bei unserem E-Mail-Anbieter, solange Ihr Anliegen es erfordert.",
        ]),
        ("Ihre Rechte", [
            "Sie können Auskunft über Ihre Daten, deren Berichtigung oder Löschung und die Einschränkung ihrer "
            "Verarbeitung verlangen, der Verarbeitung widersprechen und ihre Übertragung verlangen (Art. 15 bis "
            "21 DSGVO, Art. 25 bis 32 DSG). Da die App uns nichts sendet, haben wir von Ihnen höchstens Ihre "
            "E-Mails; für die Protokolle der Website leiten wir Ihr Anliegen an Netlify weiter. Schreiben Sie an "
            "[{email}](mailto:{email}).",
            "Über Sie wird keine automatisierte Entscheidung getroffen. Sie können sich beim Eidgenössischen "
            "Datenschutz- und Öffentlichkeitsbeauftragten (EDÖB) in Bern beschweren oder, wenn Sie in der "
            "Europäischen Union leben, bei der Datenschutzbehörde Ihres Landes.",
        ]),
        ("Änderungen", [
            "Ändern die App oder die Website den Umgang mit Daten, aktualisieren wir diese Seite, hier und in "
            "der App, mit Datum.",
        ]),
    ],
}

TERMS = {
    "title": "Nutzungsbedingungen",
    "updated": "Zuletzt aktualisiert: 21. November 2026.",
    "intro": "Diese Bedingungen gelten für die App RoomSend und für diese Website. Wer RoomSend nutzt, nimmt "
    "sie an.",
    "sections": [
        ("Herausgeber", [
            "{name}, {address}. Kontakt: [{email}](mailto:{email}).",
        ]),
        ("Der Dienst", [
            "RoomSend ist eine kostenlose iPhone-App, die Fotos, Dateien und Texte an die Geräte im selben "
            "lokalen Netzwerk sendet. Sie folgt dem öffentlichen LocalSend-Protokoll und funktioniert mit den "
            "LocalSend-Apps für Android, Windows, macOS und Linux. Sie hat kein Konto, kein Abo, keine In-App-"
            "Käufe und keine Werbung.",
        ]),
        ("Lizenz", [
            "RoomSend wird Ihnen nach dem [Standard-Lizenzvertrag von Apple]"
            "(https://www.apple.com/legal/internet-services/itunes/dev/stdeula/) überlassen. Diese Bedingungen "
            "ergänzen ihn. Bei einem Widerspruch gilt der Vertrag von Apple.",
        ]),
        ("Ihre Nutzung", [
            "Sie sind verantwortlich für das, was Sie senden, und für die Geräte, an die Sie es senden. Senden "
            "Sie nur, was Sie teilen dürfen. Nutzen Sie RoomSend nicht, um rechtswidrige Inhalte zu übermitteln, "
            "jemanden zu belästigen oder ein Gerät ohne Zustimmung seines Besitzers zu erreichen.",
            "In einem Netzwerk, das Sie nicht kennen, deaktivieren Sie besser „In diesem WLAN sichtbar“ und "
            "„Automatisch annehmen“.",
        ]),
        ("Netzwerk und Sicherheit", [
            "RoomSend hängt von Ihrem lokalen Netzwerk ab: Ein Netzwerk, das Geräte voneinander trennt, oder "
            "eine Firewall kann die Suche oder Übertragungen verhindern. Übertragungen sind standardmässig "
            "verschlüsselt. Das Teilen per Link nutzt einfaches HTTP und ist für Personen im selben Netzwerk "
            "lesbar.",
            "Eine Übertragung kann scheitern oder abbrechen: Bewahren Sie eine Kopie wichtiger Dateien auf.",
        ]),
        ("LocalSend", [
            "RoomSend ist eine unabhängige App. Sie wird vom Projekt LocalSend weder herausgegeben noch "
            "empfohlen noch unterstützt; sein Name steht hier nur, um die Kompatibilität anzugeben. Andere Apps "
            "entwickeln sich weiter: Wir garantieren keine Kompatibilität mit jeder ihrer Versionen.",
        ]),
        ("Verfügbarkeit und Gewährleistung", [
            "Die App wird kostenlos und so, wie sie ist, bereitgestellt. Wir korrigieren und verbessern sie, "
            "ohne zu garantieren, dass sie ohne Unterbrechung oder Fehler läuft oder sich für einen bestimmten "
            "Zweck eignet. Wir können sie ändern oder ihren Vertrieb einstellen.",
        ]),
        ("Haftung", [
            "Soweit das Gesetz es erlaubt, lehnen wir jede Haftung für Schäden aus der Nutzung von RoomSend ab, "
            "insbesondere für Datenverlust oder Inhalte, die Sie von einem anderen Gerät erhalten. Diese Grenze "
            "gilt nicht für absichtlich oder grobfahrlässig verursachte Schäden (Art. 100 des "
            "Obligationenrechts) und nicht dort, wo das Gesetz sie verbietet.",
        ]),
        ("Geistiges Eigentum", [
            "Name, Symbol, Design und Code von RoomSend gehören dem Herausgeber. Was Sie senden, bleibt Ihres: "
            "Wir haben nie Zugriff darauf.",
        ]),
        ("Änderungen", [
            "Wir können diese Bedingungen ändern. Die gültige Fassung steht mit Datum hier und in der App. Wenn "
            "Sie eine neue Fassung ablehnen, nutzen Sie die App nicht weiter und löschen Sie sie.",
        ]),
        ("Anwendbares Recht und Gerichtsstand", [
            "Diese Bedingungen unterstehen schweizerischem Recht. Gerichtsstand ist der Wohnsitz des "
            "Herausgebers. Als Verbraucher behalten Sie den Schutz der zwingenden Regeln Ihres Wohnsitzlandes "
            "und können dessen Gerichte anrufen.",
        ]),
    ],
}
