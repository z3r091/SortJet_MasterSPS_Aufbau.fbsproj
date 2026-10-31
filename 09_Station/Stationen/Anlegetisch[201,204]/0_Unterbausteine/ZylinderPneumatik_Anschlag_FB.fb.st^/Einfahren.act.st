(* METADATA
{
  "v3Meta": {
    "objectGuid": "a40f7916-7143-4dbf-8854-508b14c67fb7"
  }
}
*)
ACTION Einfahren
(***************************************************************************************************)
(* AKTION: EINFAHREN *)
(***************************************************************************************************)
IF ( bpStartEinfahren ) THEN
  CASE steplEinfahren OF
(*EINFAHREN =====================*)
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten 
      *)
      bpDone := FALSE;

      IF ( NOT in_bStatusZylinderEingefahren ) THEN
        tonZylinderEingefahren(IN := FALSE);

        steplEinfahren := STEP_10_E;
      ELSE
        steplEinfahren := STEP_1000_E;
      END_IF

(*EINFAHREN =====================*)
    STEP_10_E:
      (* Hinweis:
         - Zylinder ausgefahren
      *)
      out_bZylinderEinfahren := TRUE;

      IF ( in_bStatusZylinderEingefahren ) THEN
        out_bZylinderEinfahren := FALSE;
        steplEinfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung
      *)
      tonZylinderEingefahren( IN := NOT in_bStatusZylinderEingefahren,
                               PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );

      IF ( tonZylinderEingefahren.Q ) THEN
        out_bZylinderEinfahren := FALSE;
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
    out_bZylinderEinfahren := FALSE;
    steplEinfahren := STEP_0_E;
    tonZylinderEingefahren( IN := FALSE );
  END_IF

END_IF
END_ACTION