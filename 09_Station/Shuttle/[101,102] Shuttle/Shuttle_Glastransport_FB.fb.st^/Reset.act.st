(* METADATA
{
  "v3Meta": {
    "objectGuid": "a7336555-14f2-4512-9418-c45e45378466"
  }
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION RESET *)
(***************************************************************************************************)

tonlMaxWarteAufResetErfolgreich(IN:=bpReset,pt:=tgMaxWartezeitReset-t#1s);

IF ( bpReset ) THEN
  CASE steplReset OF
(*RESET ===============================*)
    STEP_0_E:
      bpDone          := FALSE;
      bprtScheibe     := FALSE;
      bpStationBelegt := FALSE;

      bpOutBereitZumAustransport       := FALSE;
      bpOutBereitZumEintransport       := FALSE;
      blStarteSlaveKopplung            := FALSE;
      bpEintransport                   := FALSE;
      bpDurchtransport                 := FALSE;

      bpSlaveAktiv := FALSE;
      blAntriebsKopplungAktiv := false;
      rlGefahreneStreckeEintransport := 0.0;
      Antrieb.wpBetriebsart := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
      Scheibenmessung.bpReset := TRUE;

    IF NOT Antrieb.bpAntrieblaeuft AND NOT Antrieb_Slave.bpAntrieblaeuft THEN
        steplReset := STEP_10_E;
    END_IF

(*RESET ===============================*)
    STEP_10_E:
      Antrieb.wpBetriebsart       := AntriebsBetriebsart_EN.RESET;
      Antrieb_Slave.wpBetriebsart := AntriebsBetriebsart_EN.RESET;

      steplReset := STEP_20_E;

(*RESET ===============================*)
    STEP_20_E:
      IF( Antrieb.bpDone 
          AND ( Antrieb_Slave.bpDone OR NOT bpSlaveAntriebVorhanden ))
      THEN
        Antrieb.wpBetriebsart       := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( ( NOT Antrieb.bpDone
         OR NOT Antrieb_Slave.bpDone )
           AND tonlMaxWarteAufResetErfolgreich.Q ) 
      THEN
        Antrieb.wpBetriebsart       := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        steplReset := STEP_900_E;
      END_IF

(*RESET ===============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bpFehler := TRUE;

(*RESET ===============================*)
    STEP_1000_E:
      bpFehler := FALSE;
      wpFehlerNr := cMELDUNG_NULL;
      bpDone := TRUE;

(*RESET ===============================*)
  END_CASE
ELSE
  IF( steplReset > STEP_0_E )THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart       := KEINE_FUNKTION;
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
    tonlMaxWarteAufResetErfolgreich( IN := FALSE );
    steplReset := STEP_0_E;
  END_IF
END_IF
END_ACTION