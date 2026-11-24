"""Política de privacidade e condições de utilização, em português europeu, como a app."""

PRIVACY = {
    "title": "Política de privacidade",
    "updated": "Última atualização: 21 de novembro de 2026.",
    "intro": "O RoomSend envia fotos, ficheiros e textos para os dispositivos da mesma rede local. Não há "
    "conta nem servidor: o que envia vai diretamente do seu dispositivo para o que escolher, e não recebemos "
    "nada. Esta página descreve o que a app faz com os seus dados e, depois, o que este site regista.",
    "sections": [
        ("Responsável", [
            "{name}, {address}. Para qualquer pergunta sobre os seus dados: [{email}](mailto:{email}).",
        ]),
        ("O que recebemos da app", [
            "Nada. O RoomSend não contém medição de audiência, publicidade, rastreadores nem serviços de "
            "terceiros. A app não se liga à internet: só fala com os dispositivos da sua rede local. Não pede "
            "conta, endereço de e-mail nem número de telefone.",
            "Se aceitou no iOS partilhar análises com os programadores, a Apple pode fornecer-nos relatórios de "
            "falhas e estatísticas globais, sem a sua identidade. Isto define-se em Definições, Privacidade e "
            "segurança, Análise e melhorias.",
        ]),
        ("O que veem os dispositivos da sua rede", [
            "Para ser encontrado, o RoomSend anuncia na rede local o nome do seu dispositivo (alterável nos "
            "Ajustes), o modelo («iPhone»), a impressão digital do certificado e a porta em que escuta. "
            "Segue o protocolo LocalSend. Os dispositivos compatíveis da mesma rede veem estes dados enquanto "
            "«Visível nesta Wi-Fi» estiver ativo.",
            "Com «Pesquisar a rede» ativo, o RoomSend envia também estes dados a cada endereço da sua sub-rede, "
            "para encontrar os dispositivos que a pesquisa habitual não vê. Numa Wi-Fi pública, desative "
            "«Visível nesta Wi-Fi» para deixar de ser visto.",
        ]),
        ("O que envia e recebe", [
            "As fotos, os ficheiros e os textos passam diretamente de um dispositivo para o outro pela sua rede "
            "local, nunca por nós nem pela internet. Por predefinição são cifrados em HTTPS, e o RoomSend "
            "verifica se o certificado do outro dispositivo corresponde à impressão digital anunciada. Se a "
            "cifragem estiver desativada num dos dois, a transferência usa HTTP simples, sem cifragem, e um "
            "cadeado aberto indica-o.",
            "O que lhe enviam só é guardado depois de o aceitar, exceto se ativar «Aceitar automaticamente». "
            "Também pode exigir um PIN. Os ficheiros recebidos vão para a pasta RoomSend da app Ficheiros.",
            "O dispositivo que recebe guarda o que lhe envia e o seu dono faz com isso o que quiser: envie só "
            "para dispositivos que conhece.",
        ]),
        ("A partilha por ligação", [
            "«Partilhar por ligação» disponibiliza os elementos escolhidos numa página web, em HTTP simples, sem "
            "cifragem nem palavra-passe. Qualquer pessoa da mesma rede que abra o endereço pode descarregá-los "
            "enquanto a partilha estiver ativa. Termina quando toca em «Parar a partilha» ou sai do RoomSend.",
        ]),
        ("As duas autorizações", [
            [
                "Rede local: para encontrar os dispositivos da sua Wi-Fi e trocar dados com eles. Sem ela, o "
                "RoomSend não pode enviar nem receber.",
                "Fotos, só adicionar: para guardar na sua fototeca as fotos e os vídeos recebidos, se «Fotos em "
                "Fotos» estiver ativo. O RoomSend não pode ler a sua fototeca. Quando escolhe fotos para enviar, "
                "o seletor do iOS só lhe entrega as que tocar.",
            ],
        ]),
        ("O que fica no seu iPhone", [
            [
                "O nome do dispositivo e as suas definições.",
                "Os seus favoritos: o nome, a impressão digital e o endereço local de cada dispositivo marcado.",
                "O histórico das últimas 200 transferências: sentido, dispositivo, número de elementos, tamanho "
                "e data. Não inclui o nome nem o conteúdo dos ficheiros.",
                "O certificado do dispositivo e a sua chave privada, no porta-chaves do iOS.",
                "Os elementos partilhados a partir de outra app, até o RoomSend abrir. Depois são apagados.",
            ],
            "Nada disto nos é enviado. Faz parte das cópias de segurança do iPhone, se as tiver ativado. "
            "Apagar a app elimina as definições, o histórico e os ficheiros. O iOS pode manter o certificado no "
            "porta-chaves depois: só tem o nome «RoomSend». As fotos guardadas em Fotos ficam lá.",
        ]),
        ("Este site", [
            "O site é alojado pela Netlify, Inc., 101 2nd Street, San Francisco, CA 94105, Estados Unidos. "
            "Quando abre uma página, a Netlify regista nos seus registos técnicos o seu endereço IP, a página "
            "pedida, a data e a hora, e o que o seu navegador envia (tipo, sistema). Estes registos servem para "
            "entregar as páginas e proteger o site contra abusos. Sem eles, a página não lhe pode ser enviada. "
            "Fundamento jurídico: o nosso interesse legítimo num site seguro (art. 6.º, n.º 1, alínea f, RGPD).",
            "Segundo os seus compromissos contratuais, a Netlify guarda os registos de tráfego 30 dias online e "
            "até 13 meses em arquivo, e os de segurança até um ano online e seis anos em arquivo. Estes dados "
            "são tratados nos Estados Unidos. A Netlify está certificada no Data Privacy Framework entre a UE e "
            "os Estados Unidos e entre a Suíça e os Estados Unidos, considerados adequados pela Comissão "
            "Europeia a 10 de julho de 2023 e pelo Conselho Federal suíço a 14 de agosto de 2024.",
            "O site não usa cookies, medição de audiência, nem tipos de letra ou scripts de outros sites. Só "
            "guarda no seu navegador o idioma e o aspeto que escolher, para os repor na visita seguinte. Apaga-os "
            "com os dados do site, no navegador.",
            "Se nos escrever, usamos o seu endereço e a sua mensagem para lhe responder. Ficam no nosso "
            "fornecedor de e-mail o tempo que o seu pedido exigir.",
        ]),
        ("Os seus direitos", [
            "Pode pedir o acesso aos seus dados, a retificação ou o apagamento, a limitação do tratamento, "
            "opor-se a ele e pedir a portabilidade (arts. 15.º a 21.º RGPD, arts. 25 a 32 da lei suíça de "
            "proteção de dados). Como a app não nos envia nada, só temos os seus eventuais e-mails; quanto aos "
            "registos do site, transmitimos o pedido à Netlify. Escreva para [{email}](mailto:{email}).",
            "Nenhuma decisão automatizada é tomada sobre si. Pode apresentar queixa ao Encarregado Federal da "
            "Proteção de Dados e da Transparência (PFPDT) da Suíça, em Berna, ou, se vive na União Europeia, à "
            "autoridade de proteção de dados do seu país.",
        ]),
        ("Alterações", [
            "Se a app ou o site mudarem a forma como tratam os dados, atualizamos esta página, aqui e na app, "
            "com a data.",
        ]),
    ],
}

TERMS = {
    "title": "Condições de utilização",
    "updated": "Última atualização: 21 de novembro de 2026.",
    "intro": "Estas condições aplicam-se à app RoomSend e a este site. Ao usar o RoomSend, aceita-as.",
    "sections": [
        ("O editor", [
            "{name}, {address}. Contacto: [{email}](mailto:{email}).",
        ]),
        ("O serviço", [
            "O RoomSend é uma app gratuita para iPhone que envia fotos, ficheiros e textos para os dispositivos "
            "da mesma rede local. Segue o protocolo público LocalSend e funciona com as apps LocalSend para "
            "Android, Windows, macOS e Linux. Não tem conta, subscrição, compras na app nem publicidade.",
        ]),
        ("Licença", [
            "O RoomSend é-lhe licenciado segundo o [contrato de licença padrão da Apple]"
            "(https://www.apple.com/legal/internet-services/itunes/dev/stdeula/). Estas condições "
            "completam-no. Em caso de contradição, prevalece o contrato da Apple.",
        ]),
        ("A sua utilização", [
            "É responsável pelo que envia e pelos dispositivos para onde o envia. Envie só o que tem direito a "
            "partilhar. Não use o RoomSend para transmitir conteúdos ilícitos, incomodar alguém ou chegar a um "
            "dispositivo sem o consentimento do dono.",
            "Numa rede que não conhece, é melhor desativar «Visível nesta Wi-Fi» e «Aceitar automaticamente».",
        ]),
        ("Rede e segurança", [
            "O RoomSend depende da sua rede local: uma rede que isola os dispositivos, ou uma firewall, pode "
            "impedir a pesquisa ou as transferências. As transferências são cifradas por predefinição. A "
            "partilha por ligação usa HTTP simples e pode ser lida pelas pessoas da mesma rede.",
            "Uma transferência pode falhar ou ser interrompida: guarde uma cópia dos seus ficheiros importantes.",
        ]),
        ("LocalSend", [
            "O RoomSend é uma app independente. Não é publicada, aprovada nem apoiada pelo projeto LocalSend, "
            "cujo nome só é citado para indicar a compatibilidade. As outras apps evoluem: não garantimos a "
            "compatibilidade com cada uma das suas versões.",
        ]),
        ("Disponibilidade e garantia", [
            "A app é fornecida gratuitamente, tal como está. Corrigimo-la e melhoramo-la, sem garantir que "
            "funcione sem interrupções nem erros, nem que sirva um uso específico. Podemos alterá-la ou deixar "
            "de a distribuir.",
        ]),
        ("Responsabilidade", [
            "Na medida em que a lei o permita, não assumimos responsabilidade por danos ligados ao uso do "
            "RoomSend, em particular perdas de dados ou conteúdos recebidos de outro dispositivo. Este limite "
            "não se aplica a danos causados intencionalmente ou por negligência grave (art. 100.º do Código "
            "das Obrigações suíço), nem onde a lei o proíba.",
        ]),
        ("Propriedade intelectual", [
            "O nome RoomSend, o ícone, o design e o código pertencem ao editor. O que envia continua a ser seu: "
            "nunca temos acesso a isso.",
        ]),
        ("Alterações", [
            "Podemos alterar estas condições. A versão em vigor é publicada aqui e na app, com a data. Se "
            "recusar uma nova versão, deixe de usar a app e apague-a.",
        ]),
        ("Lei aplicável e foro", [
            "Estas condições regem-se pelo direito suíço. O foro é o domicílio do editor. Se for consumidor, "
            "mantém a proteção das normas imperativas do seu país de residência e pode recorrer aos seus "
            "tribunais.",
        ]),
    ],
}
