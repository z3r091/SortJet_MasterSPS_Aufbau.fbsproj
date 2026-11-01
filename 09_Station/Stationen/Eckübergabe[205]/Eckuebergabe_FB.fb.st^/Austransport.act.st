(* METADATA
{
  "v3Meta": {
    "objectGuid": "6c0f0fe6-0a31-4f94-90c2-8d8599648681"
  }
}
*)
ACTION Austransport
//==================================================================================================
// AKTION AUSTRANSPORT
//==================================================================================================
IF ( BasisStationsParameter.bAustransport[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport_X.bpFehler ) THEN
    Glastransport_X.bpAustransport := FALSE;
    Glastransport_X.bpAustransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_X.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF

  IF ( Glastransport_Y.bpFehler ) THEN
    Glastransport_Y.bpAustransport := FALSE;
    Glastransport_Y.bpAustransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_Y.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    blHubrahmenPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF


  CASE steplAustransport OF
    //=== AUSTRANSPORT ===================================================================================
    STEP_0_E:
      (* Hinweis:
         - Hubrahmen auf die Austransport-Achse stellen
      *)
      elHubrahmenZielAchse     := elAchseAustransport;
      blHubrahmenPositionieren := TRUE;

      steplAustransport := STEP_10_E;

    //=== AUSTRANSPORT ===================================================================================
    STEP_10_E:
      IF ( blHubrahmenInPosition ) THEN
        blHubrahmenPositionieren := FALSE;

        steplAustransport := STEP_100_E;
      END_IF

    //=== AUSTRANSPORT ===================================================================================
    STEP_100_E:
      (* Hinweis:
         - Austransport starten
      *)
      GlastransportAus.pAuftrag                   := BasisStationsParameter.pAuftrag[cWAND_1];
      GlastransportAus.bpAustransport             := BasisStationsParameter.bAustransport[cWAND_1] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      GlastransportAus.bpAustransportRueckwaertig := BasisStationsParameter.bAustransport[cWAND_1] AND     BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

      steplAustransport := STEP_110_E;

    //=== AUSTRANSPORT ===================================================================================
    STEP_110_E:
      (* Hinweis:
         - Austransport abgeschlossen
      *)
      IF ( GlastransportAus.bpDone ) THEN
        GlastransportAus.bpAustransport             := FALSE;
        GlastransportAus.bpAustransportRueckwaertig := FALSE;

        steplAustransport := STEP_1000_E;
      END_IF

    //=== AUSTRANSPORT ===================================================================================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    //=== AUSTRANSPORT ===================================================================================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := TRUE;

  //=== AUSTRANSPORT ===================================================================================
  END_CASE
ELSE

  IF ( steplAustransport > STEP_0_E ) THEN
    BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;

    Glastransport_X.bpAustransport             := FALSE;
    Glastransport_X.bpAustransportRueckwaertig := FALSE;
    Glastransport_Y.bpAustransport             := FALSE;
    Glastransport_Y.bpAustransportRueckwaertig := FALSE;
    blHubrahmenPositionieren                   := FALSE;

    steplAustransport := STEP_0_E;
  END_IF

END_IF
END_ACTION