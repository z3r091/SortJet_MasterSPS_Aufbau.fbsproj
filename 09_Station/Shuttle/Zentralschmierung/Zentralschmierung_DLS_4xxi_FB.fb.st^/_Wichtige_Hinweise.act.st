(* METADATA
{
  "v3Meta": {
    "objectGuid": "7eb8ada6-5c0d-4871-bc45-bbcb792cf782"
  }
}
*)
ACTION _Wichtige_Hinweise
;
(*

Frühestens >3 Sekunden nach Ende des fehlerfreien und erfolgreichen Motorlaufes
kann von der externen Steuerung (SPS) ein mögliches nächstes Steuersignal gesendet
werden. In der Zwischenzeit verarbeitet die FlexxPump 125 keine Steuersignale.

Um ein sicheres und eindeutiges Erkennen des Steuersignales zu gewährleisten,
muss eine Pause eingehalten werden. Für das Steuersignal 2 Sekunden gilt bei der
FlexxPump 125 eine Pausenzeit (Tp) zwischen zwei gleichartigen oder verschiedenen
Steuersignalen von mindestens 22 Sekunden.

Um ein sicheres und eindeutiges Erkennen des Steuersignales zu gewährleisten,
muss eine Pause eingehalten werden. Für das Steuersignal 12 Sekunden gilt bei der
FlexxPump 125 eine Pausenzeit (Tp) zwischen zwei gleichartigen oder verschiedenen 
Steuersignalen von mindestens 706 (Tp=MLmaxx40 Hübe+Px40 Hübe+Toleranz) Sekunden.









Nach 24,5 km sollen die Führungswagen mit 20 Hüben geschmiert werden. Dabei werden diese 20 Hübe 
aufgeteilt: -  in 2x 10 Hübe mit einer Pause von 10min dazwischen. 
Um ein Hub zu programmieren wird ein 2s Steuersignal benötig. Nach dem die Pumpe 1 Hub ausgeführt 
hat ( Dauer ca. -22-28s) kann anschließend das nächste Steuersignal für den 2 Hub gesendet 
werden usw.  . bis Zehn Hübe programmiert sind, dann Pause 10min, dann die weiteren 10 Hübe - 
siehe Anhang: Bedienungsanleitung Kapitel 8.2.1 (und Ausschnitt unten).

Die neue Pumpe kann mit verschieden langen Steuersignalen zwischen 2 Schmierkreisen unterscheiden:
- 2s Steuersignal = Schmierkreis 1 Zahnstange
- 5s Steuersignal = Schmierkreis 2 Führungsbahn
- 8s Steuersignal = Schmierkreis 1 und Schmierkreis 2
- 10s Steuersignal=	Reset
- 12s Steuersignal=	Fill

Bisher ist im Programm implementiert, dass beim Schmierkreis 1 und 2 auch 20 Hübe ausgeführt werden sollen. Dass kann optimiert werden, da beim Shuttle Schmierkreis 1 nur 5 Hübe benötigt.
Außerdem ist das Unterprogramm erst nur für die Zentralschmierung des Shuttles angepasst für das Unterfuhrshuttle ist die Zentralschmierung noch nicht erweitert.

*)
END_ACTION