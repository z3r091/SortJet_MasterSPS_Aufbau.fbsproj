(* METADATA
{
	"v3Meta": {
		"objectGuid": "b8d8b63a-039c-49d7-ab0c-8520bb128b08"
	}
}
*)
FUNCTION_BLOCK Shuttle_Querfahrt
VAR_INPUT

  // BOOLEAN
  bpReset                : BOOL;

  // WORD
  wStation               : WORD;

  // STRUKTUR
  Auftragsdaten          : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  // BOOL
  bpDone                 : BOOL;
  bpFehler               : BOOL;

END_VAR
VAR

  // STEPS
  steplSchritt                    : STEPS_TE;

  // BAUSTEINE
  PositionierAuftragsdatenPruefen : PositionierAuftragsdatenPruefen;

END_VAR
// ****************************************************9*********************************************
// STEUERUNG: POSITIONIEREN
// *************************************************************************************************

IF ( Auftragsdaten.wAuftrag = eStation_Vorabpositionierung ) THEN
  CASE steplSchritt OF
    // POSITIONIERUNG ===========================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrShuttleBasisParameter[wStation]) THEN

        IF ( ABS( starrShuttleBasisParameter[wStation].rAktuellePositionQuerfahrt - Auftragsdaten.rVorabPosition ) <= rgMKZielPositionToleranz ) THEN
          steplSchritt := STEP_500_E;
        ELSIF starrShuttleBasisParameter[wStation].stMKs.bDeaktivieren THEN
          steplSchritt := STEP_600_E;
        ELSE
          steplSchritt := STEP_10_E;
        END_IF

      END_IF

    // POSITIONIERUNG ===========================================
    STEP_5_E:
      (* Hinweis:
         - Auftragsdaten pruefen
           => Version der Verfahrlogik beachten
      *)
      steplSchritt := STEP_10_E;

      PositionierAuftragsdatenPruefen.rpSollPosition   := Auftragsdaten.rVorabPosition;
      PositionierAuftragsdatenPruefen.wpStationsNummer := wStation;

      PositionierAuftragsdatenPruefen();

      IF ( NOT PositionierAuftragsdatenPruefen.bpErgebnis ) THEN
        steplSchritt := STEP_900_E;
      END_IF

    // POSITIONIERUNG ===========================================
    STEP_10_E:
      (* Hinweis:
         - Uebergabe der Auftragsdaten
      *)
      starrShuttleBasisParameter[wStation].pAuftragVorabPositionierung := Auftragsdaten;
      starrShuttleBasisParameter[wStation].bVorabpositionieren := TRUE;

      steplSchritt := STEP_20_E;

    // POSITIONIERUNG ===========================================
    STEP_20_E:
      (* Hinweis:
         - Nachricht absetzen
      *)
      IF ( starrShuttleBasisParameter[wStation].bUpdateVorabPositionieren = TRUE ) THEN

        wSps2MmiQuittVorabShuttleNr := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
        rgSPS2MMIExtractionShuttlePosition := starrShuttleBasisParameter[wStation].rAktuellePositionQuerfahrt;
        MsgToMmi(auftragsnr_w := SB0_SPS_SHUTTLEVORABPOSITIONIERUNGUPDATE );// Quit 2 MMI Scheibe vorne

        starrShuttleBasisParameter[wStation].bUpdateVorabPositionieren := FALSE;

        steplSchritt := STEP_100_E;

      END_IF

      (* Fehlerbehandlung:
         - Inputshuttle
      *)
      IF ( starrShuttleBasisParameter[wStation].bFehler ) THEN

        starrShuttleBasisParameter[wStation].bVorabpositionieren := FALSE;

        SpsError( eFehler_Station,
                  starrShuttleBasisParameter[wStation].wFehlerNummer,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrShuttleBasisParameter[wStation].awFehlerInformationen );

        steplSchritt := STEP_900_E;
      END_IF

    // POSITIONIERUNG ===========================================
    STEP_100_E:
      (* Hinweis:
         - Positionierung abgeschlossen
           => Nachricht absetzen
      *)
      IF ( starrShuttleBasisParameter[wStation].bVorabpositionierenAbgeschlossen ) THEN

        starrShuttleBasisParameter[wStation].bVorabpositionieren := FALSE;

        wSps2MmiQuittVorabShuttleNr        := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
        rgSPS2MMIExtractionShuttlePosition := starrShuttleBasisParameter[wStation].rAktuellePositionQuerfahrt;
        MsgToMmi(auftragsnr_w := SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG );

        steplSchritt := STEP_1000_E;

      END_IF

      (* Fehlerbehandlung:
         - Inputshuttle
      *)
      IF ( starrShuttleBasisParameter[wStation].bFehler ) THEN
        starrShuttleBasisParameter[wStation].bVorabpositionieren := FALSE;

        SpsError( eFehler_Station,
                  starrShuttleBasisParameter[wStation].wFehlerNummer,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrShuttleBasisParameter[wStation].awFehlerInformationen );

        steplSchritt := STEP_900_E;
      END_IF

    // POSITIONIERUNG ===========================================
    STEP_500_E:
      wSps2MmiQuittVorabShuttleNr := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := starrShuttleBasisParameter[wStation].rAktuellePositionQuerfahrt;
      MsgToMmi(auftragsnr_w := SB0_SPS_SHUTTLEVORABPOSITIONIERUNGUPDATE );
      steplSchritt := STEP_510_E;

    // POSITIONIERUNG ===========================================
    STEP_510_E:
      wSps2MmiQuittVorabShuttleNr        := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := starrShuttleBasisParameter[wStation].rAktuellePositionQuerfahrt;
      MsgToMmi(auftragsnr_w := SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG );
      steplSchritt := STEP_1000_E;

    // POSITIONIERUNG ===========================================
    STEP_600_E:
      wSps2MmiQuittVorabShuttleNr := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := Auftragsdaten.rVorabPosition;
      MsgToMmi(auftragsnr_w := SB0_SPS_SHUTTLEVORABPOSITIONIERUNGUPDATE );
      steplSchritt := STEP_610_E;

    // POSITIONIERUNG ===========================================
    STEP_610_E:
      wSps2MmiQuittVorabShuttleNr        := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      rgSPS2MMIExtractionShuttlePosition := Auftragsdaten.rVorabPosition;
      MsgToMmi(auftragsnr_w := SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG );
      steplSchritt := STEP_1000_E;

    // POSITIONIERUNG ===========================================
    STEP_900_E:
      bpFehler := TRUE;

    // POSITIONIERUNG ===========================================
    STEP_1000_E:
      bpDone := TRUE;
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

  // POSITIONIERUNG ===========================================
  END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpDone := FALSE;
  bpReset := FALSE;
  starrShuttleBasisParameter[wStation].bUpdateVorabPositionieren := FALSE;
  starrShuttleBasisParameter[wStation].bVorabpositionieren := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK