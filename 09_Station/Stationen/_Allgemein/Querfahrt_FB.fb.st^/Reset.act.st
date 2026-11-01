(* METADATA
{
  "v3Meta": {
    "objectGuid": "4cdd0aad-a649-46cb-b5f0-eab0fc7f7be0"
  }
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// RESET
//-------------------------------------------------------------------------------------------------
tonlMaxWarteAufResetErfolgreich(IN:= bpReset,PT :=T#10S);

IF( bpReset )THEN
  CASE steplReset OF
    // RESET ============================
    STEP_0_E:
      bpDone := FALSE;
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      blAbbruchPositionierung                := FALSE;
      bpAuftragsstatusZuruecksetzen          := FALSE;
      bpQuittungAuftragsstatusZurueckgesetzt := FALSE;

      steplReset := STEP_10_E;

    // RESET ============================
    STEP_10_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.RESET;

      steplReset := STEP_20_E;

    // RESET ============================
    STEP_20_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        tonlMaxWarteAufResetErfolgreich.IN := FALSE;
        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Querfahrt
      *)
      IF ( Antrieb.bpFehler
           AND tonlMaxWarteAufResetErfolgreich.Q )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        steplReset := STEP_900_E;
      END_IF

    // RESET ============================
    STEP_900_E:
      bpFehler := TRUE;

    // RESET ============================
    STEP_1000_E:
      wpFehlerNr := cMELDUNG_NULL;
      bpFehler := FALSE;
      bpDone := TRUE;

  // RESET ============================
  END_CASE
ELSE
  IF (steplReset > STEP_0_E) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    tonlMaxWarteAufResetErfolgreich( IN := FALSE );
    steplReset := STEP_0_E;
  END_IF
END_IF
END_ACTION