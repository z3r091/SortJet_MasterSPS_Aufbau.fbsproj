(* METADATA
{
	"v3Meta": {
		"objectGuid": "bb99af6d-fbf6-4a52-8a79-6fc5a3d5c3e7"
	}
}
*)
ACTION Durchtransport
(***************************************************************************************************)
(* DURCHTRANSPORT *)
(***************************************************************************************************)
IF (  bpDurchtransport ) THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplDurchtransport := STEP_900_E;
  END_IF
  
  IF ( Antrieb_Slave.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplDurchtransport := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler ) THEN
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplDurchtransport := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler ) THEN
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplDurchtransport := STEP_900_E;
  END_IF

  
  CASE steplDurchtransport OF
(* DURCHTRANSPORT ========================================*)
    STEP_0_E:
      (* Hinweis:
         - Pruefen ob der Antrieb bereit zum verfahren ist
      *)
      bprtScheibe  := FALSE;
      bpSlaveAktiv := FALSE;
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;

      tonlAntriebNichtBetriebsBereit( IN := FALSE);
      tonlMaximaleZeitSensorAnfahren( IN := FALSE );

      steplDurchtransport := STEP_10_E;

(* DURCHTRANSPORT ========================================*)
    STEP_10_E:
      (* Anmerkung:
         - Warten bis die Nachfolgestation bereit ist zum Eintransport
      *)
      bpOutBereitZumAustransport := TRUE;
	  
      IF (  InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_20_E;
      END_IF

(* DURCHTRANSPORT ========================================*)
    STEP_20_E:
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
	  bpDurchtransportWarAktiv := TRUE;
	  
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
	  
      tonlMaximaleZeitSensorAnfahren( IN:= TRUE, PT :=T#60S );
	  
	 (* Fehlerbehandlung:
         - Auslaufsensor schaltet nicht
      *)
      IF ( tonlMaximaleZeitSensorAnfahren.Q ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplAustransport := STEP_900_E;
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
	  
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      bpFehler := TRUE;

(* DURCHTRANSPORT ========================================*)
    STEP_1000_E:
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;

      bprtScheibe := FALSE;

	  bpDurchtransportWarAktiv := FALSE;
	  
      bpDone := TRUE;

(* DURCHTRANSPORT ========================================*)
  END_CASE
END_IF

IF ( NOT bpDurchtransport ) THEN

  IF (steplDurchtransport > STEP_0_E ) THEN
    bpDone := FALSE;

    bpOutBereitZumEintransport := FALSE;
    bpOutBereitZumAustransport := FALSE;

    bprtScheibe := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    steplDurchtransport := STEP_0_E;
  END_IF

END_IF
END_ACTION