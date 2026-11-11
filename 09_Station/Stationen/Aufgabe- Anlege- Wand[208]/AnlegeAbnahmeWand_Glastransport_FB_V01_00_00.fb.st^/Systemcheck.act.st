(* METADATA
{
	"v3Meta": {
		"objectGuid": "6d2a711e-6a9d-4387-a0b6-7c33f0496a9b"
	}
}
*)
ACTION Systemcheck
//-------------------------------------------------------------------------------------------------
// AKTION SYSTEMCHECK
//-------------------------------------------------------------------------------------------------

IF ( bpCheck ) THEN

  (* Fehlerbehandlung:
     - Antrieb
     - Partner im Verbundcheck meldet Fehler
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplCheck := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler
       AND bpCheckMitVorgaenger )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplCheck := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler
       AND bpCheckMitNachfolger )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplCheck := STEP_900_E;
  END_IF

  CASE ( steplCheck ) OF
    // SYSTEM CHECK=========================
    STEP_0_E:
      bpStationBelegt := FALSE;

      IF ( Antrieb.bpReglerBereit ) THEN
        steplCheck := STEP_10_E;
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtBetriebsBereit( IN := NOT ( Antrieb.bpReglerBereit ),
                                      PT := T#5S );

      IF ( tonlAntriebNichtBetriebsBereit.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplCheck := STEP_900_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_Glastransport;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONAL- ANTRIEB REFERENZIEREN
      //
      //  Hinweis:
      // - Die aktuelle Position auf dem Regler nullen ( Referenz ).
      // ---------------------------------------------------------------------------------------

      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;

      steplCheck := STEP_20_E;

    // SYSTEM CHECK=========================
    STEP_20_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_30_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_30_E:
      (* Anmerkung:
         - Es gibt keine Vorgaengerstation
      *)
      IF (  NOT ( bpCheckMitVorgaenger
                  OR bpCheckMitNachfolger ) )
      THEN
        steplCheck := STEP_100_E;
      ELSE
        steplCheck := STEP_300_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_100_E:
      (* Anmerkung:
         - Ueberpruefen ob sich auf der Station Glas befindet

           Ueberpruefung:
         - Kein Sensor belegt [Einlauf- Vorab - Auslauf]
         - Auslauf und Vorabstop belegt [Freifahren ohne das der Einlaufsensor belegt wird]
         - -
      *)
      IF (  NOT bpSensorEinlauf
           AND NOT bpSensorEinlaufVorab
           AND NOT bpSensorAuslaufVorab
           AND NOT bpSensorAuslauf )
      THEN
        steplCheck := STEP_110_E;
      ELSE
        bpStationBelegt := TRUE;
        steplCheck := STEP_890_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_110_E:
      // ---------------------------------------------------------------------------------------
      //  SCHEIBENSUCHFAHRT
      //
      //  Hint:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielposition    := ppParameterBaustein.rLaengeStation;
      Antrieb.wpBetriebsart     := RELATIV;

      steplCheck := STEP_120_E;

    // SYSTEM CHECK=========================
    STEP_120_E:
      IF (  bpSensorAuslaufVorab
           AND NOT bpSensorAuslauf )
      THEN
        bpStationBelegt := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_130_E;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        bpStationBelegt := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_890_E;
      END_IF

      (* Fehlerbehandlung:
         - Sensoren [Einlauf- Auslauf]
         - Antriebe
      *)
      IF ( bpSensorAuslauf ) THEN

        IF ( bpSensorEinlauf ) THEN
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_BELEGT;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_900_E;
      END_IF

      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_Glastransport;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_130_E:
      IF ( NOT bpSensorAuslauf
           AND NOT Antrieb.bpAntrieblaeuft )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_890_E;
      END_IF
      (* Fehlerbehandlung:
         - Sensoren [Einlauf- Auslauf]
      *)
      IF ( bpSensorAuslauf ) THEN
        IF ( bpSensorEinlauf ) THEN
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_BELEGT;
        END_IF
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_900_E;
      END_IF


    // SYSTEM CHECK=========================
    STEP_300_E:
      // ---------------------------------------------------------------------------------------
      //  INITIALISIERUNG VERBUND-SYSTEMCHECK
      //
      //  Hint:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      IF (  bpCheckMitVorgaenger
           AND NOT bpCheckMitNachfolger )
      THEN
        steplCheck := STEP_400_E;

      // Check mit Nachfolger:
      ELSIF( bpCheckMitNachfolger
             AND NOT bpCheckMitVorgaenger )
      THEN
        steplCheck := STEP_600_E;

      ELSE
        (* Fehlerbehandlung:
        *)
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_VERBUND_VORGAENGER_NACHFOLGER_NICHT_ERLAUBT;
        steplCheck := STEP_900_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_400_E:
      // ---------------------------------------------------------------------------------------
      //  SYSTEM CHECK MIT DER VORGAENGERSTATION
      //
      //  Hint:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Unterscheidung ob das Glas auf die Station bzw. von der Station gefahren werden muss.
      *)
      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit := 0.0;

      IF ( InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
        steplCheck := STEP_410_E;
      END_IF


    // SYSTEM CHECK=========================
    STEP_410_E:
      (* Anmerkung:
         - Glas wird auf die Station gezogen und es wird eine Glasposition gesendet
      *)
      IF (  NOT toflEinlaufsensor.Q
           AND NOT Antrieb.bpAntrieblaeuft )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpCheckMitVorgaenger := FALSE;
        steplCheck := STEP_100_E;
      END_IF

      IF ( toflEinlaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor
         - Riemenverfahrweg- Ueberwachung
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition ) >= ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_NICHT_FREI;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_500_E:
      // ---------------------------------------------------------------------------------------
      //  RUECKWERTIGER- TRANSPORT MIT DER VORGAENGERSTATION
      //
      //  Hinweis:
      // - Transport in die "negative" Richtung
      // ---------------------------------------------------------------------------------------

      bpOutBereitZumAustransport := TRUE;

      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.wpBetriebsart     := HANDMINUS;

      steplCheck := STEP_510_E;

    // SYSTEM CHECK=========================
    STEP_510_E:
      (* Hinweis:
         - Scheibenzaehler
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

      (* Hinweis:
         - Sollte das Glas-Abruf -Bit abfallen, so muss der Antrieb sofort anhalten
      *)
      IF ( NOT InGlasTransportVorgaenger.bBereitZumEintransport ) THEN
        Antrieb.rpGeschwindigkeit := 0.0;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      IF ( NOT bpSensorEinlauf ) THEN
        Antrieb.rpGeschwindigkeit := 0.0;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        bprtScheibe := FALSE;
        steplCheck := STEP_520_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_520_E:
      (* Anmerkung:
         - Antrieb in keine Funktion setzen
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        bprtScheibe := FALSE;

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpOutBereitZumAustransport := FALSE;

        IF ( bpSensorEinlauf ) THEN
          rlPositionAntriebBeiStart  := Antrieb.rpIstPosition;
          steplCheck := STEP_530_E;
        ELSE
          bpCheckMitVorgaenger := FALSE;
          steplCheck := STEP_100_E;
        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_530_E:
      (* Anmerkung:
         - Pruefen ob nicht noch eine Scheibe auf den Auslaufsensor gerutscht ist
      *)
      bprtScheibe := FALSE;

      IF ( NOT toflEinlaufsensor.Q ) THEN
        bpCheckMitVorgaenger := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_100_E;
      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor
         - Verfahrwegueberwachung
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

      IF ( ABS( rlPositionAntriebBeiStart - Antrieb.rpIstPosition ) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_NICHT_FREI;
        steplCheck := STEP_900_E;
      END_IF




    // SYSTEM CHECK=========================
    STEP_600_E:
      // ---------------------------------------------------------------------------------------
      //  SYSTEM CHECK MIT DER NACHFOLGESTATION
      //
      //  Hint:
      //  - Transport in "Positive" Richtung ( Auslaufseite )
      // ---------------------------------------------------------------------------------------

      IF ( InGlasTransportNachfolger.bBereitZumEintransport ) THEN

        IF ( NOT bpOptionMasterSlaveTransport ) THEN
          steplCheck := STEP_610_E;
        ELSE
          steplCheck := STEP_650_E;
        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_610_E:
      bpOutBereitZumAustransport := TRUE;

      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.wpBetriebsart     := HANDPLUS;

      steplCheck := STEP_620_E;

    // SYSTEM CHECK=========================
    STEP_620_E:
      (* Hinweis:
         - Scheibenzaehler
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      (* Hinweis:
         - Sollte das Glas-Abruf -Bit abfallen, so muss der Antrieb sofort anhalten
      *)
      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        Antrieb.rpGeschwindigkeit := 0.0;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      IF ( NOT bpSensorAuslauf ) THEN
        Antrieb.rpGeschwindigkeit := 0.0;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        bprtScheibe := FALSE;
        steplCheck := STEP_630_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_630_E:
      (* Anmerkung:
         - Antrieb in keine Funktion setzen
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        bprtScheibe := FALSE;

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpOutBereitZumAustransport := FALSE;

        IF ( bpSensorAuslauf ) THEN
          rlPositionAntriebBeiStart  := Antrieb.rpIstPosition;
          steplCheck := STEP_640_E;
        ELSE
          bpCheckMitNachfolger := FALSE;
          steplCheck := STEP_30_E;
        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_640_E:
      (* Anmerkung:
         - Pruefen ob nicht noch eine Scheibe auf den Auslaufsensor gerutscht ist
      *)
      bprtScheibe := FALSE;

      IF ( NOT toflAuslaufsensor.Q ) THEN
        bpCheckMitNachfolger := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_30_E;
      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor
         - Verfahrwegueberwachung
      *)
      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

      IF ( ABS( rlPositionAntriebBeiStart - Antrieb.rpIstPosition ) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_NICHT_FREI;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_650_E:
      // ---------------------------------------------------------------------------------------
      //  MASTER- SLAVE TRANSPORT MIT DER VORGAENGERSTATION
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      Antrieb.wpMaster := InGlasTransportNachfolger.wAchsID;
      Antrieb.wpBetriebsart := SYNC_AUF_MASTER;

      IF ( Antrieb.bpDone ) THEN
        bpSlaveAktiv := TRUE;
        bpOutBereitZumAustransport := TRUE;
        steplCheck := STEP_660_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_660_E:
      (* Hinweis:
         - Ruecksprung in den default Ablauf
      *)
      bprtScheibe := FALSE;

      IF ( NOT bpSensorAuslauf ) THEN
        bprtScheibe := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_630_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_890_E:
      // ---------------------------------------------------------------------------------------
      //  NACHRICHT GENERIEREN
      //
      //  Hint:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      bprtScheibe := FALSE;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        IF ( bpStationBelegt ) THEN
          rSps2MmiMessungScheibenlaenge       := 0.0;
          wSps2MmiMessungStationNummer        := stStationsNummern.NummerIntern;
          wSps2MmiMessungSlotNummer           := cEBENE_1;
          iSps2MmiMessungScheibenanzahl       := 1;
          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

        ELSE
          rSps2MmiMessungScheibenlaenge       := 0.0;
          wSps2MmiMessungStationNummer        := stStationsNummern.NummerIntern;
          wSps2MmiMessungSlotNummer           := cEBENE_1;
          iSps2MmiMessungScheibenanzahl       := 0;
          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_895_E;

      END_IF

    // SYSTEM CHECK ====================
    STEP_895_E:

      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;

      steplCheck := STEP_896_E;

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_Glastransport;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_896_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_Glastransport;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_900_E: ;
      (* Fehlerbehandlung:
      *)
      bpFehler := TRUE;

    // SYSTEM CHECK=========================
    STEP_1000_E: ;
      bpDone := TRUE;

  // SYSTEM CHECK=========================
  END_CASE
ELSE
  IF (steplCheck > STEP_0_E ) THEN
    bpDone := FALSE;
    bpCheckMitNachfolger := FALSE;
    bpOutBereitZumEintransport := FALSE;
    bpOutBereitZumAustransport := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    tonlAntriebNichtBetriebsBereit( IN := FALSE );
    steplCheck:=STEP_0_E;
  END_IF
END_IF
END_ACTION