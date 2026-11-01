(* METADATA
{
  "v3Meta": {
    "objectGuid": "c99410b2-0a53-4552-8591-830adfba857b"
  }
}
*)
ACTION RunterFahren
//_________________________________________________________________________
// ************************ Aktion Zylinder -Runter ********************
//_________________________________________________________________________
IF (  bpStartRunter
     AND NOT tofHoch.Q
     AND bpFreigabe )
THEN
  CASE steplRunter OF
    // RUNTER =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder Runter starten
      *)
      IF ( NOT in_bUnten ) THEN
        tonlUnten(IN := FALSE);
        out_bRunter := TRUE;

        steplRunter := STEP_10_E;
      ELSE
        steplRunter := STEP_1000_E;
      END_IF

    // RUNTER =====================
    STEP_10_E:
      tonlUnten( IN := NOT in_bUnten, PT:= T#15s );

      IF ( in_bUnten ) THEN
        steplRunter := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder
      *)
      IF ( tonlUnten.Q ) THEN
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
        steplRunter := STEP_900_E;
      END_IF

    // RUNTER =====================
    STEP_900_E:
      bpFehler := TRUE;

    // RUNTER =====================
    STEP_1000_E:
      bpDone := TRUE;

  // RUNTER =====================
  END_CASE
ELSE
  IF ( steplRunter > STEP_0_E ) THEN
    bpDone := FALSE;
    tonlUnten( IN := FALSE );
    tonlOben( IN := FALSE );
    steplRunter := STEP_0_E;
  END_IF
END_IF
END_ACTION