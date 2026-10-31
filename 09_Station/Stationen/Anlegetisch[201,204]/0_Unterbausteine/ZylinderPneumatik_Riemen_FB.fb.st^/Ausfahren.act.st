(* METADATA
{
  "v3Meta": {
    "objectGuid": "9a9a0ff2-e67c-486a-b996-3b8d0d2318a2"
  }
}
*)
ACTION Ausfahren
(***************************************************************************************************)
(* AUSFAHREN *)
(***************************************************************************************************)
IF (  bpStartAusfahren )
THEN
  CASE steplAusfahren OF
(*AUSFAHREN =====================*)
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten 
      *)
      IF ( NOT in_bStatusZylinderAusgefahren ) THEN
        tonlZylinderAusgefahren(IN := FALSE);
        out_bZylinderAusfahren := TRUE;

        steplAusfahren := STEP_10_E;
      ELSE
        steplAusfahren := STEP_1000_E;
      END_IF

(*AUSFAHREN =====================*)
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Zylinder ausgefahren sind
           => Da es sich um ein Federrueckstell- Ventiel handelt Eingang aktiv geschaltet lassen
      *)
      out_bZylinderAusfahren := TRUE;
      tonlZylinderAusgefahren( IN := ( NOT in_bStatusZylinderAusgefahren ),
                               PT := T#5s );

      IF ( in_bStatusZylinderAusgefahren ) THEN
        steplAusfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder
      *)
      IF ( tonlZylinderAusgefahren.Q ) THEN
        out_bZylinderAusfahren := FALSE;
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
  IF (steplAusfahren > STEP_0_E) THEN
    bpDone := FALSE;
    tonlZylinderAusgefahren( IN := FALSE );
    steplAusfahren := STEP_0_E;
  END_IF
END_IF
END_ACTION