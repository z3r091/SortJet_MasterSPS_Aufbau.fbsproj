(* METADATA
{
	"v3Meta": {
		"objectGuid": "c237ba56-aae1-4d5f-8eba-bc80fe7ef0c8"
	}
}
*)
ACTION VerstellungSchliessen
//-------------------------------------------------------------------------------------------------
// AKTION: HEBEN [ HUB AUF]
//-------------------------------------------------------------------------------------------------
IF ( bpVerstellungSchliessen AND NOT bpVerstellungOeffnen ) THEN
  CASE steplVerstellungSchliessen OF
    // AUFHub =================================
    STEP_0_E:
      IF ( in_bVerstellungGeschlossen ) THEN
        out_bVerstellungSchliessen := TRUE;
        steplVerstellungSchliessen := STEP_10_E;
      ELSE
        out_bVerstellungSchliessen := FALSE;
        steplVerstellungSchliessen := STEP_1000_E;
      END_IF

    // AUFHub =================================
    STEP_10_E:
      IF ( NOT in_bVerstellungGeschlossen ) THEN
        out_bVerstellungSchliessen := FALSE;
        steplVerstellungSchliessen := STEP_1000_E;
      END_IF

      (* Ausnahmefehler:
      *)
      IF ( tonlMaxWarteZeit.Q ) THEN
        wpFehlerNr := cMELDUNG_HUB_NICHT_GEHOBEN;
        out_bVerstellungSchliessen := FALSE;
        bpDone := FALSE;
        steplVerstellungSchliessen := STEP_900_E;
      END_IF

    // AUFHub =================================
    STEP_900_E:
      bpFehler := TRUE;

    // AUFHub =================================
    STEP_1000_E:
      bpDone := TRUE;

  // AUFHub =================================
  END_CASE
END_IF

IF ( NOT bpVerstellungSchliessen ) THEN

  IF (steplVerstellungSchliessen > STEP_0_E) THEN
    bpDone := FALSE;
    steplVerstellungSchliessen := STEP_0_E;
    out_bVerstellungSchliessen := FALSE;
  END_IF

END_IF
END_ACTION