(* METADATA
{
	"v3Meta": {
		"objectGuid": "730ca78b-982a-4649-b2bd-18e46b03d006"
	}
}
*)
ACTION Linereinheit
// VERFAHREN VORWÄRTS
IF blLineareinheitVor
   AND NOT blLineareinheitZurueck
   AND NOT blLineareinheitShuttle
   AND (    ( in_bRolltorGeoeffnet AND BasisStationsParameter.stMKs.stStationsAufbau.bRolltor )
         OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bRolltor
         OR blLinVorBeiRolltorFahrt ) // Einschleusen: Vorfahren waehrend das Rolltor hochfaehrt
   AND bpUntergestellErkannt
   AND BasisStationsParameter.bFreigabe
THEN
  CASE steplLineareinheitVor OF
    // VERFAHREN VORWÄRTS =============================
    STEP_0_E:
      blLineareinheitVorDone := FALSE;
      tonlLineareinheitVorZurueck(IN := FALSE);
      tonlTimeoutSensorVorne(IN := FALSE);

      IF blLinearEinheitVorne THEN
        steplLineareinheitVor := STEP_1000_E;
      ELSE
        IF BasisStationsParameter.bFreigabe AND bpLichtschranke_OK THEN
          steplLineareinheitVor := STEP_10_E;
        END_IF
      END_IF

    // VERFAHREN VORWÄRTS =============================
    STEP_10_E:

      tonlTimeoutSensorShutle(IN := NOT in_bKlemmZylinderEingefahren, PT := TIMEOUT_SENSOR); //2min  WatchIO nach 10sec

      // Klemmzylinder nur pruefen, wenn er laut MK vorhanden ist (stStationsAufbau.bKlemmzylinder)
      IF    NOT BasisStationsParameter.stMKs.stStationsAufbau.bKlemmzylinder
         OR in_bKlemmZylinderEingefahren
         OR NOT blGreiferZu
      THEN
        tonlTimeoutSensorShutle(IN := FALSE);
        steplLineareinheitVor := STEP_20_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutSensorShutle.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_KLEMMZYLINDER_NICHT_EINGEFAHREN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplLineareinheitVor := STEP_900_E;
      END_IF
    // VERFAHREN VORWÄRTS =============================
    STEP_20_E:
      out_bLinearEinheitVor := TRUE;
      out_bLinearEinheitZurueck := FALSE;
      steplLineareinheitVor := STEP_30_E;

    // VERFAHREN VORWÄRTS =============================
    STEP_30_E:
      tonlLineareinheitVorZurueck( IN := blLinearEinheitVorne, PT := T#2S );
      tonlTimeoutSensorVorne(IN := NOT blLinearEinheitVorne, PT := TIMEOUT_SENSOR);

      IF tonlLineareinheitVorZurueck.Q THEN
        out_bLinearEinheitVor := FALSE;
        steplLineareinheitVor := STEP_1000_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutSensorVorne.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_LINEAREINHEIT_NICHT_VORNE;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplLineareinheitVor := STEP_900_E;
      END_IF

    // VERFAHREN VORWÄRTS =============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      out_bLinearEinheitVor := FALSE;

    // VERFAHREN VORWÄRTS =============================
    STEP_1000_E:
      blLineareinheitVorDone:=TRUE;

  END_CASE
ELSE

  IF ( steplLineareinheitVor > STEP_0_E ) THEN
    out_bLinearEinheitVor  := FALSE;
    blLineareinheitVorDone := FALSE;
    tonlLineareinheitVorZurueck(IN := FALSE);
    tonlTimeoutSensorVorne(IN := FALSE);
    tonlTimeoutSensorShutle(IN := FALSE);
    steplLineareinheitVor  := STEP_0_E;
  END_IF

END_IF

// ****************************************************************************************************************************************
// MOVEMENT BACKWARD

IF blLineareinheitZurueck AND // Richtung Shuttle
   NOT blLineareinheitVor
   AND NOT blLineareinheitShuttle
   AND BasisStationsParameter.bFreigabe
   AND bpUntergestellErkannt
THEN
  CASE steplLineareinheitZur OF
    // VERFAHREN RÜCKWÄRTS =============================
    STEP_0_E:
      blLineareinheitZurueckDone := FALSE;
      tonlLineareinheitVorZurueck(IN := FALSE);
      tonlTimeoutSensorHinten(IN := FALSE);

      IF blLinearEinheitHinten THEN
        steplLineareinheitZur := STEP_1000_E;
      ELSE
        steplLineareinheitZur := STEP_10_E;
      END_IF


    // VERFAHREN RÜCKWÄRTS =============================
    STEP_10_E:

      tonlTimeoutSensorShutle(IN := NOT in_bKlemmZylinderEingefahren, PT := TIMEOUT_SENSOR); //2min  WatchIO nach 10sec

      // Klemmzylinder nur pruefen, wenn er laut MK vorhanden ist (stStationsAufbau.bKlemmzylinder)
      IF    NOT BasisStationsParameter.stMKs.stStationsAufbau.bKlemmzylinder
         OR in_bKlemmZylinderEingefahren
         OR NOT blGreiferZu
      THEN
        tonlTimeoutSensorShutle(IN := FALSE);
        steplLineareinheitZur := STEP_20_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutSensorShutle.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_KLEMMZYLINDER_NICHT_EINGEFAHREN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplLineareinheitZur := STEP_900_E;
      END_IF

    // VERFAHREN RÜCKWÄRTS =============================
    STEP_20_E:
      out_bLinearEinheitZurueck := TRUE;
      out_bLinearEinheitVor     := FALSE;
      tonlLineareinheitVorZurueck( IN := FALSE );
      steplLineareinheitZur := STEP_30_E;

    // VERFAHREN RÜCKWÄRTS =============================
    STEP_30_E:
      tonlLineareinheitVorZurueck( IN := blLinearEinheitHinten, PT := T#2S );
      tonlTimeoutSensorHinten(IN := NOT blLinearEinheitHinten, PT := TIMEOUT_SENSOR);

      IF tonlLineareinheitVorZurueck.Q THEN
        out_bLinearEinheitZurueck := FALSE;
        steplLineareinheitZur := STEP_1000_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutSensorHinten.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_LINEAREINHEIT_NICHT_HINTEN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplLineareinheitZur := STEP_900_E;
      END_IF

    // VERFAHREN RÜCKWÄRTS =============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      out_bLinearEinheitZurueck := FALSE;

    // ZURUECMOVEMENT =============================
    STEP_1000_E:
      blLineareinheitZurueckDone:=TRUE;

  END_CASE
ELSE

  IF( steplLineareinheitZur > STEP_0_E )THEN
    steplLineareinheitZur := STEP_0_E;
    out_bLinearEinheitZurueck := FALSE;
    tonlLineareinheitVorZurueck(IN := FALSE);
    tonlTimeoutSensorHinten(IN := FALSE);
    tonlTimeoutSensorShutle(IN := FALSE);
    blLineareinheitZurueckDone := FALSE;
  END_IF

END_IF
// ****************************************************************************************************************************************
// MOVEMENT SHUTTLE

IF blLineareinheitShuttle  // Richtung Shuttle
   AND NOT blLineareinheitVor
   AND NOT blLineareinheitZurueck
   AND BasisStationsParameter.bFreigabe
   AND bpUntergestellErkannt
THEN
  CASE steplLineareinheitShuttle OF
    // VERFAHREN SHUTTLE =============================
    STEP_0_E:
      blLineareinheitShuttleDone := FALSE;
      tonlLineareinheitVorZurueck(IN := FALSE);
      tonlTimeoutSensorShutle(IN := FALSE);

      IF blLinearEinheitSH THEN
        steplLineareinheitShuttle := STEP_1000_E;
      ELSE
        IF BasisStationsParameter.bFreigabe AND bpLichtschranke_OK THEN
          steplLineareinheitShuttle := STEP_10_E;
        END_IF
      END_IF


    // VERFAHREN SHUTTLE =============================
    STEP_10_E:

      tonlTimeoutSensorShutle(IN := NOT in_bKlemmZylinderEingefahren, PT := TIMEOUT_SENSOR); //2min  WatchIO nach 10sec

      // Klemmzylinder nur pruefen, wenn er laut MK vorhanden ist (stStationsAufbau.bKlemmzylinder)
      IF    NOT BasisStationsParameter.stMKs.stStationsAufbau.bKlemmzylinder
         OR in_bKlemmZylinderEingefahren
         OR NOT blGreiferZu
      THEN
        tonlTimeoutSensorShutle(IN := FALSE);
        steplLineareinheitShuttle := STEP_20_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutSensorShutle.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_KLEMMZYLINDER_NICHT_EINGEFAHREN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplLineareinheitShuttle := STEP_900_E;
      END_IF

    // VERFAHREN SHUTTLE =============================
    STEP_20_E:
      out_bLinearEinheitZurueck := TRUE;
      out_bLinearEinheitVor     := FALSE;
      tonlLineareinheitVorZurueck( IN := FALSE );
      steplLineareinheitShuttle := STEP_30_E;

    // VERFAHREN SHUTTLE =============================
    STEP_30_E:
      tonlLineareinheitVorZurueck( IN := blLinearEinheitSH, PT := T#2S );
      tonlTimeoutSensorShutle(IN := NOT blLinearEinheitSH, PT := TIMEOUT_SENSOR);

      IF tonlLineareinheitVorZurueck.Q THEN
        out_bLinearEinheitZurueck := FALSE;
        steplLineareinheitShuttle := STEP_1000_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutSensorShutle.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_LINEAREINHEIT_NICHT_SHUTTLE_UEBERGABE;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplLineareinheitShuttle := STEP_900_E;
      END_IF

    // VERFAHREN SHUTTLE =============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      out_bLinearEinheitZurueck := FALSE;

    // MOVEMENT SHUTTLE =============================
    STEP_1000_E:
      blLineareinheitShuttleDone:=TRUE;

  END_CASE
ELSE

  IF( steplLineareinheitShuttle > STEP_0_E )THEN
    steplLineareinheitShuttle := STEP_0_E;
    out_bLinearEinheitZurueck := FALSE;
    tonlLineareinheitVorZurueck(IN := FALSE);
    tonlTimeoutSensorShutle(IN := FALSE);
    blLineareinheitShuttleDone := FALSE;
  END_IF

END_IF
END_ACTION