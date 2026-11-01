(* METADATA
{
  "v3Meta": {
    "objectGuid": "982aba90-0acc-40e8-a264-02942c4eba65"
  }
}
*)
ACTION VerstellungOeffnen
(******************************************************************************)
(* AKTION: SENKEN [HUB AB] *)
(******************************************************************************)
IF (  bpVerstellungOeffnen
     AND NOT bpVerstellungSchliessen )
THEN
  CASE steplVerstellungOeffnen OF
    (*ABHub ==========================*)
    STEP_0_E:
      IF ( in_bVerstellungGeoeffnet ) THEN
        out_bVerstellungOeffnen := TRUE;
        steplVerstellungOeffnen := STEP_10_E;
      ELSE
        out_bVerstellungOeffnen := FALSE;
        steplVerstellungOeffnen := STEP_1000_E;
      END_IF

    (*ABHub ==========================*)
    STEP_10_E:
      IF ( NOT in_bVerstellungGeoeffnet ) THEN
        out_bVerstellungOeffnen := FALSE;
        steplVerstellungOeffnen := STEP_1000_E;
      END_IF

      (* Ausnahmefehler:
         - Sensoren
      *)
      IF ( tonlMaxWarteZeit.Q )THEN
        wpFehlerNr := cMELDUNG_HUB_NICHT_GESENKT;
        out_bVerstellungOeffnen := FALSE;
        steplVerstellungOeffnen := STEP_900_E;
      END_IF

    (*ABHub ==========================*)
    STEP_900_E:
      bpFehler := TRUE;

    (*ABHub ==========================*)
    STEP_1000_E:
      bpDone := TRUE;

  (*ABHub ==========================*)
  END_CASE
END_IF
IF ( NOT bpVerstellungOeffnen ) THEN
  IF (steplVerstellungOeffnen > STEP_0_E) THEN
    steplVerstellungOeffnen := STEP_0_E;
    out_bVerstellungOeffnen := FALSE;
    bpDone:=FALSE;
  END_IF
END_IF
END_ACTION