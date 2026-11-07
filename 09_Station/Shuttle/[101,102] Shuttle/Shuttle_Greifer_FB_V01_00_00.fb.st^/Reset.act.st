(* METADATA
{
	"v3Meta": {
		"objectGuid": "bf37c555-6e6b-4cfa-b4f3-6b072fb0e7ef"
	}
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// AKTION: RESET
//-------------------------------------------------------------------------------------------------
IF ( bpReset ) THEN

  CASE steplReset OF
    // RESET ==============================
    STEP_0_E:
      (* Hinweis:
         - Variablen und Anforderungen zuruecksetzen
         - Glasrueckhalter einfahren (Federrueckstellung)
         - Pneumatik zuruecksetzen (setzt sich selbst zurueck)
      *)
      bpDone                        := FALSE;
      bprtScheibe                   := FALSE;
      bpAnforderungSlaveKopplung    := FALSE;
      bpKorrekturfahrtAnfordern     := FALSE;
      bpVorpositioniertEintransport := FALSE;

      ablRueckhalterAusfahren[cZANGE_EINLAUF] := FALSE;
      ablRueckhalterAusfahren[cZANGE_AUSLAUF] := FALSE;

      GreiferHub.bpReset            := TRUE;
      Zange[cZANGE_EINLAUF].bpReset := TRUE;
      Zange[cZANGE_AUSLAUF].bpReset := TRUE;

      steplReset := STEP_10_E;

    // RESET ==============================
    STEP_10_E:
      (* Hinweis:
         - Betriebsarten zuruecksetzen
         - Warten bis die Greiferachse steht
      *)
      bpStarteEintransport                    := FALSE;
      bpStarteAustransport                    := FALSE;
      bpPositionieren                         := FALSE;
      bpStarteVorabPositionierungEintransport := FALSE;
      bpStartGrundstellungsfahrt              := FALSE;
      bpHandfahrenPlus                        := FALSE;
      bpHandfahrenMinus                       := FALSE;
      bpFahreReferenz                         := FALSE;

      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        steplReset := STEP_20_E;
      END_IF

      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
        steplReset := STEP_900_E;
      END_IF

    // RESET ==============================
    STEP_20_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.RESET;
      steplReset := STEP_30_E;

    // RESET ==============================
    STEP_30_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb laesst sich nicht zuruecksetzen (Zeitueberwachung)
      *)
      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
        steplReset := STEP_900_E;
      END_IF

    // RESET ==============================
    STEP_900_E:
      bpFehler := TRUE;

    // RESET ==============================
    STEP_1000_E:
      wpFehlerNr := cMELDUNG_NULL;
      bpFehler   := FALSE;
      bpDone     := TRUE;

  // RESET ==============================
  END_CASE

ELSE

  IF ( steplReset > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION