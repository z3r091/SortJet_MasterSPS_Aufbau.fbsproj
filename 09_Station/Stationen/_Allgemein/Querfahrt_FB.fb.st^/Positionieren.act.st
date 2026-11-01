(* METADATA
{
  "v3Meta": {
    "objectGuid": "76371902-e2b0-44ff-9558-a645788a677a"
  }
}
*)
ACTION Positionieren
//-------------------------------------------------------------------------------------------------
// POSITIONIEREN
//-------------------------------------------------------------------------------------------------
IF (  bpPositionieren ) THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_QUERFAHRT;
    steplPositionieren := STEP_900_E;
  END_IF

  CASE steplPositionieren OF
    // POSITIONIERUNG ====================
    STEP_0_E:
      (* Hinweis:
         - Timer zuruecksetzen
         - Abfragen ob Regler Betriebsbereit ist
      *)
      tonlEndschalterFreifahren(IN := FALSE);
      toflHardwareEndschalterFrei(IN := FALSE);
      wSps2ShuttleStopped[stStationsNummern.NummerIntern] := 0;

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        (* Hinweis:
           - Pruefen der Verfahr- Freigabe
              => Vorhanden: Starten des Verfahr-Auftrags
              => Fehlt    : Abbruch des Verfahr-Auftrags
        *)
        IF ( blVerfahrfreigabe ) THEN
          steplPositionieren := STEP_10_E;
        // ELSE
        //   steplPositionieren := STEP_120_E;
        END_IF

      END_IF

    // POSITIONIERUNG ====================
    STEP_10_E:
      (* Hinweis:
         - Sicherstellen das der Antrieb referenziert ist
      *)
      IF (  Antrieb.bpIstReferenziert ) THEN

        (* Hinweis:
           - Ueberpruefen ob überhaubt verfahren werden muss
        *)
        IF ( ABS(rpZielPosition - Antrieb.rpIstPosition) >= rgMKZielPositionToleranz ) THEN
          steplPositionieren := STEP_20_E;
        ELSE
          steplPositionieren := STEP_1000_E;
        END_IF

      ELSE
        // Keine Referenz
        SpsError( eFehler_Station,
                  cMELDUNG_QUERFAHRT_KEINE_REFERENZ,
                  stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(stStationsNummern.NummerIntern),
                  wpgFehlerdaten );
      END_IF

    // POSITIONIERUNG ====================
    STEP_20_E:
      (* Hinweis:
         - Vor dem Verfahren pruefen ob der Antrieb in einem Endschalter steht
           => Nach einer Stop- Situation
      *)
      IF (  NOT Antrieb.bpMinSchalterBelegt
           AND NOT Antrieb.bpMaxSchalterBelegt )
      THEN
        steplPositionieren := STEP_100_E;
      ELSE
        steplPositionieren := STEP_30_E;
      END_IF

    // POSITIONIERUNG ====================
    STEP_30_E:
      (* Hinweis:
         - Versuchen den Endschalter frei zufahren
      *)
      tonlEndschalterFreifahren( IN := TRUE, PT := T#10s);

      toflHardwareEndschalterFrei( IN := ( NOT Antrieb.bpMinSchalterBelegt
                                           OR NOT Antrieb.bpMaxSchalterBelegt ),
                                   PT := t#1s);

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;

      IF ( Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDMINUS;
      END_IF

      IF ( Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDPLUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplPositionieren := STEP_40_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei !
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND (  Antrieb.bpMinSchalterBelegt
                 OR   Antrieb.bpMaxSchalterBelegt ))
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_QUERFAHRT_ENDSCHALTER_NICHT_FREI;
        steplPositionieren := STEP_900_E;
      END_IF

    // POSITIONIERUNG ====================
    STEP_40_E:
      (* Hinweis:
         - Warten bis ANtrieb steht
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        steplPositionieren := STEP_100_E;
      END_IF

    // POSITIONIERUNG ====================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< STARTEN DER POSITIONIERUNG >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //  Hinweis:
      //  - Position vorgeben
      IF bpAutomatikAktiv THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      ELSE
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
      END_IF
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpZielPosition    := rpZielPosition;
      Antrieb.wpBetriebsart     := ABSOLUT;

      steplPositionieren := STEP_120_E;


    // POSITIONIERUNG ====================
    STEP_120_E:
      (* Hinweis:
         - die Verfahrfreigabe wird waehrend des verfahrens genommen
            => Sensor belegt etc.
      *)
      IF ( NOT blVerfahrfreigabe ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        blAbbruchPositionierung := TRUE;

        // wSps2MmiMeasureSlotNummer := 0; 0 = Shuttle bremst noch / 1 = Shuttle gestoppt und steht
        wgSps2MmiShuttleNr                                  := stStationsNummern.NummerIntern;
        rSps2MmiShuttlePosition[0]                          := Antrieb.rpIstPosition;
        wSps2ShuttleStopped[stStationsNummern.NummerIntern] := 0;
        MsgToMmi(SB0_SPS_SHUTTLEVORABPOSITIONIERUNGABBRUCH);

        // Medlung ausgeben das ein Verfahrabbruch stattgefunden hat
        IF (      bpSensorAuslauf
             AND NOT bpSensorEinlauf )
        THEN
          wpFehlerNr := cMELDUNG_QUERFAHRT_KANN_NICHT_VERFAHREN_SENSOR_AUSLAUF_BELEGT;
        ELSIF (   bpSensorEinlauf
                AND NOT bpSensorAuslauf )
        THEN
          wpFehlerNr := cMELDUNG_QUERFAHRT_KANN_NICHT_VERFAHREN_SENSOR_EINLAUF_BELEGT;
        ELSIF ( bpSensorEinlauf
                AND   bpSensorAuslauf )
        THEN
          wpFehlerNr := cMELDUNG_QUERFAHRT_KANN_NICHT_VERFAHREN_SENSOR_EINLAUF_AUSLAUF_WAND_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_QUERFAHRT_VERFAHRABBRUCH;
        END_IF

        wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    wpFehlerNr,
                    stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(stStationsNummern.NummerIntern),
                    wpgFehlerdaten );

        steplPositionieren := STEP_130_E;
      END_IF

      (* Hinweis:
         - Antrieb ist verfahren
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplPositionieren := STEP_1000_E;
      END_IF

    // POSITIONIERUNG ====================
    STEP_130_E:
      (* Hinweis:
         - Verfahrauftrag wurde abgebrochen und wird neu gestartet
         - wSps2MmiMeasureSlotNummer := 0; 0 = Shuttle bremst noch / 1 = Shuttle gestoppt und steht
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        Antrieb.rpZielPosition := Antrieb.rpIstPosition;

        wgSps2MmiShuttleNr                                  := stStationsNummern.NummerIntern;
        rSps2MmiShuttlePosition[0]                          := Antrieb.rpIstPosition;
        wSps2ShuttleStopped[stStationsNummern.NummerIntern] := 1;
        MsgToMmi(SB0_SPS_SHUTTLEVORABPOSITIONIERUNGABBRUCH);

        steplPositionieren := STEP_140_E;
      END_IF

    // POSITIONIERUNG ====================
    STEP_140_E:
      (* Hinweis:
         - Verfahrauftrag wird abgebrochen und von der Oberflaeche neu angestossen
      *)
      bpPositionieren := FALSE;

      blAbbruchPositionierung       := TRUE;
      bpAuftragsstatusZuruecksetzen := TRUE;

    // POSITIONIERUNG ====================
    STEP_900_E:
      bpFehler := TRUE;

    // POSITIONIERUNG ====================
    STEP_1000_E:
      bpDone := TRUE;

  // POSITIONIERUNG ====================
  END_CASE
ELSE
  IF ( steplPositionieren > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplPositionieren := STEP_0_E;
  END_IF
END_IF
END_ACTION