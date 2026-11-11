(* METADATA
{
	"v3Meta": {
		"objectGuid": "3ffb14b9-d8bd-42b1-8667-4fb728d40c20"
	}
}
*)
ACTION SensorenFreifahren
//-------------------------------------------------------------------------------------------------
// AKTION SENSOREN FREIFAHREN
//-------------------------------------------------------------------------------------------------

IF (  bpStarteSensorFreiFahren
     AND NOT bpCheck
     AND NOT bpEintransport
     AND NOT bpAustransport
     AND bpAutomatikAktiv )
THEN

  (* Fehlerbehandlung:
     - Antrieb
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplSensorFreiFahren := STEP_900_E;
  END_IF

  CASE steplSensorFreiFahren OF
    // SENSOR FREI FAHREN ==============================
    STEP_0_E:
      (* Hinweis:
         - Pruefen ob der Antrieb verfahren werden kann
      *)


      IF ( Antrieb.bpReglerBereit
           AND blAntriebsKopplungAktiv )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplSensorFreiFahren := STEP_10_E;
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit AND blAntriebsKopplungAktiv ),
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplSensorFreiFahren := STEP_900_E;
      END_IF
    // SENSOR FREI FAHREN ==============================
    STEP_10_E:
      (* Hinweis:
         - Pruefen welcher Sensor freigefahren werden muss
         - Freigefahren werden die Sensoren, die die Querfahrt sperren: die Stopp-Sensoren
           (ohne Stopp-Sensor liefert das Shuttle dort den Einlauf- bzw. Auslaufsensor)
      *)
      IF ( NOT toflEinlaufsensorSTOP.Q AND NOT toflAuslaufsensorSTOP.Q ) THEN
        steplSensorFreiFahren := STEP_1000_E;

      ELSIF ( toflAuslaufsensorSTOP.Q AND NOT toflEinlaufsensorSTOP.Q ) THEN
        steplSensorFreiFahren := STEP_100_E;

      ELSIF ( toflEinlaufsensorSTOP.Q AND NOT toflAuslaufsensorSTOP.Q  ) THEN
        steplSensorFreiFahren := STEP_200_E;

      ELSE
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplSensorFreiFahren := STEP_900_E;

      END_IF

    // SENSOR FREI FAHREN ==============================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< AUSLAUFSENSOR BELEGT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Versuchen den Auslaufsensor frei zu fahren
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      // Rueckwaerts bis der Auslaufsensor frei wird (fallende Flanke), dann die Freifahrstrecke weiter
      //   => der weiter aussen liegende Auslauf-Stopp-Sensor ist damit ebenfalls frei
      Antrieb.rpZielPosition    := - rgMKWegSensorFreiFahrenVerfahrabbruch;
      Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
      Antrieb.wpBetriebsart     := RESTWEG;

      steplSensorFreiFahren := STEP_110_E;

    // SENSOR FREI FAHREN ==============================
    STEP_110_E:
      (* Hinweis:
         - Antrieb verfahren
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplSensorFreiFahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlauf- Stopp- Sensor
      *)
      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_BELEGT;
        steplSensorFreiFahren := STEP_900_E;
      END_IF

    // SENSOR FREI FAHREN ==============================
    STEP_200_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< EINLAUFSENSOR BELEGT >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Versuchen den Einlaufsensor frei zu fahren
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      // Vorwaerts bis der Einlaufsensor frei wird (fallende Flanke), dann die Freifahrstrecke weiter
      //   => der weiter aussen liegende Einlauf-Stopp-Sensor ist damit ebenfalls frei
      Antrieb.rpZielPosition    := rgMKWegSensorFreiFahrenVerfahrabbruch;
      Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
      Antrieb.wpBetriebsart     := RESTWEG;

      steplSensorFreiFahren := STEP_210_E;

    // SENSOR FREI FAHREN ==============================
    STEP_210_E:
      (* Hinweis:
         - Antrieb verfahren
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplSensorFreiFahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Auslauf- Stopp- Sensor
      *)
      IF ( bpSensorAuslaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_BELEGT;
        steplSensorFreiFahren := STEP_900_E;
      END_IF

    // SENSOR FREI FAHREN ==============================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpFehler := TRUE;

    // SENSOR FREI FAHREN ==============================
    STEP_1000_E:
      bpStarteSensorFreiFahren := FALSE;

  // SENSOR FREI FAHREN ==============================
  END_CASE
ELSE

  IF ( steplSensorFreiFahren > STEP_0_E ) THEN
    bpStarteSensorFreiFahren := FALSE;
    Antrieb.wpBetriebsart    := KEINE_FUNKTION;
    tonlAntriebNichtFreigegeben( IN := FALSE );
    steplSensorFreiFahren    := STEP_0_E;
  END_IF

END_IF
END_ACTION