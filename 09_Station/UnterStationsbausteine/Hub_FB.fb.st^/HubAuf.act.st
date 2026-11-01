(* METADATA
{
  "v3Meta": {
    "objectGuid": "0c09ef4a-71a0-40c3-8886-2258d3dfd692"
  }
}
*)
ACTION HubAuf
(******************************************************************************)
(* AKTION: HEBEN [ HUB AUF] *)
(******************************************************************************)
IF ( bpStartHubAuf AND NOT bpStartHubAb ) THEN
  CASE steplHubAuf OF
    (*AUFHub =================================*)
    STEP_0_E:
      IF ( in_bSensorNichtOben ) THEN
        out_bHubAufSetzen := TRUE;
        steplHubAuf := STEP_10_E;
      ELSE
        out_bHubAufSetzen := FALSE;
        steplHubAuf := STEP_1000_E;
      END_IF

    (*AUFHub =================================*)
    STEP_10_E:
      IF ( NOT in_bSensorNichtOben ) THEN
        out_bHubAufSetzen := FALSE;
        steplHubAuf := STEP_1000_E;
      END_IF

      (* Ausnahmefehler
      *)
      IF ( tonlMaxWarteZeit.Q ) THEN
        wpFehlerNr := cMELDUNG_HUB_NICHT_GEHOBEN;
        out_bHubAufSetzen := FALSE;
        bpDone := FALSE;
        steplHubAuf := STEP_900_E;
      END_IF

    (*AUFHub =================================*)
    STEP_900_E:
      bpFehler := TRUE;

    (*AUFHub =================================*)
    STEP_1000_E:
      bpDone := TRUE;

  (*AUFHub =================================*)
  END_CASE
END_IF

IF ( NOT bpStartHubAuf ) THEN

  IF (steplHubAuf > STEP_0_E) THEN
    bpDone := FALSE;
    steplHubAuf := STEP_0_E;
    out_bHubAufSetzen := FALSE;
  END_IF

END_IF
END_ACTION