(* METADATA
{
  "v3Meta": {
    "objectGuid": "f39d4f77-3690-4b3d-9043-6900d0098add"
  }
}
*)
ACTION Reset
// RESET
IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
  BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
  SpsError( eFehler_Station,
            cMELDUNG_STATION_NICHT_ZURUECKGESETZT,
            BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
            AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
            BasisStationsparameter.awFehlerInformationen );
END_IF

IF blBetriebsartReset THEN

  CASE steplReset OF
    // RESET =====================================
    STEP_0_E:
      BasisStationsParameter.bEintransport[1] := FALSE;
      BasisStationsParameter.bAustransport[1] := FALSE;
      bpDone := FALSE;
      tonlZeitRunterfahren(IN := FALSE);
      tonlZeitHochfahren(IN := FALSE);
      tonlUeberwachungRolltor( IN := FALSE );
      tonlRolltorOeffnenSchliesen( IN := FALSE );
      tonlEntriegelungAufZu( IN := FALSE );
      tonlTimeoutEntriegelungAufZu( IN := FALSE );
      tonlGegenhalterAufZu( IN := FALSE );
      tonlTimeoutGegenhalterAufZu( IN := FALSE );
      tonlGreiferAufZu( IN := FALSE );
      tonlTimeoutGreiferAufZu( IN := FALSE );
      tonlLineareinheitVorZurueck(IN := FALSE);
      tonlTimeoutSensorShutle(IN := FALSE);
      tonlLineareinheitVorZurueck(IN := FALSE);
      tonlTimeoutSensorHinten(IN := FALSE);
      tonlLineareinheitVorZurueck(IN := FALSE);
      tonlTimeoutSensorVorne(IN := FALSE);

      steplReset := STEP_100_E;

    // RESET =====================================
    STEP_100_E:
      blRFID_DataWasValid                  := FALSE;
      blLineareinheitVor                 := FALSE;
      blLineareinheitZurueck             := FALSE;
      blLineareinheitShuttle             := FALSE;
      blEntriegelungOeffnen              := FALSE;
      blEntriegelungSchliessen           := FALSE;
      blGegenhalterOeffnen               := FALSE;
      blGegenhalterSchliessen            := FALSE;
      blGreiferOeffnen                   := FALSE;
      blGreiferSchliessen                := FALSE;
      blRolltorAuf                       := FALSE;
      blRolltorAb                        := FALSE;
      BasisStationsParameter.bFehler     := FALSE;

      bpHinweisEingriffErforderlich := FALSE;
    
      wpFehlerNr := 0;
      steplReset := STEP_1000_E;

    // RESET =====================================
    STEP_1000_E:
      bpDone := TRUE;
      BasisStationsParameter.bReset := FALSE;

  // RESET =====================================
  END_CASE
ELSE

  IF( steplReset > STEP_0_E )THEN
    bpDone := FALSE;
    BasisStationsParameter.bReset := FALSE;
    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION