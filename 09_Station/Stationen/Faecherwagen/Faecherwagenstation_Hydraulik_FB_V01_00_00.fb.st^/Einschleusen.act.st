(* METADATA
{
  "v3Meta": {
    "objectGuid": "b655c4c0-053a-4bce-b00c-e16bb21c9a61"
  }
}
*)
ACTION Einschleusen
//-------------------------------------------------------------------------------------------------
// EINSCHLEUSEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Faecherwagen steht in Ausrichtposition, Bediener quittiert am Taster
   - Hubrahmen heben, Faecherwagen pruefen (Muting-Sensoren), Rolltor oeffnen (Option bRolltor)
   - Anschlag hoch (Option bAnschlag), Faecherwagen in die Station ziehen, Anschlag ab, Zentrierung schliessen
   - Kein Faecherwagen auf dem Hubrahmen: Hubrahmen wieder senken und ohne Fehler beenden
   - Option AGV (Schritte 200..250): Faecherwagen wird vom AGV in die Station gefahren, keine Hydraulik
     => Faecherwagen auf der Station (Muting-Sensoren), RFID lesen, Rolltor oeffnen
     => Anschlag hoch und vor, danach zurueck und ab (Option bAnschlag)
*)
IF BasisStationsParameter.bEintransport[cWAND_1] AND
   ( blBetriebsartAutomatik OR
     blBetriebsartHand OR
     blBetriebartCheck )
THEN

  IF BasisStationsParameter.bFehler THEN
    steplEinschleusen := STEP_900_E;
  END_IF

  CASE steplEinschleusen OF
    // EINSCHLEUSEN ==========================
    STEP_0_E:
      (* Hinweis:
         - Initialisierung der Variablen
      *)
      bpEinschleusenAbgeschlossen := FALSE;
      blHubrahmenHeben            := FALSE;
      blHubrahmenSenken           := FALSE;
      blFaecherwagenVor           := FALSE;
      blFaecherwagenZurueck       := FALSE;
      blZentrierungOeffnen        := FALSE;
      blZentrierungSchliessen     := FALSE;
      blAnschlagAuf               := FALSE;
      blAnschlagAb                := FALSE;
      blAnschlagVor               := FALSE;
      blAnschlagZurueck           := FALSE;
      blRolltorAuf                := FALSE;
      blRolltorAb                 := FALSE;
      blStationBeladen            := FALSE;
      blMutingAusschalten         := FALSE;
      tonlTimeoutReadRFID( IN := FALSE );
      tonlTimeoutAGV( IN := FALSE );

      eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Starten_0;

      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAGV ) THEN
        steplEinschleusen := STEP_200_E;
      ELSIF ( NOT bpStatusStationInBeladePosition ) THEN
        steplEinschleusen := STEP_100_E;
      ELSE
        steplEinschleusen := STEP_180_E;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_100_E:
      (* Hinweis:
         - Warten auf Faecherwagen in Ausrichtposition und Quittierung des Bedieners
         - Ueberwachung: WatchIO "Faecherwagen nicht in Ausrichtposition" (Aktion Meldungen)
      *)
      eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Warte_Auf_Faecherwagen_In_Box_100;

      // Faecherwagen wieder weg: Quittierung verwerfen
      IF NOT in_bFWInAusrichtPosition THEN
        blMerkerEinschleusenQuittiert := FALSE;
      END_IF

      IF     ( rtlQuittierungEinschleusen.Q OR blMerkerEinschleusenQuittiert )
         AND tonlFWInBox.Q
      THEN
        // Quittierung merken, bis die Hydraulikstation den Auftrag zulaesst (begrenzte Anzahl gleichzeitiger Auftraege)
        blMerkerEinschleusenQuittiert := TRUE;
        blHydraulikAuftragAnfrage     := TRUE;

        IF ( blHydraulikAuftragFreigabe ) THEN
          wSps2FaecherwagenStationNr := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
          MsgToMmi( auftragsnr_w := SB0_SPS_RACKLOGIN );

          eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Hubrahmen_Heben_110;

          blMerkerEinschleusenQuittiert := FALSE;
          blHubrahmenHeben              := TRUE;
          steplEinschleusen             := STEP_110_E;
          blHydraulikAuftragAktiv       := TRUE;
        END_IF

      ELSIF rtlQuittierungEinschleusen.Q THEN
        // Quittiert, aber kein Faecherwagen in Ausrichtposition
        SpsHinweis( eFehler_Station,
                    cMELDUNG_FAECHERWAGEN_NICHT_IN_LADEPOSITION,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    BasisStationsParameter.awFehlerInformationen );
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_110_E:
      (* Hinweis:
         - Hubrahmen heben (Ueberwachung in der Aktion Hubrahmen), danach Faecherwagen pruefen
      *)
      IF ( blHubrahmenHebenDone ) THEN
        blHubrahmenHeben := FALSE;

        IF ( blFaecherwagenErkannt ) THEN
          eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Rolltor_Oeffnen_120;

          blRolltorAuf      := TRUE;
          steplEinschleusen := STEP_130_E;
        ELSE
          SpsHinweis( eFehler_Station,
                      cMELDUNG_FAECHERWAGEN_NICHT_VORHANDEN_EINSCHLEUSEN,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );

          blHubrahmenSenken := TRUE;
          steplEinschleusen := STEP_120_E;
        END_IF
      ELSE
        blHubrahmenHeben := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_120_E:
      (* Hinweis:
         - Kein Faecherwagen auf dem Hubrahmen: Hubrahmen senken und ohne Fehler beenden
      *)
      IF ( blHubrahmenSenkenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eAusschleusen_Abgeschlossen_InGrundstellung;

        blHubrahmenSenken := FALSE;
        steplEinschleusen := STEP_1000_E;
      ELSE
        blHubrahmenSenken := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_130_E:
      (* Hinweis:
         - Rolltor oeffnen (ohne Rolltor meldet die Aktion Rolltor sofort fertig)
      *)
      IF ( blRolltorAufDone ) THEN
        blRolltorAuf := FALSE;

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
          eLetzterStatus    := eLetzter_FW_Status.eEinschleusen_Anschlag_Auf_140;
          blAnschlagAuf     := TRUE;
          steplEinschleusen := STEP_140_E;
        ELSE
          eLetzterStatus    := eLetzter_FW_Status.eEinschleusen_Faecherwagen_Vor_150;
          blFaecherwagenVor := TRUE;
          steplEinschleusen := STEP_150_E;
        END_IF
      ELSE
        blRolltorAuf := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_140_E:
      (* Hinweis:
         - Anschlag hoch (Ueberwachung im ZylinderPneumatik_FB)
      *)
      IF ( blAnschlagAufDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Faecherwagen_Vor_150;

        blAnschlagAuf     := FALSE;
        blFaecherwagenVor := TRUE;
        steplEinschleusen := STEP_150_E;
      ELSE
        blAnschlagAuf     := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_150_E:
      (* Hinweis:
         - Faecherwagen in die Station ziehen (Ueberwachung in der Aktion Verfahren)
      *)
      IF ( blFaecherwagenVorDone ) THEN
        blFaecherwagenVor := FALSE;

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
          eLetzterStatus    := eLetzter_FW_Status.eEinschleusen_Anschlag_Ab_160;
          blAnschlagAb      := TRUE;
          steplEinschleusen := STEP_160_E;
        ELSE
          eLetzterStatus          := eLetzter_FW_Status.eEinschleusen_Zentrierung_Schliessen_170;
          blZentrierungSchliessen := TRUE;
          steplEinschleusen       := STEP_170_E;
        END_IF
      ELSE
        blFaecherwagenVor := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_160_E:
      (* Hinweis:
         - Anschlag ab (Ueberwachung im ZylinderPneumatik_FB)
      *)
      IF ( blAnschlagAbDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Zentrierung_Schliessen_170;

        blAnschlagAb            := FALSE;
        blZentrierungSchliessen := TRUE;
        steplEinschleusen       := STEP_170_E;
      ELSE
        blAnschlagAb            := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_170_E:
      (* Hinweis:
         - Zentrierung schliessen (Ueberwachung in der Aktion Zentrierung)
      *)
      IF ( blZentrierungSchliessenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Auswertung_180;

        blZentrierungSchliessen := FALSE;
        steplEinschleusen       := STEP_180_E;
      ELSE
        blZentrierungSchliessen := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_180_E:
      (* Hinweis:
         - Beladeposition pruefen, RFID-Nummer lesen (Option bRFID) und dem MMI melden
      *)
      tonlTimeoutReadRFID( IN := BasisStationsParameter.stMKs.stStationsAufbau.bRFID AND NOT in_bRFID_DataValid,
                           PT := ZEIT_TIMEOUT_RFID );

      IF NOT bpStatusStationInBeladePosition THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Fehler;

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_NICHT_IN_LADEPOSITION;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_900_E;

      ELSIF ( NOT BasisStationsParameter.stMKs.stStationsAufbau.bRFID OR in_bRFID_DataValid ) THEN
        wSps2MmiRackPositionNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSps2MmiRackPosition       := 0;
        wSps2MmiRackNumber         := SEL( BasisStationsParameter.stMKs.stStationsAufbau.bRFID, WORD#0, wlRFID_Nummer );
        MsgToMmi( auftragsnr_w := SB0_SPS_RACKONLOADINGSTATION );

        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Abgeschlossen_InBeladeposition;

        steplEinschleusen := STEP_1000_E;

      ELSIF tonlTimeoutReadRFID.Q THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Fehler;

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_RFID_CHIP_NICHT_LESBAR;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_900_E;
      END_IF

    // EINSCHLEUSEN AGV ======================
    STEP_200_E:
      (* Hinweis:
         - Option AGV: Warten bis der Faecherwagen auf der Station steht (beide Muting-Sensoren stabil belegt)
      *)
      tonlTimeoutAGV( IN := TRUE, PT := ZEIT_TIMEOUT_RFID );

      IF ( tonlMutingSensorenBelegt.Q ) THEN
        wSps2FaecherwagenStationNr := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        MsgToMmi( auftragsnr_w := SB0_SPS_RACKLOGIN );

        tonlTimeoutAGV( IN := FALSE );
        tonlTimeoutReadRFID( IN := FALSE );
        steplEinschleusen := STEP_210_E;

      ELSIF ( tonlTimeoutAGV.Q ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Fehler;

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_NICHT_VORHANDEN_EINSCHLEUSEN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_900_E;
      END_IF

    // EINSCHLEUSEN AGV ======================
    STEP_210_E:
      (* Hinweis:
         - Option AGV: RFID-Nummer lesen (Option bRFID), danach Rolltor oeffnen
      *)
      tonlTimeoutReadRFID( IN := BasisStationsParameter.stMKs.stStationsAufbau.bRFID AND NOT in_bRFID_DataValid,
                           PT := ZEIT_TIMEOUT_RFID );

      IF NOT tonlMutingSensorenBelegt.Q THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Fehler;

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_NICHT_IN_LADEPOSITION;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_900_E;

      ELSIF ( NOT BasisStationsParameter.stMKs.stStationsAufbau.bRFID OR in_bRFID_DataValid ) THEN
        tonlTimeoutReadRFID( IN := FALSE );
        blRolltorAuf      := TRUE;
        steplEinschleusen := STEP_220_E;

      ELSIF tonlTimeoutReadRFID.Q THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Fehler;

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_RFID_CHIP_NICHT_LESBAR;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_900_E;
      END_IF

    // EINSCHLEUSEN AGV ======================
    STEP_220_E:
      (* Hinweis:
         - Rolltor oeffnen (Ueberwachung in der Aktion Rolltor, ohne Rolltor sofort fertig)
      *)
      IF ( blRolltorAufDone ) THEN
        blRolltorAuf := FALSE;

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
          blAnschlagAuf     := TRUE;
          steplEinschleusen := STEP_230_E;
        ELSE
          steplEinschleusen := STEP_250_E;
        END_IF
      ELSE
        blRolltorAuf := TRUE;
      END_IF

    // EINSCHLEUSEN AGV ======================
    STEP_230_E:
      (* Hinweis:
         - Anschlag hoch (Ueberwachung im ZylinderPneumatik_FB)
      *)
      IF ( blAnschlagAufDone ) THEN
        blAnschlagAuf     := FALSE;
        blAnschlagVor     := TRUE;
        steplEinschleusen := STEP_235_E;
      ELSE
        blAnschlagAuf     := TRUE;
      END_IF

    // EINSCHLEUSEN AGV ======================
    STEP_235_E:
      (* Hinweis:
         - Anschlag vor (Ueberwachung im ZylinderPneumatik_FB)
      *)
      IF ( blAnschlagVorDone ) THEN
        blAnschlagVor     := FALSE;
        blAnschlagZurueck := TRUE;
        steplEinschleusen := STEP_240_E;
      ELSE
        blAnschlagVor     := TRUE;
      END_IF

    // EINSCHLEUSEN AGV ======================
    STEP_240_E:
      (* Hinweis:
         - Anschlag zurueck (Ueberwachung im ZylinderPneumatik_FB)
      *)
      IF ( blAnschlagZurueckDone ) THEN
        blAnschlagZurueck := FALSE;
        blAnschlagAb      := TRUE;
        steplEinschleusen := STEP_245_E;
      ELSE
        blAnschlagZurueck := TRUE;
      END_IF

    // EINSCHLEUSEN AGV ======================
    STEP_245_E:
      (* Hinweis:
         - Anschlag ab (Ueberwachung im ZylinderPneumatik_FB)
      *)
      IF ( blAnschlagAbDone ) THEN
        blAnschlagAb      := FALSE;
        steplEinschleusen := STEP_250_E;
      ELSE
        blAnschlagAb      := TRUE;
      END_IF

    // EINSCHLEUSEN AGV ======================
    STEP_250_E:
      (* Hinweis:
         - Faecherwagen in Beladeposition dem MMI melden
      *)
      IF NOT bpStatusStationInBeladePosition THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Fehler;

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_NICHT_IN_LADEPOSITION;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_900_E;
      ELSE
        wSps2MmiRackPositionNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSps2MmiRackPosition       := 0;
        wSps2MmiRackNumber         := SEL( BasisStationsParameter.stMKs.stStationsAufbau.bRFID, WORD#0, wlRFID_Nummer );
        MsgToMmi( auftragsnr_w := SB0_SPS_RACKONLOADINGSTATION );

        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Abgeschlossen_InBeladeposition;

        steplEinschleusen := STEP_1000_E;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_900_E:
      blHubrahmenHeben        := FALSE;
      blHubrahmenSenken       := FALSE;
      blFaecherwagenVor       := FALSE;
      blZentrierungSchliessen := FALSE;
      blAnschlagAuf           := FALSE;
      blAnschlagAb            := FALSE;
      blAnschlagVor           := FALSE;
      blAnschlagZurueck       := FALSE;
      blRolltorAuf            := FALSE;
      tonlTimeoutAGV( IN := FALSE );

      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bEintransport[cWAND_1] := FALSE;

    // EINSCHLEUSEN ==========================
    STEP_1000_E:
      tonlTimeoutReadRFID( IN := FALSE );
      blStationBeladen            := bpStatusStationInBeladePosition;
      bpEinschleusenAbgeschlossen := TRUE;
      BasisStationsParameter.bEintransport[cWAND_1] := FALSE;

  // EINSCHLEUSEN ==========================
  END_CASE

ELSE

  IF ( steplEinschleusen > STEP_0_E ) THEN
    bpEinschleusenAbgeschlossen   := FALSE;
    blHubrahmenHeben              := FALSE;
    blHubrahmenSenken             := FALSE;
    blFaecherwagenVor             := FALSE;
    blFaecherwagenZurueck         := FALSE;
    blZentrierungOeffnen          := FALSE;
    blZentrierungSchliessen       := FALSE;
    blAnschlagAuf                 := FALSE;
    blAnschlagAb                  := FALSE;
    blAnschlagVor                 := FALSE;
    blAnschlagZurueck             := FALSE;
    blRolltorAuf                  := FALSE;
    blRolltorAb                   := FALSE;
    blMerkerEinschleusenQuittiert := FALSE;
    tonlTimeoutReadRFID( IN := FALSE );
    tonlTimeoutAGV( IN := FALSE );

    steplEinschleusen := STEP_0_E;
  END_IF

END_IF
END_ACTION