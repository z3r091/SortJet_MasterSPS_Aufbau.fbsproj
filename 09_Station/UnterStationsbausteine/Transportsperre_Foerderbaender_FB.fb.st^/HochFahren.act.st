(* METADATA
{
  "v3Meta": {
    "objectGuid": "9c49712f-5a95-4ffc-acc8-cb6e66235aae"
  }
}
*)
ACTION HochFahren
//_________________________________________________________________________
// ************************ Aktion Zylinder -Hoch ********************
//_________________________________________________________________________
IF (  bpStartHoch
     AND NOT tofRunter.Q
     AND bpFreigabe )
THEN
  CASE steplHoch OF
    // EINFAHREN =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten
      *)
      IF ( NOT in_bOben ) THEN
        tonlOben(IN := FALSE);
        out_bRunter := FALSE;

        steplHoch := STEP_10_E;
      ELSE
        steplHoch := STEP_1000_E;
      END_IF

    // EINFAHREN =====================
    STEP_10_E:
      tonlOben( IN := NOT in_bOben, PT := T#15s );

      IF ( in_bOben ) THEN
        steplHoch := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder
      *)
      IF ( tonlOben.Q ) THEN
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        steplHoch := STEP_900_E;
      END_IF

    // EINFAHREN =====================
    STEP_900_E:
      bpFehler := TRUE;

    // EINFAHREN =====================
    STEP_1000_E:
      bpDone := TRUE;

  // EINFAHREN =====================
  END_CASE
ELSE
  IF (steplHoch > STEP_0_E) THEN
    bpDone := FALSE;
    steplHoch := STEP_0_E;
    tonlOben( IN := FALSE );
    tonlUnten( IN := FALSE );
  END_IF
END_IF
END_ACTION