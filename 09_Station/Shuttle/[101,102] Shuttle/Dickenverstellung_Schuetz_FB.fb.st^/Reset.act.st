(* METADATA
{
  "v3Meta": {
    "objectGuid": "b4bae1af-acf9-4d59-ba1e-b80a5f6a9179"
  }
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION: RESET *)
(***************************************************************************************************)
IF ( bpReset ) THEN
  CASE steplReset OF
(*RESET =====================*)
    STEP_0_E:
      tonlMaximaleWartezeitAufReset( IN := FALSE );

      wpFehlerNr := cMELDUNG_NULL;
      bpFehler   := FALSE;
      out_bVerstellungSchliessen := FALSE;
	  out_bMotorstarterReset := TRUE;
      out_bVerstellungOeffnen := FALSE;
      steplReset := STEP_10_E;

(*RESET =====================*)
    STEP_10_E:
      IF ( in_bMotorstarter_OK AND in_bSicherungMotorOK ) THEN
	    out_bMotorstarterReset := FALSE;
        steplReset := STEP_1000_E;
      ELSE
        wpFehlerNr := cMELDUNG_HUB_SICHERUNG_NICHT_OK;
	    out_bMotorstarterReset := FALSE;
        bpFehler := TRUE;
        steplReset := STEP_900_E;
     END_IF

(*RESET =====================*)
    STEP_900_E:
      bpFehler := TRUE;

(*RESET =====================*)
    STEP_1000_E:
      bpDone := TRUE;

(*RESET =====================*)
  END_CASE
END_IF
IF ( NOT bpReset ) THEN

  IF ( steplReset > STEP_0_E ) THEN
    steplReset := STEP_0_E;
    bpDone := FALSE;
	out_bMotorstarterReset := FALSE;
    tonlMaximaleWartezeitAufReset( IN := FALSE );
  END_IF

END_IF
END_ACTION