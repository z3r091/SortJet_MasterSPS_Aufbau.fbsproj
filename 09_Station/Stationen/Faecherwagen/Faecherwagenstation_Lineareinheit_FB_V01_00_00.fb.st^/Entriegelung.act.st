(* METADATA
{
  "v3Meta": {
    "objectGuid": "ef1bf0bb-24f6-4fd4-98fc-a337500dec76"
  }
}
*)
ACTION Entriegelung
//-------------------------------------------------------------------------------------------------
// ENTRIEGELUNG AUF => FUER MULTIBELADUNG
//-------------------------------------------------------------------------------------------------

IF ( blEntriegelungOeffnen 
   //AND bpUntergestellErkannt //safety eingang
   // AND NOT in_bFaecherwagenNichtInPos // Gestell ist auf dem Wagen
   (*AND BasisStationsParameter.bFreigabe*) )
THEN
  CASE steplEntriegelungOeffnen OF

    // ENTRIEGELUNG AUF  ============================
    STEP_0_E:
      blEntriegelungOeffnenDone := FALSE;

      tonlEntriegelungAufZu( IN := FALSE );
      tonlTimeoutEntriegelungAufZu( IN := FALSE );

      IF in_bEntriegelungOffen
      THEN
        steplEntriegelungOeffnen := STEP_1000_E;
      ELSE
        IF BasisStationsParameter.bFreigabe AND bpLichtschranke_OK THEN
          out_bEntriegelungAusfahren := TRUE;
          out_bEntriegelungEinfahren  := FALSE;
          steplEntriegelungOeffnen := STEP_10_E;
        END_IF
      END_IF

    // ENTRIEGELUNG AUF  ============================
    STEP_10_E:
      tonlEntriegelungAufZu( IN := in_bEntriegelungOffen, PT := T#0.5S );
      tonlTimeoutEntriegelungAufZu(IN := NOT in_bEntriegelungOffen, PT := TIMEOUT_SENSOR);

      IF ( tonlEntriegelungAufZu.Q ) THEN
        out_bEntriegelungAusfahren := FALSE;
        steplEntriegelungOeffnen := STEP_1000_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutEntriegelungAufZu.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_ENTRIEGELUNG_NICHT_OFFEN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEntriegelungOeffnen := STEP_900_E;
      END_IF


    // ENTRIEGELUNG AUF  ============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      out_bEntriegelungAusfahren := FALSE;


    // ENTRIEGELUNG AUF  ============================
    STEP_1000_E:
      blEntriegelungOeffnenDone:=TRUE;

  END_CASE
ELSE

  IF ( steplEntriegelungOeffnen > STEP_0_E ) THEN
    out_bEntriegelungAusfahren := FALSE;
    out_bEntriegelungEinfahren := FALSE;

    tonlEntriegelungAufZu( IN := FALSE );
    tonlTimeoutEntriegelungAufZu( IN := FALSE );

    blEntriegelungOeffnenDone := FALSE;

    steplEntriegelungOeffnen  := STEP_0_E;
  END_IF

END_IF



//-------------------------------------------------------------------------------------------------
// ENTRIEGELUNG AB => FUER MULTIBELADUNG
//-------------------------------------------------------------------------------------------------

IF blEntriegelungSchliessen 
// AND BasisStationsParameter.bFreigabe
//AND bpUntergestellErkannt //safety eingang
THEN
  CASE steplEntriegelungSchliessen OF

    // ENTRIEGELUNG AB ============================
    STEP_0_E:
      blEntriegelungSchliessenDone := FALSE;

      tonlEntriegelungAufZu( IN := FALSE );
      tonlTimeoutEntriegelungAufZu( IN := FALSE );

      IF in_bEntriegelungGeschlossen
      THEN
        steplEntriegelungSchliessen := STEP_1000_E;
      ELSE
        IF BasisStationsParameter.bFreigabe AND bpLichtschranke_OK THEN
          out_bEntriegelungEinfahren := TRUE;
          out_bEntriegelungAusfahren  := FALSE;
          steplEntriegelungSchliessen := STEP_10_E;
        END_IF
      END_IF

    // ENTRIEGELUNG AB  ============================
    STEP_10_E:
      tonlEntriegelungAufZu( IN := in_bEntriegelungGeschlossen, PT := T#0.5S );
      tonlTimeoutEntriegelungAufZu(IN := NOT in_bEntriegelungGeschlossen, PT := TIMEOUT_SENSOR);

      IF ( tonlEntriegelungAufZu.Q ) THEN
        out_bEntriegelungEinfahren := FALSE;
        steplEntriegelungSchliessen := STEP_1000_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutEntriegelungAufZu.Q THEN

        wpFehlerNr := cMELDUNG_FAECHERWAGEN_ENTRIEGELUNG_NICHT_GESCHLOSSEN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        steplEntriegelungSchliessen := STEP_900_E;
      END_IF


    // ENTRIEGELUNG AB  ============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      out_bEntriegelungEinfahren := FALSE;


    // ENTRIEGELUNG AB ============================
    STEP_1000_E:
      blEntriegelungSchliessenDone:=TRUE;

  // ENTRIEGELUNG AB ============================
  END_CASE
ELSE

  IF ( steplEntriegelungSchliessen > STEP_0_E ) THEN
    out_bEntriegelungAusfahren := FALSE;
    out_bEntriegelungEinfahren := FALSE;

    tonlEntriegelungAufZu( IN := FALSE );
    tonlTimeoutEntriegelungAufZu( IN := FALSE );

    steplEntriegelungSchliessen  := STEP_0_E;

    blEntriegelungSchliessenDone := FALSE;
  END_IF

END_IF
END_ACTION