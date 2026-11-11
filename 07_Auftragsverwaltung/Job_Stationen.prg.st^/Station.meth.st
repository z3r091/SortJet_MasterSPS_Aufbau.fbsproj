(* METADATA
{
	"v3Meta": {
		"objectGuid": "6e43b8d4-0bae-4a3f-b309-8e06ab9993e4"
	}
}
*)
METHOD INTERNAL Station
VAR_INPUT
  wStation : WORD;
  wWand    : WORD;
END_VAR

// ****************************************************9*********************************************
// STEUERUNG: ANLEGEN
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Anlegen ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Anlegen[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], bpAbbruchAnlegeauftrag := abpAbbruchAnlegeauftrag[wStation], wStation := wStation);
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Anlegen[wStation, wWand].bpDone THEN
    abpAbbruchAnlegeauftrag[wStation] := FALSE;
    AuftragsdatenWand[wStation, wWand] := Anlegen[wStation, wWand].Auftragsdaten;
    Anlegen[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Anlegen[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Anlegen[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Anlegen[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: ABNEHMEN
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Abnehmen ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Abnehmen[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation);
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Abnehmen[wStation, wWand].bpDone THEN
    abpAbbruchAnlegeauftrag[wStation] := FALSE;
    AuftragsdatenWand[wStation, wWand] := Abnehmen[wStation, wWand].Auftragsdaten;
    Abnehmen[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Abnehmen[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Abnehmen[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Abnehmen[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: HÖHENMESSUNG
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Hoehenmessung ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Glashoehenmessung[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, bpAbbruchAnlegeauftrag := abpAbbruchAnlegeauftrag[wStation]);
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Glashoehenmessung[wStation, wWand].bpDone THEN
    abpAbbruchAnlegeauftrag[wStation] := FALSE;
    AuftragsdatenWand[wStation, wWand] := Glashoehenmessung[wStation, wWand].Auftragsdaten;
    Glashoehenmessung[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Glashoehenmessung[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Glashoehenmessung[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Glashoehenmessung[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: LÄNGENMESSUNG
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Messfahrt ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Glaslaengenmessung[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, bpAbbruchAnlegeauftrag := abpAbbruchAnlegeauftrag[wStation] );
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Glaslaengenmessung[wStation, wWand].bpDone THEN
    abpAbbruchAnlegeauftrag[wStation] := FALSE;
    AuftragsdatenWand[wStation, wWand] := Glaslaengenmessung[wStation, wWand].Auftragsdaten;
    Glaslaengenmessung[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Glaslaengenmessung[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Glaslaengenmessung[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Glaslaengenmessung[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: Eintransport
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Eintransport ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Eintransport[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, wWand := wWand);
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Eintransport[wStation, wWand].bpDone THEN
    AuftragsdatenWand[wStation, wWand] := Eintransport[wStation, wWand].Auftragsdaten;
    Eintransport[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Eintransport[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Eintransport[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Eintransport[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: AUSTRANSPORT
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Austransport ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Austransport[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, wWand := wWand);
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Austransport[wStation, wWand].bpDone THEN
    AuftragsdatenWand[wStation, wWand] := Austransport[wStation, wWand].Auftragsdaten;
    Austransport[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Austransport[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Austransport[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Austransport[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: DURCHTRANSPORT
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Durchtransport ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Durchtransport[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, wWand := wWand);
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Durchtransport[wStation, wWand].bpDone THEN
    AuftragsdatenWand[wStation, wWand] := Durchtransport[wStation, wWand].Auftragsdaten;
    Durchtransport[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Durchtransport[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Durchtransport[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Durchtransport[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: Vortransport
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Vortransport ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Vortransport[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, wWand := wWand);
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Vortransport[wStation, wWand].bpDone THEN
    AuftragsdatenWand[wStation, wWand] := Vortransport[wStation, wWand].Auftragsdaten;
    Vortransport[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Vortransport[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Vortransport[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Vortransport[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: TRANSPORTKOPPLUNG
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Transportkopplung ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Transportkopplung[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, wWand := wWand);
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Transportkopplung[wStation, wWand].bpDone THEN
    AuftragsdatenWand[wStation, wWand] := Transportkopplung[wStation, wWand].Auftragsdaten;
    Transportkopplung[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Transportkopplung[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Transportkopplung[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Transportkopplung[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF
// ****************************************************9*********************************************
// STEUERUNG: MESSKOPPLUNG
// *************************************************************************************************

IF ( AuftragsdatenWand[wStation, wWand].wAuftrag = eStation_Messkopplung )
THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Messkopplung[wStation, wWand]( Auftragsdaten := AuftragsdatenWand[wStation, wWand], wStation := wStation, wWand := wWand);
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Transportkopplung[wStation, wWand].bpDone THEN
    AuftragsdatenWand[wStation, wWand] := Messkopplung[wStation, wWand].Auftragsdaten;
    Messkopplung[wStation, wWand](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, wWand] := Messkopplung[wStation, wWand].bpFehler;
  IF rtlFehler[wStation, wWand].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Messkopplung[wStation, wWand].steplSchritt > STEP_0_E ) THEN
    Messkopplung[wStation, wWand](bpReset := TRUE);
  END_IF
END_IF

// ****************************************************9*********************************************
// STEUERUNG: QUERFAHRT
// *************************************************************************************************

IF ( AuftragsdatenStation[wStation].wAuftrag = eStation_Vorabpositionierung ) THEN
  (* Hinweis:
     - Aufruf der Schrittkette
  *)
  Querfahrt[wStation]( Auftragsdaten := AuftragsdatenStation[wStation], wStation := wStation );
  (* Hinweis:
     - Abschluss der Schrittkette
  *)
  IF Querfahrt[wStation].bpDone THEN
    AuftragsdatenStation[wStation] := Querfahrt[wStation].Auftragsdaten;
    Querfahrt[wStation](bpReset := TRUE);
  END_IF
  (* Hinweis:
     - Fehler-Auswertung
  *)
  ablFehler[wStation, cWAND_1] := Querfahrt[wStation].bpFehler;
  IF rtlFehler[wStation, cWAND_1].Q THEN
    AutomatikFehlerSetzen(starrStationBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis:
     - Reset der Schrittkette
  *)
  IF ( Querfahrt[wStation].steplSchritt <> STEP_0_E ) THEN
    Querfahrt[wStation](bpReset := TRUE);
  END_IF
END_IF
END_METHOD