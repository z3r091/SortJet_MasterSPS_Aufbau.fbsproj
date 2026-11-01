(* METADATA
{
  "v3Meta": {
    "objectGuid": "61b35210-ba3b-45e2-84f3-1bb8ab20b8ef"
  }
}
*)
ACTION Greifer
//-------------------------------------------------------------------------------------------------
// Greifer ÖFFNEN => FUER MULTIBELADUNG
//-------------------------------------------------------------------------------------------------

IF ( blGreiferOeffnen 
     //  AND blUntergestellErkannt //safety eingang
     AND NOT blLinearEinheitSH // Der Greifer darf nicht geöffnet werden, wenn die Lineareinheit auf der Übergabeposition zum Shuttle steht. 
   // Andernfalls können wir den Wagen nicht mehr greifen, da wir die Lineareinheit nur ganz nach vorn/hinten fahren können 
   (*AND BasisStationsParameter.bFreigabe*) )
THEN
  CASE steplGreiferOeffnen OF

    // Greifer ÖFFNEN  ============================
    STEP_0_E:
      blGreiferOeffnenDone := FALSE;

      tonlGreiferAufZu( IN := FALSE );
      tonlTimeoutGreiferAufZu( IN := FALSE );

      IF blGreiferOffen
      THEN
        steplGreiferOeffnen := STEP_1000_E;
      ELSE
        IF BasisStationsParameter.bFreigabe AND bpLichtschranke_OK THEN
          out_bGreiferEinfahren := TRUE;
          out_bGreiferAusfahren  := FALSE;
          steplGreiferOeffnen := STEP_10_E;
        END_IF
      END_IF

    // Greifer ÖFFNEN  ============================
    STEP_10_E:
      tonlGreiferAufZu( IN := blGreiferOffen, PT := T#0.5S );
      tonlTimeoutGreiferAufZu(IN := NOT blGreiferOffen, PT := TIMEOUT_SENSOR);

      IF ( tonlGreiferAufZu.Q ) THEN
        out_bGreiferEinfahren := FALSE;
        steplGreiferOeffnen := STEP_1000_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutGreiferAufZu.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_GREIFER_NICHT_OFFEN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                  BasisStationsParameter.awFehlerInformationen );

        steplGreiferOeffnen := STEP_900_E;
      END_IF


    // Greifer ÖFFNEN  ============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      out_bGreiferEinfahren := FALSE;


    // Greifer ÖFFNEN  ============================
    STEP_1000_E:
      blGreiferOeffnenDone:=TRUE;

  END_CASE
END_IF

IF NOT blGreiferOeffnen THEN

  IF ( steplGreiferOeffnen > STEP_0_E ) THEN
    out_bGreiferAusfahren := FALSE;
    out_bGreiferEinfahren := FALSE;

    tonlGreiferAufZu( IN := FALSE );
    tonlTimeoutGreiferAufZu( IN := FALSE );

    blGreiferOeffnenDone := FALSE;

    steplGreiferOeffnen  := STEP_0_E;
  END_IF

END_IF



//-------------------------------------------------------------------------------------------------
// Greifer SCHLIESSEN => FUER MULTIBELADUNG
//-------------------------------------------------------------------------------------------------

IF blGreiferSchliessen 
// AND BasisStationsParameter.bFreigabe
//  AND blUntergestellErkannt //safety eingang
// AND NOT in_bFaecherwagenNichtInPos // Gestell ist auf dem Wagen
THEN
  CASE steplGreiferSchliessen OF

    // Greifer SCHLIESSEN ============================
    STEP_0_E:
      blGreiferSchliessenDone := FALSE;

      tonlGreiferAufZu( IN := FALSE );
      tonlTimeoutGreiferAufZu( IN := FALSE );

      IF blGreiferZu
      THEN
        steplGreiferSchliessen := STEP_1000_E;
      ELSE
        IF BasisStationsParameter.bFreigabe AND bpLichtschranke_OK THEN
          out_bGreiferAusfahren := TRUE;
          out_bGreiferEinfahren  := FALSE;
          steplGreiferSchliessen := STEP_10_E;
        END_IF
      END_IF

    // Greifer SCHLIESSEN  ============================
    STEP_10_E:
      tonlGreiferAufZu( IN := blGreiferZu, PT := T#0.5S );
      tonlTimeoutGreiferAufZu(IN := NOT blGreiferZu, PT := TIMEOUT_SENSOR);

      IF ( tonlGreiferAufZu.Q ) THEN
        out_bGreiferAusfahren := FALSE;
        steplGreiferSchliessen := STEP_1000_E;
      END_IF

      // FEHLER:
      //   - Sensor

      IF tonlTimeoutGreiferAufZu.Q THEN
        wpFehlerNr := cMELDUNG_FAECHERWAGEN_GREIFER_NICHT_GESCHLOSSEN;
        SpsError( eFehler_Station,
                  wpFehlerNr,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                  BasisStationsParameter.awFehlerInformationen );

        steplGreiferSchliessen := STEP_900_E;
      END_IF


    // Greifer SCHLIESSEN  ============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      out_bGreiferAusfahren := FALSE;


    // Greifer SCHLIESSEN ============================
    STEP_1000_E:
      blGreiferSchliessenDone:=TRUE;

  // Greifer AUF ============================
  END_CASE
END_IF

IF NOT blGreiferSchliessen THEN

  IF ( steplGreiferSchliessen > STEP_0_E ) THEN
    out_bGreiferAusfahren := FALSE;
    out_bGreiferEinfahren := FALSE;

    tonlGreiferAufZu( IN := FALSE );
    tonlTimeoutGreiferAufZu( IN := FALSE );

    steplGreiferSchliessen  := STEP_0_E;

    blGreiferSchliessenDone := FALSE;
  END_IF

END_IF
END_ACTION