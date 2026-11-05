(* METADATA
{
  "v3Meta": {
    "objectGuid": "00538213-1902-415d-a877-2063365d0692"
  }
}
*)
ACTION Gegenhalter
//-------------------------------------------------------------------------------------------------
// Gegenhalter AB => FUER MULTIBELADUNG
//-------------------------------------------------------------------------------------------------

IF ( blGegenhalterOeffnen 
   //  AND bpUntergestellErkannt //safety eingang
   // AND NOT in_bFaecherwagenNichtInPos // Gestell ist auf dem Wagen
   (*AND BasisStationsParameter.bFreigabe*) )
THEN
  CASE steplGegenhalterOeffnen OF

    // Gegenhalter AB  ============================
    STEP_0_E:
      blGegenhalterOeffnenDone := FALSE;

      tonlGegenhalterAufZu( IN := FALSE );
      tonlTimeoutGegenhalterAufZu( IN := FALSE );

      IF in_bGegenhalterOffen
      THEN
        steplGegenhalterOeffnen := STEP_1000_E;
      ELSE
        IF BasisStationsParameter.bFreigabe AND bpLichtschranke_OK THEN
          out_bGegenhalterEinfahren := TRUE;
          out_bGegenhalterAusfahren  := FALSE;
          steplGegenhalterOeffnen := STEP_10_E;
        END_IF
      END_IF

    // Gegenhalter AB  ============================
    STEP_10_E:
      tonlGegenhalterAufZu( IN := in_bGegenhalterOffen, PT := T#1S );
      tonlTimeoutGegenhalterAufZu(IN := NOT in_bGegenhalterOffen, PT := TIMEOUT_SENSOR);

      IF ( tonlGegenhalterAufZu.Q ) THEN
        out_bGegenhalterEinfahren := FALSE;
        steplGegenhalterOeffnen := STEP_1000_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutGegenhalterAufZu.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_GEGENHALTER_NICHT_OFFEN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplGegenhalterOeffnen := STEP_900_E;
      END_IF


    // Gegenhalter AB  ============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      out_bGegenhalterEinfahren := FALSE;


    // Gegenhalter AB  ============================
    STEP_1000_E:
      blGegenhalterOeffnenDone:=TRUE;

  END_CASE
ELSE

  IF ( steplGegenhalterOeffnen > STEP_0_E ) THEN
    out_bGegenhalterAusfahren := FALSE;
    out_bGegenhalterEinfahren := FALSE;

    tonlGegenhalterAufZu( IN := FALSE );
    tonlTimeoutGegenhalterAufZu( IN := FALSE );

    blGegenhalterOeffnenDone := FALSE;

    steplGegenhalterOeffnen  := STEP_0_E;
  END_IF

END_IF



//-------------------------------------------------------------------------------------------------
// Gegenhalter AUF => FUER MULTIBELADUNG
//-------------------------------------------------------------------------------------------------

IF blGegenhalterSchliessen 
// AND BasisStationsParameter.bFreigabe
//  AND bpUntergestellErkannt //safety eingang
// AND NOT in_bFaecherwagenNichtInPos // Gestell ist auf dem Wagen
THEN
  CASE steplGegenhalterSchliessen OF

    // Gegenhalter Auf ============================
    STEP_0_E:
      blGegenhalterSchliessenDone := FALSE;

      tonlGegenhalterAufZu( IN := FALSE );
      tonlTimeoutGegenhalterAufZu( IN := FALSE );

      IF in_bGegenhalterZu
      THEN
        steplGegenhalterSchliessen := STEP_1000_E;
      ELSE
        IF BasisStationsParameter.bFreigabe AND bpLichtschranke_OK THEN
          out_bGegenhalterAusfahren := TRUE;
          out_bGegenhalterEinfahren  := FALSE;
          steplGegenhalterSchliessen := STEP_10_E;
        END_IF
      END_IF

    // Gegenhalter AUF  ============================
    STEP_10_E:
      tonlGegenhalterAufZu( IN := in_bGegenhalterZu, PT := T#1S );
      tonlTimeoutGegenhalterAufZu(IN := NOT in_bGegenhalterOffen, PT := TIMEOUT_SENSOR);

      IF ( tonlGegenhalterAufZu.Q ) THEN
        out_bGegenhalterAusfahren := FALSE;
        steplGegenhalterSchliessen := STEP_1000_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutGegenhalterAufZu.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_GEGENHALTER_NICHT_GESCHLOSSEN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplGegenhalterSchliessen := STEP_900_E;
      END_IF


    // Gegenhalter AUF  ============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      out_bGegenhalterAusfahren := FALSE;


    // Gegenhalter AUF ============================
    STEP_1000_E:
      blGegenhalterSchliessenDone:=TRUE;

  // Gegenhalter AUF ============================
  END_CASE
ELSE

  IF ( steplGegenhalterSchliessen > STEP_0_E ) THEN
    out_bGegenhalterAusfahren := FALSE;
    out_bGegenhalterEinfahren := FALSE;

    tonlGegenhalterAufZu( IN := FALSE );
    tonlTimeoutGegenhalterAufZu( IN := FALSE );

    steplGegenhalterSchliessen  := STEP_0_E;

    blGegenhalterSchliessenDone := FALSE;
  END_IF

END_IF
END_ACTION