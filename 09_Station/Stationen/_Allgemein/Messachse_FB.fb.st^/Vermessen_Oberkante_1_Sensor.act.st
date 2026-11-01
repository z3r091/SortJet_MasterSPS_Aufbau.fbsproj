(* METADATA
{
  "v3Meta": {
    "objectGuid": "c5d2779d-1e0a-46ba-8928-f7dce1a1f66f"
  }
}
*)
ACTION Vermessen_Oberkante_1_Sensor
//-------------------------------------------------------------------------------------------------
// AKTION: VERMESSUNG DER SCHEIBE
//-------------------------------------------------------------------------------------------------
IF ( bpVermessen_Oberkante_1_Sensor ) THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_MESSACHSE;
    steplOberkante_1_Sensor := STEP_900_E;
  END_IF

  CASE steplOberkante_1_Sensor OF
    // VERMESSEN OBER KANTE 1 SENSOR  ====================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
         - Pruefen ob der Umrichter bereit zum verfahren ist
      *)
      bpDone         := FALSE;
      rlMessErgebnis := REAL#0;
      epGlashoehenTypMode2 := eGlasHoheKeinStatus;

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION ;
        steplOberkante_1_Sensor := STEP_10_E;
      END_IF

    // VERMESSEN OBER KANTE 1 SENSOR  ====================
    STEP_10_E:
      (* Hinweis:
         - Starten der Positionierung. Der Sensor muss belegt sein. Wenn nicht gleich
      *)
      IF ( in_bSensorUnten ) THEN

        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

        (* Wichtig:
           - Rest-Positionierung | Positionieren auf die Ermittelte Position
        *)
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpGeschwindigkeitMessen;

        Antrieb.rpZielPosition    := ppParameterBaustein.rStreckePositionieren;
        Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplOberkante_1_Sensor := STEP_100_E;

      ELSE
        epGlashoehenTypMode2 := eGlasZuNiedrig;
        steplOberkante_1_Sensor := STEP_1000_E;

      END_IF

    // VERMESSEN OBER KANTE 1 SENSOR  ====================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  RESTWEG [VERMESSEN DER SCHEIBE MITTELS RESTWEGPOSITIONIERUNG]
      //
      //  Hinweis:
      // - Positionierung des Sensors mittels Restweg auf die "Fallende Flanke" [Scheibenkante]
      //   um einen Wert um so anhand der Ist-Position die Scheiben- Hoehe \ Laenge zur
      //   ermitteln
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Antrieb ist verfahren
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplOberkante_1_Sensor := STEP_110_E;
      END_IF

      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn man sich den Bereichgrenzen naehrt
      *)
      IF (  Antrieb.rpIstPosition > Antrieb.rpMaxPosition - ppParameterBaustein.rVerfahrbereichsOffset
           AND Antrieb.rpIstPosition <Antrieb.rpMinPosition + ppParameterBaustein.rVerfahrbereichsOffset )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
      END_IF

      (* Hinweis:
         - Wegstrecke ueberwachen
      *)
      IF ( ABS(Antrieb.rpIstPosition) > rpZielPosition + cUEBERWACHUNG_WEGSTRECKE ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplOberkante_1_Sensor := STEP_110_E;
      END_IF

      (* Fehlerbehandlung:
         - Pruefen der Position. Liegt die Position ausserhalb des Verfahrbereichs darf nicht verfahren werden
            => Position ausserhalb der SW-Endschalter = Referenzverlust bei SEW
      *)
      IF (  Antrieb.rpIstPosition >= Antrieb.rpMaxPosition
           AND Antrieb.rpIstPosition <= Antrieb.rpMinPosition )
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;

        wpFehlerNr := cMELDUNG_MESSACHSE_VERFAHRBEREICH;

        steplOberkante_1_Sensor := STEP_900_E;

      END_IF

    // VERMESSEN OBER KANTE 1 SENSOR  ====================
    STEP_110_E:
      (* Hinweis:
         - Sicherstellen das der Antrieb steht
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplOberkante_1_Sensor := STEP_120_E;
      END_IF

    // VERMESSEN OBER KANTE 1 SENSOR  ====================
    STEP_120_E:
      (* Hinweis:
         - Belegung des Sensors-pruefen
           Wichtig:
         - Aufgrund der Weg-Ueberwachung kann die Restweg-Positionierung abgebrochen werden und somit der Sensor belegt sein.
      *)
      IF ( NOT in_bSensorUnten ) THEN

        (* Wichtig:
           - In das Messergebnis muss ein Korrekturwert inkludiert werden aufgrund der ruckelnden Verefahrbewegung + Schaltverzug des Sensors
        *)
        rlMessErgebnis := ( (ABS(Antrieb.rpIstPosition) - ppParameterBaustein.rStreckePositionieren) + ppParameterBaustein.rOffsetMessung );

        IF ( ABS( rlMessErgebnis - rpZielPosition ) <= ppParameterBaustein.rToleranz ) THEN
          epGlashoehenTypMode2 := eGlasHoeheOK;
        ELSE

          IF ( ( rlMessErgebnis - rpZielPosition ) > ppParameterBaustein.rToleranz ) THEN
            epGlashoehenTypMode2 := eGlasZuHoch;

          ELSE
            epGlashoehenTypMode2 := eGlasZuNiedrig;

          END_IF

        END_IF

        steplOberkante_1_Sensor := STEP_1000_E;

      ELSE
        epGlashoehenTypMode2 := eGlasZuHoch;
        steplOberkante_1_Sensor := STEP_1000_E;

      END_IF

    // VERMESSEN OBER KANTE 1 SENSOR  ====================
    STEP_900_E:
      bpFehler := TRUE;

    // VERMESSEN OBER KANTE 1 SENSOR  ====================
    STEP_1000_E:
      bpDone := TRUE;

  // VERMESSEN OBER KANTE 1 SENSOR  ====================
  END_CASE

ELSE

  IF ( steplOberkante_1_Sensor > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.rpGeschwindigkeit := REAL#0;
    Antrieb.wpBetriebsart     := KEINE_FUNKTION;
    steplOberkante_1_Sensor := STEP_0_E;
  END_IF

END_IF
END_ACTION