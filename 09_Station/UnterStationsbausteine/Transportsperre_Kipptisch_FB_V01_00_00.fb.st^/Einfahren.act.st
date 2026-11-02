(* METADATA
{
  "v3Meta": {
    "objectGuid": "8f6b1391-f6bd-453b-8149-a922c18cfd4b"
  }
}
*)
ACTION Einfahren
//_________________________________________________________________________
// ************************ Aktion Zylinder -Einfahren ********************
//_________________________________________________________________________
IF (     bpStartEinfahren
     AND NOT tofAusfahren.Q
     AND bpFreigabeEinfahren
     AND bpFreigabe )
THEN
  CASE steplEinfahren OF
    // EINFAHREN =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder einfahren starten (ohne Endlagensensor immer die volle Bewegungszeit abwarten)
      *)
      bpDone := FALSE;
      tonlZylinderEingefahren( IN := FALSE );
      tonlBewegungszeitEinfahren( IN := FALSE );

      IF ( bpAbfrageEingefahrenVorhanden AND in_StatusZylinderEingefahren ) THEN
        steplEinfahren := STEP_1000_E;
      ELSE
        wpStatusZylinder := eZylinderUndefiniert;
        steplEinfahren   := STEP_10_E;
      END_IF

    // EINFAHREN =====================
    STEP_10_E:
      (* Hinweis:
         - Zylinder einfahren, Gegenausgang aus
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_ZylinderEinfahren := TRUE;
      out_ZylinderAusfahren := FALSE;

      tonlZylinderEingefahren( IN := bpAbfrageEingefahrenVorhanden AND NOT in_StatusZylinderEingefahren,
                               PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      tonlBewegungszeitEinfahren( IN := NOT bpAbfrageEingefahrenVorhanden,
                                  PT := tpBewegungszeit );

      IF (    ( bpAbfrageEingefahrenVorhanden AND in_StatusZylinderEingefahren )
           OR ( NOT bpAbfrageEingefahrenVorhanden AND tonlBewegungszeitEinfahren.Q ) )
      THEN
        out_ZylinderEinfahren := FALSE;
        steplEinfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung (nur mit Endlagensensor)
      *)
      IF ( tonlZylinderEingefahren.Q ) THEN
        out_ZylinderEinfahren := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        steplEinfahren := STEP_900_E;
      END_IF

    // EINFAHREN =====================
    STEP_900_E:
      out_ZylinderEinfahren := FALSE;
      bpFehler := TRUE;

    // EINFAHREN =====================
    STEP_1000_E:
      // Ohne Sensor ist die Stellung zeitlich angenommen, nicht gemessen
      wpStatusZylinder := eZylinder1Eingefahren;
      bpDone := TRUE;

  // EINFAHREN =====================
  END_CASE
ELSE

  IF ( steplEinfahren > STEP_0_E ) THEN
    bpDone := FALSE;
    out_ZylinderEinfahren := FALSE;
    tonlZylinderEingefahren( IN := FALSE );
    tonlBewegungszeitEinfahren( IN := FALSE );
    steplEinfahren := STEP_0_E;
  END_IF

END_IF
END_ACTION