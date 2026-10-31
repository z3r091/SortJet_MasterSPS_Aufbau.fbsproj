(* METADATA
{
	"v3Meta": {
		"objectGuid": "5d18f8be-22c6-4aa4-9a8f-54afb500c109"
	}
}
*)
ACTION Referenz
(***************************************************************************************************)
(* AKTION REFERENZ *)
(***************************************************************************************************)
IF( bpFahreReferenz )THEN
	
  // Fehlerbehandlung
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplReferenz := STEP_900_E;
  END_IF
  
  IF ( Antrieb_Slave.bpFehler ) THEN
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplReferenz := STEP_900_E;
  END_IF
	  
  CASE steplReferenz OF
(*REFERENZ =============================*)
    STEP_0_E:
      bpDone := FALSE;
      tonlSlaveKopplungDeaktiviert( IN := FALSE );
	  
      steplReferenz := STEP_10_E;
	
(*REFERENZ =============================*)
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob der Regler bereit meldet
      *)
      IF (  Antrieb.bpReglerBereit
        AND ( Antrieb_Slave.bpReglerBereit OR NOT bpSlaveAntriebVorhanden ) )
      THEN
        Antrieb.wpBetriebsart        := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart  := KEINE_FUNKTION;

        steplReferenz := STEP_20_E;
      END_IF
	
(*REFERENZ =============================*)
    STEP_20_E:
      (* Hinweis:
         - Starten der Referenzierung
         WICHTIG
         - Zeitliche Verzoegerung damit der Slave komplett abgekoppelt ist und nicht in 
           einen Schleppfehler kommt.
      *)
      tonlSlaveKopplungDeaktiviert( IN := ( NOT blAntriebsKopplungAktiv OR NOT bpSlaveAntriebVorhanden ),
                                    PT := T#250ms );

      IF (  NOT Antrieb.bpAntrieblaeuft
        AND NOT Antrieb_Slave.bpAntrieblaeuft
        AND tonlSlaveKopplungDeaktiviert.Q )
      THEN
        Antrieb.rpZielposition    := 0;
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;
	    
		IF bpSlaveAntriebVorhanden THEN
          Antrieb_Slave.rpZielposition    := 0;
          Antrieb_Slave.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
          Antrieb_Slave.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb_Slave.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
          Antrieb_Slave.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;
		END_IF
		
        steplReferenz := STEP_30_E;
		
      END_IF

(*REFERENZ =============================*)
    STEP_30_E:
      (* Hinweis:
         - Antrieb wurde referenziert
      *)
      IF( Antrieb.bpDone 
          AND (Antrieb_Slave.bpDone OR NOT bpSlaveAntriebVorhanden ) )
      THEN
        Antrieb.wpBetriebsart       := KEINE_FUNKTION;
        Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_1000_E;
      END_IF


(*REFERENZ =============================*)
    STEP_900_E:
      // Fehlerbehandlung
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
      bpFehler := TRUE;

(*REFERENZ =============================*)
    STEP_1000_E:
      bpDone := TRUE;

(*REFERENZ =============================*)
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