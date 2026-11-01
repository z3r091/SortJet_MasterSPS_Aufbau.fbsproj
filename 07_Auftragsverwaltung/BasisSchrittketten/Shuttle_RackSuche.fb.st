(* METADATA
{
  "v3Meta": {
    "objectGuid": "f075b551-e071-4bf5-ac95-2cac71043e2d"
  }
}
*)
FUNCTION_BLOCK Shuttle_RackSuche
VAR_INPUT
    
  (* BOOLEAN *)
  bpReset                : BOOL;
  
  (* WORD *)
  wStation               : WORD;
  
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
(*  STEUERUNG VORABKOMPONENETEN *)
(***************************************************************************************************)

IF ( Auftragsdaten.wAuftrag = eStation_RackSuche ) THEN

  (* Fehlerbehandlung:
     - Inputshuttle
  *)
  IF starrShuttleBasisParameter[wStation].bFehler AND steplSchritt <> STEP_900_E THEN
    aShuttle[wStation].bpStarteFaecherwagensuche := FALSE;
    SpsError( eFehler_Station, 
              starrShuttleBasisParameter[wStation].wFehlerNummer, 
              starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
              AutomatikkreisBestimmen(wStation), 
              starrShuttleBasisParameter[wStation].awFehlerInformationen );
          
    steplSchritt := STEP_900_E;
  END_IF

  CASE steplSchritt OF
    (* RACKSUCHE ===========================================*)
    STEP_0_E:
      (* Hinweis:
         - Pruefen ob der Sicherheitskreis ausgeloest oder angefragz wurde
      *)
      IF checkSafetyCircuitsNotBlocked(starrShuttleBasisParameter[wStation]) THEN
        steplSchritt := STEP_10_E;
      END_IF

    (* RACKSUCHE ===========================================*)
    STEP_10_E:
      (* Hinweis:
         - Starten der Schrittkette -> MMI Fährt mittel Shuttlepositionierung den Weg ab 
      *)
      aShuttle[wStation].bpStarteFaecherwagensuche := TRUE;

      steplSchritt := STEP_100_E;

    (* RACKSUCHE ===========================================*)
    STEP_100_E:
      (* Hinweis:
          Fächerwagensuche: Wort 0 = (int) SPS Nr Shuttle  / Wort 1+2 = (real) Position rechte (?) Kante der Folie[-1 für nicht gefunden]
           => Nachricht absetzen
      *)
      IF ( aShuttle[wStation].bpFaecherwagenGefunden ) THEN

        wSps2MmiStationsNummer     := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
        rSps2MmiShuttlePosition[0] := aShuttle[wStation].rpAktuelleFaecherwagenPosition;
        MsgToMmi(auftragsnr_w := SB0_SPS_POSITIONMEASUREDATA );

        steplSchritt := STEP_1000_E;

      END_IF

    (* RACKSUCHE ===========================================*)
    STEP_900_E:
      bpFehler := TRUE;

    (* RACKSUCHE ===========================================*)
    STEP_1000_E:
      bpDone := TRUE;
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

  (* RACKSUCHE ===========================================*)
  END_CASE

END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpDone := FALSE;
  bpReset := FALSE;
  aShuttle[wStation].bpStarteFaecherwagensuche := FALSE;
  IF (aShuttle[wStation].rpAktuelleFaecherwagenPosition = -100000)  THEN (* ungültige Rackposition von -10000 angeben da kein Rack gefunden  *)
    wSps2MmiStationsNummer     := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
    rSps2MmiShuttlePosition[0] := aShuttle[wStation].rpAktuelleFaecherwagenPosition;
    MsgToMmi(auftragsnr_w := SB0_SPS_POSITIONMEASUREDATA );
  END_IF
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK