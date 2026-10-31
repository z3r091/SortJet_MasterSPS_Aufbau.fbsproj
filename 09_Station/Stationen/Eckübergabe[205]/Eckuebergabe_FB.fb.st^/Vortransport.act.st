(* METADATA
{
  "v3Meta": {
    "objectGuid": "c3323f5b-682c-449b-bae3-4a347a0f6acd"
  }
}
*)
ACTION Vortransport
//==================================================================================================
// AKTION VORTRANSPORT
//==================================================================================================
IF ( BasisStationsParameter.bVortransport[cWAND_1]
  AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport_X.bpFehler ) THEN
    Glastransport_X.bpVortransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_X.wpFehlerNr;
    steplVortransport := STEP_900_E;
  END_IF

  IF ( Glastransport_Y.bpFehler ) THEN
    Glastransport_Y.bpVortransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_Y.wpFehlerNr;
    steplVortransport := STEP_900_E;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    blHubrahmenPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplVortransport := STEP_900_E;
  END_IF


  CASE steplVortransport OF
//=== VORTRANSPORT ===================================================================================
    STEP_0_E:
      BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;

      (* Hinweis:
         - Hubrahmen auf die Austransport-Achse stellen
      *)
      elHubrahmenZielAchse     := elAchseAustransport;
      blHubrahmenPositionieren := TRUE;

      steplVortransport := STEP_10_E;

//=== VORTRANSPORT ===================================================================================
    STEP_10_E:
      IF ( blHubrahmenInPosition ) THEN
        blHubrahmenPositionieren := FALSE;

        steplVortransport := STEP_100_E;
      END_IF

//=== VORTRANSPORT ===================================================================================
    STEP_100_E:
      (* Hinweis:
         - Starten des Vortransports auf der Austransport-Achse
      *)
      GlastransportAus.bpVortransport := TRUE;

      steplVortransport := STEP_110_E;

//=== VORTRANSPORT ===================================================================================
    STEP_110_E:
      (* Hinweis:
         - Vortransport abgeschlossen
      *)
      IF ( GlastransportAus.bpDone ) THEN
        GlastransportAus.bpVortransport := FALSE;

        steplVortransport := STEP_1000_E;
      END_IF

//=== VORTRANSPORT ===================================================================================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

//=== VORTRANSPORT ===================================================================================
    STEP_1000_E:
      BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := TRUE;

//=== VORTRANSPORT ===================================================================================
  END_CASE
ELSE

  IF ( steplVortransport > STEP_0_E ) THEN
    BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;

    Glastransport_X.bpVortransport := FALSE;
    Glastransport_Y.bpVortransport := FALSE;
    blHubrahmenPositionieren       := FALSE;

    steplVortransport := STEP_0_E;
  END_IF

END_IF
END_ACTION