"""Política de privacidad y condiciones de uso, en español. Mismo contenido que `fr.py`."""

PRIVACY = {
    "title": "Política de privacidad",
    "updated": "Última actualización: 21 de noviembre de 2026.",
    "intro": "RoomSend envía fotos, archivos y textos a los dispositivos de la misma red local. No hay cuenta "
    "ni servidor: lo que usted envía va directamente de su dispositivo al que elige, y no recibimos nada. "
    "Esta página describe lo que la app hace con sus datos y, después, lo que registra este sitio.",
    "sections": [
        ("Responsable", [
            "{name}, {address}. Para cualquier pregunta sobre sus datos: [{email}](mailto:{email}).",
        ]),
        ("Lo que recibimos de la app", [
            "Nada. RoomSend no contiene medición de audiencia, publicidad, rastreadores ni servicios de "
            "terceros. La app no se conecta a internet: solo habla con los dispositivos de su red local. No pide "
            "cuenta, correo electrónico ni número de teléfono.",
            "Si aceptó en iOS compartir análisis con los desarrolladores, Apple puede enviarnos informes de "
            "fallos y estadísticas globales, sin su identidad. Se configura en Ajustes, Privacidad y seguridad, "
            "Análisis y mejoras.",
        ]),
        ("Lo que ven los dispositivos de su red", [
            "Para que lo encuentren, RoomSend anuncia en la red local el nombre de su dispositivo (puede "
            "cambiarlo en Ajustes), su modelo («iPhone»), la huella de su certificado y el puerto en el que "
            "escucha. Sigue el protocolo LocalSend. Los dispositivos compatibles de la misma red lo ven mientras "
            "«Visible en este Wi-Fi» esté activado.",
            "Con «Explorar la red» activado, RoomSend envía además estos datos a cada dirección de su subred, "
            "para encontrar los dispositivos que la búsqueda habitual no ve. En un Wi-Fi público, desactive "
            "«Visible en este Wi-Fi» para dejar de ser visto.",
        ]),
        ("Lo que envía y recibe", [
            "Las fotos, los archivos y los textos pasan directamente de un dispositivo a otro por su red local, "
            "nunca por nosotros ni por internet. Por defecto se cifran con HTTPS, y RoomSend comprueba que el "
            "certificado del otro dispositivo coincide con la huella que anunció. Si el cifrado está desactivado "
            "en uno de los dos, la transferencia usa HTTP simple, sin cifrado, y un candado abierto lo indica.",
            "Lo que le envían solo se guarda cuando usted lo acepta, salvo que active «Aceptar "
            "automáticamente». También puede exigir un PIN. Los archivos recibidos van a la carpeta RoomSend de "
            "la app Archivos.",
            "El dispositivo que recibe conserva lo que usted le envía y su propietario hace con ello lo que "
            "quiere: envíe solo a dispositivos que conozca.",
        ]),
        ("Compartir por enlace", [
            "«Compartir por enlace» sirve los elementos elegidos en una página web, por HTTP simple, sin cifrado "
            "ni contraseña. Cualquier persona de la misma red que abra la dirección puede descargarlos mientras "
            "el enlace siga activo. Se detiene cuando toca «Dejar de compartir» o sale de RoomSend.",
        ]),
        ("Los dos permisos", [
            [
                "Red local: para encontrar los dispositivos de su Wi-Fi e intercambiar con ellos. Sin él, "
                "RoomSend no puede enviar ni recibir.",
                "Fotos, solo añadir: para guardar en su fototeca las fotos y los vídeos recibidos, si «Fotos en "
                "Fotos» está activado. RoomSend no puede leer su fototeca. Cuando elige fotos para enviar, el "
                "selector de iOS solo le entrega las que usted toca.",
            ],
        ]),
        ("Lo que queda en su iPhone", [
            [
                "El nombre de su dispositivo y sus ajustes.",
                "Sus favoritos: el nombre, la huella y la dirección local de cada dispositivo marcado.",
                "El historial de las últimas 200 transferencias: sentido, dispositivo, número de elementos, "
                "tamaño y fecha. No incluye ni el nombre ni el contenido de los archivos.",
                "El certificado del dispositivo y su clave privada, en el llavero de iOS.",
                "Los elementos compartidos desde otra app, hasta que se abre RoomSend. Después se borran.",
            ],
            "Nada de esto se nos envía. Forma parte de las copias de seguridad del iPhone si las tiene "
            "activadas. Al eliminar la app se borran sus ajustes, su historial y sus archivos. iOS puede "
            "conservar el certificado en el llavero después: solo lleva el nombre «RoomSend». Las fotos "
            "guardadas en Fotos permanecen allí.",
        ]),
        ("Este sitio", [
            "El sitio está alojado por Netlify, Inc., 101 2nd Street, San Francisco, CA 94105, Estados Unidos. "
            "Cuando abre una página, Netlify registra en sus registros técnicos su dirección IP, la página "
            "pedida, la fecha y la hora, y lo que envía su navegador (su tipo, su sistema). Estos registros "
            "sirven para entregar las páginas y proteger el sitio contra abusos. Sin ellos, la página no se le "
            "puede enviar. Base jurídica: nuestro interés legítimo en un sitio seguro (art. 6, apdo. 1, letra f "
            "RGPD).",
            "Según sus compromisos contractuales, Netlify conserva los registros de tráfico 30 días en línea y "
            "hasta 13 meses en archivo, y los de seguridad hasta un año en línea y seis años en archivo. Estos "
            "datos se tratan en Estados Unidos. Netlify está certificada según el Data Privacy Framework entre "
            "la UE y Estados Unidos y entre Suiza y Estados Unidos, declarados adecuados por la Comisión Europea "
            "el 10 de julio de 2023 y por el Consejo Federal suizo el 14 de agosto de 2024.",
            "El sitio no usa cookies, ni medición de audiencia, ni fuentes o scripts de otros sitios. Solo "
            "guarda en su navegador el idioma y la apariencia que elige, para devolvérselos en la próxima "
            "visita. Los borra con los datos del sitio, en su navegador.",
            "Si nos escribe, usamos su dirección y su mensaje para responderle. Quedan en nuestro proveedor de "
            "correo el tiempo que requiera su solicitud.",
        ]),
        ("Sus derechos", [
            "Puede pedir el acceso a sus datos, su rectificación o supresión, la limitación de su tratamiento, "
            "oponerse a él y pedir su portabilidad (arts. 15 a 21 RGPD, arts. 25 a 32 de la ley suiza de "
            "protección de datos). Como la app no nos envía nada, solo tenemos sus posibles correos; para los "
            "registros del sitio, trasladamos su solicitud a Netlify. Escriba a [{email}](mailto:{email}).",
            "No se toma ninguna decisión automatizada sobre usted. Puede reclamar ante el Encargado Federal de "
            "Protección de Datos y Transparencia (PFPDT) de Suiza, en Berna, o, si vive en la Unión Europea, "
            "ante la autoridad de protección de datos de su país.",
        ]),
        ("Cambios", [
            "Si la app o el sitio cambian su forma de tratar los datos, actualizamos esta página, aquí y en la "
            "app, con su fecha.",
        ]),
    ],
}

TERMS = {
    "title": "Condiciones de uso",
    "updated": "Última actualización: 21 de noviembre de 2026.",
    "intro": "Estas condiciones se aplican a la app RoomSend y a este sitio. Al usar RoomSend, las acepta.",
    "sections": [
        ("El editor", [
            "{name}, {address}. Contacto: [{email}](mailto:{email}).",
        ]),
        ("El servicio", [
            "RoomSend es una app gratuita para iPhone que envía fotos, archivos y textos a los dispositivos de "
            "la misma red local. Sigue el protocolo público LocalSend y funciona con las apps LocalSend de "
            "Android, Windows, macOS y Linux. No tiene cuenta, suscripción, compras dentro de la app ni "
            "publicidad.",
        ]),
        ("Licencia", [
            "RoomSend se le concede según el [contrato de licencia estándar de Apple]"
            "(https://www.apple.com/legal/internet-services/itunes/dev/stdeula/). Estas condiciones lo "
            "completan. En caso de contradicción, prevalece el contrato de Apple.",
        ]),
        ("Su uso", [
            "Usted es responsable de lo que envía y de los dispositivos a los que lo envía. Envíe solo lo que "
            "tiene derecho a compartir. No use RoomSend para transmitir contenidos ilícitos, molestar a alguien "
            "o llegar a un dispositivo sin el consentimiento de su propietario.",
            "En una red que no conoce, mejor desactive «Visible en este Wi-Fi» y «Aceptar automáticamente».",
        ]),
        ("Red y seguridad", [
            "RoomSend depende de su red local: una red que aísla los dispositivos, o un cortafuegos, puede "
            "impedir la búsqueda o las transferencias. Las transferencias se cifran por defecto. Compartir por "
            "enlace usa HTTP simple y lo pueden leer las personas de la misma red.",
            "Una transferencia puede fallar o interrumpirse: guarde una copia de sus archivos importantes.",
        ]),
        ("LocalSend", [
            "RoomSend es una app independiente. No la publica, avala ni respalda el proyecto LocalSend, cuyo "
            "nombre se cita solo para indicar la compatibilidad. Las otras apps evolucionan: no garantizamos la "
            "compatibilidad con cada una de sus versiones.",
        ]),
        ("Disponibilidad y garantía", [
            "La app se ofrece gratis, tal cual. La corregimos y mejoramos, sin garantizar que funcione sin "
            "interrupciones ni errores, ni que sirva para un uso concreto. Podemos modificarla o dejar de "
            "distribuirla.",
        ]),
        ("Responsabilidad", [
            "En la medida en que la ley lo permita, no asumimos responsabilidad por daños ligados al uso de "
            "RoomSend, en especial pérdidas de datos o contenidos recibidos de otro dispositivo. Este límite no "
            "se aplica a daños causados intencionadamente o por negligencia grave (art. 100 del Código de "
            "Obligaciones suizo), ni donde la ley lo prohíba.",
        ]),
        ("Propiedad intelectual", [
            "El nombre RoomSend, su icono, su diseño y su código pertenecen al editor. Lo que usted envía sigue "
            "siendo suyo: nunca tenemos acceso a ello.",
        ]),
        ("Cambios", [
            "Podemos modificar estas condiciones. La versión vigente se publica aquí y en la app, con su fecha. "
            "Si rechaza una nueva versión, deje de usar la app y elimínela.",
        ]),
        ("Ley aplicable y jurisdicción", [
            "Estas condiciones se rigen por el derecho suizo. El fuero es el domicilio del editor. Si es usted "
            "consumidor, conserva la protección de las normas imperativas de su país de residencia y puede "
            "acudir a sus tribunales.",
        ]),
    ],
}
