(* METADATA
{
  "v3Meta": {
    "objectGuid": "a40f7916-7143-4dbf-8854-508b14c67fb7"
  }
}
*)
ACTION Einfahren
//-------------------------------------------------------------------------------------------------
// AKTION: EINFAHREN
//-------------------------------------------------------------------------------------------------
IF ( bpStartEinfahren ) THEN
  CASE steplEinfahren OF
    // EINFAHREN =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder einfahren starten (ohne Endlagensensor immer die volle Bewegungszeit abwarten)
      *)
      bpDone := FALSE;
      tonZylinderEingefahren( IN := FALSE );
      tonlBewegungszeitEinfahren( IN := FALSE );

      IF ( bpAbfrageEingefahrenVorhanden AND in_bStatusZylinderEingefahren ) THEN
        steplEinfahren := STEP_1000_E;
      ELSE
        epStatusZylinder := eZylinderUndefiniert;
        steplEinfahren   := STEP_10_E;
      END_IF

    // EINFAHREN =====================
    STEP_10_E:
      (* Hinweis:
         - Zylinder einfahren, Gegenausgang aus
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bZylinderEinfahren := TRUE;
      out_bZylinderAusfahren := FALSE;

      tonZylinderEingefahren( IN := bpAbfrageEingefahrenVorhanden AND NOT in_bStatusZylinderEingefahren,
                              PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      tonlBewegungszeitEinfahren( IN := NOT bpAbfrageEingefahrenVorhanden,
                                  PT := tpBewegungszeit );

      IF (    ( bpAbfrageEingefahrenVorhanden AND in_bStatusZylinderEingefahren )
           OR ( NOT bpAbfrageEingefahrenVorhanden AND tonlBewegungszeitEinfahren.Q ) )
      THEN
        out_bZylinderEinfahren := FALSE;
        steplEinfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung (nur mit Endlagensensor)
      *)
      IF ( tonZylinderEingefahren.Q ) THEN
        out_bZylinderEinfahren := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        steplEinfahren := STEP_900_E;
      END_IF

    // EINFAHREN =====================
    STEP_900_E:
      out_bZylinderEinfahren := FALSE;
      bpFehler := TRUE;

    // EINFAHREN =====================
    STEP_1000_E:
      // Ohne Sensor ist die Stellung zeitlich angenommen, nicht gemessen
      epStatusZylinder := eZylinderEingefahren;
      bpDone := TRUE;

  END_CASE
ELSE

  IF ( steplEinfahren > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bZylinderEinfahren := FALSE;
    tonZylinderEingefahren( IN := FALSE );
    tonlBewegungszeitEinfahren( IN := FALSE );
    steplEinfahren := STEP_0_E;
  END_IF

END_IF
END_ACTION