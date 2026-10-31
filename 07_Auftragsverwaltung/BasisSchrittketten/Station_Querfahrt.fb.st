(* METADATA
{
  "v3Meta": {
    "objectGuid": "54d45b69-8d91-483b-a87f-7b1de952ab2e"
  }
}
*)
FUNCTION_BLOCK Station_Querfahrt
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
  
  (* BAUSTEINE *)
  PositionierAuftragsdatenPruefen : PositionierAuftragsdatenPruefen;

END_VAR

(*****************************************************9**********************************************)
(* STEUERUNG: POSITIONIEREN *)
(***************************************************************************************************)

IF ( Auftragsdaten.wAuftrag = eStation_Vorabpositionierung ) THEN
  CASE steplSchritt OF
(* POSITIONIERUNG ===========================================*)
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
		  
        IF ( ABS( starrStationBasisParameter[wStation].rAktuellePositionQuerfahrt - Auftragsdaten.rVorabPosition ) <= rgMKZielPositionToleranz ) THEN
          steplSchritt := STEP_500_E;
        ELSE
          steplSchritt := STEP_10_E;
        END_IF
		
      END_IF

(* POSITIONIERUNG ===========================================*)
    STEP_5_E:
      (* Hinweis:
         - Auftragsdaten pruefen 
           => Version der Verfahrlogik beachten
      *)
      steplSchritt := STEP_10_E;

      PositionierAuftragsdatenPruefen.pPositionierAuftragsdaten := Auftragsdaten.pPositionierAuftrag;
      PositionierAuftragsdatenPruefen.pAntriebsinformationen    := starrStationBasisParameter[wStation].stAntriebsparameter.stQuerfahrt;

      PositionierAuftragsdatenPruefen();

      IF ( NOT PositionierAuftragsdatenPruefen.bpErgebnis ) THEN
        steplSchritt := STEP_900_E;
      END_IF

(* POSITIONIERUNG ===========================================*)
    STEP_10_E:
      (* Hinweis:
         - Uebergabe der Auftragsdaten
      *)
      starrStationBasisParameter[wStation].pAuftragVorabPositionierung := Auftragsdaten;
      starrStationBasisParameter[wStation].bVorabpositionieren := TRUE;
        
      steplSchritt := STEP_20_E;

(* POSITIONIERUNG ===========================================*)
  STEP_20_E:
    (* Hinweis:
       - Nachricht absetzen
    *)
    IF ( starrStationBasisParameter[wStation].bUpdateVorabPositionieren = TRUE ) THEN

      wSps2MmiQuittVorabShuttleNr := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := starrStationBasisParameter[wStation].rAktuellePositionQuerfahrt;
      MsgToMmi(auftragsnr_w := SB0_SPS_SHUTTLEVORABPOSITIONIERUNGUPDATE );(* Quit 2 MMI Scheibe vorne*)

      starrStationBasisParameter[wStation].bUpdateVorabPositionieren := FALSE;

      steplSchritt := STEP_100_E;

    END_IF

     (* Fehlerbehandlung:
       - Inputshuttle
     *)
     IF ( starrStationBasisParameter[wStation].bFehler ) THEN

       starrStationBasisParameter[wStation].bVorabpositionieren := FALSE;

       SpsError( eFehler_Station,
                 starrStationBasisParameter[wStation].wFehlerNummer,
                 starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                 AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                 starrStationBasisParameter[wStation].awFehlerInformationen );

       steplSchritt := STEP_900_E;
     END_IF

(* POSITIONIERUNG ===========================================*)
    STEP_100_E:
      (* Hinweis:
         - Positionierung abgeschlossen
           => Nachricht absetzen
      *)
      IF ( starrStationBasisParameter[wStation].bVorabpositionierenAbgeschlossen ) THEN

        starrStationBasisParameter[wStation].bVorabpositionieren := FALSE;

        wSps2MmiQuittVorabShuttleNr        := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
        rgSPS2MMIExtractionShuttlePosition := starrStationBasisParameter[wStation].rAktuellePositionQuerfahrt;
        MsgToMmi(auftragsnr_w := SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG );

        steplSchritt := STEP_1000_E;

     END_IF

     (* Fehlerbehandlung:
       - Inputshuttle
     *)
     IF ( starrStationBasisParameter[wStation].bFehler ) THEN
       starrStationBasisParameter[wStation].bVorabpositionieren := FALSE;

       SpsError( eFehler_Station,
                 starrStationBasisParameter[wStation].wFehlerNummer,
                 starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                 AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                 starrStationBasisParameter[wStation].awFehlerInformationen );

       steplSchritt := STEP_900_E;
     END_IF

(* POSITIONIERUNG ===========================================*)
    STEP_500_E:
      wSps2MmiQuittVorabShuttleNr := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := starrStationBasisParameter[wStation].rAktuellePositionQuerfahrt;
      MsgToMmi(auftragsnr_w := SB0_SPS_SHUTTLEVORABPOSITIONIERUNGUPDATE );
      steplSchritt := STEP_510_E;

(* POSITIONIERUNG ===========================================*)
    STEP_510_E:
      wSps2MmiQuittVorabShuttleNr        := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := starrStationBasisParameter[wStation].rAktuellePositionQuerfahrt;
      MsgToMmi(auftragsnr_w := SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG );
      steplSchritt := STEP_1000_E;

(* POSITIONIERUNG ===========================================*)
    STEP_900_E:
      bpFehler := TRUE;

(* POSITIONIERUNG ===========================================*)
    STEP_1000_E:
      bpDone := TRUE;
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

(* POSITIONIERUNG ===========================================*)
  END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpDone   := FALSE;
  bpReset  := FALSE;
  Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;
  starrStationBasisParameter[wStation].bUpdateVorabPositionieren := FALSE;
  starrStationBasisParameter[wStation].bVorabpositionieren := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK