(* METADATA
{
  "v3Meta": {
    "objectGuid": "d76b4e7c-09a5-4c4a-bd14-4ca4deaa304a"
  }
}
*)
ACTION HubAb
(******************************************************************************)
(* AKTION: SENKEN [HUB AB] *)
(******************************************************************************)
IF ( bpStartHubAb AND NOT bpStartHubAuf ) THEN
  CASE steplHubAb OF
(*ABHub ==========================*)
    STEP_0_E:
      IF ( in_bSensorNichtUnten ) THEN
        out_bHubAbSetzen := TRUE;
        steplHubAb := STEP_10_E;
      ELSE
        out_bHubAbSetzen := FALSE;
        steplHubAb := STEP_1000_E;
      END_IF

(*ABHub ==========================*)
    STEP_10_E:
      IF ( NOT in_bSensorNichtUnten ) THEN
        out_bHubAbSetzen := FALSE;
        steplHubAb := STEP_1000_E;
      END_IF

      (* Ausnahmefehler:
         - Sensoren
      *)
      IF ( tonlMaxWarteZeit.Q )THEN
        wpFehlerNr := cMELDUNG_HUB_NICHT_GESENKT;
        out_bHubAbSetzen := FALSE;
        steplHubAb := STEP_900_E;
      END_IF

(*ABHub ==========================*)
    STEP_900_E:
      bpFehler := TRUE;

(*ABHub ==========================*)
    STEP_1000_E:
      bpDone := TRUE;

(*ABHub ==========================*)
  END_CASE
else
  IF (steplHubAb > STEP_0_E) THEN
    steplHubAb := STEP_0_E;
    out_bHubAbSetzen := FALSE;
    bpDone:=FALSE;
  END_IF
END_IF
END_ACTION