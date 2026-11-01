(* METADATA
{
  "v3Meta": {
    "objectGuid": "f097c686-4b8c-4f9b-b9f9-8ce3825c4bfb"
  }
}
*)
ACTION SystemCheck
//-------------------------------------------------------------------------------------------------
// SYSTEMCHECK
//-------------------------------------------------------------------------------------------------
IF( blBetriebartCheck )THEN

  // Ausnahmesituation
  
  
  CASE ( steplCheck ) OF
    // SYSTEM CHECK=========================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1]  := FALSE;
      BasisStationsParameter.bCheckAbgeschlossen := FALSE;

      (* Hinweis:
         - Sollte es sich z.B. um eine Station handeln die in einen anderen SK transportiert
           kann die <<Freigabe>> [Hardware-] entzogen sein wenn dieser geoeffnet ist.
      *)
      IF ( BasisStationsParameter.bFreigabe ) THEN
        steplCheck := STEP_10_E;

      ELSE

        IF ( NOT (  BasisStationsParameter.bCheckMitNachfolger[cWAND_1] OR BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]) ) THEN

          IF ( Glastransport.bpSensorEinlauf
               OR Glastransport.bpSensorEinlaufVorAb
               OR Glastransport.bpSensorEinlaufVorAb
               OR Glastransport.bpSensorauslauf )
          THEN
            BasisStationsParameter.bStationBelegt[cWAND_1] := TRUE;
            steplCheck := STEP_800_E;
          ELSE
            steplCheck := STEP_800_E;
          END_IF

        ELSE
          BasisStationsParameter.wFehlerNummer := cMELDUNG_SYSTEMCHECK_KANN_NICHT_DURCHGEFUEHRT_WERDEN;
          steplCheck := STEP_900_E;

        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_10_E:
      IF ( blGeblaeseAktiv ) THEN
        steplCheck := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Geblaese
      *)
      IF ( Geblaese.bpFehler )  THEN
        Geblaese.bpStart := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES SYSTEMCHECKS
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      Glastransport.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];
      Glastransport.bpCheckMitVorgaenger := BasisStationsParameter.bCheckMitVorgaenger[cWAND_1];

      Glastransport.bpRueckwaertigerTransport := BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      Glastransport.bpCheck                    := TRUE;

      steplCheck := STEP_110_E;

    // SYSTEM CHECK=========================
    STEP_110_E:
      (* Hinweis:
         - Pruefen ob die Station belegt ist
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1] := Glastransport.bpStationBelegt;

      IF ( BasisStationsParameter.OutGlasTransport[cWAND_1].bQuittScheibe ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben + 1;
      END_IF

      IF ( ftlGlastransportCheckMitNachfolger.Q ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben - 1;
      END_IF

      (* Hinweis:
         - SystemCheck der Glastransport wurde beendet
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpCheck := FALSE;
        steplCheck := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpCheck := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_120_E:
      (* Hinweis:
         - Pruefen ob die Station steht wo sie stehen soll
         - Wenn vom MMI -1 kommt (d. h. das MMI hat auf der Station keine Scheiben oder keine Drehpos für die Scheiben) muss das umgewandelt werden!
      *)
      Drehen.epZielPosition := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rStationsZielposition);

      (* Hinweis:
         - Ansteuerung Kippen
      *)
      IF BasisStationsParameter.bStationBelegt[cWAND_1] THEN

        CASE Drehen.epZielPosition OF

          eDrehPosition0Grad:
            Kippen.epZielPosition := eKippen_Position_84Grad;
            Kippen.bpPositionieren  := TRUE;

          eDrehPosition90Grad:
            Kippen.epZielPosition := eKippen_Position_90Grad;
            Kippen.bpPositionieren  := TRUE;

        END_CASE

      ELSE

        Kippen.epZielPosition := eKippen_Position_84Grad;
        Kippen.bpPositionieren  := TRUE;

      END_IF

      CASE Drehen.epZielPosition OF

        eDrehPosition0Grad:
          Kippen.epZielPosition := eKippen_Position_84Grad;
          Kippen.bpPositionieren  := TRUE;

          (* Hinweis:
             - Das drehen wird immer angestossen - Pruefung ob gedreht werden muss findet im Dreh- Baustein statt
          *)
          Drehen.bpStarteAbsolutPositionierung := TRUE;

          steplCheck := STEP_130_E;

        eDrehPosition90Grad:
          Kippen.epZielPosition := eKippen_Position_90Grad;
          Kippen.bpPositionieren  := TRUE;
          steplCheck := STEP_130_E;

          (* Hinweis:
             - Das drehen wird immer angestossen - Pruefung ob gedreht werden muss findet im Dreh- Baustein statt
          *)
          Drehen.bpStarteAbsolutPositionierung := TRUE;

          steplCheck := STEP_130_E;

        ELSE

          BasisStationsParameter.awFehlerInformationen[1] := Drehen.epZielPosition;
          BasisStationsParameter.wFehlerNummer := cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_DREHPOSITION;
          steplCheck := STEP_900_E;

      END_CASE

    // SYSTEM CHECK =========================
    STEP_130_E:
      (* Hinweis:
         - Drehung abgeschlossen [Drehen von 0- 180 Grad ; 180 - 0 Grad ]
      *)
      IF ( Drehen.bpDone OR NOT Drehen.bpStarteAbsolutPositionierung ) THEN
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        steplCheck := STEP_210_E;
      END_IF

      (* Fehlerbehandlung:
         - Drehen
      *)
      IF ( Drehen.bpFehler ) THEN
        Drehen.bpStarteAbsolutPositionierung := FALSE;
        BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_210_E:
      IF Kippen.bpDone OR NOT Kippen.bpPositionieren THEN
        Kippen.bpPositionieren := FALSE;

        steplCheck := STEP_800_E;
      END_IF

      // Ausnahmesituation
      //   - Komponenten
      IF ( Kippen.bpFehler) THEN
        Kippen.bpPositionieren  := FALSE;

        BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;

        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_800_E:
      // ---------------------------------------------------------------------------------------
      //  AUSWERTEN DES BELADUNGSSTATUS MIT DEN MMI DATEN
      //
      //  Hinweis:
      // - Nachricht an den Bediener senden wenn die Daten nicht passen
      // ---------------------------------------------------------------------------------------

      steplCheck := STEP_1000_E;

      IF ( ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben = 0 ) AND BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );

        BasisStationsParameter.wFehlerNummer := cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN;
        BasisStationsParameter.awFehlerInformationen := wpgFehlerdaten;
        steplCheck := STEP_900_E;
      END_IF

      IF ( ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben <> 0 ) AND NOT BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_KEINE_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );

        BasisStationsParameter.wFehlerNummer := cMELDUNG_SYSTEMCHECK_KEINE_SCHEIBE_GEFUNDEN;
        BasisStationsParameter.awFehlerInformationen := wpgFehlerdaten;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      blNachSystemcheckMerker := FALSE;

    // SYSTEM CHECK=========================
    STEP_1000_E:
      // Auftrag für erneuten Automatikbetrieb setzen
      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Belegt;
      ELSE
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Kein_Auftrag;
      END_IF

      BasisStationsParameter.bCheckAbgeschlossen := TRUE;
      blNachSystemcheckMerker := TRUE;

  // SYSTEM CHECK=========================
  END_CASE;
ELSE
  IF (steplCheck > STEP_0_E ) THEN
    BasisStationsParameter.bCheckAbgeschlossen := FALSE;

    BasisStationsParameter.bCheckMitVorgaenger[cWAND_1] := FALSE;
    BasisStationsParameter.bCheckMitNachfolger[cWAND_1] := FALSE;

    BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1] := FALSE;

    Drehen.bpStarteAbsolutPositionierung := FALSE;
    Drehen.bpStarteDrehBewegung          := FALSE;

    Kippen.bpPositionieren := FALSE;

    Glastransport.bpCheck := FALSE;

    blNachSystemcheckMerker := FALSE;
    steplCheck := STEP_0_E;
  END_IF
END_IF
END_ACTION