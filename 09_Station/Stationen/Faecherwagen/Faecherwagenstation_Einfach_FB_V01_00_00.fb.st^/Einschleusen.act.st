(* METADATA
{
	"v3Meta": {
		"objectGuid": "725a1df2-94ca-41bc-928b-e8138c8a381e"
	}
}
*)
ACTION Einschleusen
//-------------------------------------------------------------------------------------------------
// EINSCHLEUSEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Bediener schiebt den Faecherwagen in die Station und quittiert am Taster
   - Arretierung haelt den ganzen Faecherwagen fest
   - Rolltor oeffnet (Option stStationsAufbau.bRolltor), danach steht der Wagen in der Beladeposition
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
      blArretierungSchliessen     := FALSE;
      blArretierungOeffnen        := FALSE;
      blRolltorAuf                := FALSE;
      blRolltorAb                 := FALSE;

      eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Starten_0;

      IF ( NOT bpStatusStationInBeladePosition ) THEN
        steplEinschleusen := STEP_100_E;
      ELSE
        steplEinschleusen := STEP_180_E;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_100_E:
      (* Hinweis:
         - Warten, bis ein Faecherwagen in der Station steht, dann beim MMI anmelden
         - Ueberwachung: WatchIO "Faecherwagen nicht in Ausrichtposition" (Aktion Meldungen)
      *)
      eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Warte_Auf_Faecherwagen_In_Box_100;

      IF ( tonlFWInBox.Q ) THEN
        wSps2FaecherwagenStationNr := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        MsgToMmi( auftragsnr_w := SB0_SPS_RACKLOGIN );

        steplEinschleusen := STEP_105_E;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_105_E:
      (* Hinweis:
         - Warten auf die Quittierung des Bedieners (Taster), Faecherwagen muss noch in der Station stehen
         - Ueberwachung: WatchIO "Faecherwagen nicht in Ausrichtposition" (Aktion Meldungen)
      *)
      eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Warten_Auf_Lichtschranke_Und_Quittierung_105;

      IF     ( rtlQuittierungEinschleusen.Q OR blMerkerEinschleusenQuittiert )
         AND tonlFWInBox.Q
      THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Arretierung_Schliessen_110;

        blMerkerEinschleusenQuittiert := FALSE;
        blArretierungSchliessen       := TRUE;
        steplEinschleusen             := STEP_110_E;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_110_E:
      (* Hinweis:
         - Arretierung ausfahren, der Faecherwagen wird festgehalten
         - Ueberwachung der Endlage im Arretierung_FB
      *)
      IF NOT in_bFaecherwagenVorhanden THEN
        blArretierungSchliessen := FALSE;

        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Fehler;

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_NICHT_VORHANDEN_EINSCHLEUSEN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_900_E;

      ELSIF ( blArretierungSchliessenDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Rolltor_Oeffnen_120;

        blArretierungSchliessen := FALSE;
        blRolltorAuf            := TRUE;
        steplEinschleusen       := STEP_120_E;
      ELSE
        blArretierungSchliessen := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_120_E:
      (* Hinweis:
         - Rolltor oeffnen (ohne Rolltor meldet die Aktion Rolltor sofort fertig)
         - Ueberwachung der Endlage in der Aktion Rolltor
      *)
      IF ( blRolltorAufDone ) THEN
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Auswertung_180;

        blRolltorAuf      := FALSE;
        steplEinschleusen := STEP_180_E;
      ELSE
        blRolltorAuf      := TRUE;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_180_E:
      (* Hinweis:
         - Beladeposition pruefen und dem MMI melden (kein RFID: Rack-Nummer 0)
      *)
      IF ( bpStatusStationInBeladePosition ) THEN
        wSps2MmiRackPositionNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSps2MmiRackPosition       := 0;
        wSps2MmiRackNumber         := 0;
        MsgToMmi( auftragsnr_w := SB0_SPS_RACKONLOADINGSTATION );

        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Abgeschlossen_InBeladeposition;

        steplEinschleusen := STEP_1000_E;

      ELSE
        eLetzterStatus := eLetzter_FW_Status.eEinschleusen_Fehler;

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_NICHT_IN_LADEPOSITION;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEinschleusen := STEP_900_E;
      END_IF

    // EINSCHLEUSEN ==========================
    STEP_900_E:
      blArretierungSchliessen := FALSE;
      blRolltorAuf            := FALSE;

      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bEintransport[cWAND_1] := FALSE;

    // EINSCHLEUSEN ==========================
    STEP_1000_E:
      bpEinschleusenAbgeschlossen := TRUE;
      BasisStationsParameter.bEintransport[cWAND_1] := FALSE;

  // EINSCHLEUSEN ==========================
  END_CASE

ELSE

  IF ( steplEinschleusen > STEP_0_E ) THEN
    bpEinschleusenAbgeschlossen   := FALSE;
    blArretierungSchliessen       := FALSE;
    blArretierungOeffnen          := FALSE;
    blRolltorAuf                  := FALSE;
    blRolltorAb                   := FALSE;
    blMerkerEinschleusenQuittiert := FALSE;

    steplEinschleusen := STEP_0_E;
  END_IF

END_IF
END_ACTION