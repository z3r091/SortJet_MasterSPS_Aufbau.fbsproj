(* METADATA
{
	"v3Meta": {
		"objectGuid": "e42b2542-194f-4c2f-b5a2-92a7178ec258"
	}
}
*)
ACTION Referenz
//-------------------------------------------------------------------------------------------------
// REFERENZ
//-------------------------------------------------------------------------------------------------
IF ( bpReferenz )THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplReferenz := STEP_900_E;
  END_IF

  IF ( Antrieb_Slave.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplReferenz := STEP_900_E;
  END_IF


  CASE steplReferenz OF
    // REFERENZ =========================
    STEP_0_E:

      bpDone := FALSE;

      tonlSlaveKopplungDeaktiviert( IN := FALSE );

      IF (  Antrieb.bpReglerBereit
           AND ( Antrieb_Slave.bpReglerBereit OR NOT bpOptionSlaveAntrieb ) )
      THEN
        Antrieb.wpBetriebsart       := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;

        steplReferenz := STEP_10_E;
      END_IF

    // REFERENZ =========================
    STEP_10_E:
      (* Hinweis:
         - Starten der Referenzierung
           WICHTIG
         - Zeitliche Verzoegerung damit der Slave komplett abgekoppelt ist und nicht in
           einen Schleppfehler kommt.
      *)
      // Direkt auf den Slave schauen: blAntriebsKopplungAktiv ist beim Referenzieren immer FALSE (Slave-Kette nicht aktiv)
      tonlSlaveKopplungDeaktiviert( IN := NOT Antrieb_Slave.bpAchseSychron,
                                    PT := T#150MS );

      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT Antrieb_Slave.bpAntrieblaeuft
           AND ( tonlSlaveKopplungDeaktiviert.Q OR NOT bpOptionSlaveAntrieb ) )
      THEN

        Antrieb.rpZielPosition    := 0;
        Antrieb.rpGeschwindigkeit := 0;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;

        IF bpOptionSlaveAntrieb THEN
          Antrieb_Slave.rpZielPosition    := 0;
          Antrieb_Slave.rpGeschwindigkeit := 0;
          Antrieb_Slave.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb_Slave.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
          Antrieb_Slave.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;
        END_IF

        steplReferenz := STEP_20_E;

      END_IF

    // REFERENZ =========================
    STEP_20_E:
      (* Hinweis:
         - Referenzierung abgeschlossen
      *)
      IF ( Antrieb.bpDone
           AND ( Antrieb_Slave.bpDone OR NOT bpOptionSlaveAntrieb ) )
      THEN
        Antrieb.wpBetriebsart       := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_1000_E;
      END_IF

    // REFERENZ =========================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
      bpFehler :=TRUE;

    // REFERENZ =========================
    STEP_1000_E:
      bpDone := TRUE;

  // REFERENZ =========================
  END_CASE

ELSE

  IF( steplReferenz > STEP_0_E )THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart       := KEINE_FUNKTION;
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;

    tonlSlaveKopplungDeaktiviert( IN := FALSE );
    steplReferenz := STEP_0_E;
  END_IF

END_IF
END_ACTION