(* METADATA
{
  "v3Meta": {
    "objectGuid": "7f06bdd7-dd30-4f23-890c-64b08d194069"
  }
}
*)
ACTION Rolltor
// @TEXT_IMPLEMENTATION := 'ST'
// ROLLTOR HOCH

IF blRolltorAuf THEN
  CASE steplRolltorAuf OF
    // ROLLER DOOR UP  ============================
    STEP_0_E:
      blRolltorAufDone := FALSE;
      tonlZeitRunterfahren(IN := FALSE);
      tonlZeitHochfahren(IN := FALSE);
      tonlUeberwachungRolltor(IN := FALSE);
      tonlRolltorOeffnenSchliesen(IN := FALSE);

      IF in_bNichtRolltorGeoeffnet AND BasisStationsParameter.stMKs.stStationsAufbau.bRolltor THEN
        steplRolltorAuf := STEP_5_E;
      ELSE
        steplRolltorAuf := STEP_1000_E;
      END_IF

    // ROLLTOR HOCH  ============================
    STEP_5_E:
      out_bRolltorAuf := TRUE; 
      out_bRolltorAb  := FALSE;
      tonlZeitHochfahren(IN := TRUE, PT := t#60s);
      steplRolltorAuf := STEP_10_E;

    // ROLLTOR HOCH  ============================
    STEP_10_E:
      tonlUeberwachungRolltor( IN := in_bNichtRolltorGeoeffnet, PT := T#60S );
      tonlRolltorOeffnenSchliesen( IN := NOT in_bNichtRolltorGeoeffnet, PT := T#500MS );
      tonlZeitHochfahren(IN := TRUE, PT := t#60s);

      IF tonlRolltorOeffnenSchliesen.Q THEN
        out_bRolltorAuf := FALSE;
        wlZeitHochfahren := TIME_TO_WORD(tonlZeitHochfahren.ET);
        tlZeitHochfahren := tonlZeitHochfahren.ET;
        tonlZeitHochfahren(IN := FALSE);
        steplRolltorAuf := STEP_1000_E;
      END_IF

      // Fehler:
      //   - Zeitliche Überwachung Rolltor
      IF tonlUeberwachungRolltor.Q THEN
        out_bRolltorAuf := FALSE;
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_UEBERWACHUNG_ROLLTOR_OEFFNEN;
        SpsError( eFehler_Station, 
                  wpFehlerNr, 
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, 
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern), 
                  BasisStationsParameter.awFehlerInformationen );

        steplRolltorAuf := STEP_900_E;
      END_IF

    // ROLLTOR HOCH  ============================
    STEP_900_E:
      out_bRolltorAb  := FALSE;
      out_bRolltorAuf := FALSE;
      BasisStationsParameter.bFehler := TRUE;

    // ROLLTOR HOCH  ============================
    STEP_1000_E:
      blRolltorAufDone := TRUE;

  // ROLLTOR HOCH  ============================
  END_CASE
END_IF

IF NOT blRolltorAuf THEN

  IF ( steplRolltorAuf > STEP_0_E ) THEN
    out_bRolltorAuf  := FALSE;
    steplRolltorAuf  := STEP_0_E;
    blRolltorAufDone := FALSE;
    tonlZeitRunterfahren(IN := FALSE);
    tonlZeitHochfahren(IN := FALSE);
    tonlUeberwachungRolltor( IN := FALSE );
    tonlRolltorOeffnenSchliesen( IN := FALSE );
  END_IF

END_IF

// *********************************************************************************
// ROLLTOR RUNTER

IF blRolltorAb AND
   (blLinearEinheitHinten OR blLineareinheitSH)
THEN
  CASE steplRolltorAb OF
    // ROLLTOR RUNTER ============================
    STEP_0_E:
      blRolltorAbDone := FALSE;
      tonlZeitRunterfahren(IN := FALSE);
      tonlZeitHochfahren(IN := FALSE);
      tonlUeberwachungRolltor( IN := FALSE );
      tonlRolltorOeffnenSchliesen( IN := FALSE );

      IF( blRolltorUnten OR  (NOT BasisStationsParameter.stMKs.stStationsAufbau.bRolltor))THEN
        steplRolltorAb := STEP_1000_E;
      ELSE
        steplRolltorAb := STEP_5_E;
      END_IF

    // ROLLTOR RUNTER ============================
    STEP_5_E:
      out_bRolltorAb  := TRUE;
      out_bRolltorAuf := FALSE;
      tonlZeitRunterfahren(IN := TRUE, PT := t#60s);
      tonlZeitHochfahren(IN := FALSE);
      tonlUeberwachungRolltor( IN := FALSE );
      tonlRolltorOeffnenSchliesen( IN := FALSE );
      steplRolltorAb := STEP_10_E;

    // ROLLTOR RUNTER ============================
    STEP_10_E:
      tonlUeberwachungRolltor( IN := NOT blRolltorUnten, PT := T#60S );
      tonlRolltorOeffnenSchliesen( IN := blRolltorUnten, PT := t#600ms );
      tonlZeitRunterfahren(IN := TRUE, PT := t#60s);

      IF tonlRolltorOeffnenSchliesen.Q THEN
        out_bRolltorAb  := FALSE;
        wlZeitRunterfahren := TIME_TO_WORD(tonlZeitRunterfahren.ET);
        tlZeitRunterfahren := tonlZeitRunterfahren.ET;
        tonlZeitRunterfahren(IN := FALSE);
        steplRolltorAb := STEP_1000_E;
      END_IF

      // Fehler:
      //   - Zeitliche Überwachung Rolltor
      IF tonlUeberwachungRolltor.Q THEN
        out_bRolltorAb := FALSE;
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_UEBERWACHUNG_ROLLTOR_SCHLIESSEN;
        SpsError( eFehler_Station,
                  wpFehlerNr, 
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, 
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern), 
                  BasisStationsParameter.awFehlerInformationen );

        steplRolltorAb := STEP_900_E;
      END_IF

    // ROLLTOR RUNTER ============================
    STEP_900_E:
      out_bRolltorAb  := FALSE;
      out_bRolltorAuf := FALSE;
      BasisStationsParameter.bFehler := TRUE;

    // ROLLTOR RUNTER ============================
    STEP_1000_E:
      blRolltorAbDone := TRUE;

  // ROLLTOR RUNTER ============================
  END_CASE
END_IF

IF NOT blRolltorAb THEN

  IF steplRolltorAb > STEP_0_E THEN
    out_bRolltorAb  := FALSE;
    steplRolltorAb  := STEP_0_E;
    blRolltorAbDone := FALSE;
    tonlZeitRunterfahren(IN := FALSE);
    tonlZeitHochfahren(IN := FALSE);
    tonlUeberwachungRolltor( IN := FALSE );
    tonlRolltorOeffnenSchliesen( IN := FALSE );
  END_IF

END_IF
END_ACTION