(* METADATA
{
	"v3Meta": {
		"objectGuid": "8f6b1391-f6bd-453b-8149-a922c18cfd4b"
	}
}
*)
ACTION Einfahren
(*
_________________________________________________________________________
 ************************ Aktion Zylinder -Einfahren ********************
_________________________________________________________________________
*)
IF (  bpStartEinfahren
  AND NOT tofAusfahren.Q
  AND bpFreigabeEinfahren
  AND bpFreigabe )
THEN
  CASE steplEinfahren OF
(*EINFAHREN =====================*)
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten 
      *)
      IF ( NOT in_StatusZylinderEingefahren ) THEN
        tonlZylinderEingefahren(IN := FALSE);
        out_ZylinderEinfahren := TRUE;

        steplEinfahren := STEP_10_E;
      ELSE
        steplEinfahren := STEP_1000_E;
      END_IF

(*EINFAHREN =====================*)
    STEP_10_E:
      tonlZylinderEingefahren( IN := NOT in_StatusZylinderEingefahren, PT := T#15s );

      IF ( in_StatusZylinderEingefahren ) THEN
        out_ZylinderEinfahren := FALSE;
        steplEinfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder
      *)
      IF ( tonlZylinderEingefahren.Q ) THEN
        out_ZylinderEinfahren := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        steplEinfahren := STEP_900_E;
      END_IF

(*EINFAHREN =====================*)
    STEP_900_E:
      bpFehler := TRUE;

(*EINFAHREN =====================*)
    STEP_1000_E:
      bpDone := TRUE;

(*EINFAHREN =====================*)
  END_CASE
ELSE
  IF (steplEinfahren > STEP_0_E) THEN
    bpDone := FALSE;
    out_ZylinderAusfahren := FALSE;
    out_ZylinderEinfahren := FALSE;
    steplEinfahren := STEP_0_E;
    tonlZylinderAusgefahren( IN := FALSE );
    tonlZylinderEingefahren( IN := FALSE );
  END_IF
END_IF
END_ACTION