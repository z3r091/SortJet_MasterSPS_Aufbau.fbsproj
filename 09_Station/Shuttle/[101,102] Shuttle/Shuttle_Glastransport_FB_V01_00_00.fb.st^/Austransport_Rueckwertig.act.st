(* METADATA
{
  "v3Meta": {
    "objectGuid": "0d0cddc4-f0a8-4ab0-b778-9f5f7bbe2973"
  }
}
*)
ACTION Austransport_Rueckwertig
//-------------------------------------------------------------------------------------------------
// AUSTRANSPORT [NEGATIVE- RICHTUNG]
//-------------------------------------------------------------------------------------------------
IF (  bpRueckwaertsAustransportieren
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituationen:
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplAustransportRueckwaertig := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplAustransportRueckwaertig := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplAustransportRueckwaertig OF
    // AUSTRANSPORT ====================================
    STEP_0_E:
      (* Hinweis:
         - Variablen initialisierung
      *)
      tlWarteZeiteAufnahme := TIME();

      rlGefahreneStreckeEintransport := REAL#0;

      bprtScheibe        := FALSE;
      blSensorFreiFahren := FALSE;


      tonlWarteSchritt(IN := FALSE);
      tonlAntriebNichtFreigegeben(IN := FALSE);

      steplAustransportRueckwaertig := STEP_5_E;

    // AUSTRANSPORT ==============================
    STEP_5_E:
      (* Hinweis:
         - Sicherstellen das die Slavekopplung aktiv ist
      *)
      IF ( blAntriebsKopplungAktiv ) THEN
        steplAustransportRueckwaertig := STEP_10_E;
      END_IF

    // AUSTRANSPORT ====================================
    STEP_10_E:
      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplAustransportRueckwaertig := STEP_20_E;
      END_IF

      // Ueberwachung:
      //   - Zeitliche Ueberwachung des Schritts
      tonlAntriebNichtFreigegeben( IN := TRUE,
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

    // AUSTRANSPORT ====================================
    STEP_20_E:
      (* Hinweis:
         - Pruefen ob der Glas-Empfaenger bereit ist
      *)
      IF ( InGlasTransportVorgaenger.bBereitZumEintransport  ) THEN

        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeiteAufnahme);

        IF ( NOT pAuftrag.bErsteScheibe ) THEN
          steplAustransportRueckwaertig := STEP_100_E;
        ELSE
          steplAustransportRueckwaertig := STEP_200_E;
        END_IF

      END_IF

    // AUSTRANSPORT ====================================
    STEP_100_E:
      (* Hinweis:
         - Sensorik pruefen [Restweg Positioniert]
      *)
      IF ( NOT bpSensorEinlauf ) THEN
        rlAntriebIstPositionBeiStart  := Antrieb.rpIstPosition;

        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielposition    := ppParameterBaustein.rWegUeberAuslaufRueck - pAuftrag.rModellVersatzVorne;
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportRueckwaertig := STEP_110_E;

      ELSE

        IF (  NOT InGlasTransportVorgaenger.bAuslaufsensor
             AND NOT blSensorFreifahren )
        THEN
          blSensorFreifahren := TRUE;
          steplAustransportRueckwaertig  := STEP_300_E;

        ELSE
          steplAustransportRueckwaertig := STEP_200_E;

        END_IF

      END_IF

    // AUSTRANSPORT ====================================
    STEP_110_E:
      // Wird der Vorstop- Sensor ueberfahren die Geschwindigkeit des
      //   Antriebsdrosseln.
      IF ( bpSensorEinlaufVorab ) THEN
        rlAntriebIstPositionBeiStart  := Antrieb.rpIstPosition;
        Antrieb.rpGeschwindigkeit     := rgGeschwindigkeit10;
        steplAustransportRueckwaertig := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - kein Glas auf der Station ( Stationslaemge abfahren)
         - Antrieb
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_UND_AUSLAUFVORAB_SCHALTEN_NICHT;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

    // AUSTRANSPORT ====================================
    STEP_120_E:
      (* Hinweis:
         - Restweg- Positionierung abgeschlossen auf den Auslauf-Sensor
      *)
      IF (  Antrieb.bpDone
           AND bpSensorEinlauf )
      THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;
        steplAustransportRueckwaertig := STEP_200_E;
      END_IF

      // Ausnahmesituation
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rUeberwachungAuslaufsensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

      IF (  Antrieb.bpDone
           AND NOT bpSensorEinlauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

    // AUSTRANSPORT ====================================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES TRANSPORTS
      //
      //  Hinweis:
      // - Transport "NEGATIVE" Richtung
      // ---------------------------------------------------------------------------------------
      ilScheibenZaehler := WORD_TO_INT( pAuftrag.wAnzahlScheiben );

      rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

      // Master-Slave Austransport
      IF bpOptionMasterSlaveTransport THEN
        
        Antrieb.wpMaster := InGlasTransportVorgaenger.wAchsID;

        // Wenn der Vorgänger "Rückwärtig" fährt, darf das Shuttle nicht "invertiert" gekoppelt werdem, da es sonst in der falsche Richtung fährt
        IF InGlasTransportVorgaenger.bTransportRueckwaertig THEN
          Antrieb.wpBetriebsart := SYNC_AUF_MASTER;
        ELSE
          Antrieb.wpBetriebsart := INVERTIERTER_SYNC_AUF_MASTER;
        END_IF
        
        IF ( Antrieb.bpDone ) THEN
          bpSlaveAktiv := TRUE;
          bpOutBereitZumAustransport := TRUE;
          steplAustransportRueckwaertig := STEP_240_E;
        END_IF
      
      // Austransport Hand-Minus
      ELSE

        Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;
        
        bpOutBereitZumAustransport := TRUE;
        
        steplAustransportRueckwaertig := STEP_210_E;
        
      END_IF
        
        
    // AUSTRANSPORT ====================================
    STEP_210_E:
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( bpSensorEinlauf ) THEN
        steplAustransportRueckwaertig := STEP_220_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor schaltet nicht: mehr als die Stationslaenge gefahren (je Scheibe neu)
         - Steht der Antrieb (Vorgaenger mit Geschwindigkeit 0), laeuft die Ueberwachung nicht ab
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

    // AUSTRANSPORT ====================================
    STEP_220_E:
      (* Hinweis:
         - Scheibenzaehler
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( NOT bpSensorEinlauf ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;

        IF ( ilScheibenZaehler > 0 ) THEN
          dwpWartezeit := 0;

          // Wegueberwachung fuer die naechste Scheibe neu starten
          rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
          steplAustransportRueckwaertig := STEP_210_E;

        ELSE
          Antrieb.rpGeschwindigkeit := REAL#0;
          Antrieb.wpBetriebsart     := KEINE_FUNKTION;
          steplAustransportRueckwaertig := STEP_280_E;

        END_IF

      END_IF


    // AUSTRANSPORT ====================================
    STEP_240_E:      
      bprtScheibe := FALSE;
      
      IF ( bpSensorEinlauf ) THEN
        steplAustransportRueckwaertig := STEP_250_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor schaltet nicht: mehr als die Stationslaenge gefahren
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

    // AUSTRANSPORT ====================================
    STEP_250_E:      
      (* Hinweis:
         - Scheibenzaehler
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( NOT bpSensorEinlauf ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;

        IF ( ilScheibenZaehler > 0 ) THEN
          dwpWartezeit := 0;

          // Wegueberwachung fuer die naechste Scheibe neu starten
          rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
          steplAustransportRueckwaertig := STEP_210_E;

        ELSE
          Antrieb.rpGeschwindigkeit := REAL#0;
          Antrieb.wpBetriebsart     := KEINE_FUNKTION;
          steplAustransportRueckwaertig := STEP_280_E;

        END_IF

      END_IF

    
    // AUSTRANSPORT ====================================
    STEP_280_E:
      bprtScheibe := FALSE;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        bpOutBereitZumAustransport := FALSE;
        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( NOT bpSensorEinlauf ) THEN
          steplAustransportRueckwaertig := STEP_400_E;
        ELSE
          steplAustransportRueckwaertig := STEP_300_E;
        END_IF

      END_IF    
    
    
    // AUSTRANSPORT ====================================
    STEP_300_E:
      // ---------------------------------------------------------------------------------------
      //  SENSOR FREIFAHREN
      //
      //  Hinweis:
      // - Transport "Positive" Richtung
      // ---------------------------------------------------------------------------------------

      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflEinlaufsensorFrei.Q )
      THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( blSensorFreifahren ) THEN
          steplAustransportRueckwaertig  :=  STEP_10_E;
        ELSE
          steplAustransportRueckwaertig  :=  STEP_800_E;
        END_IF

      END_IF

      IF ( toflEinlaufsensorFrei.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;
      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor belegt
         - Verfahrweg- Ueberwachung
      *)
      IF ( bpSensorAuslauf ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_400_E:
      // ---------------------------------------------------------------------------------------
      //  REFERENZ
      //
      //  Hinweis:
      // - Antrieb Referenzieren
      // ---------------------------------------------------------------------------------------
      // GEHT NICHT WEGEN MASTER SLAVE KOPPLUNG
      //      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
      //      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.wpMaxBeschleunigung;
      //      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.wpMaxVerzoegerung;
      //
      //      Antrieb.wpBetriebsart     := REFERENZ;
      //
      //      steplAustransportRueckwaertig := STEP_410_E;
      steplAustransportRueckwaertig := STEP_1000_E;
    // AUSTRANSPORT =========================
    STEP_410_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportRueckwaertig := STEP_1000_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpOutBereitZumAustransport := FALSE;
      bpFehler := TRUE;

    // AUSTRANSPORT ==============================
    STEP_1000_E:
      bpOutBereitZumAustransport := FALSE;
      bprtScheibe := FALSE;
      bpDone := TRUE;

  // AUSTRANSPORT ==============================
  END_CASE
ELSE
  IF ( steplAustransportRueckwaertig > STEP_0_E ) THEN
    bpDone := FALSE;
    bpOutBereitZumAustransport := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplAustransportRueckwaertig := STEP_0_E;
  END_IF
END_IF
END_ACTION