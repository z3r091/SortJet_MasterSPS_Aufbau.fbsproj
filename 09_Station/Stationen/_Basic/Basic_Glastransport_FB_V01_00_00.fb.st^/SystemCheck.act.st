(* METADATA
{
  "v3Meta": {
    "objectGuid": "4144f955-8fdf-4ce2-8e3f-e0008a275aa7"
  }
}
*)
ACTION SystemCheck
//-------------------------------------------------------------------------------------------------
// AKTION SYSTEMCHECK
//-------------------------------------------------------------------------------------------------
IF ( bpCheck ) THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplCheck := STEP_900_E;
  END_IF
  
  IF ( Antrieb_Slave.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplCheck := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler
       AND bpCheckMitVorgaenger )
  THEN
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplCheck := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler
       AND bpCheckMitNachfolger )
  THEN
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplCheck := STEP_900_E;
  END_IF

  // Ausnahmesituation:
  //   - Slave-Kopplung waehrend der Kette verloren
  IF ( NOT blAntriebsKopplungAktiv AND ( steplCheck > STEP_0_E ) AND ( steplCheck < STEP_900_E ) ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_SYSTEMCHECK_SLAVE_KOPPLUNG_VERLOREN;
    steplCheck := STEP_900_E;
  END_IF

  CASE ( steplCheck ) OF
    // SYSTEM CHECK=========================
    STEP_0_E:
      (* Hinweis:
         - Variablen zurueckgesetzt
      *)
      bpDone          := FALSE;
      bprtScheibe     := FALSE;
      bpStationBelegt := FALSE;
      bpUebergrosseScheibeUebergang := FALSE;

      rlGefahreneStreckeEintransport := 0.0;
      rpGemesseneGlaslaenge          := 0.0;

      tonlAntriebNichtBetriebsBereit( IN := FALSE);
      tonlMaxWartezeitFremdanlage( IN := FALSE);

      blReduzierteGeschwindigkeit := ( pAuftrag.rAuftragsGewicht > rgReduzierteGeschwindigkeitGlasGewicht );

      // Sicherstellen das die Slavekopplung aktiv ist
      IF ( blAntriebsKopplungAktiv ) THEN
        steplCheck := STEP_10_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_10_E:
      (* Hinweis:
         - Antrieb pruefen
      *)
      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := 0;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        blReduzierteGeschwindigkeit := ( pAuftrag.rAuftragsGewicht > rgReduzierteGeschwindigkeitGlasGewicht );

        // Keine Refernezfahrt bei Slave Antrieb
        // Sicherstellen das die Slavekopplung aktiv ist
        IF ( bpOptionSlaveAntrieb ) THEN
          IF ( blAntriebsKopplungAktiv ) THEN
            steplCheck := STEP_100_E; // VERERBTER SCHRITT - NICHT ABÄNDERN !!!
          end_if
        // Antrieb nur referenzieren wenn Schwellwert überschritten oder nicht referenziert
        ELSIF ( ABS(Antrieb.rpIstPosition) > rgSchwellwertReferenzieren ) OR NOT Antrieb.bpIstReferenziert THEN
          Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
          steplCheck := STEP_30_E;
        ELSE
          steplCheck := STEP_100_E; // VERERBTER SCHRITT - NICHT ABÄNDERN !!!
        END_IF 
        
      END_IF

      // Fehlersituation:
      //   - Antrieb nicht bereit
      tonlAntriebNichtBetriebsBereit( IN := NOT Antrieb.bpReglerBereit,
                                      PT := T#5S );

      IF ( tonlAntriebNichtBetriebsBereit.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_30_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_100_E; // VERERBTER SCHRITT - NICHT ABÄNDERN !!!
      END_IF

    // SYSTEM CHECK========================= VERERBTER SCHRITT - NICHT ABÄNDERN !!!
    STEP_100_E:
      // Pruefen ob es sich um einen SystemCheck mit einer Vorganger- Nachfolge- Station handelt oder ob der
      //   default SystemCheck abgehandelt werden soll.
      IF ( NOT ( bpCheckMitVorgaenger
                 OR bpCheckMitNachfolger) )
      THEN
        steplCheck := STEP_110_E;
      ELSE
        steplCheck := STEP_300_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_110_E:
      // ---------------------------------------------------------------------------------------
      //  DEFAULT SYSTEMCHECK
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------
      bprtScheibe := FALSE; // Nach Verbundsystemcheck zurücksetzen

      IF NOT ( bpSensorEinlauf OR bpSensorAuslauf ) THEN

        IF (  bpOptionMessungSystemCheckAktiv
             AND NOT pAuftrag.bModell )
        THEN
          steplCheck := STEP_170_E;
        ELSE
          steplCheck := STEP_120_E;
        END_IF

      ELSIF ( bpSensorEinlauf AND NOT bpSensorAuslauf  )
            OR  ( bpSensorAuslauf AND NOT bpSensorEinlauf )
      THEN
        bpStationBelegt := TRUE;

        IF bpSensorAuslaufVorab AND bpSensorEinlauf OR ( bpDurchtransportWarAktiv ) THEN
          steplCheck := STEP_890_E;
        ELSIF (  bpOptionMessungSystemCheckAktiv
                AND NOT pAuftrag.bModell )
        THEN
          steplCheck := STEP_800_E;
        ELSE
          steplCheck := STEP_120_E;
        END_IF

      ELSE
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_120_E:
      (* Hinweis:
         - Ist- Position merken
      *)
      rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

      (* Hinweis:
         - Modell-Status pruefen
      *)
      IF ( NOT pAuftrag.bLetzteScheibe
           OR pAuftrag.bModell )
      THEN
        (* Hinweis:
           - Glas zurueck hinter den Einlaufsensor Positionieren
        *)
        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeitSlow;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeitSystemcheck;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        IF bpOptionNachSystemcheckAufAuslaufsensor THEN
          IF ( NOT bpSensorAuslauf ) THEN
            Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberEinlauf;
            Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
          ELSE
            Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberEinlauf;
            Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
          END_IF
        ELSE
          IF ( NOT bpSensorEinlauf ) THEN
            Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberEinlaufEintransport;
            Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
          ELSE
            Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberEinlaufEintransport;
            Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
          END_IF
        END_IF

        Antrieb.wpBetriebsart     := RESTWEG;

        steplCheck := STEP_140_E;

      ELSE
        (* Hinweis:
           - Glas zurueck hinter den Auslaufsensor Positionieren
        *)
        IF ( bpSensorAuslaufVorAb
             AND NOT bpSensorAuslauf )
        THEN
          bpStationBelegt := TRUE;
          steplCheck := STEP_200_E;

        ELSE
          IF blReduzierteGeschwindigkeit THEN
            Antrieb.rpGeschwindigkeit  := rgGeschwindigkeitSlow;
            Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
            Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          ELSE
            Antrieb.rpGeschwindigkeit  := rgGeschwindigkeitSystemcheck;
            Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
            Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
          END_IF

          IF ( NOT bpSensorAuslauf ) THEN
            Antrieb.wpBetriebsart     := HANDPLUS;

            steplCheck := STEP_150_E;

          ELSE
            steplCheck := STEP_160_E;

          END_IF

        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_140_E:
      // ---------------------------------------------------------------------------------------
      //  DEFAULT SYSTEMCHECK -> BIT <LETZTE SCHEIBE> NICHT GESETZT
      //
      //  Hinweis:
      //  - Beladung pruefen und Status setzen
      // ---------------------------------------------------------------------------------------

      IF bpOptionNachSystemcheckAufAuslaufsensor THEN
        IF bpSensorAuslaufVorAb THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVerySlow;
        END_IF
      ELSE
        IF bpSensorEinlaufVorAb THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVerySlow;
        END_IF
      END_IF

      IF ( Antrieb.bpDone ) THEN
        bpStationBelegt := TRUE;

        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;
        steplCheck := STEP_200_E;
      END_IF

      IF (ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        bpStationBelegt := FALSE;

        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplCheck := STEP_200_E;
      END_IF

      (* Fehlerbehandlung:
         - Sensorik
      *)
      IF ( bpSensorAuslauf AND bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_150_E:
      // ---------------------------------------------------------------------------------------
      //  DEFAULT SYSTEMCHECK -> BIT <LETZTE SCHEIBE> GESETZT | AUSLAUFSENSOR FREI
      //
      //  Hinweis:
      // - Sensorik pruefen
      // ---------------------------------------------------------------------------------------

      IF bpSensorAuslaufVorab THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVerySlow;
      END_IF

      IF ( bpSensorAuslaufVorab
           OR bpSensorAuslauf  ) 
      THEN
        bpStationBelegt := TRUE;

        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        IF ( bpSensorAuslauf ) THEN
          steplCheck := STEP_160_E;
        ELSE
          steplCheck := STEP_200_E;
        END_IF

      END_IF


      IF ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > (ppParameterBaustein.rLaengeStation ) THEN
        bpStationBelegt := FALSE;

        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplCheck := STEP_200_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_160_E:
      // ---------------------------------------------------------------------------------------
      //  DEFAULT SYSTEMCHECK -> BIT <LETZTE SCHEIBE> GESETZT | AUSLAUFSENSOR BELEGT
      //
      //  Hinweis:
      // - Sensorik pruefen
      // ---------------------------------------------------------------------------------------

      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflAuslaufsensor.Q )
      THEN
        bpStationBelegt := TRUE;

        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplCheck := STEP_200_E;

      END_IF

      IF ( toflAuslaufsensor.Q )THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung:
         - Sensorik
         - Zeit- Ueberwachung
      *)
      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := SEL( bpSensorAuslauf, cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT, cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT );
        steplCheck := STEP_900_E;
      END_IF


      tonlMaximaleZeitAuslaufsensorFreiFahren ( IN:= bpSensorAuslauf, PT :=T#10s );

      IF ( tonlMaximaleZeitAuslaufsensorFreiFahren.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_NICHT_FREI;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_170_E:
      // ---------------------------------------------------------------------------------------
      //  DEFAULT SYSTEMCHECK -> SCHEIBENMESSUNG UEBERPARAMETER AKTIVIERT
      //
      //  Hinweis:
      //  - Sensor pruefen
      // ---------------------------------------------------------------------------------------

      IF ( NOT bpSensorEinlauf ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

        Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberSensorenSystemCheck;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeit20;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeitSystemcheck;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplCheck := STEP_180_E;

      ELSE
        bpStationBelegt := TRUE;
        steplCheck := STEP_200_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_180_E:
      (* Anmerkung:
         - Sicherstellen das der Antrieb nicht mehr laeuft
      *)
      IF bpSensorEinlaufVorAb THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVerySlow;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        bpStationBelegt := TRUE;

        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplCheck := STEP_200_E;
      END_IF

      IF (ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        bpStationBelegt := FALSE;

        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplCheck := STEP_200_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  DEFAULT SYSTEMCHECK ABGESCHLOSSEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_800_E;
      END_IF

      (* Fehlerbehandlung:
         - Sensoren
         - Antrieb
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF ( bpSensorEinlauf ) THEN
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_BELEGT;
        END_IF
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_300_E:
      // ---------------------------------------------------------------------------------------
      //  VERBUND SYSTEM CHECK
      //
      //  Hint:
      //  - Pruefen wie der Verbundsystemcheck durchgefuehrt werden soll
      // ---------------------------------------------------------------------------------------

      // Check mit Vorgaenger:
      IF (  bpCheckMitVorgaenger
           AND NOT bpCheckMitNachfolger )
      THEN
        IF ( NOT bpRueckwaertigerTransport ) THEN
          steplCheck := STEP_400_E;
        ELSE
          steplCheck := STEP_500_E;
        END_IF

      // Check mit Nachfolger:
      ELSIF ( bpCheckMitNachfolger
              AND NOT bpCheckMitVorgaenger )
      THEN

        IF ( NOT bpRueckwaertigerTransport ) THEN
          steplCheck := STEP_600_E;
        ELSE
          steplCheck := STEP_700_E;
        END_IF

      ELSE
        // Fehlerbehandlung            *)
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_VERBUND_VORGAENGER_NACHFOLGER_NICHT_ERLAUBT;
        steplCheck := STEP_900_E;

      END_IF


    // SYSTEM CHECK=========================
    STEP_400_E:
      // ---------------------------------------------------------------------------------------
      //  SYSTEM CHECK MIT DER VORGAENGERSTATION
      //
      //  Hint:
      //  - Transport in "Positive" Richtung
      // ---------------------------------------------------------------------------------------

      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit := 0.0;

      IF ( InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
        steplCheck := STEP_410_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_410_E:
      (* Anmerkung:
         - Glas wird auf die Station gezogen
      *)
      IF (  NOT bpSensorAuslaufVorAb ) THEN

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeit20;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeitSystemcheck;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDPLUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Anmerkung:
         - Es wird eine Glasposition gesendet
      *)
      IF ( (  NOT toflEinlaufsensor.Q OR ( ( InGlasTransportVorgaenger.bAuslaufsensor OR toflEinlaufsensor.Q ) AND bpSensorAuslaufVorab ) )  // 20240319 Update übergroße Scheiben LTR-TW
           AND NOT Antrieb.bpAntrieblaeuft )
      THEN
        IF ( ( InGlasTransportVorgaenger.bAuslaufsensor OR toflEinlaufsensor.Q ) AND bpSensorAuslaufVorab ) THEN // 20240319 Update übergroße Scheiben LTR-TW
          IF ( pAuftrag.wAnzahlScheiben = 0 ) THEN
            bprtScheibe := TRUE;
          END_IF
          bpUebergrosseScheibeUebergang := TRUE; // 20240319 Update übergroße Scheiben LTR-TW
          bpStationBelegt := TRUE;
          steplCheck := STEP_890_E;
        ELSE
          bprtScheibe := TRUE;
          steplCheck := STEP_110_E;
        END_IF
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpCheckMitVorgaenger := FALSE;
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

      IF ( InGlasTransportVorgaenger.bBereitZumEintransport ) THEN

        Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.wpBetriebsart     := HANDMINUS;

        bpOutBereitZumAustransport := TRUE;

        steplCheck := STEP_510_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_510_E:
      (* Hinweis:
         - Scheibenzaehler
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;


      (* Hinweis:
         - Sollte das Glas-Abruf -Bit abfallen, so muss der Antrieb sofort anhalten
      *)
      IF ( NOT InGlasTransportVorgaenger.bBereitZumEintransport ) THEN
        Antrieb.rpGeschwindigkeit := 0.0;
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
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT;
          steplCheck := STEP_900_E;
        ELSE
          bpCheckMitVorgaenger := FALSE;
          steplCheck := STEP_110_E;
        END_IF

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

        (* Wichtig:
           - VORGAENGER KANN EIN DOPPELWAND SF SEIN DARUM ERSTMAL HIER KEINE MASTER-SLAVE KOPPLUNG
             ZUGELASSEN

             IF ( NOT bpOptionMasterSlaveTransport ) THEN
             steplCheck := STEP_610_E;
             ELSE
             steplCheck := STEP_650_E;
             END_IF
        *)

        steplCheck := STEP_610_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_610_E:
      bpOutBereitZumAustransport := TRUE;

      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF blReduzierteGeschwindigkeit THEN
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      Antrieb.wpBetriebsart     := HANDPLUS;

      steplCheck := STEP_620_E;

    // SYSTEM CHECK=========================
    STEP_620_E:
      (* Hinweis:
         - Geschwindigkeit der Nachfolgestation uebergeben
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( ( NOT toflAuslaufsensor.Q AND NOT InGlasTransportNachfolger.bEinlaufsensor )
           OR NOT InGlasTransportNachfolger.bBereitZumEintransport )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_630_E;
      END_IF


      IF NOT InGlasTransportNachfolger.bBereitZumEintransport THEN
        IF bpSensorAuslauf OR InGlasTransportNachfolger.bEinlaufsensor THEN
          bpUebergrosseScheibeUebergang := TRUE;
        END_IF
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
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
          steplCheck := STEP_100_E;
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
        steplCheck := STEP_110_E;
      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

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

      Antrieb.wpMaster    := InGlasTransportNachfolger.wAchsID;
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
    STEP_700_E:
      // ---------------------------------------------------------------------------------------
      //  RUECKWERTIGER- TRANSPORT MIT DER NACHFOLGESTATION
      //
      //  Hinweis:
      // - Transport in die "NEGATIVE" Richtung
      // ---------------------------------------------------------------------------------------
      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit := 0.0;

      IF ( InGlasTransportNachfolger.bBereitZumAustransport ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
        steplCheck := STEP_710_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_710_E:
      (* Anmerkung:
         - Glas wird auf die Station gezogen und es wird eine Glasposition gesendet
      *)
      IF (  NOT toflAuslaufsensor.Q
           AND NOT Antrieb.bpAntrieblaeuft )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpCheckMitNachfolger := FALSE;
        steplCheck := STEP_110_E;
      END_IF

      IF ( toflAuslaufsensor.Q ) THEN

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeit20;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeitSystemcheck;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor
         - Riemenverfahrweg- Ueberwachung
      *)
      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition ) >= ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_NICHT_FREI;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_800_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONAL - VERMESSUNG DER SCHEIBENBELADUNG [LAENGE]
      //
      //  Hinweis:
      //  - Nachricht absetzen wenn die Station nicht belegt ist
      // ---------------------------------------------------------------------------------------

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        IF ( bpOptionMessungSystemCheckAktiv ) THEN

          IF ( bpStationBelegt ) THEN
            steplCheck := STEP_810_E;
          ELSE
            steplCheck := STEP_890_E;
          END_IF

        ELSE // ohne Scheibenmesssung
          rpGemesseneGlaslaenge := 1;

          IF ( bpStationBelegt ) THEN
            steplCheck := STEP_890_E; // STEP_870_E;
          ELSE
            steplCheck := STEP_890_E;
          END_IF

        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_810_E:
      (* Anmerkung:
         - Sicherstellen das der Einlaufsensor belegt ist
      *)
      IF ( NOT bpSensorEinlauf ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeit20;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit  := rgGeschwindigkeitSystemcheck;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberSensorenSystemCheck;
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplCheck := STEP_820_E;

      ELSE
        steplCheck := STEP_830_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_820_E:
      (* Anmerkung:
         - Sicherstellen das der Antrieb nicht mehr laeuft
      *)
      IF ( bpSensorEinlaufVorAb ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplCheck := STEP_830_E;
      END_IF

      (* Fehlerbehandlung:
         - UEBERWACHUNG
      *)
      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_830_E:
      (* Anmerkung:
         - Starten der Glaslaengenvermessung
         - Zuruecksetzen der Scheibenlaenge
      *)
      rpGemesseneGlaslaenge := 0.0;


      Scheibenmessung.rpErwarteteScheibenLaenge := pAuftrag.rAuftragsLaenge;
      Scheibenmessung.bpGlasvermessung          := TRUE;

      IF ( Scheibenmessung.bpGlasmessungAbgeschlossen ) THEN
        Scheibenmessung.bpGlasvermessung := FALSE;
        rpGemesseneGlaslaenge := Scheibenmessung.rpGemesseneGlaslaenge;
        steplCheck := STEP_840_E;
      END_IF

      (* Fehlerbehandlung:
         - Scheibenmessung
      *)
      IF ( Scheibenmessung.bpFehler ) THEN
        Scheibenmessung.bpGlasvermessung := FALSE;
        wpFehlerNr := Scheibenmessung.wpFehlerNr;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_840_E:
      (* Hinweis:
         - Betriebsart des Antriebs zuruecksetzen
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_870_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_870_E:
      (* Hinweis:
         - Glas zurueck auf den Einlaufsensor Positionieren [ Restwegpositionierung negativ auf den Einlaufsensor ]
      *)
      rlPositionAntriebBeiStart      := Antrieb.rpIstPosition;

      IF blReduzierteGeschwindigkeit THEN
        Antrieb.rpGeschwindigkeit  := rgGeschwindigkeit20;
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpGeschwindigkeit  := rgGeschwindigkeitSystemcheck;
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      IF bpOptionNachSystemcheckAufAuslaufsensor THEN
        // Langsam fahren, damit der Sensor nicht überfahren wird // TODO TESTEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        IF bpSensorAuslauf THEN
          Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberEinlauf;
          Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
        ELSE
          Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberEinlauf;
          Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
        END_IF
      ELSE
        Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberEinlaufEintransport;
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
      END_IF
      Antrieb.wpBetriebsart     := RESTWEG;

      steplCheck := STEP_880_E;

    // SYSTEM CHECK=========================
    STEP_880_E:
      (* Hinweis:
         - Positionierung abgeschlossen
      *)
      IF ( bpSensorEinlaufVorAb ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVerySlow;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_890_E;
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Sensorik
      *)
      IF (ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_SCHALTET_NICHT;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_900_E;
      END_IF

      IF ( bpSensorEinlauf
           AND bpSensorAuslauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_890_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NACHRICHT ABSETZEN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Nachricht fuer die Glaslaenge absetzen
      //     => Nachricht muss auch abgesetzt werden wenn die Station leer ist
      //   - Messstrecke merken fuer einen eventuellen Eintransport
      bprtScheibe := FALSE;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        IF ( bpStationBelegt ) THEN
          rlGefahreneStreckeEintransport := rpGemesseneGlaslaenge;

          rSps2MmiMessungScheibenlaenge   := rpGemesseneGlaslaenge;
          wSps2MmiMessungStationNummer    := stStationsNummern.NummerSPS;
          wSps2MmiMessungSlotNummer       := 1;
          iSps2MmiMessungScheibenanzahl   := 1;

          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

        ELSE
          rSps2MmiMessungScheibenlaenge   := 0.0;
          wSps2MmiMessungStationNummer    := stStationsNummern.NummerSPS;
          wSps2MmiMessungSlotNummer       := 1;
          iSps2MmiMessungScheibenanzahl   := 0;

          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_1000_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_900_E:
      (* Fehlerbehandlung:
         - Dem MMI die fehlerhafte Messung mitteilen
           ( -1 in iSps2MmiMessungScheibenanzahl ist die Fehlererkennung für das MMI )
      *)

      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;

      rSps2MmiMessungScheibenlaenge   := 0.0;
      wSps2MmiMessungStationNummer    := stStationsNummern.NummerSPS;
      wSps2MmiMessungSlotNummer       := 1;
      iSps2MmiMessungScheibenanzahl   := -1;

      MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

      steplCheck := STEP_910_E;

    // SYSTEM CHECK=========================
    STEP_910_E:
      (* Hinweis:
         - Fehlergenerieren
      *)
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;

      bpFehler := TRUE;

    // SYSTEM CHECK=========================
    STEP_1000_E: ;
      bpDone := TRUE;

  // SYSTEM CHECK=========================
  END_CASE
ELSE

  IF ( steplCheck > STEP_0_E ) THEN
    bpDone                     := FALSE;
    bprtScheibe                := FALSE;
    bpOutBereitZumEintransport := FALSE;
    bpOutBereitZumAustransport := FALSE;

    bpCheckMitVorgaenger       := FALSE;
    bpCheckMitNachfolger       := FALSE;

    rpGemesseneGlaslaenge := 0.0;
    Scheibenmessung.bpGlasvermessung := FALSE;

    Antrieb.wpBetriebsart       := KEINE_FUNKTION;
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;

    tonlMaxWartezeitFremdanlage( IN := FALSE );
    steplCheck:=STEP_0_E;
  END_IF

END_IF
END_ACTION