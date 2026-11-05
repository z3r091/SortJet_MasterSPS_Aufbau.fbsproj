(* METADATA
{
  "v3Meta": {
    "objectGuid": "0786d428-d10c-4383-86e6-455a1eb74db7"
  }
}
*)
ACTION Austransport
//-------------------------------------------------------------------------------------------------
// AUSTRANSPORT [POSITIVE- RICHTUNG]
//-------------------------------------------------------------------------------------------------
IF ( bpAustransport
     AND NOT bpEintransport
     AND NOT bpRueckwaertsEintransportieren
     AND bpAutomatikAktiv )
THEN

  // Fehlerverhalten:
  //  - Antrieb
  //  - Nachfolger meldet Fehler
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplAustransport := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplAustransport := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplAustransport OF
    // AUSTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - Variablen initialisieren
      *)
      rlGefahreneStreckeEintransport := 0.0;

      tlWarteZeiteAufnahme := TIME();

      tonlAntriebNichtFreigegeben(IN:=FALSE);
      tonlWarteSchritt(IN:=FALSE);


      steplAustransport := STEP_5_E;

    // AUSTRANSPORT ==============================
    STEP_5_E:
      (* Hinweis:
         - Sicherstellen das die Slavekopplung aktiv ist
      *)
      IF ( blAntriebsKopplungAktiv ) THEN
        steplAustransport := STEP_10_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_10_E:
      (* Hinweis:
         - Antriebueberpruefen ob bereit zum verfahren.
      *)
      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplAustransport := STEP_20_E;
      END_IF

      // Ueberwachung:
      //   - Zeitliche Ueberwachung des Schritts
      tonlAntriebNichtFreigegeben( IN := TRUE,
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================GEHT NICHT WEGEN MASTER SLAVE KOPPLUNG
    STEP_20_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONAL - REFERENZIEREN DES ANTRIEBS
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;

      steplAustransport := STEP_30_E;

    // AUSTRANSPORT =========================
    STEP_30_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransport := STEP_40_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_40_E:
      // ---------------------------------------------------------------------------------------
      //  KOPPLUNG [ SCHNITTSTELLE ZWISCHEN DEN STATIONEN]
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( InGlasTransportNachfolger.bBereitZumEintransport ) THEN

        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeiteAufnahme);

        IF ( NOT pAuftrag.bErsteScheibe ) THEN
          steplAustransport := STEP_50_E;
        ELSE
          steplAustransport := STEP_100_E;
        END_IF

      END_IF

    // AUSTRANSPORT ==============================
    STEP_50_E:
      // Pruefen ob der Auslaufsensor belegt ist.
      //   - Auslaufsesnor nicht belegt, Glas auf den Auslaufsensor positionieren
      //   - Auslaufsesnor belegt, Glas bereit zum Austransport
      IF ( NOT bpSensorAuslauf  ) THEN
        rlAntriebIstPositionBeiStart  := Antrieb.rpIstPosition;

        IF ( bpSensorAuslaufVorab ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
        END_IF

        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielposition    := ( ppParameterBaustein.rWegUeberAuslauf - pAuftrag.rModellVersatzVorne );

        Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransport := STEP_60_E;

      ELSE

        (* Hinweis:
           - Inputshuttle sollten beim ersten Austransport schon auf den Auslaufsensor-Positioniert sein, dies
             muss hier gesondert abgefragt werden
        *)
        IF ( eStationsTyp = eInputshuttle ) THEN

          IF ( bpSensorAuslaufStopp ) THEN
            steplAustransport := STEP_80_E;
          ELSE
            steplAustransport := STEP_100_E;
          END_IF

        ELSE
          steplAustransport := STEP_80_E;

        END_IF

      END_IF

    // AUSTRANSPORT ==============================
    STEP_60_E:
      (* Hinweis:
         - Geschwindigkeit reduzieren
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        rlAntriebIstPositionBeiStart  := Antrieb.rpIstPosition;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;

        steplAustransport := STEP_70_E;
      END_IF

      (* Fehlerbehandlung:
         - kein Glas auf der Station ( Stationslaemge abfahren)
         - Antrieb
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_UND_AUSLAUFVORAB_SCHALTEN_NICHT;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_70_E:
      (* Hinweis:
         - Restweg- Positionierung abgeschlossen auf den Auslauf-Sensor
      *)
      IF ( Antrieb.bpDone
           AND bpSensorAuslauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransport := STEP_80_E;
      END_IF

      (* Fehlerbehandlung:
         - Glas moeglicherweise verkeilt \ gebrochen da der Auslaufsensor nicht schaltet
           bzw. nicht angefahren wird (Stationslaemge abfahren)
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rUeberwachungAuslaufsensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransport := STEP_900_E;
      END_IF

      IF (  Antrieb.bpDone
           AND NOT bpSensorAuslauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_80_E:
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransport := STEP_100_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES AUSTRANSPORTS
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------
      ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

      rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

      // Master-Slave Austransport
      IF bpOptionMasterSlaveTransport THEN

        Antrieb.wpMaster := InGlasTransportNachfolger.wAchsID;

        // Wenn der Vorgänger "Rückwärtig" fährt, darf das Shuttle nicht "invertiert" gekoppelt werdem, da es sonst in der falsche Richtung fährt
        IF InGlasTransportNachfolger.bTransportRueckwaertig THEN
          Antrieb.wpBetriebsart :=INVERTIERTER_SYNC_AUF_MASTER;
        ELSE
          Antrieb.wpBetriebsart := SYNC_AUF_MASTER;
        END_IF
        
        IF ( Antrieb.bpDone ) THEN
          bpSlaveAktiv := TRUE;
          bpOutBereitZumAustransport := TRUE;
          steplAustransport := STEP_215_E;
        END_IF

      // Austransport Hand-Minus
      ELSE
        
        Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;

        bpOutBereitZumAustransport := TRUE;

        steplAustransport := STEP_110_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_110_E:

      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( bpSensorAuslaufStopp ) THEN
        steplAustransport :=  STEP_120_E;
      END_IF

      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransport :=  STEP_140_E;
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor schaltet nicht: mehr als die Stationslaenge gefahren (je Scheibe neu)
         - Steht der Antrieb (Nachfolger mit Geschwindigkeit 0), laeuft die Ueberwachung nicht ab
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ====================================
    STEP_215_E:
      bprtScheibe := FALSE;

      IF ( bpSensorAuslaufStopp ) THEN
        steplAustransport := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor schaltet nicht: mehr als die Stationslaenge gefahren
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_120_E:
      (* Hinweis:
         - Scheibenzaehler
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( NOT bpSensorAuslaufStopp ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ( ilScheibenZaehler - 1 );
        IF ( ilScheibenZaehler > 0 ) THEN

          dwpWartezeit := 0;

          // Wegueberwachung fuer die naechste Scheibe neu starten
          rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
          steplAustransport := STEP_110_E;

        ELSE
          Antrieb.wpBetriebsart := KEINE_FUNKTION;
          Antrieb.rpGeschwindigkeit := REAL#0;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

          steplAustransport :=   STEP_140_E;
        END_IF

      END_IF

      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        steplAustransport := STEP_140_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_140_E:

      bprtScheibe := FALSE;
      dwpWartezeit := 0;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        bpOutBereitZumAustransport := FALSE;

        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
          
        // TODO Option zum auslauf freifahren / ansonsten nur auslaufstopp
        IF NOT bpSensorAuslaufStopp THEN
          steplAustransport := STEP_1000_E;

        ELSE
          steplAustransport := STEP_200_E;

        END_IF

      END_IF

    // AUSTRANSPORT ==============================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  AUSLAUFSENSOR FREIFAHREN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflAuslaufsensorFrei.Q )
      THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplAustransport := STEP_1000_E;
      END_IF

      IF ( bpSensorAuslauf ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;
      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor belegt
         - Verfahrweg- Ueberwachung
      *)
      IF ( bpSensorEinlauf ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplAustransport := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpOutBereitZumAustransport := FALSE;
      bpFehler := TRUE;

    // AUSTRANSPORT ==============================
    STEP_1000_E:
      bprtScheibe := FALSE;
      bpDone := TRUE;

  // AUSTRANSPORT ==============================
  END_CASE
ELSE

  IF ( steplAustransport > STEP_0_E ) THEN
    bpDone := FALSE;
    bpOutBereitZumAustransport := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplAustransport := STEP_0_E;
  END_IF

END_IF
END_ACTION