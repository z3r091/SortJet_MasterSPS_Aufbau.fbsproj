(* METADATA
{
  "v3Meta": {
    "objectGuid": "3b71d128-0dee-4e73-86cf-acf038433a4d"
  }
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// S T A R T - Reset
//-------------------------------------------------------------------------------------------------
IF ( bpReset ) THEN
  CASE steplReset OF
    // RESET ===============================
    STEP_0_E:
      (* Anmerkung:
         - Komponenten zurueck setzen
      *)
      bpDone := FALSE;

      bpAusnahmeSituationSensorBelegt := FALSE;

      bpStarteZentrierungAusfahren   := FALSE;
      bpStarteZentrierungEinfahren   := FALSE;

      Arretierung.bpStartAusfahren   := FALSE;
      Arretierung.bpStartEinfahren   := FALSE;

      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      IF NOT Antrieb.bpAntrieblaeuft THEN
        steplReset := STEP_10_E;
      END_IF

    // RESET ===============================
    STEP_10_E:
      Arretierung.bpReset := TRUE;
      steplReset := STEP_20_E;

    // RESET ===============================
    STEP_20_E:
      (* Hinweis:
         - Arretierung zurueckgesetzt
           => Fehlerbehandlung ist hier unnoetig
      *)
      IF ( NOT Arretierung.bpReset AND NOT Arretierung.bpFehler ) THEN
        steplReset := STEP_30_E;
      END_IF

    // RESET ===============================
    STEP_30_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.RESET;

      steplReset := STEP_40_E;

    // RESET ===============================
    STEP_40_E:
      IF( Antrieb.bpDone )THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF (  NOT Antrieb.bpDone
           AND tonlMaxWarteAufResetErfolgreich.Q )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        steplReset := STEP_900_E;
      END_IF

    // RESET ===============================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpFehler := TRUE;

    // RESET ===============================
    STEP_1000_E:
      bpFehler := FALSE;
      wpFehlerNr := cMELDUNG_NULL;
      bpDone := TRUE;

  // RESET ===============================
  END_CASE
ELSE
  IF( steplReset > STEP_0_E )THEN
    bpDone:=FALSE;
    Arretierung.bpReset := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplReset := STEP_0_E;
  END_IF
END_IF

//-------------------------------------------------------------------------------------------------
// S T A R T - Reset
//-------------------------------------------------------------------------------------------------
END_ACTION