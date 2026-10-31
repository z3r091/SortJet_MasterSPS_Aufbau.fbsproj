(* METADATA
{
  "v3Meta": {
    "objectGuid": "54dd860d-eb3f-452c-95b0-22095a5d1b7e"
  }
}
*)
ACTION Reset
(***************************************************************************************************)
(* RESET *)
(***************************************************************************************************)
IF ( bpReset ) THEN
  CASE steplReset OF
(*RESET ==========================*)
    STEP_0_E:
      bpDone                      := FALSE;
      bprtScheibe                 := FALSE;
      bpStationBelegt             := FALSE;
      bpResetAbgeschlossen        := FALSE;
      bpScheibeFaehrtUeberEinlauf := FALSE;
      bpScheibeFaehrtUeberAuslauf := FALSE;
      bpFreigabeFremdprozess      := FALSE;
      bpOutBereitZumAustransport  := FALSE;
      bpOutBereitZumEintransport  := FALSE;

      Scheibenmessung.bpReset := TRUE;

      tonlMaximaleZeitEinlaufsensorFreiFahren( IN:= FALSE);
      tonlMaximaleZeitAuslaufsensorFreiFahren( IN:= FALSE);

      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;

      // Warten bis beide Antriebe stehen
      IF (    NOT Antrieb.bpAntrieblaeuft
          AND ( NOT Antrieb_Slave.bpAntrieblaeuft OR NOT bpOptionSlaveAntrieb ) )
      THEN
        steplReset := STEP_10_E;
      END_IF

(*RESET ==========================*)
    STEP_10_E:
      Antrieb.wpBetriebsart       := AntriebsBetriebsart_EN.RESET;
      Antrieb_Slave.wpBetriebsart := AntriebsBetriebsart_EN.RESET;

      steplReset := STEP_20_E;

(*RESET ==========================*)
    STEP_20_E:
      IF( Antrieb.bpDone AND ( Antrieb_Slave.bpDone OR NOT bpOptionSlaveAntrieb ) ) THEN
        Antrieb.wpBetriebsart       := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
        steplReset := STEP_1000_E;
      END_IF

      // Fehlerbehandlung
      // - Mindestens ein Antrieb hat seinen Reset nicht abgeschlossen => beide Antriebe abschalten
      IF (    tonlMaxWarteAufResetErfolgreich.Q
          AND NOT ( Antrieb.bpDone AND ( Antrieb_Slave.bpDone OR NOT bpOptionSlaveAntrieb ) ) )
      THEN
        Antrieb.wpBetriebsart       := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        steplReset := STEP_900_E;
      END_IF

(*RESET ==========================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bpFehler := TRUE;

(*RESET ==========================*)
    STEP_1000_E:
      bpDone := TRUE;
      bpResetAbgeschlossen := TRUE;
      bpFehler := FALSE;
      wpFehlerNr := cMELDUNG_NULL;

(*RESET ==========================*)
  END_CASE
ELSE
  IF( steplReset > STEP_0_E )THEN
    bpResetAbgeschlossen := FALSE;
    bpDone := FALSE;

    steplReset := STEP_0_E;

    Antrieb.wpBetriebsart       := KEINE_FUNKTION;
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
  END_IF
END_IF
END_ACTION