(* METADATA
{
	"v3Meta": {
		"objectGuid": "502c0bad-5de8-401d-8f48-55e181efa641"
	}
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// AKTION: RESET
//-------------------------------------------------------------------------------------------------
IF ( bpReset ) THEN
  CASE steplReset OF
    // RESET =====================
    STEP_0_E:
      tonlMaximaleWartezeitAufReset( IN := FALSE );
      tonlReset( IN := FALSE );
      wpFehlerNr := cMELDUNG_NULL;
      bpFehler   := FALSE;

      out_bHubAbSetzen  := FALSE;
      out_bHubAufSetzen := FALSE; 
      out_bReset        := TRUE;

      IF ( NOT in_bMotorstarter_OK ) THEN
        steplReset := STEP_5_E;
      ELSE
        steplReset := STEP_10_E;
      END_IF

    // RESET =====================
    STEP_5_E:
      // Reset- Phoenix Modul
      tonlReset( IN := TRUE , PT :=  T#1500MS );

      IF tonlReset.Q THEN
        out_bReset := FALSE;
        steplReset := STEP_10_E;
      END_IF

    // RESET =====================
    STEP_10_E:
      IF ( in_bLS400V_OK ) THEN
        steplReset := STEP_15_E;
      ELSE
        wpFehlerNr := cMELDUNG_HUB_SICHERUNG_NICHT_OK;
        bpFehler := TRUE;
        steplReset := STEP_900_E;
      END_IF

    // RESET =====================
    STEP_15_E:
      IF ( in_bMotorstarter_OK ) THEN
        steplReset := STEP_20_E;
      ELSE
        wpFehlerNr := cMELDUNG_HUB_MOTORSTARTER_NICHT_OK;
        bpFehler := TRUE;
        steplReset := STEP_900_E;
      END_IF

    // RESET =====================
    STEP_20_E:
      IF ( in_bLSBremse_OK ) THEN
        steplReset := STEP_1000_E;
      ELSE
        wpFehlerNr := cMELDUNG_HUB_BREMSE_NICHT_OK;
        bpFehler := TRUE;
        steplReset := STEP_900_E;
      END_IF

    // RESET =====================
    STEP_900_E:
      out_bReset := FALSE;
      bpFehler   := TRUE;

    // RESET =====================
    STEP_1000_E:
      wpFehlerNr := cMELDUNG_NULL;
      bpFehler   := FALSE;
      bpDone := TRUE;

  // RESET =====================
  END_CASE
  
ELSE

  IF ( steplReset > STEP_0_E ) THEN
    tonlReset( IN := FALSE );
    steplReset := STEP_0_E;
    bpDone     := FALSE;
    out_bReset := FALSE;
    tonlMaximaleWartezeitAufReset( IN := FALSE );
  END_IF

END_IF
END_ACTION