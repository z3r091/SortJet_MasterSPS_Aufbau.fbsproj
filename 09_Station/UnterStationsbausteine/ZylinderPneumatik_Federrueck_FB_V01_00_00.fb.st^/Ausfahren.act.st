(* METADATA
{
  "v3Meta": {
    "objectGuid": "34c5ccff-6524-45a4-9d75-d6ac2e47df34"
  }
}
*)
ACTION Ausfahren
//-------------------------------------------------------------------------------------------------
// AUSFAHREN
//-------------------------------------------------------------------------------------------------
IF ( bpStartAusfahren ) THEN
  CASE steplAusfahren OF
    // AUSFAHREN =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten (ohne Endlagensensor immer die volle Bewegungszeit abwarten)
      *)
      bpDone := FALSE;
      tonlZylinderAusgefahren( IN := FALSE );
      tonlBewegungszeitAusfahren( IN := FALSE );

      IF ( bpAbfrageAusgefahrenVorhanden AND in_bStatusZylinderAusgefahren ) THEN
        out_bZylinderAusfahren := TRUE;
        steplAusfahren := STEP_1000_E;
      ELSE
        epStatusZylinder := eZylinderUndefiniert;
        steplAusfahren   := STEP_10_E;
      END_IF

    // AUSFAHREN =====================
    STEP_10_E:
      (* Hinweis:
         - Zylinder ausfahren
           => Da es sich um ein Federrueckstell- Ventiel handelt Ausgang aktiv geschaltet lassen
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bZylinderAusfahren := TRUE;

      tonlZylinderAusgefahren( IN := bpAbfrageAusgefahrenVorhanden AND NOT in_bStatusZylinderAusgefahren,
                               PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      tonlBewegungszeitAusfahren( IN := NOT bpAbfrageAusgefahrenVorhanden,
                                  PT := tpBewegungszeit );

      IF (    ( bpAbfrageAusgefahrenVorhanden AND in_bStatusZylinderAusgefahren )
           OR ( NOT bpAbfrageAusgefahrenVorhanden AND tonlBewegungszeitAusfahren.Q ) )
      THEN
        steplAusfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung (nur mit Endlagensensor)
      *)
      IF ( tonlZylinderAusgefahren.Q ) THEN
        out_bZylinderAusfahren := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
        steplAusfahren := STEP_900_E;
      END_IF

    // AUSFAHREN =====================
    STEP_900_E:
      out_bZylinderAusfahren := FALSE;
      bpFehler := TRUE;

    // AUSFAHREN =====================
    STEP_1000_E:
      // Ohne Sensor ist die Stellung zeitlich angenommen, nicht gemessen
      epStatusZylinder := eZylinderAusgefahren;
      bpDone := TRUE;

  // AUSFAHREN =====================
  END_CASE
ELSE

  // Ausgang bleibt gesetzt (Federrueckstell- Ventiel), erst Einfahren nimmt ihn zurueck
  IF ( steplAusfahren > STEP_0_E ) THEN
    bpDone := FALSE;
    tonlZylinderAusgefahren( IN := FALSE );
    tonlBewegungszeitAusfahren( IN := FALSE );
    steplAusfahren := STEP_0_E;
  END_IF

END_IF
END_ACTION