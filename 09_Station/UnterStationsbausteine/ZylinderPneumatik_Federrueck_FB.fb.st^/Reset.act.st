(* METADATA
{
  "v3Meta": {
    "objectGuid": "2478e776-b21a-4f75-bdaf-ad9f0ae26858"
  }
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// S T A R T - Reset
//-------------------------------------------------------------------------------------------------

IF ( bpReset ) THEN
  CASE steplReset OF
    // RESET =====================
    STEP_0_E:
      out_bZylinderAusfahren := FALSE;

      steplReset := STEP_1000_E;

    // RESET =====================
    STEP_1000_E:
      wpFehlerNr := cMELDUNG_NULL;
      bpFehler := FALSE;
      bpDone := TRUE;

  // RESET =====================
  END_CASE
ELSE
  IF ( steplReset > STEP_0_E ) THEN
    bpDone := FALSE;
    steplReset := STEP_0_E;
  END_IF
END_IF

//-------------------------------------------------------------------------------------------------
// E N D E - Reset
//-------------------------------------------------------------------------------------------------
END_ACTION