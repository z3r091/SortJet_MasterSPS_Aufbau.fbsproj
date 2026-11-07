(* METADATA
{
	"v3Meta": {
		"objectGuid": "aec4a2b9-e42d-4dc6-88d8-ed1075e37aed"
	}
}
*)
FUNCTION_BLOCK Eckuebergabe_Austransport_FB_V01_00_00 EXTENDS Basic_Station_Austransport_FB_V01_00_00
VAR_IN_OUT

  // Anforderung an den Hubrahmen der Station
  blHubrahmenPositionieren : BOOL;
  elHubrahmenZielAchse     : Achsrichtung_EN;

END_VAR
VAR_INPUT

  // BOOL
  bpHubrahmenInPosition : BOOL; // Hubrahmen steht auf der angeforderten Achse

  // ENUM
  elAchseAustransport : Achsrichtung_EN; // Achse fuer den Austransport (Schnittstellendaten)

  // Bausteine
  Glastransport_X  : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00;
  Glastransport_Y  : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00;
  GlastransportAus : REFERENCE TO Eckuebergabe_Glastransport_FB_V01_00_00; // Austransport-Achse
  Hubrahmen        : REFERENCE TO ZylinderPneumatik_FB_V01_00_00;

END_VAR
//-------------------------------------------------------------------------------------------------
// AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bAustransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport_X.bpFehler ) THEN
    Glastransport_X.bpAustransport             := FALSE;
    Glastransport_X.bpAustransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_X.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Glastransport_Y.bpFehler ) THEN
    Glastransport_Y.bpAustransport             := FALSE;
    Glastransport_Y.bpAustransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_Y.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    blHubrahmenPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // AUSTRANSPORT =====================
    STEP_0_E:
      (* Hinweis:
         - Hubrahmen auf die Austransport-Achse stellen
      *)
      bpFehler := FALSE;

      elHubrahmenZielAchse     := elAchseAustransport;
      blHubrahmenPositionieren := TRUE;

      steplAktion := STEP_10_E;

    // AUSTRANSPORT =====================
    STEP_10_E:
      IF ( bpHubrahmenInPosition ) THEN
        blHubrahmenPositionieren := FALSE;

        steplAktion := STEP_100_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_100_E:
      (* Hinweis:
         - Austransport starten
      *)
      GlastransportAus.pAuftrag                   := BasisStationsParameter.pAuftrag[wWand];
      GlastransportAus.bpAustransport             := BasisStationsParameter.bAustransport[wWand] AND NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      GlastransportAus.bpAustransportRueckwaertig := BasisStationsParameter.bAustransport[wWand] AND     BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      steplAktion := STEP_110_E;

    // AUSTRANSPORT =====================
    STEP_110_E:
      (* Hinweis:
         - Austransport abgeschlossen
      *)
      IF ( GlastransportAus.bpDone ) THEN
        GlastransportAus.bpAustransport             := FALSE;
        GlastransportAus.bpAustransportRueckwaertig := FALSE;

        steplAktion := STEP_1000_E;
      END_IF

    // AUSTRANSPORT =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // AUSTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[wWand] := TRUE;

  // AUSTRANSPORT =====================
  END_CASE
ELSE

  IF ( steplAktion > STEP_0_E ) THEN
    bpFehler := FALSE;
    BasisStationsParameter.bAustransportAbgeschlossen[wWand] := FALSE;

    Glastransport_X.bpAustransport             := FALSE;
    Glastransport_X.bpAustransportRueckwaertig := FALSE;
    Glastransport_Y.bpAustransport             := FALSE;
    Glastransport_Y.bpAustransportRueckwaertig := FALSE;
    blHubrahmenPositionieren                   := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK