(* METADATA
{
  "v3Meta": {
    "objectGuid": "d4215ee0-47ee-45d9-8520-4f4f5fb6c469"
  }
}
*)
FUNCTION_BLOCK Station_Anlegen
VAR_INPUT
    
  // BOOLEAN
  bpReset                : BOOL;
  bpAbbruchAnlegeauftrag : BOOL;
  
  // WORD
  wStation               : WORD;
  
  // STRUKTUR
  Auftragsdaten          : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                 : BOOL;
  bpFehler               : BOOL;

END_VAR
VAR
  
  // BOOL
  blAktiv                : BOOL;
  
  // STEPS
  steplSchritt           : STEPS_TE;

END_VAR

blAktiv := TRUE;
//-------------------------------------------------------------------------------------------------
// STEUERUNG ANLEGEN
//-------------------------------------------------------------------------------------------------
IF ( Auftragsdaten.wAuftrag = eStation_Anlegen ) THEN
  CASE steplSchritt OF
    // ANLEGEN ==================================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
        steplSchritt := STEP_10_E;
      END_IF

      (* Hinweis:
         - Abbruch des Anl
      *)
      IF ( bpAbbruchAnlegeauftrag ) THEN
        bpAbbruchAnlegeauftrag := FALSE;
        bpDone := TRUE;
        Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;
      END_IF

    // ANLEGEN ==================================================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  PRUEFUNG DER GLASDATEN [AUFTRAGSDATEN]
      //
      //  Hinweis:
      // - Anlegeauftraege muessen immer auf richte GLas- Abmessungen geprueft werden
      // ---------------------------------------------------------------------------------------
      steplSchritt := STEP_20_E;

      IF NOT AuftragsdatenPruefen( wStation, cWAND_1, Auftragsdaten) THEN
        steplSchritt := STEP_900_E;
      END_IF

    // ANLEGEN ==================================================
    STEP_20_E:
      (* Hinweis:
         - Starten des Anlegevorgangs
      *)

      // Glastyp bestimmen
      IF Auftragsdaten.bModell THEN
        starrStationBasisParameter[wStation].wGlasTyp[cWAND_1] := cMODELLSCHEIBE;
      ELSE
        starrStationBasisParameter[wStation].wGlasTyp[cWAND_1] := cDEFAULTSCHEIBE;
      END_IF

      starrStationBasisParameter[wStation].pAuftrag[cWAND_1] := Auftragsdaten;
      starrStationBasisParameter[wStation].bAnlegen := TRUE;
       
      steplSchritt := STEP_30_E;

    // ANLEGEN ==================================================
    STEP_30_E:
      (* Hinweis:
         - Prüfen dass der Auftragsstatus sich geändert hat
      *)
      IF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragAktiv )
         OR  ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragAktivWiederholen )
      THEN
        steplSchritt := STEP_100_E;
      END_IF

    // ANLEGEN ==================================================
    STEP_100_E:
      (* Hinweis:
         - Station hat ihren Vorgang abgeschlossen
      *)
      IF ( starrStationBasisParameter[wStation].bAnlegenAbgeschlossen ) THEN
        starrStationBasisParameter[wStation].bAnlegen := FALSE;

        IF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragErfolgreich ) THEN

          wSps2MmiInputtableNummer := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          dwSps2MmiWartezeit       := starrStationBasisParameter[wStation].dwWartezeit[cWAND_1];
          MsgToMmi(auftragsnr_w := SB0_SPS_SHEETONINPUTTABLE);

          IF Auftragsdaten.bModell OR NOT (starrStationBasisParameter[wStation].stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen) THEN
            wSps2MmiInputtableNummer := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
            dwSps2MmiWartezeit       := starrStationBasisParameter[wStation].dwWartezeit[cWAND_1];
            MsgToMmi(auftragsnr_w := SB0_SPS_SortierungQuittInputInQueue);
          END_IF

        END_IF

        steplSchritt := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Anlegewand
      *)
      IF ( starrStationBasisParameter[wStation].bFehler ) THEN

        SpsError( eFehler_Station,
                  starrStationBasisParameter[wStation].wFehlerNummer,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrStationBasisParameter[wStation].awFehlerInformationen );

        starrStationBasisParameter[wStation].bAnlegen := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

    // ANLEGEN ==================================================
    STEP_900_E:
      bpFehler := TRUE;

    // ANLEGEN ==================================================
    STEP_1000_E:
      bpDone := TRUE;
       
      IF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragErfolgreich ) THEN

        IF Auftragsdaten.bModell  OR NOT (starrStationBasisParameter[wStation].stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen) THEN
          Auftragsdaten.wAuftrag := eStation_Warte_Auf_Austransport;
        ELSE
          Auftragsdaten.wAuftrag := eStation_Hoehenmessung;
        END_IF

      ELSIF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragWiederholen ) THEN
        steplSchritt := STEP_0_E;

      END_IF

  // ANLEGEN ==================================================
  END_CASE
END_IF

IF bpReset THEN
  blAktiv := FALSE;
  bpFehler := FALSE;
  bpReset := FALSE;
  bpDone := FALSE;
  steplSchritt := STEP_0_E;
  starrStationBasisParameter[wStation].bAnlegen := FALSE;
END_IF
END_FUNCTION_BLOCK