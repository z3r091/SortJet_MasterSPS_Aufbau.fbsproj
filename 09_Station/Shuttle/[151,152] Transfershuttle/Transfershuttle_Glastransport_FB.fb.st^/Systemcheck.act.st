(* METADATA
{
  "v3Meta": {
    "objectGuid": "ea6c2cec-e0d7-4b81-9498-bf03e6183560"
  }
}
*)
ACTION Systemcheck
// @TEXT_IMPLEMENTATION := 'ST'
//_________________________________________________________________________
// ************************ START Sytsem Check ***************************
//_________________________________________________________________________

IF ( bpCheck ) THEN

  (* Fehlerbehandlung:
     - Antrieb [Glastransport]
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplCheck := STEP_900_E;
  END_IF

  CASE steplCheck OF
    // SYSTEM CHECK=========================
    STEP_0_E:
      bpDone := FALSE;

      IF ( Antrieb.bpReglerBereit )THEN
        rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;
        steplCheck := STEP_10_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_10_E:
      (* Hinweis:
         - prüfen mit den schmalen Luftschranken oder mit den optionalen Luftschranken (dicken)
      *)
      steplCheck := STEP_20_E;

    // SYSTEM CHECK=========================
    STEP_20_E:
      // Timer um zu prüfen der Luftdruck-Sensoren zuruecksetzen
      // - Einlauf- Seite
      // - Auslauf- Seite
      tonlEinlaufsensorTesten(IN:= FALSE);
      tonlAuslaufsensorTesten(IN:= FALSE);
      tonlWartenAufAnheben(IN := FALSE);

      steplCheck := STEP_30_E;

    // SYSTEM CHECK=========================
    STEP_30_E:
      // Ueberpruefung ob die Luftsensoren frei sind und richtig durchschalten
      blScheibenKontrolleAuslaufseiteEin := TRUE;
      blScheibenKontrolleEinlaufseiteEin := TRUE;
      tonlEinlaufsensorTesten(IN := NOT bpSensorScheibenKontrolleEinlaufseiteFrei, PT := t#5s);
      tonlAuslaufsensorTesten(IN := NOT bpSensorScheibenKontrolleAuslaufseiteFrei, PT := t#5s);

      IF  ( bpSensorScheibenKontrolleEinlaufseiteFrei
            AND bpSensorScheibenKontrolleAuslaufseiteFrei )
      THEN
        steplCheck := STEP_40_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufseite frei
         - Auslaufseite frei
      *)
      IF ( tonlEinlaufsensorTesten.Q ) THEN
        wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_WIRD_NICHT_FREI;
        steplCheck := STEP_900_E;
      END_IF

      IF ( tonlAuslaufsensorTesten.Q ) THEN
        wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_WIRD_NICHT_FREI;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_40_E:
      (* Anmerkung:
         - Prüfen ob Glas über den Einlauf oder Ausluaf steht,
           falls ja Systemcheck als nicht erfolgreich beenden
      *)
      out_bShuttleAnheben := TRUE;
      out_bScheibenKontrolleAuslaufseiteAuf := TRUE;
      out_bScheibenKontrolleEinlaufseiteAuf := TRUE;

      tonlWartenAufAnheben(IN := NOT blBereitZumGlastransport, PT := t#10s);

      IF ( blBereitZumGlastransport ) THEN
        steplCheck := STEP_50_E;
      END_IF

      (* Fehlerbehandlung:
         - Druckluft
         - Glastransport oben
         - Ein- Aus- Laufsensoren
      *)
      IF ( tonlWartenAufAnheben.Q ) THEN
        // Glastransport oben
        IF ( NOT blSensorGlastransportOben ) THEN
          wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_OBEN;
        // Luftsensoren oben
        ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_OBEN;
        // Luftsensoren oben
        ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_OBEN;
        // Druckluft Ok
        ELSIF NOT blDruckluftEinlaufSeiteOK THEN
          wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_EINLAUF_NICHT_OK;
        // Druckluft Ok
        ELSIF ( NOT blDruckluftAuslaufSeiteOK ) THEN
          wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_AUSLAUF_NICHT_OK;
        ELSE
          wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
        END_IF

        steplCheck := STEP_900_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_50_E:
      (* Anmerkung:
         - Prüfen ob Glas über den Einlauf oder Ausluaf steht,
           falls ja Systemcheck als nicht erfolgreich beenden
      *)
      IF ( blAuslaufSensor ) THEN

        IF ( blEinlaufSensor ) THEN
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
          steplCheck := STEP_900_E;
        ELSE

          steplCheck := STEP_60_E;
        END_IF

      ELSE
        IF ( blEinlaufSensor ) THEN

          steplCheck := STEP_70_E;

        ELSE

          steplCheck := STEP_800_E;// alles frei dann raus aus der Schrittkette
        END_IF

      END_IF



    // SYSTEM CHECK=========================
    STEP_60_E:
      (* Anmerkung:
         - Glas steht über Auslauf steht,
      *)
      IF ( NOT blAuslaufSensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( pSystemCheckDaten.wAnzahlScheiben = 0 ) THEN
          SpsWarnung( eFehler_Station,
                      cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN,
                      stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(stStationsNummern.NummerIntern),
                      starrTransfershuttleBasisParameter[stStationsNummern.NummerIntern].awFehlerInformationen );
        END_IF
        steplCheck := STEP_800_E;

      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung ;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung ;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        Antrieb.wpBetriebsart     := HANDMINUS;
      END_IF

      (* Fehlerbehandlung:
         - Wegüberwachung
         - Einlaufsensor angefahren
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rMaxPosEinlaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF


      IF ( blEinlaufSensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_70_E:
      (* Anmerkung:
         - Glas steht über Einlauf
      *)
      IF ( NOT blEinlaufSensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF ( pSystemCheckDaten.wAnzahlScheiben = 0 ) THEN
          SpsWarnung( eFehler_Station,
                      cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN,
                      stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(stStationsNummern.NummerIntern),
                      starrTransfershuttleBasisParameter[stStationsNummern.NummerIntern].awFehlerInformationen );
        END_IF
        steplCheck := STEP_800_E;

      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung ;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung ;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        Antrieb.wpBetriebsart     := HANDPLUS;
      END_IF



      (* Fehlerbehandlung:
         - Wegüberwachung
         - Auslaufsensor angefahren
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rMaxPosEinlaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

      IF ( blAuslaufSensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_800_E:
      (* Anmerkung:
         - alles beenden und Shuttle absenken
      *)
      out_bShuttleAnheben := FALSE;
      out_bScheibenKontrolleAuslaufseiteAuf := FALSE;
      out_bScheibenKontrolleEinlaufseiteAuf := FALSE;
      steplCheck := STEP_1000_E;

    // SYSTEM CHECK=========================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      out_bShuttleAnheben := FALSE;
      out_bScheibenKontrolleAuslaufseiteAuf := FALSE;
      out_bScheibenKontrolleEinlaufseiteAuf := FALSE;
      bpFehler := TRUE;

    // SYSTEM CHECK=========================
    STEP_1000_E:
      bpDone := TRUE;
      bpScheibeFaehrtUeberAuslauf := FALSE;

  // SYSTEM CHECK=========================
  END_CASE
ELSE
  IF ( steplCheck > STEP_0_E ) THEN
    bpDone := FALSE;
    bpOutBereitZumAustransport := FALSE;
    bpOutBereitZumEintransport := FALSE;
    out_bShuttleAnheben := FALSE;
    out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
    blScheibenKontrolleAuslaufseiteEin    := FALSE;
    out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
    blScheibenKontrolleEinlaufseiteEin    := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplCheck := STEP_0_E;
  END_IF
END_IF


//_________________________________________________________________________
// ************************ ENDE Sytsem Check ***************************
//_________________________________________________________________________
END_ACTION