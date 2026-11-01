(* METADATA
{
  "v3Meta": {
    "objectGuid": "302a3845-d7bd-4de5-be7f-afeb7baaa6cc"
  }
}
*)
FUNCTION_BLOCK TS_Querfahrt
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
(* STEUERUNG: POSITIONIERUNG *)
(***************************************************************************************************)
(* Hinweis [VERFAHRLOGIK]:
   - Das TS wird an eine mögliche neue Zielposition des nächsten echten Auftrages vorpositioniert, 
     weil das dazugehörige Transfershuttle noch besetzt ist durch einen anderen Auftrag
*)
IF ( Auftragsdaten.wAuftrag = eStation_Vorabpositionierung) THEN

  CASE steplSchritt OF
    (* POSITIONIERUNG ===========================================*)
    STEP_0_E:
      IF checkSafetyCircuitsNotBlocked(starrTransferShuttleBasisParameter[wStation])
         AND NOT starrTransfershuttleBasisParameter[wStation].bReset
      THEN

        IF ( ABS( starrTransfershuttleBasisParameter[wStation].rAktuellePositionQuerfahrt - Auftragsdaten.rVorabPosition ) <= rgMKZielPositionToleranz ) THEN
          steplSchritt := STEP_500_E;
        ELSIF starrTransfershuttleBasisParameter[wStation].stMKs.bDeaktivieren THEN
          steplSchritt := STEP_600_E;
        ELSE
          steplSchritt := STEP_10_E;
        END_IF

      END_IF

    (* POSITIONIERUNG ===========================================*)
    STEP_10_E: (* Positionere Shuttle  *)
      (* Hinweis:
         - Uebergabe der Auftragsdaten
      *)
      starrTransfershuttleBasisParameter[wStation].pAuftragVorabPositionierung := Auftragsdaten;
      aTransfershuttles[wStation].pAuftragsdatenPositionieren := Auftragsdaten.pPositionierAuftrag;
      starrTransfershuttleBasisParameter[wStation].bVorabpositionieren := TRUE;

      steplSchritt := STEP_20_E;

    (* POSITIONIERUNG ===========================================*)
    STEP_20_E:
      (* Hinweis:
         - Nachricht absetzen
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bUpdateVorabPositionieren = TRUE ) THEN

        wSps2MmiQuittVorabShuttleNr := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
        rgSPS2MMIExtractionShuttlePosition := starrTransfershuttleBasisParameter[wStation].rAktuellePositionQuerfahrt;
        MsgToMmi(auftragsnr_w := SB0_SPS_SHUTTLEVORABPOSITIONIERUNGUPDATE );(* Quit 2 MMI Scheibe vorne*)

        starrTransfershuttleBasisParameter[wStation].bUpdateVorabPositionieren := FALSE;

        steplSchritt := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
        - Inputshuttle
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bFehler ) THEN
        starrTransfershuttleBasisParameter[wStation].bVorabpositionieren := FALSE;

        SpsError( eFehler_Station,
                  starrTransfershuttleBasisParameter[wStation].wFehlerNummer,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrTransfershuttleBasisParameter[wStation].awFehlerInformationen );

        steplSchritt := STEP_900_E;
      END_IF

    (* POSITIONIERUNG ===========================================*)
    STEP_100_E:
      (* Hinweis:
         - Positionierung abgeschlossen
           => Nachricht absetzen
      *)
      IF NOT starrTransfershuttleBasisParameter[wStation].stMKs.bDeaktivieren THEN

        IF ( starrTransfershuttleBasisParameter[wStation].bVorabpositionierenAbgeschlossen ) THEN
          starrTransfershuttleBasisParameter[wStation].bVorabpositionieren := FALSE;

          wSps2MmiQuittVorabShuttleNr        := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          rgSPS2MMIExtractionShuttlePosition := aTransfershuttles[wStation].rpIstPositionNachPositionierung;
          MsgToMmi(auftragsnr_w := SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG );(* Quit 2 MMI Scheibe vorne*)

          steplSchritt := STEP_1000_E;
        END_IF

      ELSE

        IF ( starrTransfershuttleBasisParameter[wStation].bVorabpositionierenAbgeschlossen ) THEN
          starrTransfershuttleBasisParameter[wStation].bVorabpositionieren := FALSE;

          wSps2MmiQuittVorabShuttleNr        := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          rgSPS2MMIExtractionShuttlePosition := Auftragsdaten.rVorabPosition;
          MsgToMmi(auftragsnr_w := SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG );(* Quit 2 MMI Scheibe vorne*)

          steplSchritt := STEP_1000_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
        - Inputshuttle
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bFehler ) THEN
        starrTransfershuttleBasisParameter[wStation].bVorabpositionieren := FALSE;

        SpsError( eFehler_Station,
                  starrTransfershuttleBasisParameter[wStation].wFehlerNummer,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrTransfershuttleBasisParameter[wStation].awFehlerInformationen );

        steplSchritt := STEP_900_E;
      END_IF

    (* POSITIONIERUNG ===========================================*)
    STEP_500_E:
      wSps2MmiQuittVorabShuttleNr := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := starrTransfershuttleBasisParameter[wStation].rAktuellePositionQuerfahrt;
      MsgToMmi(auftragsnr_w := SB0_SPS_SHUTTLEVORABPOSITIONIERUNGUPDATE );(* Quit 2 MMI Scheibe vorne*)
      steplSchritt := STEP_510_E;

    (* POSITIONIERUNG ===========================================*)
    STEP_510_E:
      wSps2MmiQuittVorabShuttleNr        := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := starrTransfershuttleBasisParameter[wStation].rAktuellePositionQuerfahrt;
      MsgToMmi(auftragsnr_w := SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG );(* Quit 2 MMI Scheibe vorne*)
      steplSchritt := STEP_1000_E;

    (* POSITIONIERUNG ===========================================*)
    STEP_600_E:
      wSps2MmiQuittVorabShuttleNr := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := Auftragsdaten.rVorabPosition;
      MsgToMmi(auftragsnr_w := SB0_SPS_SHUTTLEVORABPOSITIONIERUNGUPDATE );(* Quit 2 MMI Scheibe vorne*)
      steplSchritt := STEP_610_E;

    (* POSITIONIERUNG ===========================================*)
    STEP_610_E:
      wSps2MmiQuittVorabShuttleNr        := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := Auftragsdaten.rVorabPosition;
      MsgToMmi(auftragsnr_w := SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG );(* Quit 2 MMI Scheibe vorne*)
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
  bpDone := FALSE;
  bpReset := FALSE;
  starrTransfershuttleBasisParameter[wStation].bUpdateVorabPositionieren := FALSE;
  starrTransfershuttleBasisParameter[wStation].bVorabpositionieren := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK