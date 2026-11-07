(* METADATA
{
	"v3Meta": {
		"objectGuid": "516e6825-2e78-467d-914f-94fc332667ab"
	}
}
*)
FUNCTION_BLOCK Eckuebergabe_Vortransport_FB_V01_00_00 EXTENDS Basic_Station_Vortransport_FB_V01_00_00
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
// VORTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bVortransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport_X.bpFehler ) THEN
    Glastransport_X.bpVortransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_X.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Glastransport_Y.bpFehler ) THEN
    Glastransport_Y.bpVortransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport_Y.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    blHubrahmenPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // VORTRANSPORT =====================
    STEP_0_E:
      (* Hinweis:
         - Hubrahmen auf die Austransport-Achse stellen
      *)
      bpFehler := FALSE;
      BasisStationsParameter.bVortransportAbgeschlossen[wWand] := FALSE;

      elHubrahmenZielAchse     := elAchseAustransport;
      blHubrahmenPositionieren := TRUE;

      steplAktion := STEP_10_E;

    // VORTRANSPORT =====================
    STEP_10_E:
      IF ( bpHubrahmenInPosition ) THEN
        blHubrahmenPositionieren := FALSE;

        steplAktion := STEP_100_E;
      END_IF

    // VORTRANSPORT =====================
    STEP_100_E:
      (* Hinweis:
         - Starten des Vortransports auf der Austransport-Achse
      *)
      GlastransportAus.bpVortransport := TRUE;

      steplAktion := STEP_110_E;

    // VORTRANSPORT =====================
    STEP_110_E:
      (* Hinweis:
         - Vortransport abgeschlossen
      *)
      IF ( GlastransportAus.bpDone ) THEN
        GlastransportAus.bpVortransport := FALSE;

        steplAktion := STEP_1000_E;
      END_IF

    // VORTRANSPORT =====================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // VORTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bVortransportAbgeschlossen[wWand] := TRUE;

  // VORTRANSPORT =====================
  END_CASE
ELSE

  IF ( steplAktion > STEP_0_E ) THEN
    bpFehler := FALSE;
    BasisStationsParameter.bVortransportAbgeschlossen[wWand] := FALSE;

    Glastransport_X.bpVortransport := FALSE;
    Glastransport_Y.bpVortransport := FALSE;
    blHubrahmenPositionieren       := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK