(* METADATA
{
	"v3Meta": {
		"objectGuid": "373c35ef-a5bf-449e-80ec-3724b7f79bbd"
	}
}
*)
ACTION Eintransport_Rueckwertig
//-------------------------------------------------------------------------------------------------
// AKTION: EINTRANSPORT [NEGATIV- RICHTUNG]
//-------------------------------------------------------------------------------------------------
IF (  bpRueckwaertsEintransportieren
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation:
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplEintransportRueckwaertig := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplEintransportRueckwaertig := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplEintransportRueckwaertig OF
    // EINTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - Variablen initialisieren
      *)
      tlWarteZeiteAufnahme := TIME();
      tonlAntriebNichtFreigegeben( IN := FALSE );

      bpFreigabeQuerfahrt := FALSE;


      rlGeschwindigkeitEintransport := REAL#0;

      steplEintransportRueckwaertig := STEP_5_E;

    // EINTRANSPORT ==============================
    STEP_5_E:
      (* Hinweis:
         - Sicherstellen das die Slavekopplung aktiv ist
      *)
      IF ( blAntriebsKopplungAktiv ) THEN
        steplEintransportRueckwaertig := STEP_10_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_10_E:
      (* Hinweis:
         - Antriebueberpruefen ob bereit zum verfahren.
      *)
      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplEintransportRueckwaertig := STEP_20_E;
      END_IF

      // Ueberwachung:
      //   - Zeitliche Ueberwachung des Schritts
      tonlAntriebNichtFreigegeben( IN := TRUE,
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================GEHT NICHT BEI MASTER SLAVE KOPPLUNG
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

      steplEintransportRueckwaertig := STEP_30_E;

    // EINTRANSPORT ==============================
    STEP_30_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransportRueckwaertig := STEP_40_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_40_E:
      // ---------------------------------------------------------------------------------------
      //  WARTEN AUF KOPPLUNG
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit  := REAL#0;

      IF ( InGlasTransportNachfolger.bBereitZumAustransport ) THEN

        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeiteAufnahme);

        steplEintransportRueckwaertig := STEP_100_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  EINTRANSPORT UEBER DEN AUSLAUFSENSOR [RUECKWERTIG]
      //
      //  Hinweis:
      // - Transport "NEGATIV" Richtung
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Wegstrecke zur reduzierung
      *)
      rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                     rpRampe                := ppAntriebsInformationen.rpMaxVerzoegerung,
                                                                     rpGeschwindigkeit      := ppAntriebsInformationen.rpMaxGeschwindigkeit,
                                                                     rpTrennGeschwindigkeit := rgGeschwindigkeit25 );

      (* Hinweis:
         - Sensor pruefen
      *)
      IF ( NOT bpSensorAuslauf ) THEN

        ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        CASE pAuftrag.wTransferstationsNr1 OF

          cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
            rlGeschwindigkeitEintransport := rgGeschwindigkeit40;

          ELSE
            rlGeschwindigkeitEintransport := ppAntriebsInformationen.rpMaxGeschwindigkeit;


        END_CASE

        Antrieb.rpGeschwindigkeit := rlGeschwindigkeitEintransport;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        IF ( pAuftrag.bLetzteScheibe ) THEN
          (* Hinweis:
             - Lage der letzten Scheibe laut Konfiguration (eGlastransport), Seiten physisch, am Shuttle gelten nur
               => Auf Einlauf: Scheibe faehrt um rWegUeberEinlaufRueck ueber den Einlaufsensor (Ende der Fahrt)
               => Auf Auslauf: Scheibe bleibt um rWegUeberAuslaufRueck auf dem Auslaufsensor liegen (Laenge - Weg)
               => Auf Auslauf-Vorab: Scheibe wird am Eingang (Auslauf) gesammelt (Laenge + rWegUeberEinlaufRueck), die Vorab positioniert sie spaeter
             - Auf Einlauf-Vorab gibt es rueckwaerts am Shuttle nicht (Konfigurationsfehler)
             - Ziel = Flankenposition + Zielwert, rueckwaerts deshalb negativ
          *)
          CASE pAuftrag.stAuftragsOptionen.eGlastransport OF

            eGlastransport_AufAuslaufVorab:
              Antrieb.rpZielposition    := - (pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberEinlaufRueck);
              Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;

            eGlastransport_AufEinlauf:
              Antrieb.rpZielposition    := - ( ppParameterBaustein.rWegUeberEinlaufRueck - pAuftrag.rModellVersatzVorne );
              Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;

            eGlastransport_AufAuslauf:
              Antrieb.rpZielposition    := - ( pAuftrag.rAuftragsLaenge - ppParameterBaustein.rWegUeberAuslaufRueck - pAuftrag.rModellVersatzVorne );
              Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;

          ELSE
            // Fehlende Konfiguration: Lage der letzten Scheibe (eGlastransport) ist nicht gesetzt
            wpFehlerNr := cMELDUNG_EINTRANSPORT_GLASTRANSPORT_OPTION_NICHT_KONFIGURIERT;
            steplEintransportRueckwaertig := STEP_900_E;
          END_CASE
        ELSE
          Antrieb.rpZielposition    := - (pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberEinlaufRueck);
          Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;
        END_IF

        IF ( steplEintransportRueckwaertig <> STEP_900_E ) THEN
          Antrieb.wpBetriebsart     := RESTWEG;

          steplEintransportRueckwaertig := STEP_110_E;
        END_IF

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT_RESTWEGPOSITIONIERUNG;

        steplEintransportRueckwaertig := STEP_900_E;

      END_IF

    // EINTRANSPORT ==============================
    STEP_110_E:
      bprtScheibe := FALSE;

      (* Hinweis:
         - Scheibe laeuft in die Station ein
      *)
      IF ( bpSensorAuslauf ) THEN
        rlPositionScheibenAnfangErkannt := rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        steplEintransportRueckwaertig := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor belegt
      *)
      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

      IF ( pAuftrag.bErsteScheibe ) THEN

        // Erste Scheibe: Laenge der Nachfolgerstation (ohne bekannte Nachfolgerlaenge: eigene Stationslaenge)
        rlMaxStreckeErsteScheibe := InGlasTransportNachfolger.rLaengeStation;
        IF ( rlMaxStreckeErsteScheibe <= 0.0 ) THEN
          rlMaxStreckeErsteScheibe := ppParameterBaustein.rLaengeStation;
        END_IF
        IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > rlMaxStreckeErsteScheibe ) THEN
          Antrieb.wpBetriebsart := KEINE_FUNKTION;
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
          steplEintransportRueckwaertig := STEP_900_E;
        END_IF

      ELSE

        IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition)>  ppParameterBaustein.rUeberwachungAuslaufsensor ) THEN
          Antrieb.wpBetriebsart := KEINE_FUNKTION;
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
          steplEintransportRueckwaertig := STEP_900_E;
        END_IF

      END_IF

    // EINTRANSPORT ==============================
    STEP_120_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      bprtScheibe := FALSE;

      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler = 1 ) THEN
          IF ( ABS( rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition) >= rlStreckeBisZurVerzoegerung ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit25;
          END_IF

        ELSE
          Antrieb.rpGeschwindigkeit   := rlGeschwindigkeitEintransport;

        END_IF

      END_IF

      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
      END_IF

      IF ( NOT bpSensorAuslauf ) THEN

        ilScheibenZaehler := ( ilScheibenZaehler - 1 );
        bprtScheibe := TRUE;

        IF ( ilScheibenZaehler <= 0 ) THEN

          bpFreigabeQuerfahrt := TRUE;

          steplEintransportRueckwaertig := STEP_140_E;
        ELSE
          steplEintransportRueckwaertig := STEP_130_E;
        END_IF

      END_IF

      IF ( Antrieb.bpDone
           AND bpSensorAuslauf )
      THEN
        bprtScheibe := TRUE;

        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplEintransportRueckwaertig := STEP_200_E;
      END_IF

      (* Fehlerbehandlung:
         - -Einlauf- und Auslauf- Sensor
      *)
      IF ( bpSensorAuslauf AND bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_130_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler = 1 ) THEN
          IF ( ABS( rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition) >= rlStreckeBisZurVerzoegerung ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit25;
          END_IF

        ELSE
          Antrieb.rpGeschwindigkeit   := rlGeschwindigkeitEintransport;

        END_IF

      END_IF

      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
      END_IF

      dwpWartezeit := 0;

      bprtScheibe := FALSE;


      IF ( bpSensorAuslauf ) THEN
        steplEintransportRueckwaertig := STEP_120_E;
      END_IF

      IF ( Antrieb.bpDone
           AND NOT Antrieb.bpAntrieblaeuft )
      THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        IF ( bpSensorAuslauf ) THEN
          blScheibenMerker := TRUE;
          steplEintransportRueckwaertig := STEP_140_E;
        ELSE

          steplEintransportRueckwaertig := STEP_1000_E;
        END_IF
      END_IF

      (* Fehlerbehandlung:
         - -Auslauf- Sensor belegt und Antrieb Weg verfahren
         - Einlaufsensor belegt
      *)
      IF ( Antrieb.bpDone AND bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_140_E:
      bprtScheibe := FALSE;

      dwpWartezeit := 0;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransportRueckwaertig := STEP_200_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  SENSORIK PRUEFEN
      //
      //  Hinweis:
      // - Transport "NEGATIVE" Richtung
      // ---------------------------------------------------------------------------------------

      bprtScheibe := FALSE;

      IF ( NOT toflAuslaufsensor.Q ) THEN

        IF ( blScheibenMerker ) THEN
          blScheibenMerker := FALSE;
          bprtScheibe := TRUE;
          ilScheibenZaehler := ilScheibenZaehler - 1;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpOutBereitZumEintransport := FALSE;

        rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - Antrieb.rpIstPosition);

        steplEintransportRueckwaertig := STEP_1000_E;

      ELSIF ( toflAuslaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart := HANDMINUS;

      END_IF

      // Ausnahmesituation:
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition)>  ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bprtScheibe := FALSE;
      bpOutBereitZumEintransport := FALSE;
      bpFehler := TRUE;

      (* Hinweis:
         - Eintransport setzt sich Autark zurueck
      *)
      bpRueckwaertsEintransportieren := FALSE;

    // EINTRANSPORT ==============================
    STEP_1000_E:
      bpOutBereitZumEintransport := FALSE;
      bprtScheibe := FALSE;
      bpDone := TRUE;

      (* Hinweis:
         - Eintransport setzt sich Autark zurueck
      *)
      bpRueckwaertsEintransportieren := FALSE;

  // EINTRANSPORT ==============================

  END_CASE

ELSE

  IF (steplEintransportRueckwaertig > STEP_0_E) THEN
    bpDone := FALSE;
    bprtScheibe := FALSE;
    blScheibenMerker := FALSE;
    bpOutBereitZumEintransport := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplEintransportRueckwaertig := STEP_0_E;
  END_IF

END_IF
END_ACTION