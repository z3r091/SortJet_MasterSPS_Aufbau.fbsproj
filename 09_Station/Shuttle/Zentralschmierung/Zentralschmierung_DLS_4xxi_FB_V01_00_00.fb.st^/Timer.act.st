(* METADATA
{
	"v3Meta": {
		"objectGuid": "95ed7381-25e7-4c45-94c5-f25520f75bb5"
	}
}
*)
ACTION Timer
//-------------------------------------------------------------------------------------------------
// TIMER, EINSTELLUNGEN, ETC.
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Die  DLS-4xx-i sendet an PIN 4 ein permanentes Ausgangssignal (high-Pegel), welches der externen Steuerung (SPS)
     die Betriebsbereitschaft anzeigt. Dieses Ausgangssignal muss >3 Sekunden permanent und ununterbrochen anliegen. Nur
     bei Vorliegen dieser Voraussetzung ist überhaupt ein Ansteuern durch die externe Steuerung möglich.
*)
tonlSchmierungBetriebsbereit( IN := ( in_bStatus OR blSchmierhubOkBaldLeer ) AND bpTeilnehmerErreichbar, PT := T#3100MS );
tonlSchmierungNichtBetriebsbereit( IN := NOT in_bStatus AND bpTeilnehmerErreichbar, PT := T#1M );

//Triger und tof für das auslösen der Pause von Schmierkreis 1
(* Hinweis:
   - Die Pause im Programm wurde so geschrieben, dass die einzelnen Schmierkreise seperat in eine Pause gehen können, ohne den anderen Schmierkreis zu beeinflussen.
*)
artlPause[cSCHMIERKREIS_1] ( CLK := ablPauseStarten[cSCHMIERKREIS_1] );
atoflPause[cSCHMIERKREIS_1](IN := artlPause[cSCHMIERKREIS_1].Q, PT := tPause);

//Triger und tof für das auslösen der Pause von Schmierkreis 2 

artlPause[cSCHMIERKREIS_2]( CLK := ablPauseStarten[cSCHMIERKREIS_2]  );
atoflPause[cSCHMIERKREIS_2](IN := artlPause[cSCHMIERKREIS_2].Q, PT := tPause);


rtlStarteHandschmierung (CLK := bpStartSchmierungHand);
rtlMeldungFehlerPumpe(CLK := blGeraeteFehler);
END_ACTION