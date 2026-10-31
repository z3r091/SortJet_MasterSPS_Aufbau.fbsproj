(* METADATA
{
  "v3Meta": {
    "objectGuid": "ba5e6f36-6aa7-48af-be8b-d0f032f2c3eb"
  }
}
*)
ACTION Reset
(***************************************************************************************************)
(* RESET *)
(***************************************************************************************************)

IF ( bpReset ) THEN
  CASE steplReset OF
(*RESET =====================*)
    STEP_0_E:
      out_bZylinderAusfahren := FALSE;

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
    steplReset := STEP_0_E;
  END_IF
END_IF
END_ACTION