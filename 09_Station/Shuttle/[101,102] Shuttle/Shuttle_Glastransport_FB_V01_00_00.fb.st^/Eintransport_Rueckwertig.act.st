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
(* Hinweis:
   - Spiegelbild der Aktion Eintransport (gleiche Schritte), getauscht sind nur
     => Richtung (HANDMINUS, Negativ-Restwegmodi), Eingangssensor = Auslaufsensor, Vorab/Stopp = Einlaufseite
     => Sender ist der Nachfolger
*)
IF (  bpRueckwaertsEintransportieren
     AND bpAutomatikAktiv )
THEN

  (* Fehlerbehandlung:
     - Antrieb
     - Kopplung Nachfolger
  *)
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

    // EINTRANSPORT ==============================GEHT NICHT WEGEN MASTER SLAVE KOPPLUNG
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
      //  KOPPLUNG [ SCHNITTSTELLE ZWISCHEN DEN STATIONEN]
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit  := REAL#0;

      IF ( InGlasTransportNachfolger.bBereitZumAustransport ) THEN

        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeiteAufnahme);

        IF ( NOT bpTransferstationTransfershuttle ) THEN
          steplEintransportRueckwaertig := STEP_100_E;
        ELSE
          steplEintransportRueckwaertig := STEP_400_E;
        END_IF

      END_IF

    // EINTRANSPORT ==============================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES EINTRANSPORT
      //
      //  Hinweis:
      // - Transport "NEGATIVE" Richtung
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Wegstrecke bis zur Geschwindigkeits reduzierung [Scheibentrennung]
           WICHTIG
           => Aktuell wird nur mit 1m/s^2 als Verzoegerung gerechnet auch wenn der Antrieb staerker Verzoegern kann. Das aktuelle System
            ist etwas zu traege um die reduzierung passend zu gestallten. (Bus-Laufzeiten | CPU | etc. )
      *)
      rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                     rpRampe                := ppAntriebsInformationen.rpMaxVerzoegerung,
                                                                     rpGeschwindigkeit      := ppAntriebsInformationen.rpMaxGeschwindigkeit,
                                                                     rpTrennGeschwindigkeit := rgGeschwindigkeit30 );

      (* Hinweis:
         - Starten des Eintransports:
            => Restwegpositionierung (Wenn der Auslaufsensor belegt wurde Zielposition fahren )
            => Fehlverhalten sollte der Auslaufsensor belegt sein beim Starten der Restweg-Positionierung
      *)
      ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

      rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;


      IF ( NOT bpSensorAuslauf ) THEN

        IF (  pAuftrag.bErsteScheibe
             AND pAuftrag.bLetzteScheibe )
        THEN
          rlGeschwindigkeitEintransport := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        ELSE
          rlGeschwindigkeitEintransport := rgGeschwindigkeit40;
        END_IF

        (* Hinweis:
           - Reduzieren der Geschwindigkeit nach Glasgewicht
             => Da es passieren kann dass das Glas rutschen kann
        *)
        rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge := pAuftrag.rAuftragsLaenge,
                                                 rpGlasbreite := pAuftrag.rAuftragsHoehe,
                                                 rpGlasstaerke := SEL( pAuftrag.rAuftragsDicke > wgUnterteilerMinMaxGlasdicke, GLASSTAERKE_DEFAULT_MIN, GLASSTAERKE_DEFAULT_MAX ) ) );

        IF ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht ) THEN
          rlGeschwindigkeitEintransport := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
          blReduzierteGeschwindigkeit   := TRUE;
        ELSE
          blReduzierteGeschwindigkeit   := FALSE;
        END_IF

        Antrieb.rpGeschwindigkeit := rlGeschwindigkeitEintransport;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        IF ( pAuftrag.bLetzteScheibe ) THEN
          (* Hinweis:
             - Lage der letzten Scheibe laut Konfiguration (eGlastransport), Seiten physisch, am Shuttle gelten nur
               => Auf Einlauf: Scheibe faehrt um rWegUeberEinlaufRueck ueber den Einlaufsensor (Ende der Fahrt)
               => Auf Auslauf: Scheibe bleibt um rWegUeberAuslaufRueck auf dem Auslaufsensor liegen (Laenge - Weg)
               => Auf Auslauf-Vorab: Scheibe wird am Eingang (Auslauf) gesammelt (Laenge + rWegUeberAuslaufRueck), die Vorab positioniert sie spaeter
             - Auf Einlauf-Vorab gibt es rueckwaerts am Shuttle nicht (Konfigurationsfehler)
             - Ziel = Flankenposition + Zielwert, rueckwaerts deshalb negativ
          *)
          CASE pAuftrag.stAuftragsOptionen.eGlastransport OF

            eGlastransport_AufEinlauf:
              Antrieb.rpZielposition    := - ( ppParameterBaustein.rWegUeberEinlaufRueck - pAuftrag.rModellVersatzVorne );
              Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;

            eGlastransport_AufAuslaufVorab:
              Antrieb.rpZielposition    := - ( ( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberAuslaufRueck ) - pAuftrag.rModellVersatzVorne );
              Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;

            eGlastransport_AufAuslauf:
              Antrieb.rpZielposition    := - ( pAuftrag.rAuftragsLaenge - ppParameterBaustein.rWegUeberAuslaufRueck - pAuftrag.rModellVersatzVorne );
              Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;

          ELSE
            // Fehlende Konfiguration: Lage der letzten Scheibe (eGlastransport) ist nicht gesetzt
            wpFehlerNr := cMELDUNG_EINTRANSPORT_GLASTRANSPORT_OPTION_NICHT_KONFIGURIERT;
            steplEintransportRueckwaertig := STEP_900_E;
          END_CASE
        ELSE
          Antrieb.rpZielposition    := - ( ( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberAuslaufRueck ) - pAuftrag.rModellVersatzVorne );
          Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;
        END_IF

        IF ( steplEintransportRueckwaertig <> STEP_900_E ) THEN
          Antrieb.wpBetriebsart := RESTWEG;

          steplEintransportRueckwaertig := STEP_110_E;
        END_IF

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT_RESTWEGPOSITIONIERUNG;

        steplEintransportRueckwaertig := STEP_900_E;

      END_IF

    // EINTRANSPORT ==============================
    STEP_110_E:

      // Vorabstop- Sensor:
      //   - Geschwindigkeit reduzieren
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      bprtScheibe := FALSE;

      (* Hinweis:
         - Scheibe laeuft in die Station ein
      *)
      IF ( bpSensorAuslauf ) THEN
        rlPositionScheibenAnfangErkannt := rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        steplEintransportRueckwaertig := STEP_120_E;
      END_IF

      // Vorabstop- Sensor:
      //   - Geschwindigkeit verringern
      IF ( ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung)
           AND NOT blReduzierteGeschwindigkeit )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      // Vorabstop- Sensor:
      //   - Geschwindigkeit reduzieren
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        Antrieb.rpVerzoegerung    := ( ppAntriebsInformationen.rpMaxVerzoegerung * 1.5 );
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor schaltet nicht (Unterscheidung ob es die erste Scheibe ist oder eine weitere )
         - Einlaufsensor wird belegt
      *)
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

      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_120_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler = 1 ) THEN
          IF ( ABS( rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition) >= rlStreckeBisZurVerzoegerung ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
          END_IF

        END_IF

      END_IF


      (* Hinweis:
         - Sensorik frei geworden
      *)
      IF ( NOT toflAuslaufsensorFrei.Q ) THEN

        ilScheibenZaehler := ( ilScheibenZaehler - 1 );
        bprtScheibe := TRUE;

        IF ( ilScheibenZaehler <= 0 ) THEN
          bpFreigabeQuerfahrt := TRUE;
        END_IF

        steplEintransportRueckwaertig := STEP_130_E;
      END_IF

      IF ( Antrieb.bpDone
           AND NOT Antrieb.bpAntrieblaeuft )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpSensorAuslauf ) THEN
          blScheibenMerker := TRUE;
          rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
          steplEintransportRueckwaertig := STEP_200_E;

        ELSE
          rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - Antrieb.rpIstPosition);
          steplEintransportRueckwaertig := STEP_1000_E;

        END_IF

      END_IF

      (* Hinweis:
         - Geschwindigkeit verringern
      *)
      IF ( ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung)
           AND NOT blReduzierteGeschwindigkeit )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      // Vorabstop- Sensor:
      //   - Langsame Transportgeschwindigkeit
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        Antrieb.rpVerzoegerung    := ( ppAntriebsInformationen.rpMaxVerzoegerung * 1.5 );
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor belegt
         - Antrieb
      *)
      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
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
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
          END_IF

        END_IF

      END_IF

      (* Hinweis:
         - Zeitwert zuruecksetzen
      *)
      IF bprtScheibe THEN
        dwpWartezeit := 0;
      END_IF

      bprtScheibe := FALSE;

      IF ( bpSensorAuslauf ) THEN
        steplEintransportRueckwaertig := STEP_120_E;
      END_IF

      IF ( Antrieb.bpDone ) THEN

        IF ( bpSensorAuslauf ) THEN
          blScheibenMerker := TRUE;
        END_IF

        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplEintransportRueckwaertig := STEP_200_E;

      END_IF

      (* Hinweis:
         - Geschwindigkeit verringern
      *)
      IF ( ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung)
           AND NOT blReduzierteGeschwindigkeit )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      // Vorabstop- Sensor:
      //   - Langsame Transportgeschwindigkeit
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        Antrieb.rpVerzoegerung    := ( ppAntriebsInformationen.rpMaxVerzoegerung * 1.5 );
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor belegt
         - Antrieb
      *)
      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  AUSLAUFSENSOR FREIFAHREN
      //
      //  Hinweis:
      // - Transport "NEGATIVE" Richtung
      // ---------------------------------------------------------------------------------------


      bprtScheibe := FALSE;
      dwpWartezeit := 0;

      (* Hinweis:
         - Scheibe liegt im Uebergang (Eingangssensor und Sensor des Partners belegt): nicht freifahren, fertig
      *)
      IF ( bpSensorAuslauf AND InGlasTransportNachfolger.bEinlaufsensor ) THEN

        IF ( blScheibenMerker ) THEN
          blScheibenMerker := FALSE;
          bprtScheibe := TRUE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpOutBereitZumEintransport := FALSE;

        rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - Antrieb.rpIstPosition);

        steplEintransportRueckwaertig := STEP_1000_E;

      ELSIF ( NOT toflAuslaufsensor.Q ) THEN

        IF ( blScheibenMerker ) THEN
          blScheibenMerker := FALSE;
          bprtScheibe := TRUE;
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

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Einlaufsensor belegt
         - Antrieb
      *)
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
    STEP_400_E:
      // ---------------------------------------------------------------------------------------
      //  EINTRANSPORT UEBER DEN AUSLAUFSENSOR [TRANSFERSHUTTLE]
      //
      //  Hinweis:
      //  - Restwegpositionierung
      //  - Fehlverhalten bei belegtem Sensor belegt
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Wegstrecke zur reduzierung
      *)
      rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                     rpRampe                := ppAntriebsInformationen.rpMaxVerzoegerung,
                                                                     rpGeschwindigkeit      := ppAntriebsInformationen.rpMaxGeschwindigkeit,
                                                                     rpTrennGeschwindigkeit := rgGeschwindigkeit25 );

      (* Hinweis:
         - Reduzieren der Geschwindigkeit + Beschleunigung nach Glasgewicht
           => Da es passieren kann dass das Glas rutschen kann
      *)
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge := pAuftrag.rAuftragsLaenge,
                                               rpGlasbreite := pAuftrag.rAuftragsHoehe,
                                               rpGlasstaerke := SEL( pAuftrag.rAuftragsDicke > wgUnterteilerMinMaxGlasdicke, GLASSTAERKE_DEFAULT_MIN, GLASSTAERKE_DEFAULT_MAX ) ) );

      IF ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht ) THEN
        Antrieb.rpBeschleunigung    := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung      := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpGeschwindigkeit   := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;

        rlGeschwindigkeitEintransport := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
        blReduzierteGeschwindigkeit   := TRUE;
      ELSE
        Antrieb.rpVerzoegerung      := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung    := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpGeschwindigkeit   := rgGeschwindigkeit40;

        rlGeschwindigkeitEintransport := rgGeschwindigkeit40;
        blReduzierteGeschwindigkeit   := FALSE;
      END_IF


      ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

      rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

      IF ( NOT bpSensorAuslauf ) THEN

        IF ( pAuftrag.bLetzteScheibe ) THEN
          // Letzte Scheibe faehrt um rWegUeberEinlaufRueck ueber den Einlaufsensor (Ende der Fahrt)
          Antrieb.rpZielPosition    := - ( ppParameterBaustein.rWegUeberEinlaufRueck - pAuftrag.rModellVersatzVorne );
          Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;

        ELSE

          Antrieb.rpZielposition    := - ( ( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberAuslaufRueck ) - pAuftrag.rModellVersatzVorne );
          Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;

        END_IF
        Antrieb.wpBetriebsart     := RESTWEG;

        steplEintransportRueckwaertig := STEP_410_E;

      ELSE
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT_RESTWEGPOSITIONIERUNG;

        steplEintransportRueckwaertig := STEP_900_E;

      END_IF


    // EINTRANSPORT ==============================
    STEP_410_E:

      bprtScheibe := FALSE;

      IF ( bpSensorAuslauf ) THEN
        rlPositionScheibenAnfangErkannt := rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        steplEintransportRueckwaertig := STEP_420_E;
      END_IF

      (* Hinweis:
         - Geschwindigkeit verringern
      *)
      IF ( ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung)
           AND NOT blReduzierteGeschwindigkeit )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      // Vorabstop- Sensor:
      //   - Geschwindigkeit reduzieren
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor schaltet nicht (Unterscheidung ob es die erste Scheibe ist oder eine weitere )
         - Einlaufsensor wird belegt
      *)
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

      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_420_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler = 1 ) THEN
          IF ( ABS( rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition) >= rlStreckeBisZurVerzoegerung ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit25;
          END_IF

        END_IF

      ELSE
        Antrieb.rpGeschwindigkeit := rlGeschwindigkeitEintransport;

      END_IF

      (* Hinweis:
         - Geschwindigkeit verringern
      *)
      IF ( ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung)
           AND NOT blReduzierteGeschwindigkeit )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      // Vorabstop- Sensor:
      //   - Geschwindigkeit reduzieren
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF


      IF ( NOT toflAuslaufsensorFrei.Q ) THEN

        ilScheibenZaehler := ( ilScheibenZaehler - 1 );
        bprtScheibe := TRUE;

        IF ( ilScheibenZaehler <= 0 ) THEN

          bpFreigabeQuerfahrt := TRUE;

        END_IF

        steplEintransportRueckwaertig := STEP_430_E;
      END_IF

      IF ( Antrieb.bpDone AND NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpSensorAuslauf ) THEN
          blScheibenMerker := TRUE;
          rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
          steplEintransportRueckwaertig := STEP_440_E;
        ELSE
          rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - Antrieb.rpIstPosition);
          steplEintransportRueckwaertig := STEP_1000_E;
        END_IF

      END_IF


      (* Fehlerbehandlung:
         - Einlaufsensor belegt
         - Antrieb
      *)
      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_430_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler = 1 ) THEN
          IF ( ABS( rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition) >= rlStreckeBisZurVerzoegerung ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit25;
          END_IF

        END_IF

      ELSE
        Antrieb.rpGeschwindigkeit := rlGeschwindigkeitEintransport;

      END_IF

      (* Hinweis:
         - Geschwindigkeit verringern
      *)
      IF ( ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung)
           AND NOT blReduzierteGeschwindigkeit )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      // Vorabstop- Sensor:
      //   - Geschwindigkeit reduzieren
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      IF bprtScheibe THEN
        dwpWartezeit := 0;
      END_IF

      bprtScheibe := FALSE;

      IF ( bpSensorAuslauf ) THEN
        steplEintransportRueckwaertig := STEP_420_E;
      END_IF

      IF ( Antrieb.bpDone ) THEN

        IF ( bpSensorAuslauf ) THEN
          blScheibenMerker := TRUE;
        END_IF

        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplEintransportRueckwaertig := STEP_440_E;

      END_IF


      (* Fehlerbehandlung:
         - Einlaufsensor belegt
         - Antrieb
      *)
      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_440_E:
      bprtScheibe := FALSE;
      dwpWartezeit := 0;

      (* Hinweis:
         - Scheibe liegt im Uebergang (Eingangssensor und Sensor des Partners belegt): nicht freifahren, fertig
      *)
      IF ( bpSensorAuslauf AND InGlasTransportNachfolger.bEinlaufsensor ) THEN

        IF ( blScheibenMerker ) THEN
          blScheibenMerker := FALSE;
          bprtScheibe := TRUE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpOutBereitZumEintransport := FALSE;

        rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - Antrieb.rpIstPosition);

        steplEintransportRueckwaertig := STEP_1000_E;

      ELSIF ( NOT toflAuslaufsensor.Q ) THEN

        IF ( blScheibenMerker ) THEN
          blScheibenMerker := FALSE;
          bprtScheibe := TRUE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpOutBereitZumEintransport := FALSE;

        rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - Antrieb.rpIstPosition);

        steplEintransportRueckwaertig := STEP_1000_E;

      ELSIF ( toflAuslaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;

      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Einlaufsensor belegt
         - Antrieb
      *)
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
    bpDone                                 := FALSE;
    bprtScheibe                            := FALSE;
    blScheibenMerker                       := FALSE;
    bpOutBereitZumEintransport             := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplEintransportRueckwaertig := STEP_0_E;
  END_IF
END_IF
END_ACTION