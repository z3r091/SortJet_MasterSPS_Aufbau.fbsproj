(* METADATA
{
  "v3Meta": {
    "objectGuid": "e84e8610-6959-40cb-bed8-4c6148a86167"
  }
}
*)
ACTION Positionieren
//-------------------------------------------------------------------------------------------------
// POSITIONIEREN
//-------------------------------------------------------------------------------------------------

IF ( bpPositionieren ) THEN

  // Ausnahmesituation
  IF ( bpSensorAuslauf
       AND NOT bpSensorEinlauf )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
    steplPositionieren := STEP_900_E;

  ELSIF ( bpSensorEinlauf
          AND NOT bpSensorAuslauf )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT;
    steplPositionieren := STEP_900_E;

  ELSIF ( bpSensorEinlauf
          AND   bpSensorAuslauf )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
    steplPositionieren := STEP_900_E;

  END_IF

  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_KIPPEN;
    steplPositionieren := STEP_900_E;
  END_IF

  
  CASE steplPositionieren OF
    // POSITIONIEREN ===================================
    STEP_0_E:
      (* Hinweis:
         - Variablen zurueck setzen
         - Pruefen ob der Antrieb bereit zum verfahrern ist
      *)
      bpDone := FALSE;
      bpPositionierenAbgeschlossen := FALSE;

      IF ( Antrieb.bpReglerBereit ) THEN

        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplPositionieren := STEP_10_E;
      END_IF

    // POSITIONIEREN ===================================
    STEP_10_E:
      (* Hinweis:
         - Es darf weder der Einlauf noch der Auslauf- Sensor während der Dreh-Bewegung belegt sein
      *)
      IF NOT ( bpSensorEinlauf OR bpSensorAuslauf OR bpSensorAuslaufVorgaenger ) THEN

        IF NOT ( epKippStatus = epZielPosition ) THEN

          steplPositionieren := STEP_40_E;

        ELSE

          steplPositionieren := STEP_1000_E;

        END_IF

      ELSE

        IF ( bpSensorAuslauf AND NOT bpSensorEinlauf ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
          steplPositionieren := STEP_900_E;

        ELSIF ( bpSensorEinlauf AND NOT bpSensorAuslauf  ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT;
          steplPositionieren := STEP_900_E;

        ELSIF ( bpSensorAuslaufVorgaenger  ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_VORGAENGER;
          steplPositionieren := STEP_900_E;

        ELSE
          wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
          steplPositionieren := STEP_900_E;

        END_IF

      END_IF

    // POSITIONIEREN ===================================
    STEP_40_E:
      // ---------------------------------------------------------------------------------------
      //  ENDSCHALTER PRUEFEN
      //
      //  Hinweis:
      // - Vor dem Verfahren pruefen ob der Antrieb in einem Endschalter steht
      // ---------------------------------------------------------------------------------------

      IF (  NOT Antrieb.bpMinSchalterBelegt
           AND NOT Antrieb.bpMaxSchalterBelegt )
      THEN
        steplPositionieren := STEP_100_E;
      ELSE
        steplPositionieren := STEP_50_E;
      END_IF

    // POSITIONIEREN ===================================
    STEP_50_E:
      (* Hinweis:
         - Versuchen den Endschalter frei zufahren
           WICHTIG [PROJEKT INTERPANE HOERDT]
         - Geschwindigkeit sehrlangsam
      *)
      tonlEndschalterFreifahren( IN := TRUE, PT:= T#10s);

      toflHardwareEndschalterFrei( IN := ( NOT Antrieb.bpMaxSchalterBelegt
                                           AND NOT Antrieb.bpMinSchalterBelegt),
                                   PT := t#1s);

      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpEinrichtGeschwindigkeit;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;

      IF ( Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDMINUS;
      END_IF

      IF ( Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDPLUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplPositionieren := STEP_60_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei !
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND (  Antrieb.bpMinSchalterBelegt
                 OR   Antrieb.bpMaxSchalterBelegt ))
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_KIPPEN_ENDSCHALTER_NICHT_FREI;
        steplPositionieren := STEP_900_E;
      END_IF

    // POSITIONIEREN ===================================
    STEP_60_E:
      (* Hinweis:
         - Erzwungene Pause, damit der Antrieb wieder ordnungsgemaeß schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT:= T#2s);

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        tonlWarteSchrittEndschalterFreifahren(IN := FALSE );
        steplPositionieren := STEP_100_E;
      END_IF

    // POSITIONIEREN ===================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DER ABSOLUT- POSITIONIERUNG
      //
      //  Hinweis:
      // - Uebergabe der Zielposition fuer den Antrieb
      // ---------------------------------------------------------------------------------------

      steplPositionieren := STEP_110_E;

      CASE epZielPosition OF

        eKippen_Position_0Grad:
          rlAntriebsZielPosition := ppParameterBaustein.rPosition0Grad;

        eKippen_Position_84Grad:
          rlAntriebsZielPosition := ppParameterBaustein.rPosition84Grad;

        eKippen_Position_90Grad:
          rlAntriebsZielPosition := ppParameterBaustein.rPosition90Grad;

        eKippen_Position_96Grad:
          rlAntriebsZielPosition := ppParameterBaustein.rPosition96Grad;

        ELSE
          wpFehlerNr := cMELDUNG_KIPPEN_ZIEL_POSITION_UNGUELTIG;
          steplPositionieren := STEP_900_E;

      END_CASE

    // POSITIONIEREN ===================================
    STEP_110_E:
      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielposition    := rlAntriebsZielPosition;
      Antrieb.wpBetriebsart     := ABSOLUT;

      steplPositionieren := STEP_120_E;

    // POSITIONIEREN ===================================
    STEP_120_E:
      (* Hinweis:
         - Bewegung abgeschlossen
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplPositionieren := STEP_1000_E;
      END_IF

    // POSITIONIEREN ===================================
    STEP_900_E:
      bpFehler := TRUE;

    // POSITIONIEREN ===================================
    STEP_1000_E:
      bpDone := TRUE;
      bpPositionierenAbgeschlossen := TRUE;

  // POSITIONIEREN ===================================
  END_CASE

END_IF

IF ( NOT bpPositionieren ) THEN

  IF ( steplPositionieren > STEP_0_E ) THEN
    bpDone := FALSE;
    bpPositionierenAbgeschlossen := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplPositionieren := STEP_0_E;
  END_IF

END_IF
END_ACTION