(* METADATA
{
	"v3Meta": {
		"objectGuid": "5201c53d-be9e-4979-82e7-22292312a1cd"
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

      Anschlag.bpReset           := TRUE;
      AnschlagHorizontal.bpReset := TRUE;

      steplReset := STEP_100_E;

    // RESET =====================================
    STEP_100_E:
      blHubrahmenHeben               := FALSE;
      blHubrahmenSenken              := FALSE;
      blFaecherwagenVor              := FALSE;
      blFaecherwagenZurueck          := FALSE;
      blZentrierungOeffnen           := FALSE;
      blZentrierungSchliessen        := FALSE;
      blAnschlagAuf                  := FALSE;
      blAnschlagAb                   := FALSE;
      blAnschlagVor                  := FALSE;
      blAnschlagZurueck              := FALSE;
      blPositionskorrekturAktiv      := FALSE;
      blMutingResetAnforderung       := FALSE;
      bpUmlaufVentilPause            := FALSE;
      blRolltorAuf                   := FALSE;
      blRolltorAb                    := FALSE;
      blMerkerEinschleusenQuittiert  := FALSE;
      BasisStationsParameter.bFehler := FALSE;

      wpFehlerNr := cMELDUNG_NULL;
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