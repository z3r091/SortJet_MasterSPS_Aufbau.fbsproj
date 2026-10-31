(* METADATA
{
  "v3Meta": {
    "objectGuid": "bbc15bee-7f2f-43fc-826d-24e7f6394171"
  }
}
*)
FUNCTION_BLOCK Zentralschmierung_DLS_4xxi_FB
VAR_INPUT
	
	// BOOLEAN 
	bpStartSchmierungHand  : BOOL;
	bpReset                : BOOL;
	bpFreigabe             : BOOL;
	bpTeilnehmerErreichbar : BOOL;
	bpAktivieren           : BOOL;
	
	// DINT
	dipAktuelleAntriebsPosition : DINT; // Istposition des Shuttles 
	
	// POINTER 
	ppParameterBaustein : REFERENCE TO Parameter_Zentralschmierung_DLS_4xxi; 

    // STRUKTUR 
	stStationsNummern : Station_ST;
END_VAR
VAR_OUTPUT
	
	// BOOLEAN 
	bpFehler         : BOOL; // Die Pumpe meldet einen Fehler 
	bpInternerFehler : BOOL; // Der SPS-Baustein meldet einen Fehler 
	
END_VAR
VAR
	// BOOLEAN 
	blErsterZyklus            : BOOL := TRUE;
	blStarteSchmierung        : BOOL; // Schrittketten-starter zur Schmierung 
	blFettLeer                : BOOL; // Merker wenn 1Hz Signal an Status anliegt 
	blSchmierhubOk            : BOOL;
	blSchmierhubOkBaldLeer    : BOOL;
	blKeineOderLeereKartusche : BOOL;
	blGeraeteFehler           : BOOL;
	ablStarteKreis            : ARRAY[cSCHMIERKREIS_1..cSCHMIERKREIS_2] OF BOOL;
	ablPauseStarten           : ARRAY[cSCHMIERKREIS_1..cSCHMIERKREIS_2] OF BOOL;
	ablHubAktiv               : ARRAY[cSCHMIERKREIS_1..cSCHMIERKREIS_2] OF BOOL;
	
	// DINT
	diAltePosition        : DINT; // Vergleichsposition ALT für Schmierung 
	diNeuePosition        : DINT; // Vergleichsposition NEU für Schmierung 
	adiGefahrenerWeg      : ARRAY[cSCHMIERKREIS_1..cSCHMIERKREIS_2] OF DINT; // Aktuell gefahrener Weg seit letzter Schmierung der Zahnstange
	diPositionsUnterschied : DINT; // Unterschied der Vergleichspositionen 
	
	// INT
	ailAktiverHub : ARRAY[cSCHMIERKREIS_1..cSCHMIERKREIS_2] OF INT; // Aktueller Hub der durchgeführt wird wenn Schmierung aktiv 
	
    // WORD 
	wlIndex : WORD;
	
	// TIMER
	tonlWartezeitBisFehler            : TON; // Wartezeit bis ein Fehler generiert wird 
	tonlSteuerSignal_Reset_Starten    : TON; // Dauer, die das Steuersignal anstehen muss, um einen Reset durchzuführen 
	tonlWartezeitFuerSchmierHub       : TON; // Wartezeit, bis der Hub von der Pumpe komplett durchgeführt wurde 
	tonlSchmierungBetriebsbereit      : TON;
	tonlSchmierungNichtBetriebsbereit : TON;	
	tonSchmierkreisAnsteuerung        : TON; // NEU Ausschaltverzögerung um 2s,5s, ... ansteuerung zu ermöglischen
	tonlFunktionskontrolle            : TON; //NEU Einschaltverzögerung für die Funktionskontrolle welche nach jedem Hub überprüft werden muss 
	atoflPause                        : ARRAY[cSCHMIERKREIS_1..cSCHMIERKREIS_2] OF TOF;
	
	// TIME
	tAnsteuern: TIME; // NEU Steuersignal zum auswählend es Schmierkreises Zeit wird im Baustein Schmierung deffiniert
	
	/// TRIGGER 
	rtlStarteSchmierung     : R_TRIG;
	ftlSignal               : F_TRIG;
	rtlSignal               : R_TRIG;
	rtlFunktionskontrolle   : R_TRIG; //Steige nde Flankenerkennung für die Funktionskontrolle
	rtlStarteHandschmierung : R_TRIG;
	rtlMeldungFehlerPumpe   : R_TRIG;
	artlPause               : ARRAY[cSCHMIERKREIS_1..cSCHMIERKREIS_2] OF R_TRIG; //Triger für die pausen tof´s damit diese nicht manuel resettet werden müssen
	
	//Bausteine
	Taktberechnung  : Taktberechnung_FB;
	
	// STEPS 
	steplSchmierung : STEPS_TE;
	steplReset      : STEPS_TE;
	
    //  STRING 
	slInLogString: STRING;
	
   //Ein/Ausgänge zum Mappen in der Config 
	in_bStatus        : BOOL; // Signal, dass die Schmierung erfolgreich ist, oder Fehlersignal 
	out_bSteuerSignal : BOOL; // Ausgang der die Zentralschmierung ansteuert 
END_VAR

VAR CONSTANT
	
	tPause           : TIME := TIME#10M0S0MS; // Zeitwert, die pausiert werden muss, wenn wAnzahlHuebeBisGrossePause erreicht wurde 
	tResetStarten    : TIME := TIME#10S0MS; // Steuersignal zum starten des Resets 
	tDauerEinHub     : TIME := TIME#30S0MS; //14,25für Hub ok, Zeitwert wie lange ein Hub der Schmierpumpe dauert 
	tAnsteuernKreise : ARRAY[cSCHMIERKREIS_1..cSCHMIERKREIS_1_2] OF TIME := [TIME#2S0MS, TIME#5S0MS, TIME#8S0MS];

	iAnzahlHuebeBisGrossePause: INT := 10; // Anzahl der Hübe bis tPause gewartet werden muss für weitere Hübe 
END_VAR

(***************************************************************************************************)
(* INITIALISIERUNG *)
(***************************************************************************************************)
IF ( blErsterZyklus ) THEN
  blErsterZyklus                    := FALSE;
  diAltePosition                    := dipAktuelleAntriebsPosition;
  IF stStationsNummern.NummerSPS < cERSTES_TRANSFERSHUTTLE THEN
    adiGefahrenerWeg[cSCHMIERKREIS_1] := PersistentVars.digGefahrenerWegShuttle[cSCHMIERKREIS_1, stStationsNummern.NummerSPS] * 1000;
    adiGefahrenerWeg[cSCHMIERKREIS_2] := PersistentVars.digGefahrenerWegShuttle[cSCHMIERKREIS_2, stStationsNummern.NummerSPS] * 1000;
  ELSE
    adiGefahrenerWeg[cSCHMIERKREIS_1] := PersistentVars.digGefahrenerWegTransferShuttle[cSCHMIERKREIS_1, stStationsNummern.NummerSPS] * 1000;
    adiGefahrenerWeg[cSCHMIERKREIS_2] := PersistentVars.digGefahrenerWegTransferShuttle[cSCHMIERKREIS_2, stStationsNummern.NummerSPS] * 1000;
  END_IF
END_IF


(***************************************************************************************************)
(* BAUSTEIN: AKTIVIERUNG *)
(***************************************************************************************************)
IF NOT bpAktivieren THEN
  RETURN;
END_IF

(***************************************************************************************************)
(* AKTIONEN *)
(***************************************************************************************************)
Timer();
WegErkennung();
Schmiervorgang();
Meldungen();
Reset();
END_FUNCTION_BLOCK