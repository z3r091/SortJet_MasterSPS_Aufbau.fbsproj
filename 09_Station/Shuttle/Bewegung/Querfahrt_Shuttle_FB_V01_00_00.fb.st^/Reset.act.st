(* METADATA
{
	"v3Meta": {
		"objectGuid": "2e00e0c2-f77f-4454-8393-146db61d87ea"
	}
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// RESET
//-------------------------------------------------------------------------------------------------

IF ( bpReset ) THEN
  CASE schrittlReset OF
    // RESET =======================
    STEP_0_E:
      bpDone := FALSE;
      tonlWarteAufStop(IN := FALSE);
      bpAbbruchPositionierung := FALSE;
      bpAuftragsstatusZuruecksetzen := FALSE;
      bpQuittungAuftragsstatusZurueckgesetzt := FALSE;
      tonlAntriebNichtBetriebsbereit(IN := FALSE);

      Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.wpBetriebsart  := KEINE_FUNKTION;

      schrittlReset := STEP_10_E;

    // RESET =======================
    STEP_10_E: // Shuttle sicher anhalten
      bpVerfahreShuttle:= FALSE;
      STEP_Mov_Shuttle_W := STEP_0_E;

      schrittlReset := STEP_20_E;

    // RESET =======================
    STEP_20_E:
      (* Hinweis:
         - Shuttle sicher anhalten
      *)
      tonlWarteAufStop(IN := NOT Antrieb.bpDone, PT := T#5S);

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        schrittlReset := STEP_30_E;
      END_IF

      (* Fehlerbehandlung:
      *)
      IF ( tonlWarteAufStop.Q ) THEN
        schrittlReset := STEP_900_E;
      END_IF

    // RESET =======================
    STEP_30_E:
      (* Hinweis:
         - Antrieb Fehler zurücksetzen
      *)
      blFreigabeGesetzt := FALSE;
      Antrieb.bpFreigabe := FALSE;

      tonlWarteAufReset(IN := FALSE);
      Antrieb.wpBetriebsart :=  AntriebsBetriebsart_EN.RESET;

      schrittlReset := STEP_40_E;

    // RESET =======================
    STEP_40_E:
      (* Hinweis:
         - Antrieb Fehler zurücksetzen
      *)
      tonlWarteAufReset(IN := NOT Antrieb.bpDone, PT := tgMaxWartezeitReset);

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        schrittlReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( tonlWarteAufReset.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        schrittlReset := STEP_900_E;
      END_IF

    // RESET =======================
    STEP_900_E:
      bpFehler := TRUE;

    // RESET =======================
    STEP_1000_E:
      Antrieb.rpZielPosition := Antrieb.rpIstPosition;
      bpDone := TRUE;
      bpFehler := FALSE;

  // RESET =======================
  END_CASE
END_IF

IF ( NOT bpReset ) THEN

  IF ( schrittlReset > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    schrittlReset := STEP_0_E;
  END_IF

END_IF
END_ACTION