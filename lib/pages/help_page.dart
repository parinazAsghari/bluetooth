import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.93),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Help',
          style: TextStyle(
              fontSize: 20,
              color: Color(0xFF0C9869),
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withOpacity(0.7),
        iconTheme: const IconThemeData(
          color: Color(0xFF0C9869),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          // height: double.infinity,
          child: Column(
            children: [
              Image.asset(
                'assets/device_horizontal.jpg',
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                      TextSpan(
                        children: <InlineSpan>[
                           TextSpan(
                            text: 'ANLEITUNG:\n\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                "Um den Füllstand Ihrer Propangasfla-sche (5, 11 & 33 kg, sowie Flaschender Firma Campingaz) festzustellen,setzen Sie das Gerät im oberen Be-reich der Flasche auf (haftet durch in-tegrierte Magnete).\n"
                                "Nach Betätigen des Druckschalters leuchtet eine rote Kontrollleuchte.Nehmen Sie das Gerät von derFlasche ab und setzen es ein Stückweiter unten wieder an die Flasche.Sobald Sie den mit Flüssiggas befülltenBereich erreichen, wechselt die Kon-trolleuchte von rot auf grün. Der Mess-punkt des Füllstandes ist auf der er-habenen Mittellinie mit den beidenPfeilen auf dem Gerät erkennbar.Durch leichtes Auf- und Ab-bewegendes Gerätes, kann ein sehr genauerFüllstand bestimmt werden.\n\n",
                          ),
                          TextSpan(
                              text: 'HINWEISE:/n'
                                  'Bitte die Gummifläche auf der Rückseite stets sauber halten. Stark beschmutzte Gasflaschen, Rost oder Aufkleber auf der Flasche können die Funktion stören. Sollte ein Batteriewechsel notwendig sein, verwenden Sie bitte handelsübliche Lithium-Knopfzellen CR2032.\n\n'
                                  'TIPP: Silikonöl oder ein leichter Ölfilm auf der Flasche lässt das Gerät leichter auf der Oberfläche gleiten\n\n',
                              style: TextStyle(color: Color(0xFF0E8AEF))),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/helper_trash_underline.png',
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Expanded(
                          child: Text(
                            'Werfen Sie das Gerät keinesfalls in den normalen Hausmüll. Dieses Produkt unterliegtder europäischen Richtlinie 2002/96/EC WEEE (Waste Electrical and ElectronicEquipment).\n'
                            'Entsorgen Sie das Gerät über einen zugelassenen Entsorgungsbetrieb oder rüber Ihrekommunale Entsorgungseinrichtung. Beachten Sie die aktuell geltenden Vorschriften.Setzen Sie sich im Zweifelsfall mit Ihrer Entsorgungseinrichtung in Verbindung.',
                            style: TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/helper_trash.png',
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Expanded(
                          child: Text(
                            'Batterien dürfen nicht im Hausmüll entsorgt werden. Jeder Verbraucher ist gesetzlichverpflichtet, Batterien bei einer Sammelstelle seiner Gemeinde, seines Stadtteils oder imHandel abzugeben. Diese Verpflichtung dient dazu, dass Batterien einerumweltschonenden Entsorgung zugeführt werden können. Geben Sie Batterien nur imentladenen Zustand zurück.',
                            style: TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/helper_instruction.png',
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Expanded(
                          child: Text(
                            'Dieses Gerät entspricht der EU-Richtlinie 2014/34/EV.',
                            style: TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/helper_secure.png',
                        ),
                        const SizedBox(
                          width: 30,
                        ),
                        const Expanded(
                          child: Text(
                            'Dieses Produkt erfüllt die grundlegenden Sicherheits- und GesundheitsanforderungenEX ll 3 Ex nA llA T3 Gc\n',
                            style: TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // const Spacer(),

            ],
          ),
        ),
      ),
    );
  }
}
