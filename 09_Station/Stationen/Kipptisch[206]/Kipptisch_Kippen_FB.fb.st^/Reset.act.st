(* METADATA
{
	"v3Meta": {
		"objectGuid": "b783d9d1-ee7b-427d-9c10-3f56fcd326b8"
	}
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION RESET *)
(***************************************************************************************************)
IF ( bpReset ) THEN

  CASE steplReset OF
(*RESET ===============================*)
    STEP_0_E:
      bpDone := FALSE;
	  
      wpFehlerNr := cMELDUNG_NULL;

      bpStartKippenAuf := FALSE;
      bpStartKippenAb  := FALSE;

      Antrieb.wpBetriebsart:= KEINE_FUNKTION;

	  IF NOT Antrieb.bpAntrieblaeuft THEN
        steplReset := STEP_10_E;
	  END_IF

(*RESET ===============================*)
    STEP_10_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.RESET;

      steplReset := STEP_20_E;

(*RESET ===============================*)
    STEP_20_E:
      IF( Antrieb.bpDone )THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung
         - Antrieb 
      *)
      IF ( NOT Antrieb.bpDone AND tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        steplReset := STEP_900_E;
      END_IF

(*RESET ===============================*)
    STEP_900_E:
      bpFehler := TRUE;

(*RESET ===============================*)
    STEP_1000_E:
      wpFehlerNr := cMELDUNG_NULL;
      bpFehler := FALSE;
      bpDone := TRUE;

(*RESET ===============================*)
  END_CASE

END_IF

IF ( NOT bpReset ) THEN

  IF( steplReset > STEP_0_E )THEN
    bpDone:=FALSE;
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION