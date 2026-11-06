(* METADATA
{
  "v3Meta": {
    "objectGuid": "96d228cf-d746-4fe5-9c98-31003f1298ea"
  }
}
*)
ACTION Eintransport
//-------------------------------------------------------------------------------------------------
// AKTION: EINTRANSPORT ANLEGETISCH
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Ablauf wie Basic_Glastransport_FB_V01_00_00.Eintransport, Abweichungen:
     => Die Scheibe bleibt fuer die Hoehenmessung auf dem Einlaufsensor liegen (kein Einlaufsensor freifahren)
     => Analogkopplung zur Fremdanlage, bpOutBereitZumEintransport bleibt bis zum Ende der Positionierung gesetzt
     => Scheibenquittung nach abgeschlossener Positionierung, da die Scheibe auf dem Einlaufsensor liegen bleibt
        (beim Anlegen wertet Station_Anlegen die Quittung nicht aus, dort wird ueber SheetOnStation gebucht)
*)
IF ( bpEintransport
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplEintransport := STEP_900_E;
  END_IF

  CASE steplEintransport OF
    // EINTRANSPORT =====================
    STEP_0_E:
      (* Hinweis:
         - Variablen setzen
      *)
      bpDone      := FALSE;
      bprtScheibe := FALSE;

      // Antrieb nur referenzieren wenn Schwellwert überschritten oder nicht referenziert
      IF ( ABS(Antrieb.rpIstPosition) > rgSchwellwertReferenzieren ) OR NOT Antrieb.bpIstReferenziert THEN
        Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
        steplEintransport := STEP_10_E;
      ELSE
        steplEintransport := STEP_20_E;
      END_IF

    // EINTRANSPORT ====================
    STEP_10_E:
      (* Hinweis:
         - Antrieb ist referenziert
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_20_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_20_E:
      // ---------------------------------------------------------------------------------------
      //  KOPPLUNG ZWISCHEN DEN STATIONEN
      //
      //  Hinweis:
      // - Warten bis die Vorgaengerstation bereit zum Austransport ist [Soll-Geschwindigkeits- Kopplung]
      // ---------------------------------------------------------------------------------------
      Antrieb.rpGeschwindigkeit  := 0.0;

      bpOutBereitZumEintransport := TRUE; // Analogkopplung der Brechanlage; die Folgen uns solange, bis wir das GlasAbruf wegnehmen

      IF ( InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
        steplEintransport := STEP_100_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  EINTRANSPORT UEBER DEN EINLAUFSENSOR
      //
      //  Hinweis:
      // - Transport in "Positive" Richtung, die Scheibe bleibt auf dem Einlaufsensor stehen
      // ---------------------------------------------------------------------------------------
      IF ( NOT bpSensorEinlauf ) THEN

        // Antriebsposition merken
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        IF ( eGlastyp = cMAXSCHEIBE ) THEN
          Antrieb.rpZielPosition := ( ppParameterBaustein.rWegEinlaufsensorZuVorStopSensor - pAuftrag.rModellVersatzVorne );
        ELSE
          Antrieb.rpZielPosition := (( pAuftrag.rAuftragsLaenge - ppParameterBaustein.rWegUeberEinlaufEintransport ) - pAuftrag.rModellVersatzVorne );
        END_IF

        Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplEintransport := STEP_110_E;

      ELSE
        // Scheibe liegt bereits auf dem Einlaufsensor
        steplEintransport := STEP_140_E;

      END_IF

    // EINTRANSPORT =====================
    STEP_110_E:
      // Sicherstellen das der Einlaufsensor auch überfahren wurde
      IF ( bpSensorEinlauf ) THEN
        steplEintransport := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor
         - Einlaufsensor schaltet nicht
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

      // Laenge der Vorgaengerstation (ohne bekannte Vorgaengerlaenge: eigene Stationslaenge)
      rlMaxStreckeErsteScheibe := InGlasTransportVorgaenger.rLaengeStation;
      IF ( rlMaxStreckeErsteScheibe <= 0.0 ) THEN
        rlMaxStreckeErsteScheibe := ppParameterBaustein.rLaengeStation;
      END_IF
      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > rlMaxStreckeErsteScheibe ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_120_E:
      (* Hinweis:
         - Positionierung abwarten
         - Analogkopplung loesen (ausser Maximalscheibe)
      *)
      IF ( Antrieb.bpDone ) THEN

        IF ( eGlastyp <> cMAXSCHEIBE ) THEN
          bpOutBereitZumEintransport := FALSE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_140_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_140_E:
      (* Hinweis:
         - Sicherstellen das der Antrieb steht
         - Auslaufsensor Freifahren
         - Einlaufsensor Anfahren (die Scheibe muss fuer die Hoehenmessung auf dem Einlaufsensor liegen)
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        IF ( bpSensorAuslauf ) THEN
          rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
          steplEintransport := STEP_300_E;
        ELSIF ( NOT bpSensorEinlauf ) THEN
          rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
          steplEintransport := STEP_200_E;
        ELSE
          steplEintransport := STEP_150_E;
        END_IF

      END_IF

    // EINTRANSPORT =====================
    STEP_150_E:
      (* Hinweis:
         - Scheibenquittung nach abgeschlossener Positionierung
         - Keine Pruefung des Vorgaenger- Auslaufsensors: ist der Anlegetisch kuerzer als die
           Maximalscheibe, steht das Glas auf der Fremdanlage ueber
      *)
      bprtScheibe := TRUE;
      steplEintransport := STEP_1000_E;

    // EINTRANSPORT =====================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  EINLAUFSENSOR ANFAHREN
      //
      //  Hinweis:
      // - Scheibe zurueck auf den Einlaufsensor fahren
      // ---------------------------------------------------------------------------------------
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSlow;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberEinlaufEintransport;

      Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
      Antrieb.wpBetriebsart     := RESTWEG;
      steplEintransport := STEP_210_E;

    // EINTRANSPORT =====================
    STEP_210_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpSensorEinlauf ) THEN
          steplEintransport := STEP_140_E;
        ELSE
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
          steplEintransport := STEP_900_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Weg- Ueberwachung
      *)
      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_300_E:
      (* Anmerkung:
         - Auslaufsensor freifahren
      *)
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSlow;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberEinlauf;

      Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
      Antrieb.wpBetriebsart     := RESTWEG;
      steplEintransport := STEP_310_E;

    // EINTRANSPORT =====================
    STEP_310_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpSensorAuslauf ) THEN
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
          steplEintransport := STEP_900_E;
        ELSE
          steplEintransport := STEP_140_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Weg- Ueberwachung
      *)
      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpFehler    := TRUE;
      bprtScheibe := FALSE;

      Antrieb.wpBetriebsart := KEINE_FUNKTION;

    // EINTRANSPORT =====================
    STEP_1000_E:
      bprtScheibe := FALSE;
      bpDone := TRUE;

  // EINTRANSPORT =====================
  END_CASE
ELSE

  IF (steplEintransport > STEP_0_E) THEN
    bpDone := FALSE;
    bprtScheibe := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplEintransport := STEP_0_E;
  END_IF

END_IF
END_ACTION