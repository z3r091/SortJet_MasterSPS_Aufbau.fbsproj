(* METADATA
{
  "v3Meta": {
    "objectGuid": "c99410b2-0a53-4552-8591-830adfba857b"
  }
}
*)
ACTION RunterFahren
//_________________________________________________________________________
// ************************ Aktion Zylinder -Runter ********************
//_________________________________________________________________________
IF (     bpStartRunter
     AND NOT tofHoch.Q
     AND bpFreigabe )
THEN
  CASE steplRunter OF
    // RUNTER =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder Runter starten (ohne Endlagensensor immer die volle Bewegungszeit abwarten)
      *)
      bpDone := FALSE;
      tonlUnten( IN := FALSE );
      tonlBewegungszeitRunter( IN := FALSE );

      IF ( bpAbfrageUntenVorhanden AND in_bUnten ) THEN
        out_bRunter := TRUE;
        steplRunter := STEP_1000_E;
      ELSE
        wpStatus    := eTransportsperreUndefiniert;
        steplRunter := STEP_10_E;
      END_IF

    // RUNTER =====================
    STEP_10_E:
      (* Hinweis:
         - Ausgang bleibt gesetzt (Federrueckstell- Ventil)
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bRunter := TRUE;

      tonlUnten( IN := bpAbfrageUntenVorhanden AND NOT in_bUnten,
                 PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      tonlBewegungszeitRunter( IN := NOT bpAbfrageUntenVorhanden,
                               PT := tpBewegungszeit );

      IF (    ( bpAbfrageUntenVorhanden AND in_bUnten )
           OR ( NOT bpAbfrageUntenVorhanden AND tonlBewegungszeitRunter.Q ) )
      THEN
        steplRunter := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung (nur mit Endlagensensor)
      *)
      IF ( tonlUnten.Q ) THEN
        out_bRunter := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
        steplRunter := STEP_900_E;
      END_IF

    // RUNTER =====================
    STEP_900_E:
      out_bRunter := FALSE;
      bpFehler := TRUE;

    // RUNTER =====================
    STEP_1000_E:
      // Ohne Sensor ist die Stellung zeitlich angenommen, nicht gemessen
      wpStatus := eTransportsperreUnten;
      bpDone := TRUE;

  // RUNTER =====================
  END_CASE
ELSE

  // Ausgang bleibt gesetzt (Federrueckstell- Ventil), erst Hoch nimmt ihn zurueck
  IF ( steplRunter > STEP_0_E ) THEN
    bpDone := FALSE;
    tonlUnten( IN := FALSE );
    tonlBewegungszeitRunter( IN := FALSE );
    steplRunter := STEP_0_E;
  END_IF

END_IF
END_ACTION