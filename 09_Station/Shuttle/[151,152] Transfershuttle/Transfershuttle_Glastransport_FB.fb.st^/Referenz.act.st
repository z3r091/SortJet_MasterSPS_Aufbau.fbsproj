(* METADATA
{
  "v3Meta": {
    "objectGuid": "7e49653b-63c3-4083-8b83-e6614fe8406d"
  }
}
*)
ACTION Referenz
(* @TEXT_IMPLEMENTATION := 'ST' *)
(***************************************************************************************************)
(* S T A R T - Referenzpunktfahrt *)
(***************************************************************************************************)

IF( bpFahreReferenz )THEN
  CASE steplReferenz OF
    (*REFERENZ =============================*)
    STEP_0_E:

      steplReferenz := STEP_10_E;

    (*REFERENZ =============================*)
    STEP_10_E:
      Antrieb.rpZielPosition := 0;

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;
        steplReferenz := STEP_20_E;
      END_IF

    (*REFERENZ ===========================*)
    STEP_20_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung
      *)
      IF ( Antrieb.bpFehler ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_900_E;
      END_IF

    (*REFERENZ =============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bpFehler :=TRUE;

    (*REFERENZ =============================*)
    STEP_1000_E:
      bpDone := TRUE;

  (*REFERENZ =============================*)
  END_CASE

ELSE
  IF( steplReferenz > STEP_0_E )THEN
    bpDone := FALSE;
    steplReferenz := STEP_0_E;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
  END_IF
END_IF
(***************************************************************************************************)
(* E N D E - Referenzpunktfahrt *)
(***************************************************************************************************)
END_ACTION