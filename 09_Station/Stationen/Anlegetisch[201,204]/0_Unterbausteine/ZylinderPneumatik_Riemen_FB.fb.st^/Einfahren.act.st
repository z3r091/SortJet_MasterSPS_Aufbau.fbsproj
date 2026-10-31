(* METADATA
{
	"v3Meta": {
		"objectGuid": "95c58bf0-6461-4d2f-9722-81bfd485b977"
	}
}
*)
ACTION Einfahren
(***************************************************************************************************)
(* EINFAHREN *)
(***************************************************************************************************)
IF (  bpStartEinfahren )
THEN
  CASE steplEinfahren OF
(*EINFAHREN =====================*)
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Bit fuer das Zylinder ausfahren zuruecksetzen 
           => Federrueckstell- Ventiel
      *)
      IF (  NOT in_bStatusZylinderEingefahren ) THEN
        tonlZylinderEingefahren(IN := FALSE);
        out_bZylinderAusfahren := FALSE;

        steplEinfahren := STEP_10_E;
      ELSE
        steplEinfahren := STEP_1000_E;

      END_IF

(*EINFAHREN =====================*)
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Zylinder eingefahren sind
      *)
      tonlZylinderEingefahren( IN := ( NOT in_bStatusZylinderEingefahren  ),
                               PT := T#5s );

      IF (  in_bStatusZylinderEingefahren ) THEN
        out_bZylinderAusfahren := FALSE;
        steplEinfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder
      *)
      IF ( tonlZylinderAusgefahren.Q ) THEN
        out_bZylinderAusfahren := FALSE;
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
    out_bZylinderAusfahren := FALSE;
    tonlZylinderEingefahren( IN := FALSE );
    steplEinfahren := STEP_0_E;
  END_IF
END_IF
END_ACTION