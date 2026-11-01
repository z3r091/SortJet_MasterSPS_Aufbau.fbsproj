(* METADATA
{
  "v3Meta": {
    "objectGuid": "21924107-5083-4ec1-bb34-cbc38950aee7"
  }
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// Reset
//-------------------------------------------------------------------------------------------------

IF ( bpReset ) THEN
  CASE steplReset OF
    // RESET =====================
    STEP_0_E:
      bpDone := FALSE;
      tonlZylinder1Ausgefahren( IN := FALSE );
      tonlZylinder1Eingefahren( IN := FALSE );
      tonlZylinder2Ausgefahren( IN := FALSE );
      tonlZylinder2Eingefahren( IN := FALSE );
      out_bZylinder1Ausfahren := FALSE;
      out_bZylinder1Einfahren := FALSE;
      out_bZylinder2Ausfahren := FALSE;
      out_bZylinder2Einfahren := FALSE;
      bpStartPneumatik := FALSE;
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
END_ACTION