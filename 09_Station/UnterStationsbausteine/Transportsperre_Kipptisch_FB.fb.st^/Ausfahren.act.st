(* METADATA
{
  "v3Meta": {
    "objectGuid": "06029a88-39ad-4ab5-99dd-8f7b148e55a4"
  }
}
*)
ACTION Ausfahren
(*
_________________________________________________________________________
 ************************ Aktion Zylinder -Ausfahren ********************
_________________________________________________________________________
*)
IF (  bpStartAusfahren
     AND NOT tofEinfahren.Q
     AND bpFreigabe )
THEN
  CASE steplAusfahren OF
    (*AUSFAHREN =====================*)
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten 
      *)
      IF ( NOT in_StatusZylinderAusgefahren ) THEN
        tonlZylinderAusgefahren(IN := FALSE);
        out_ZylinderAusfahren := TRUE;

        steplAusfahren := STEP_10_E;
      ELSE
        steplAusfahren := STEP_1000_E;
      END_IF

    (*AUSFAHREN =====================*)
    STEP_10_E:
      tonlZylinderAusgefahren( IN := NOT in_StatusZylinderAusgefahren, PT:= T#15s );

      IF ( in_StatusZylinderAusgefahren ) THEN
        out_ZylinderAusfahren := FALSE;
        steplAusfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder
      *)
      IF ( tonlZylinderAusgefahren.Q ) THEN
        out_ZylinderAusfahren := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
        steplAusfahren := STEP_900_E;
      END_IF

    (*AUSFAHREN =====================*)
    STEP_900_E:
      bpFehler := TRUE;

    (*AUSFAHREN =====================*)
    STEP_1000_E:
      bpDone := TRUE;

  (*AUSFAHREN =====================*)
  END_CASE
ELSE
  IF ( steplAusfahren > STEP_0_E ) THEN
    bpDone := FALSE;
    tonlZylinderAusgefahren( IN := FALSE );
    tonlZylinderEingefahren( IN := FALSE );
    out_ZylinderAusfahren := FALSE;
    out_ZylinderEinfahren := FALSE;
    steplAusfahren := STEP_0_E;
  END_IF
END_IF
END_ACTION