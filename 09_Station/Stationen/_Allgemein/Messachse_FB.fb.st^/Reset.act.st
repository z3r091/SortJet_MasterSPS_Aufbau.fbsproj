(* METADATA
{
  "v3Meta": {
    "objectGuid": "a1da0c06-fed4-44a2-9e20-3976f9e28ecf"
  }
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// AKTION: RESET
//-------------------------------------------------------------------------------------------------
tonlMaxWarteAufResetErfolgreich(IN:=bpReset,pt:=tgMaxWartezeitReset-t#1s);

IF( bpReset )THEN
  CASE steplReset OF
    // RESET ===========================
    STEP_0_E:
      bprtScheibe := FALSE;
      bpDone := FALSE;
      bpVermessenAbgeschlossen := FALSE;
      Antrieb.wpBetriebsart :=  KEINE_FUNKTION;

      IF NOT Antrieb.bpAntrieblaeuft THEN
        steplReset := STEP_10_E;
      END_IF

    // RESET ===========================
    STEP_10_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.RESET;

      steplReset := STEP_20_E;

    // RESET ===========================
    STEP_20_E:
      (* Hinweis:
         - Antrieb wurde zurueckgesetzt
      *)
      IF (Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplReset := STEP_1000_E;
        tonlMaxWarteAufResetErfolgreich.IN :=FALSE;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb / Timer
      *)
      IF ( Antrieb.bpFehler AND tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        steplReset := STEP_900_E;
      END_IF

    // RESET ===========================
    STEP_900_E:
      bpFehler := TRUE;

    // RESET ===========================
    STEP_1000_E:
      wpFehlerNr := cMELDUNG_NULL;
      bpFehler := FALSE;
      bpDone := TRUE;

  // RESET ===========================
  END_CASE
END_IF

IF ( NOT bpReset )THEN

  IF (steplReset > STEP_0_E) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION