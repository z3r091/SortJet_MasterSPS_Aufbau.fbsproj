(* METADATA
{
  "v3Meta": {
    "objectGuid": "534cd60c-316c-4ae0-b7b4-952c98a27941"
  }
}
*)
ACTION Reset
(***************************************************************************************************)
(* RESET *)
(***************************************************************************************************)
tonlMaxWarteAufResetErfolgreich(IN:=bpReset,pt:=tgMaxWartezeitReset-T#1S);

IF( bpReset )THEN
  CASE steplReset OF
(*RESET ============================*)
    STEP_0_E:
      bpDone := FALSE;
		  Antrieb.wpBetriebsart := KEINE_FUNKTION;

  	   IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
         steplReset := STEP_10_E;
	     END_IF
(*RESET ============================*)
    STEP_10_E:
      (* Hinweis:
         - Betriebsarten zuruecksetzen
      *)
      bpPositionieren       := FALSE;
      bpHandfahrenPlus      := FALSE;
      bpHandfahrenMinus     := FALSE;

      steplReset := STEP_20_E;

(*RESET ============================*)
    STEP_20_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.RESET;

      steplReset := STEP_30_E;

(*RESET ============================*)
    STEP_30_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        tonlMaxWarteAufResetErfolgreich.IN := FALSE;
        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb 
      *)
      IF ( Antrieb.bpFehler
        AND tonlMaxWarteAufResetErfolgreich.Q )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        steplReset := STEP_900_E;
      END_IF

(*RESET ============================*)
    STEP_900_E:
      bpFehler := TRUE;

(*RESET ============================*)
    STEP_1000_E:
      bpFehler := FALSE;
      wpFehlerNr := cMELDUNG_NULL;
      bpDone := TRUE;

(*RESET ============================*)
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