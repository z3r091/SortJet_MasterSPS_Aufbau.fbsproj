(* METADATA
{
  "v3Meta": {
    "objectGuid": "e25eb648-15fd-48bd-a7dd-56d4873c05f6"
  }
}
*)
ACTION Ausfahren
//-------------------------------------------------------------------------------------------------
// AKTION: AUSFAHREN
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
      tonZylinderAusgefahren( IN := FALSE );
      tonlBewegungszeitAusfahren( IN := FALSE );

      IF ( bpAbfrageAusgefahrenVorhanden AND in_bStatusZylinderAusgefahren ) THEN
        steplAusfahren := STEP_1000_E;
      ELSE
        epStatusZylinder := eZylinderUndefiniert;
        steplAusfahren   := STEP_10_E;
      END_IF

    // AUSFAHREN =====================
    STEP_10_E:
      (* Hinweis:
         - Zylinder ausfahren, Gegenausgang aus
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bZylinderAusfahren := TRUE;
      out_bZylinderEinfahren := FALSE;

      tonZylinderAusgefahren( IN := bpAbfrageAusgefahrenVorhanden AND NOT in_bStatusZylinderAusgefahren,
                              PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      tonlBewegungszeitAusfahren( IN := NOT bpAbfrageAusgefahrenVorhanden,
                                  PT := tpBewegungszeit );

      IF (    ( bpAbfrageAusgefahrenVorhanden AND in_bStatusZylinderAusgefahren )
           OR ( NOT bpAbfrageAusgefahrenVorhanden AND tonlBewegungszeitAusfahren.Q ) )
      THEN
        out_bZylinderAusfahren := FALSE;
        steplAusfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung (nur mit Endlagensensor)
      *)
      IF ( tonZylinderAusgefahren.Q ) THEN
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

  END_CASE
ELSE

  IF ( steplAusfahren > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bZylinderAusfahren := FALSE;
    tonZylinderAusgefahren( IN := FALSE );
    tonlBewegungszeitAusfahren( IN := FALSE );
    steplAusfahren := STEP_0_E;
  END_IF

END_IF
END_ACTION