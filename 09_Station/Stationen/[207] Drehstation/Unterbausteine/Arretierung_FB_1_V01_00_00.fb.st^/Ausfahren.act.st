(* METADATA
{
  "v3Meta": {
    "objectGuid": "88f3d7e9-6c5b-4212-bd0b-08cd740371c8"
  }
}
*)
ACTION Ausfahren
//-------------------------------------------------------------------------------------------------
// AKTION: AUSFAHREN
//-------------------------------------------------------------------------------------------------
IF (  bpStartAusfahren ) THEN
  CASE steplAusfahren OF
    // AUSFAHREN =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten
      *)
      bpDone := FALSE;

      IF ( NOT in_bStatusZylinderAusgefahren ) THEN
        tonZylinderAusgefahren(IN := FALSE);

        steplAusfahren := STEP_10_E;
      ELSE
        steplAusfahren := STEP_1000_E;
      END_IF

    // AUSFAHREN =====================
    STEP_10_E:
      (* Hinweis:
         - Zylinder ausfahren
      *)
      out_bZylinderAusfahren := TRUE;

      IF ( in_bStatusZylinderAusgefahren ) THEN
        out_bZylinderAusfahren := FALSE;
        steplAusfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung
      *)
      tonZylinderAusgefahren( IN := NOT in_bStatusZylinderAusgefahren,
                              PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );

      IF ( tonZylinderAusgefahren.Q ) THEN
        out_bZylinderAusfahren := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
        steplAusfahren := STEP_900_E;
      END_IF

    // AUSFAHREN =====================
    STEP_900_E:
      bpFehler := TRUE;

    // AUSFAHREN =====================
    STEP_1000_E:
      bpDone := TRUE;

  // AUSFAHREN =====================
  END_CASE
END_IF

IF ( NOT bpStartAusfahren ) THEN

  IF ( steplAusfahren > STEP_0_E) THEN
    bpDone := FALSE;
    out_bZylinderAusfahren := FALSE;
    tonZylinderAusgefahren( IN := FALSE );

    steplAusfahren := STEP_0_E;
  END_IF

END_IF
END_ACTION