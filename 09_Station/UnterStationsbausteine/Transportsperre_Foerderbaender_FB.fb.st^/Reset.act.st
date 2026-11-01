(* METADATA
{
  "v3Meta": {
    "objectGuid": "55f785e3-f679-4c8a-a12d-9284e2890ff0"
  }
}
*)
ACTION Reset
(***************************************************************************************************)
(* Aktion - Reset *)
(***************************************************************************************************)

IF ( bpReset ) THEN
  CASE steplReset OF
    (*RESET =====================*)
    STEP_0_E:
      bpDone := FALSE;

      bpStartHoch := FALSE;
      bpStartRunter := FALSE;

      tonlOben(IN := FALSE);
      tonlUnten(IN := FALSE);

      tofHoch(IN := FALSE);
      tofRunter(IN := FALSE);

      steplReset := STEP_1000_E;

    (*RESET =====================*)
    STEP_1000_E:
      wpFehlerNr := cMELDUNG_NULL;
      bpFehler := FALSE;
      bpDone := TRUE;

  (*RESET =====================*)
  END_CASE
ELSE
  IF ( steplReset > STEP_0_E ) THEN
    bpDone := FALSE;
    tonlUnten( IN := FALSE );
    tonlOben( IN := FALSE );
    steplReset := STEP_0_E;
  END_IF
END_IF
END_ACTION