(* METADATA
{
  "v3Meta": {
    "objectGuid": "bb99af6d-fbf6-4a52-8a79-6fc5a3d5c3e7"
  }
}
*)
ACTION Durchtransport
//-------------------------------------------------------------------------------------------------
// DURCHTRANSPORT
//-------------------------------------------------------------------------------------------------
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

  
  // Ausnahmesituation:
  //   - Slave-Kopplung waehrend der Kette verloren
  IF ( NOT blAntriebsKopplungAktiv AND ( steplDurchtransport > STEP_0_E ) AND ( steplDurchtransport < STEP_900_E ) ) THEN
    wpFehlerNr := cMELDUNG_DURCHTRANSPORT_SLAVE_KOPPLUNG_VERLOREN;
    steplDurchtransport := STEP_900_E;
  END_IF

  CASE steplDurchtransport OF
    // DURCHTRANSPORT ========================================
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

      // Sicherstellen das die Slavekopplung aktiv ist
      IF ( blAntriebsKopplungAktiv ) THEN
        steplDurchtransport := STEP_10_E;
      END_IF

    // DURCHTRANSPORT ========================================
    STEP_10_E:
      (* Anmerkung:
         - Warten bis die Nachfolgestation bereit ist zum Eintransport
      *)
      bpOutBereitZumAustransport := TRUE;

      IF (  InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_20_E;
      END_IF

    // DURCHTRANSPORT ========================================
    STEP_20_E:
      (* Anmerkung:
         - Warten bis die Nachfolgestation bereit ist zum Eintransport
      *)
      bpOutBereitZumEintransport := TRUE;

      IF (  InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
        steplDurchtransport := STEP_100_E;
      END_IF

    // DURCHTRANSPORT ========================================
    STEP_100_E:
      (* Hinweis:
         - Antrieb in den Master- Slave- Modus setzen
      *)
      bpDurchtransportWarAktiv := TRUE;

      ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

      rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart := HANDPLUS;

      steplDurchtransport := STEP_110_E;

    // DURCHTRANSPORT ========================================
    STEP_110_E:
      (* Wichtig:
         - Kopplung wird solange aktiv gehalten bis der Nachfolger seinen Transport beendet hat
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( tonlEinlaufsensor.Q ) THEN
        steplDurchtransport := STEP_120_E;
      END_IF

      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor schaltet nicht: Wegueberwachung erst, wenn die Scheibe am Auslauf des Vorgaengers steht
           => davor ist der Weg unbekannt (Laenge des Vorgaengers), der Vorgaenger ueberwacht seinen Teil selbst
      *)
      IF ( NOT InGlasTransportVorgaenger.bAuslaufsensor ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
      END_IF

      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplDurchtransport := STEP_900_E;
      END_IF

    // DURCHTRANSPORT ========================================
    STEP_120_E:
      (* Hinweis:
         - Scheibe ist auf der Station, warten bis sie den Auslaufsensor erreicht
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( tonlAuslaufsensor.Q ) THEN
        steplDurchtransport := STEP_130_E;
      END_IF

      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_1000_E;
      END_IF

    // DURCHTRANSPORT ========================================
    STEP_130_E:
      (* Hinweis:
         - Scheibenzaehlen ueber den Auslaufsensor: jede Scheibe, die die Station verlaesst, gibt einen Impuls
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( NOT toflAuslaufsensor.Q ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;
        steplDurchtransport := STEP_140_E;
      END_IF

      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_1000_E;
      END_IF

    // DURCHTRANSPORT ========================================
    STEP_140_E:
      (* Wichtig:
         - Kopplung wird solange aktiv gehalten bis der Nachfolger seinen Transport beendet hat
         - Naechste Scheibe des Batches erreicht den Auslaufsensor => wieder zaehlen
      *)
      bprtScheibe := FALSE;

      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( tonlAuslaufsensor.Q ) THEN
        steplDurchtransport := STEP_130_E;
      END_IF

      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        steplDurchtransport := STEP_1000_E;
      END_IF

    // DURCHTRANSPORT ========================================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;
      bpSlaveAktiv               := FALSE;

      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      bpFehler := TRUE;

    // DURCHTRANSPORT ========================================
    STEP_1000_E:
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;

      bprtScheibe := FALSE;

      bpDurchtransportWarAktiv := FALSE;

      bpDone := TRUE;

  // DURCHTRANSPORT ========================================
  END_CASE
ELSE
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