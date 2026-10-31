(* METADATA
{
  "v3Meta": {
    "objectGuid": "8b9552af-6049-45bf-b0f7-4c4aa4ca1037"
  }
}
*)
ACTION Eintransport
//==================================================================================================
// AKTION EINTRANSPORT
//==================================================================================================
IF ( BasisStationsParameter.bEintransport[cWAND_1]
  AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport_X.bpFehler ) THEN
    Glastransport_X.bpEintransport             := FALSE;
    Glastransport_X.bpEintransportRueckwaertig := FALSE;
    Glastransport_X.bpVortransport             := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_X.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF

  IF ( Glastransport_Y.bpFehler ) THEN
    Glastransport_Y.bpEintransport             := FALSE;
    Glastransport_Y.bpEintransportRueckwaertig := FALSE;
    Glastransport_Y.bpVortransport             := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_Y.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    blHubrahmenPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF


  CASE steplEintransport OF
//=== EINTRANSPORT ==================================================================================
    STEP_0_E:
      (* Hinweis:
         - Hubrahmen auf die Eintransport-Achse stellen
      *)
      elHubrahmenZielAchse     := elAchseEintransport;
      blHubrahmenPositionieren := TRUE;

      steplEintransport := STEP_10_E;

//=== EINTRANSPORT ==================================================================================
    STEP_10_E:
      IF ( blHubrahmenInPosition ) THEN
        blHubrahmenPositionieren := FALSE;

        steplEintransport := STEP_100_E;
      END_IF

//=== EINTRANSPORT ==================================================================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES EINTRANSPORTS
      //
      //  Hinweis:
      //  - Eintransport ueber die Achse aus dem Auftrag
      //  - Einzelscheibe ueber die Querachse: Ablage ueber rWegEinlaufsensorZuVorStopSensor
      // ---------------------------------------------------------------------------------------
      GlastransportEin.bpScheibentrennen          := BasisStationsParameter.bScheibentrennen[cWAND_1];
      GlastransportEin.pAuftrag                   := BasisStationsParameter.pAuftrag[cWAND_1];
      GlastransportEin.bpEintransport             := BasisStationsParameter.bEintransport[cWAND_1] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];
      GlastransportEin.bpEintransportRueckwaertig := BasisStationsParameter.bEintransport[cWAND_1] AND     BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1];

      steplEintransport := STEP_110_E;

//=== EINTRANSPORT ==================================================================================
    STEP_110_E:
      IF ( GlastransportEin.bpDone ) THEN
        GlastransportEin.bpEintransport             := FALSE;
        GlastransportEin.bpEintransportRueckwaertig := FALSE;

        IF ( elAchseEintransport = elAchseAustransport ) THEN
          steplEintransport := STEP_1000_E;
        ELSE
          steplEintransport := STEP_200_E;
        END_IF
      END_IF

//=== EINTRANSPORT ==================================================================================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  UEBERGABE AN DIE AUSTRANSPORT-ACHSE
      //
      //  Hinweis:
      //  - Hubrahmen auf die Austransport-Achse stellen
      // ---------------------------------------------------------------------------------------
      elHubrahmenZielAchse     := elAchseAustransport;
      blHubrahmenPositionieren := TRUE;

      steplEintransport := STEP_210_E;

//=== EINTRANSPORT ==================================================================================
    STEP_210_E:
      IF ( blHubrahmenInPosition ) THEN
        blHubrahmenPositionieren := FALSE;

        steplEintransport := STEP_220_E;
      END_IF

//=== EINTRANSPORT ==================================================================================
    STEP_220_E:
      (* Hinweis:
         - Austransport-Achse uebernimmt die Scheibe und faehrt sie auf den VorStop- Sensor
      *)
      GlastransportAus.pAuftrag       := BasisStationsParameter.pAuftrag[cWAND_1];
      GlastransportAus.bpVortransport := TRUE;

      steplEintransport := STEP_230_E;

//=== EINTRANSPORT ==================================================================================
    STEP_230_E:
      IF ( GlastransportAus.bpDone ) THEN
        GlastransportAus.bpVortransport := FALSE;

        steplEintransport := STEP_1000_E;
      END_IF

//=== EINTRANSPORT ==================================================================================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

//=== EINTRANSPORT ==================================================================================
    STEP_1000_E:
      BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := TRUE;

//=== EINTRANSPORT ==================================================================================
  END_CASE
ELSE

  IF ( steplEintransport > STEP_0_E ) THEN
    BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;

    Glastransport_X.bpEintransport             := FALSE;
    Glastransport_X.bpEintransportRueckwaertig := FALSE;
    Glastransport_X.bpVortransport             := FALSE;
    Glastransport_Y.bpEintransport             := FALSE;
    Glastransport_Y.bpEintransportRueckwaertig := FALSE;
    Glastransport_Y.bpVortransport             := FALSE;
    blHubrahmenPositionieren                   := FALSE;

    steplEintransport := STEP_0_E;
  END_IF

END_IF
END_ACTION