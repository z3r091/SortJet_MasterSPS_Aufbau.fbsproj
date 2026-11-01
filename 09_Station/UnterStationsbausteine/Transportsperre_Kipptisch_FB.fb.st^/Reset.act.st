(* METADATA
{
  "v3Meta": {
    "objectGuid": "d97ed245-e1b2-4097-96fe-cae5bbd262f9"
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

      out_ZylinderAusfahren := FALSE;
      out_ZylinderEinfahren := FALSE;
      tonlZylinderEingefahren(IN := FALSE);
      tonlZylinderAusgefahren(IN := FALSE);
      tofEinfahren(IN := FALSE);
      tofAusfahren(IN := FALSE);

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
    tonlZylinderAusgefahren( IN := FALSE );
    tonlZylinderEingefahren( IN := FALSE );
    steplReset := STEP_0_E;
  END_IF
END_IF
END_ACTION