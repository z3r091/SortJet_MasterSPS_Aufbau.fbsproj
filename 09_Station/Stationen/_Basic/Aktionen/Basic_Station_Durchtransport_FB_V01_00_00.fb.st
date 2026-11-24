(* METADATA
{
	"v3Meta": {
		"objectGuid": "ca80c58d-93c1-43cb-beb6-89c88c6be1a7"
	}
}
*)
FUNCTION_BLOCK Basic_Station_Durchtransport_FB_V01_00_00 EXTENDS Basic_Station_Aktion_FB_V01_00_00
VAR_INPUT

  // Bausteine
  Hub : REFERENCE TO Hub_FB_V01_00_00;

END_VAR
//-------------------------------------------------------------------------------------------------
// DURCHTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bDurchtransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpDurchtransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Hub.bpFehler ) THEN
    Hub.bpStartHubAuf := FALSE;
    Hub.bpStartHubAb  := FALSE;
    BasisStationsParameter.wFehlerNummer := Hub.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // DURCHTRANSPORT =============================
    STEP_0_E:
      bpFehler := FALSE;
      BasisStationsParameter.bDurchtransportAbgeschlossen[wWand] := FALSE;

      steplAktion := STEP_5_E;

    // DURCHTRANSPORT =============================
    STEP_5_E:
      (* Hinweis:
         - Hub auf die Sollposition des Auftrags fahren (nur Oben / Unten, sonst keine Bewegung)
      *)
      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHub ) THEN
        Hub.bpStartHubAuf := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub = eHub_Oben );
        Hub.bpStartHubAb  := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eHub = eHub_Unten );
      END_IF

      steplAktion := STEP_6_E;

    // DURCHTRANSPORT =============================
    STEP_6_E:
      IF ( Hub.bpDone OR NOT ( Hub.bpStartHubAuf OR Hub.bpStartHubAb ) OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHub ) THEN
        Hub.bpStartHubAuf := FALSE;
        Hub.bpStartHubAb  := FALSE;
        steplAktion := STEP_10_E;
      END_IF

    // DURCHTRANSPORT =============================
    STEP_10_E:
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[wWand];
      Glastransport.bpDurchtransport := TRUE;

      steplAktion := STEP_20_E;

    // DURCHTRANSPORT =============================
    STEP_20_E:
      IF ( Glastransport.bpDone )  THEN
        Glastransport.bpDurchtransport := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

    // DURCHTRANSPORT =============================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // DURCHTRANSPORT =============================
    STEP_1000_E:
      BasisStationsParameter.bDurchtransportAbgeschlossen[wWand] := TRUE;

  // DURCHTRANSPORT =============================
  END_CASE
ELSE

  IF (steplAktion > STEP_0_E) THEN
    bpFehler := FALSE;
    BasisStationsParameter.bDurchtransportAbgeschlossen[wWand] := FALSE;
    Glastransport.bpDurchtransport := FALSE;
    Hub.bpStartHubAuf := FALSE;
    Hub.bpStartHubAb  := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK