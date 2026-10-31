(* METADATA
{
  "v3Meta": {
    "objectGuid": "2705adee-87c7-49e7-9fc6-baba39eb4987"
  }
}
*)
ACTION Durchtransport
(***************************************************************************************************)
(* DURCHTRANSPORT *)
(***************************************************************************************************)
IF (  bpDurchtransport ) THEN

  (* Ausnahmesituation:
     - ANTRIEB
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplDurchtransport := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplDurchtransport := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplDurchtransport := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplDurchtransport OF
(* DURCHTRANSPORT ========================================*)
    STEP_0_E:
      (* Hinweis:
         - Pruefen ob der Antrieb bereit zum verfahren ist
      *)
      bprtScheibe := FALSE;
      bpSlaveAktiv := FALSE;
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;

      steplDurchtransport := STEP_10_E;

(* DURCHTRANSPORT ========================================*)
    STEP_10_E:
      (* Hinweis:
         - Antriebueberpruefen ob bereit zum verfahren. 
      *)
      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplDurchtransport := STEP_15_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_15_E:
      (* Hinweis:
         - Sicherstellen das die Slavekopplung aktiv ist
      *)
      IF ( blAntriebsKopplungAktiv ) THEN
        steplDurchtransport := STEP_20_E;
      END_IF
	  
(* DURCHTRANSPORT ========================================*)
    STEP_20_E:
      (* Anmerkung:
         - Warten bis die Nachfolgestation bereit ist zum Eintransport
      *)
      bpOutBereitZumAustransport := TRUE;
	  
      IF (  InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_30_E;
      END_IF

(* DURCHTRANSPORT ========================================*)
    STEP_30_E:
      (* Anmerkung:
         - Warten bis die Nachfolgestation bereit ist zum Eintransport
      *)
      bpOutBereitZumEintransport := TRUE;
	  
      IF (  InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
        steplDurchtransport := STEP_100_E;
      END_IF

(* DURCHTRANSPORT ========================================*)
    STEP_100_E:
      (* Hinweis:
        - Antrieb in den Master- Slave- Modus setzen
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart := HANDPLUS;

      steplDurchtransport := STEP_110_E;

(* DURCHTRANSPORT ========================================*)
    STEP_110_E:
      (* WICHTIG:
         - Kopplung wird solange aktiv gehalten bis der Nachfolger seinen Transport beendet hat
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;
	  
	  IF bpSensorEinlauf THEN
        steplDurchtransport := STEP_120_E;
	  END_IF
	  
      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_1000_E;
      END_IF

(* DURCHTRANSPORT ========================================*)
    STEP_120_E:
      (* WICHTIG:
         - Kopplung wird solange aktiv gehalten bis der Nachfolger seinen Transport beendet hat
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;
	  
	  IF NOT bpSensorEinlauf THEN
		bprtScheibe := TRUE;
        steplDurchtransport := STEP_130_E;
	  END_IF
	  
      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_1000_E;
      END_IF

(* DURCHTRANSPORT ========================================*)
    STEP_130_E:
	
  	  bprtScheibe := FALSE;

      (* WICHTIG:
         - Kopplung wird solange aktiv gehalten bis der Nachfolger seinen Transport beendet hat
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;
	  
      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_1000_E;
      END_IF

(* DURCHTRANSPORT ========================================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;
      bpSlaveAktiv               := FALSE;

      bpFehler := TRUE;

(* DURCHTRANSPORT ========================================*)
    STEP_1000_E:
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;

      bprtScheibe := FALSE;

      bpDone := TRUE;

(* DURCHTRANSPORT ========================================*)
  END_CASE
ELSE
  IF (steplDurchtransport > STEP_0_E ) THEN
    bpDone := FALSE;

    bpOutBereitZumEintransport := FALSE;
    bpOutBereitZumAustransport := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    steplDurchtransport := STEP_0_E;
  END_IF
END_IF
END_ACTION