"""Privacy policy and terms of use, in English. Same content as `fr.py`, section for section."""

PRIVACY = {
    "title": "Privacy Policy",
    "updated": "Last updated: 21 November 2026.",
    "intro": "RoomSend sends photos, files and text to the devices on the same local network. There is no "
    "account and no server: what you send goes straight from your device to the one you pick, and we "
    "receive none of it. This page describes what the app does with your data, then what this site records.",
    "sections": [
        ("Who is responsible", [
            "{name}, {address}. For any question about your data: [{email}](mailto:{email}).",
        ]),
        ("What we receive from the app", [
            "Nothing. RoomSend contains no analytics, no advertising, no tracker and no third-party service. "
            "The app does not connect to the internet: it only talks to the devices on your local network. It "
            "asks for no account, no email address and no phone number.",
            "If you agreed in iOS to share analytics with app developers, Apple may give us crash reports and "
            "overall statistics, without your identity. You set this in Settings, Privacy & Security, "
            "Analytics & Improvements.",
        ]),
        ("What the devices on your network see", [
            "To be found, RoomSend announces on the local network your device's name (you can change it in "
            "Settings), its model (\"iPhone\"), its certificate fingerprint and the port it listens on. This "
            "follows the LocalSend protocol. Compatible devices on the same network see it as long as "
            "\"Visible on this Wi-Fi\" is on.",
            "When \"Scan the network\" is on, RoomSend also sends this information to every address of your "
            "subnet, to find the devices the usual search misses. On public Wi-Fi, turn off \"Visible on this "
            "Wi-Fi\" to stop being seen.",
        ]),
        ("What you send and receive", [
            "Photos, files and text go directly from one device to the other over your local network, never "
            "through us or the internet. By default they are encrypted with HTTPS, and RoomSend checks that the "
            "other device's certificate matches the fingerprint it announced. If encryption is off on either "
            "device, the transfer uses plain HTTP, without encryption, and an open padlock shows it.",
            "What is sent to you is saved only once you accept it, unless you turn on \"Accept "
            "automatically\". You can also require a PIN. Received files go to the RoomSend folder of the "
            "Files app.",
            "The receiving device keeps what you send it, and its owner does what they like with it: only send "
            "to devices you know.",
        ]),
        ("Sharing by link", [
            "\"Share by link\" serves the items you picked on a web page, over plain HTTP, without encryption "
            "or password. Anyone on the same network who opens the address can download them while sharing "
            "stays on. It stops when you tap \"Stop sharing\" or leave RoomSend.",
        ]),
        ("The two permissions", [
            [
                "Local network: to find the devices on your Wi-Fi and exchange with them. Without it, RoomSend "
                "can neither send nor receive.",
                "Photos, add only: to put the photos and videos you receive into your library, if \"Photos to "
                "Photos\" is on. RoomSend cannot read your library. When you pick photos to send, the iOS picker "
                "hands it only the ones you tap.",
            ],
        ]),
        ("What stays on your iPhone", [
            [
                "Your device's name and your settings.",
                "Your favorites: the name, fingerprint and local address of each device you starred.",
                "The history of the last 200 transfers: direction, device, number of items, size and date. "
                "File names and contents are not part of it.",
                "The device's certificate and private key, in the iOS keychain.",
                "Items shared from another app, until RoomSend opens. They are deleted afterwards.",
            ],
            "None of this is sent to us. It is part of your iPhone backups if you turned them on. Deleting "
            "the app erases its settings, history and files. iOS may keep the certificate in the keychain after "
            "deletion: it carries only the name \"RoomSend\". Photos saved to Photos stay there.",
        ]),
        ("This site", [
            "The site is hosted by Netlify, Inc., 101 2nd Street, San Francisco, CA 94105, United States. When "
            "you open a page, Netlify records in its technical logs your IP address, the page requested, the "
            "date and time, and what your browser sends (its type, your system). These logs serve to deliver "
            "the pages and protect the site from abuse. Without them, the page cannot be sent to you. Legal "
            "basis: our legitimate interest in running a safe site (Art. 6(1)(f) GDPR).",
            "Under its contractual commitments, Netlify keeps traffic logs for 30 days online and up to 13 "
            "months in archive, and security logs for up to one year online and six years in archive. This "
            "data is processed in the United States. Netlify is certified under the EU-U.S. and Swiss-U.S. "
            "Data Privacy Framework, found adequate by the European Commission on 10 July 2023 and by the Swiss "
            "Federal Council on 14 August 2024.",
            "The site uses no cookies, no analytics, and no fonts or scripts from other sites. It only keeps in "
            "your browser the language and appearance you choose, to give them back on your next visit. You "
            "erase them with the site's data, in your browser.",
            "If you write to us, we use your address and message to answer you. They stay with our email "
            "provider for as long as your request needs.",
        ]),
        ("Your rights", [
            "You can ask for access to your data, its correction or erasure, the restriction of its "
            "processing, object to it and ask for its portability (Art. 15 to 21 GDPR, Art. 25 to 32 Swiss "
            "FADP). Since the app sends us nothing, the only data we hold about you is any email you sent; for "
            "the site's logs, we pass your request on to Netlify. Write to [{email}](mailto:{email}).",
            "No automated decision is made about you. You can lodge a complaint with the Swiss Federal Data "
            "Protection and Information Commissioner (FDPIC) in Bern or, if you live in the European Union, "
            "with the data protection authority of your country.",
        ]),
        ("Changes", [
            "If the app or the site change how they handle data, we update this page, here and in the app, "
            "with its date.",
        ]),
    ],
}

TERMS = {
    "title": "Terms of Use",
    "updated": "Last updated: 21 November 2026.",
    "intro": "These terms apply to the RoomSend app and to this site. By using RoomSend, you accept them.",
    "sections": [
        ("The publisher", [
            "{name}, {address}. Contact: [{email}](mailto:{email}).",
        ]),
        ("The service", [
            "RoomSend is a free iPhone app that sends photos, files and text to the devices on the same local "
            "network. It follows the public LocalSend protocol and works with the LocalSend apps for Android, "
            "Windows, macOS and Linux. It has no account, no subscription, no in-app purchase and no ads.",
        ]),
        ("Licence", [
            "RoomSend is licensed to you under [Apple's standard licence agreement]"
            "(https://www.apple.com/legal/internet-services/itunes/dev/stdeula/). These terms add to it. Where "
            "they conflict, Apple's agreement prevails.",
        ]),
        ("Your use", [
            "You are responsible for what you send and for the devices you send it to. Only send what you have "
            "the right to share. Do not use RoomSend to pass on unlawful content, bother someone or reach a "
            "device without its owner's consent.",
            "On a network you do not know, rather turn off \"Visible on this Wi-Fi\" and \"Accept "
            "automatically\".",
        ]),
        ("Network and security", [
            "RoomSend depends on your local network: a network that isolates devices, or a firewall, can block "
            "discovery or transfers. Transfers are encrypted by default. Sharing by link uses plain HTTP and "
            "can be read by people on the same network.",
            "A transfer can fail or be interrupted: keep a copy of your important files.",
        ]),
        ("LocalSend", [
            "RoomSend is an independent app. It is not published, endorsed or supported by the LocalSend "
            "project, whose name is used only to state compatibility. Other apps evolve: we do not guarantee "
            "compatibility with every one of their versions.",
        ]),
        ("Availability and warranty", [
            "The app is provided free of charge, as is. We fix and improve it, without guaranteeing that it "
            "works without interruption or error, or that it fits a particular purpose. We may change it or "
            "stop distributing it.",
        ]),
        ("Liability", [
            "To the extent the law allows, we accept no liability for damage linked to the use of RoomSend, in "
            "particular data loss or content received from another device. This limit does not apply to damage "
            "caused intentionally or by gross negligence (Art. 100 of the Swiss Code of Obligations), nor where "
            "the law forbids it.",
        ]),
        ("Intellectual property", [
            "The RoomSend name, icon, design and code belong to the publisher. What you send remains yours: we "
            "never have access to it.",
        ]),
        ("Changes", [
            "We may change these terms. The current version is published here and in the app, with its date. "
            "If you refuse a new version, stop using the app and delete it.",
        ]),
        ("Governing law and jurisdiction", [
            "These terms are governed by Swiss law. The place of jurisdiction is the publisher's domicile. If "
            "you are a consumer, you keep the protection of the mandatory rules of your country of residence "
            "and may bring a claim before its courts.",
        ]),
    ],
}
