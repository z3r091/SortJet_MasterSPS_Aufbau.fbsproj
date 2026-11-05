(* METADATA
{
  "v3Meta": {
    "objectGuid": "f887ed1b-f10d-4106-9f95-b540cce6687a"
  }
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// RESET
//-------------------------------------------------------------------------------------------------
IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
  BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
  SpsError( eFehler_Station,
            cMELDUNG_STATION_NICHT_ZURUECKGESETZT,
            BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
            AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
            BasisStationsParameter.awFehlerInformationen );
END_IF

IF blBetriebsartReset THEN

  CASE steplReset OF
    // RESET =====================================
    STEP_0_E:
      BasisStationsParameter.bEintransport[cWAND_1] := FALSE;
      BasisStationsParameter.bAustransport[cWAND_1] := FALSE;
      bpDone := FALSE;
      tonlZeitRunterfahren( IN := FALSE );
      tonlZeitHochfahren( IN := FALSE );
      tonlUeberwachungRolltor( IN := FALSE );
      tonlRolltorOeffnenSchliesen( IN := FALSE );

      Arretierung.bpReset := TRUE;

      steplReset := STEP_100_E;

    // RESET =====================================
    STEP_100_E:
      blArretierungSchliessen        := FALSE;
      blArretierungOeffnen           := FALSE;
      blRolltorAuf                   := FALSE;
      blRolltorAb                    := FALSE;
      blMerkerEinschleusenQuittiert  := FALSE;
      BasisStationsParameter.bFehler := FALSE;

      wpFehlerNr := 0;
      steplReset := STEP_1000_E;

    // RESET =====================================
    STEP_1000_E:
      bpDone := TRUE;
      BasisStationsParameter.bReset := FALSE;

  // RESET =====================================
  END_CASE

ELSE

  IF ( steplReset > STEP_0_E ) THEN
    bpDone := FALSE;
    BasisStationsParameter.bReset := FALSE;
    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION