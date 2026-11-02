(* METADATA
{
  "v3Meta": {
    "objectGuid": "4d1af65a-c513-468b-b1bf-268395fa9efe"
  }
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSGAENGE
//-------------------------------------------------------------------------------------------------

CASE steplReset OF

  // -----------------------------------------------
  STEP_0_E:
    bpStartePositionierung := FALSE;
    bpResourceAktiv        := FALSE;
    bpReferenz             := FALSE;
    bpDone                 := FALSE;
    bpFehler               := FALSE;

    tonlMaxWarteAufResetErfolgreich( IN := FALSE);

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    steplReset := STEP_10_E;

  // -----------------------------------------------
  STEP_10_E:
    Antrieb.wpBetriebsart :=  AntriebsBetriebsart_EN.RESET;

    steplReset := STEP_20_E;

  // -----------------------------------------------
  STEP_20_E:
    IF ( Antrieb.bpDone ) THEN
      Antrieb.wpBetriebsart := KEINE_FUNKTION;
      steplReset := STEP_1000_E;
    END_IF

    (* Fehlerbehandlung:
       - Ueberwachung
    *)
    tonlMaxWarteAufResetErfolgreich( IN := TRUE,
                                     PT := T#15s);

    IF ( NOT Antrieb.bpDone
         AND tonlMaxWarteAufResetErfolgreich.Q )
    THEN
      Antrieb.wpBetriebsart := KEINE_FUNKTION;
      wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
      steplReset := STEP_900_E;
    END_IF

  // -----------------------------------------------
  STEP_900_E:
    bpFehler        := TRUE;
    bpReset         := FALSE;
    steplReset      := STEP_0_E;

  // -----------------------------------------------
  STEP_1000_E:
    bpFehler        := FALSE;
    bpDone          := FALSE;
    bpReset         := FALSE;
    wpFehlerNr      := 0;

    steplReset      := STEP_0_E;

END_CASE
END_ACTION