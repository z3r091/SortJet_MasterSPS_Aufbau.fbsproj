(* METADATA
{
  "v3Meta": {
    "objectGuid": "9f1ab894-d35e-4a4e-8f77-3236b7a1099b"
  }
}
*)
FUNCTION_BLOCK Station_Vortransport
VAR_INPUT
    
  (* BOOLEAN *)
  bpReset                : BOOL;
  
  (* WORD *)
  wStation               : WORD;
  wWand                  : WORD;
  
  (* STRUKTUR *)
  Auftragsdaten          : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  (* BOOLEAN*)
  bpDone                 : BOOL;
  bpFehler               : BOOL;

END_VAR
VAR
    
  (* STEPS *)
  steplSchritt           : STEPS_TE;

END_VAR

(***************************************************************************************************)
(* STEUERUNG: EINTRANSPORT  *)
(***************************************************************************************************)
IF ( Auftragsdaten.wAuftrag = eStation_Vortransport ) THEN
  CASE steplSchritt OF
(* EINTRANSPORT ================================================== *)
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
        steplSchritt := STEP_10_E;
      END_IF

(* EINTRANSPORT ================================================== *)
    STEP_10_E:  
      (* Hinweis:
         - Vortransport starten
      *)
      (* Hinweis:
         Auftragsdaten zuweisen
      *)
      starrStationBasisParameter[wStation].pAuftrag[wWand] := Auftragsdaten;

      starrStationBasisParameter[wStation].bVortransport[wWand]    := TRUE;

      steplSchritt := STEP_20_E;

(* EINTRANSPORT ================================================== *)
    STEP_20_E:
      (* Hinweis:
         - Abschliessen des Eintransports
      *)
      IF ( starrStationBasisParameter[wStation].bVortransportAbgeschlossen[wWand] ) THEN
        starrStationBasisParameter[wStation].bVortransport[wWand] := FALSE;
        steplSchritt := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Station
      *)
      IF ( starrStationBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station, 
                  starrStationBasisParameter[wStation].wFehlerNummer, 
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern, 
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrStationBasisParameter[wStation].awFehlerInformationen );
        starrStationBasisParameter[wStation].bVortransport[wWand] := FALSE;
        steplSchritt := STEP_900_E;
      END_IF


(* EINTRANSPORT ================================================== *)
    STEP_900_E:
      bpFehler := TRUE;

(* EINTRANSPORT ================================================== *)
    STEP_1000_E:
      bpDone := TRUE;
      Auftragsdaten.wAuftrag := eStation_Warte_Auf_Austransport;

(* EINTRANSPORT ================================================== *)
 END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpReset := FALSE;
  bpDone := FALSE;
  steplSchritt := STEP_0_E;
  starrStationBasisParameter[wStation].bVortransport[wWand] := FALSE;
END_IF
END_FUNCTION_BLOCK