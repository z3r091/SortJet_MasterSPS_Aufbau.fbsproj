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
(* Hinweis:
   - Spiegelbild der Aktion Austransport (gleiche Schritte), getauscht sind nur
     => Richtung (HANDMINUS, Negativ-Restwegmodi), Ausgangssensor = Einlaufsensor, Vorab/Stopp = Einlaufseite
     => Empfaenger ist der Vorgaenger
*)
IF (  bpRueckwaertsAustransportieren
     AND NOT bpEintransport
     AND NOT bpRueckwaertsEintransportieren
     AND bpAutomatikAktiv )
THEN

  // Fehlerverhalten:
  //  - Antrieb
  //  - Vorgaenger meldet Fehler
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
    // AUSTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - Variablen initialisieren
      *)
      rlGefahreneStreckeEintransport := 0.0;

      tlWarteZeiteAufnahme := TIME();

      tonlAntriebNichtFreigegeben(IN:=FALSE);
      tonlWarteSchritt(IN:=FALSE);


      steplAustransportRueckwaertig := STEP_5_E;

    // AUSTRANSPORT ==============================
    STEP_5_E:
      (* Hinweis:
         - Sicherstellen das die Slavekopplung aktiv ist
      *)
      IF ( blAntriebsKopplungAktiv ) THEN
        steplAustransportRueckwaertig := STEP_10_E;
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

      steplAustransportRueckwaertig := STEP_30_E;

    // AUSTRANSPORT =========================
    STEP_30_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportRueckwaertig := STEP_40_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_40_E:
      // ---------------------------------------------------------------------------------------
      //  KOPPLUNG [ SCHNITTSTELLE ZWISCHEN DEN STATIONEN]
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( InGlasTransportVorgaenger.bBereitZumEintransport ) THEN

        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeiteAufnahme);

        IF ( NOT pAuftrag.bErsteScheibe ) THEN
          steplAustransportRueckwaertig := STEP_50_E;
        ELSE
          steplAustransportRueckwaertig := STEP_100_E;
        END_IF

      END_IF

    // AUSTRANSPORT ==============================
    STEP_50_E:
      // Pruefen ob der Einlaufsensor belegt ist.
      //   - Einlaufsensor nicht belegt, Glas auf den Einlaufsensor positionieren
      //   - Einlaufsensor belegt, Glas bereit zum Austransport
      IF ( NOT bpSensorEinlauf  ) THEN
        rlAntriebIstPositionBeiStart  := Antrieb.rpIstPosition;

        IF ( bpSensorEinlaufVorab ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
        END_IF

        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielposition    := - ( ppParameterBaustein.rWegUeberEinlaufRueck - pAuftrag.rModellVersatzVorne );

        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportRueckwaertig := STEP_60_E;

      ELSE

        (* Hinweis:
           - Inputshuttle sollten beim ersten Austransport schon auf den Einlaufsensor-Positioniert sein, dies
             muss hier gesondert abgefragt werden
        *)
        IF ( eStationsTyp = eInputshuttle ) THEN

          IF ( bpSensorEinlaufStopp ) THEN
            steplAustransportRueckwaertig := STEP_80_E;
          ELSE
            steplAustransportRueckwaertig := STEP_100_E;
          END_IF

        ELSE
          steplAustransportRueckwaertig := STEP_80_E;

        END_IF

      END_IF

    // AUSTRANSPORT ==============================
    STEP_60_E:
      (* Hinweis:
         - Geschwindigkeit reduzieren
      *)
      IF ( bpSensorEinlaufVorab ) THEN
        rlAntriebIstPositionBeiStart  := Antrieb.rpIstPosition;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;

        steplAustransportRueckwaertig := STEP_70_E;
      END_IF

      (* Fehlerbehandlung:
         - kein Glas auf der Station ( Stationslaemge abfahren)
         - Antrieb
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_UND_EINLAUFVORAB_SCHALTEN_NICHT;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_70_E:
      (* Hinweis:
         - Restweg- Positionierung abgeschlossen auf den Einlauf-Sensor
      *)
      IF ( Antrieb.bpDone
           AND bpSensorEinlauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportRueckwaertig := STEP_80_E;
      END_IF

      (* Fehlerbehandlung:
         - Glas moeglicherweise verkeilt \ gebrochen da der Einlaufsensor nicht schaltet
           bzw. nicht angefahren wird (Stationslaemge abfahren)
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rUeberwachungEinlaufsensor ) THEN
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

    // AUSTRANSPORT ==============================
    STEP_80_E:
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportRueckwaertig := STEP_100_E;
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
          steplAustransportRueckwaertig := STEP_215_E;
        END_IF

      // Austransport Hand-Minus
      ELSE

        Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;

        bpOutBereitZumAustransport := TRUE;

        steplAustransportRueckwaertig := STEP_110_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_110_E:
      (* Hinweis:
         - Vorgaenger nicht bereit: kein Abbruch, der Antrieb folgt der Geschwindigkeit des Vorgaengers und wartet
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( bpSensorEinlaufStopp ) THEN
        steplAustransportRueckwaertig :=  STEP_120_E;
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
    STEP_215_E:
      bprtScheibe := FALSE;

      IF ( bpSensorEinlaufStopp ) THEN
        steplAustransportRueckwaertig := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor schaltet nicht: mehr als die Stationslaenge gefahren
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_120_E:
      (* Hinweis:
         - Scheibenzaehler
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( NOT bpSensorEinlaufStopp ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ( ilScheibenZaehler - 1 );
        IF ( ilScheibenZaehler > 0 ) THEN

          dwpWartezeit := 0;

          // Wegueberwachung fuer die naechste Scheibe neu starten
          rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
          steplAustransportRueckwaertig := STEP_110_E;

        ELSE
          Antrieb.wpBetriebsart := KEINE_FUNKTION;
          Antrieb.rpGeschwindigkeit := REAL#0;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

          steplAustransportRueckwaertig :=   STEP_140_E;
        END_IF

      END_IF

    // AUSTRANSPORT ==============================
    STEP_140_E:

      bprtScheibe := FALSE;
      dwpWartezeit := 0;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        bpOutBereitZumAustransport := FALSE;

        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        // Freifahren nur bis der Stopp-Sensor frei ist; ohne Stopp-Sensor (MK bSensorEinlaufStopp = FALSE)
        // ist bpSensorEinlaufStopp der Einlaufsensor, dann wird der Einlauf freigefahren
        IF NOT bpSensorEinlaufStopp THEN
          steplAustransportRueckwaertig := STEP_1000_E;

        // Scheibe liegt im Uebergang (eigener Sensor und Sensor des Partners belegt): nicht freifahren, fertig
        ELSIF ( InGlasTransportVorgaenger.bAuslaufsensor ) THEN
          steplAustransportRueckwaertig := STEP_1000_E;

        ELSE
          steplAustransportRueckwaertig := STEP_200_E;

        END_IF

      END_IF

    // AUSTRANSPORT ==============================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  EINLAUFSENSOR FREIFAHREN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflEinlaufsensorFrei.Q )
      THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplAustransportRueckwaertig := STEP_1000_E;
      END_IF

      IF ( bpSensorEinlauf ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;
      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor belegt
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

  IF ( steplAustransportRueckwaertig > STEP_0_E ) THEN
    bpDone := FALSE;
    bpOutBereitZumAustransport := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplAustransportRueckwaertig := STEP_0_E;
  END_IF

END_IF
END_ACTION