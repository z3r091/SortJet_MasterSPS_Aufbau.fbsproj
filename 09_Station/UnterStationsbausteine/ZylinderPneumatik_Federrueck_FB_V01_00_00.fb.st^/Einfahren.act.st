(* METADATA
{
  "v3Meta": {
    "objectGuid": "a5d1a6be-0096-46b4-84e9-6cc85377480f"
  }
}
*)
ACTION Einfahren
//-------------------------------------------------------------------------------------------------
// EINFAHREN
//-------------------------------------------------------------------------------------------------
IF ( bpStartEinfahren ) THEN
  CASE steplEinfahren OF
    // EINFAHREN =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Bit fuer das Zylinder ausfahren zuruecksetzen
           => Federrueckstell- Ventiel
      *)
      bpDone := FALSE;
      tonlZylinderEingefahren( IN := FALSE );
      tonlBewegungszeitEinfahren( IN := FALSE );
      out_bZylinderAusfahren := FALSE;

      IF ( bpAbfrageEingefahrenVorhanden AND in_bStatusZylinderEingefahren ) THEN
        steplEinfahren := STEP_1000_E;
      ELSE
        epStatusZylinder := eZylinderUndefiniert;
        steplEinfahren   := STEP_10_E;
      END_IF

    // EINFAHREN =====================
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Zylinder eingefahren sind
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bZylinderAusfahren := FALSE;

      tonlZylinderEingefahren( IN := bpAbfrageEingefahrenVorhanden AND NOT in_bStatusZylinderEingefahren,
                               PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      tonlBewegungszeitEinfahren( IN := NOT bpAbfrageEingefahrenVorhanden,
                                  PT := tpBewegungszeit );

      IF (    ( bpAbfrageEingefahrenVorhanden AND in_bStatusZylinderEingefahren )
           OR ( NOT bpAbfrageEingefahrenVorhanden AND tonlBewegungszeitEinfahren.Q ) )
      THEN
        steplEinfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung (nur mit Endlagensensor)
      *)
      IF ( tonlZylinderEingefahren.Q ) THEN
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        steplEinfahren := STEP_900_E;
      END_IF

    // EINFAHREN =====================
    STEP_900_E:
      out_bZylinderAusfahren := FALSE;
      bpFehler := TRUE;

    // EINFAHREN =====================
    STEP_1000_E:
      // Ohne Sensor ist die Stellung zeitlich angenommen, nicht gemessen
      epStatusZylinder := eZylinderEingefahren;
      bpDone := TRUE;

  // EINFAHREN =====================
  END_CASE
ELSE

  IF ( steplEinfahren > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bZylinderAusfahren := FALSE;
    tonlZylinderEingefahren( IN := FALSE );
    tonlBewegungszeitEinfahren( IN := FALSE );
    steplEinfahren := STEP_0_E;
  END_IF

END_IF
END_ACTION