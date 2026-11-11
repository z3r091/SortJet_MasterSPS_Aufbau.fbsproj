(* METADATA
{
	"v3Meta": {
		"objectGuid": "be9bb2a6-ff1f-49f3-93cb-838a39542131"
	}
}
*)
ACTION Eintransport_Rueckwaertig
//-------------------------------------------------------------------------------------------------
// AKTION: EINTRANSPORT RÜCKWÄRTIG
//-------------------------------------------------------------------------------------------------

rtlMessungOK( CLK := Antrieb.bpMessungOk );

IF ( rtlMessungOK.Q AND ( ilIndexScheibenmessung <= 10 ) AND bpOptionScheibenmessungEintransport ) THEN
  rlScheibenmessung[ilIndexScheibenmessung] := Antrieb.rpMessErgebnis;
  ilIndexScheibenmessung := ilIndexScheibenmessung + 1;
END_IF

IF ( bpEintransportRueckwaertig
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplEintransportRueckwaertig := STEP_900_E;
  END_IF

  IF ( Antrieb_Slave.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplEintransportRueckwaertig := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler ) THEN
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplEintransportRueckwaertig := STEP_900_E;
  END_IF


  // Ausnahmesituation:
  //   - Slave-Kopplung waehrend der Kette verloren
  IF ( NOT blAntriebsKopplungAktiv AND ( steplEintransportRueckwaertig > STEP_0_E ) AND ( steplEintransportRueckwaertig < STEP_900_E ) ) THEN
    wpFehlerNr := cMELDUNG_EINTRANSPORT_SLAVE_KOPPLUNG_VERLOREN;
    steplEintransportRueckwaertig := STEP_900_E;
  END_IF

  CASE steplEintransportRueckwaertig OF
    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_0_E:
      (* Hinweis:
         - Variablen setzen
           => Scheibenzaehler
           => Lokale Antriebsfreigabe fuer die Glastransport
      *)
      bpDone                        := FALSE;
      bprtScheibe                   := FALSE;
      blScheibenMerker              := FALSE;
      bpFreigabeFremdprozess        := FALSE;
      bpUebergrosseScheibeUebergang := FALSE;

      ilIndexScheibenmessung  := 1;
      FOR wlIndex := 1 TO 10 DO
        rlScheibenmessung[wlIndex] := 0.0;
      END_FOR

      tonlAntriebNichtBetriebsBereit ( IN:= FALSE);
      tonlMaximaleZeitEinlaufsensorFreiFahren ( IN:= FALSE);
      tonlMaximaleZeitAuslaufsensorFreiFahren ( IN:= FALSE);
      tonlSchrittueberwachung( IN := FALSE );
      tonlMaximaleZeitSensorAnfahren( IN := FALSE );

      rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge  := pAuftrag.rAuftragsLaenge,
                                               rpGlasbreite  := pAuftrag.rAuftragsHoehe,
                                               rpGlasstaerke := pAuftrag.rAuftragsDicke ) );

      blReduzierteGeschwindigkeit := ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht );

      // Zeit für Statistik
      tlWarteZeitAufnahme := TIME();

      // Keine Refernezfahrt bei Slave Antrieb
      // Sicherstellen das die Slavekopplung aktiv ist
      //   - Mit Slave auf die Kopplung warten, nicht den gekoppelten Master referenzieren (wie Eintransport)
      IF ( bpOptionSlaveAntrieb ) THEN
        IF ( blAntriebsKopplungAktiv ) THEN
          steplEintransportRueckwaertig := STEP_20_E;
        END_IF
      ELSE
        // Antrieb nur referenzieren wenn Schwellwert überschritten oder nicht referenziert
        IF ( ABS(Antrieb.rpIstPosition) > rgSchwellwertReferenzieren ) OR NOT Antrieb.bpIstReferenziert THEN
          Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
          steplEintransportRueckwaertig := STEP_10_E;
        ELSE
          steplEintransportRueckwaertig := STEP_20_E;
        END_IF
      END_IF

    // EINTRANSPORT ====================
    STEP_10_E:
      (* Hinweis:
         - Antrieb ist referenziert
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransportRueckwaertig := STEP_20_E;
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_20_E:
      // ---------------------------------------------------------------------------------------
      //  KOPPLUNG ZWISCHEN DEN STATIONEN
      //
      //  Hinweis:
      // - Warten bis die Vorgaengerstation breit zum Austransport ist
      // ---------------------------------------------------------------------------------------

      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit   := ppAntriebsInformationen.rpMaxGeschwindigkeit;

      IF ( InGlasTransportNachfolger.bBereitZumAustransport ) THEN
        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeitAufnahme);
        ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

        steplEintransportRueckwaertig := STEP_100_E;
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  EINTRANSPORT UEBER DEN AUSLAUFSENSOR
      //
      //  Hinweis:
      // - Transport in "Negative" Richtung
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Wird die Scheibenbeladung getrennt, berechnen ab welcher Strecke der Antrieb seine
           Geschwindigkeit reduzieren muss
      *)
      IF ( bpScheibentrennen ) THEN

        rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                       rpRampe                := ppAntriebsInformationen.rpMaxVerzoegerung,
                                                                       rpGeschwindigkeit      := ppAntriebsInformationen.rpMaxGeschwindigkeit,
                                                                       rpTrennGeschwindigkeit := rgGeschwindigkeit25 );
      END_IF

      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      // Antriebsposition merken
      rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

      IF ( NOT bpSensorAuslauf ) THEN

        IF ( pAuftrag.bLetzteScheibe ) THEN

          (* Hinweis:
             - Lage der letzten Scheibe laut Konfiguration (eGlastransport), Seiten physisch
               => Auf Einlauf: Scheibe faehrt um rWegUeberEinlaufAustransport ueber den Einlaufsensor (Ende der Fahrt)
               => Auf Auslauf: Scheibe bleibt um rWegUeberAuslaufAustransport auf dem Auslaufsensor liegen (Laenge - Weg)
               => Vorab-Optionen: Scheibe bleibt am Eingang (Auslauf) stehen (gesammelt), positioniert wird erst bei der Vorabpositionierung
             - Einzelscheibe (erste und letzte Scheibe) bei AufEinlaufVorab: direkt um rWegEinlaufsensorZuVorStopSensor auf den Vorab-Sensor
             - Ziel = Flankenposition + Zielwert, rueckwaerts deshalb negativ
          *)
          CASE pAuftrag.stAuftragsOptionen.eGlastransport OF

            eGlastransport_AufEinlaufVorab:
              IF ( pAuftrag.bErsteScheibe ) THEN
                // Einzelscheibe: vom Auslaufsensor (Eingang rueckwaerts) direkt auf den Vorab-Sensor am Einlauf
                Antrieb.rpZielPosition := - ( ppParameterBaustein.rWegEinlaufsensorZuVorStopSensor - pAuftrag.rModellVersatzVorne );
                Antrieb.wpRestwegMode  := Negativ_Steigend_Sensor2;
              ELSE
                Antrieb.rpZielPosition := - (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberAuslaufEintransport ) - pAuftrag.rModellVersatzVorne);
                Antrieb.wpRestwegMode  := Negativ_Steigend_Sensor2;
              END_IF

            eGlastransport_AufAuslaufVorab:
              Antrieb.rpZielPosition := - (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberAuslaufEintransport ) - pAuftrag.rModellVersatzVorne);
              Antrieb.wpRestwegMode  := Negativ_Steigend_Sensor2;

            eGlastransport_AufAuslauf:
              Antrieb.rpZielPosition := - ( pAuftrag.rAuftragsLaenge - ppParameterBaustein.rWegUeberAuslaufAustransport - pAuftrag.rModellVersatzVorne );
              Antrieb.wpRestwegMode  := Negativ_Steigend_Sensor2;

            eGlastransport_AufEinlauf:
              Antrieb.rpZielPosition := - ( ppParameterBaustein.rWegUeberEinlaufAustransport - pAuftrag.rModellVersatzVorne );
              Antrieb.wpRestwegMode  := Negativ_Steigend_Sensor1;

          ELSE
            // Fehlende Konfiguration: Lage der letzten Scheibe (eGlastransport) ist nicht gesetzt
            wpFehlerNr := cMELDUNG_EINTRANSPORT_GLASTRANSPORT_OPTION_NICHT_KONFIGURIERT;
            steplEintransportRueckwaertig := STEP_900_E;
          END_CASE

        ELSE
          Antrieb.rpZielPosition  := - (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberAuslaufEintransport ) - pAuftrag.rModellVersatzVorne);
          Antrieb.wpRestwegMode   := Negativ_Steigend_Sensor2;
        END_IF

        IF ( steplEintransportRueckwaertig <> STEP_900_E ) THEN
          Antrieb.wpBetriebsart := RESTWEG;

          steplEintransportRueckwaertig := STEP_110_E;
        END_IF

      ELSE
        Antrieb.rpGeschwindigkeit   := rgGeschwindigkeit20;
        Antrieb.rpVerzoegerung      := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung    := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.wpBetriebsart := HANDMINUS;
        steplEintransportRueckwaertig := STEP_110_E;
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_110_E:
      IF ( bpSensorEinlaufVorAb ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      // Sicherstellen das der Einlaufsensor auch überfahren wurde
      IF ( bpSensorAuslauf ) THEN
        bprtScheibe := FALSE;
        rlPositionScheibenAnfangErkannt := rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
        steplEintransportRueckwaertig := STEP_120_E;
      END_IF

      // Ausnahmesituation
      //   - Einlaufsensor schaltet nicht
      //   - Auslaufsensor wird belegt
      IF ( pAuftrag.bErsteScheibe ) THEN

        (* Hinweis:
           - Die erste Scheibe kann irgendwo auf der Nachfolgerstation stehen: Laenge der Nachfolgerstation
           - Ohne bekannte Nachfolgerlaenge (z. B. Fremdanlage) gilt die eigene Stationslaenge
        *)
        rlMaxStreckeErsteScheibe := InGlasTransportNachfolger.rLaengeStation;
        IF ( rlMaxStreckeErsteScheibe <= 0.0 ) THEN
          rlMaxStreckeErsteScheibe := ppParameterBaustein.rLaengeStation;
        END_IF
        IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > rlMaxStreckeErsteScheibe ) THEN
          Antrieb.wpBetriebsart := KEINE_FUNKTION;
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
          steplEintransportRueckwaertig := STEP_900_E;
        END_IF

      ELSE

        IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition)
             >  (ppParameterBaustein.rUeberwachungEinlaufsensor) )
        THEN
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
          steplEintransportRueckwaertig := STEP_900_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor
      *)
      IF ( tonlEinlaufsensor.Q ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_120_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennen ) THEN

        IF (  ilScheibenZaehler = 1 ) THEN

          IF ( ( ABS(rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition) >= rlStreckeBisZurVerzoegerung ) )  THEN
            IF blReduzierteGeschwindigkeit THEN
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
            ELSE
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit25;
            END_IF
          END_IF

        ELSE
          IF blReduzierteGeschwindigkeit THEN
            Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
          ELSE
            Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
          END_IF

        END_IF

      END_IF

      // Geschwindigkeit reduzieren
      IF ( bpSensorEinlaufVorAb ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      bprtScheibe := FALSE;

      IF ( NOT toflAuslaufsensor.Q ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;
        steplEintransportRueckwaertig := STEP_130_E;
      END_IF


      (* Hinweis:
         - Es kann passieren aufgrund von falschen Scheibendaten das Glas auf dem Einlaufsensor stehen bleibt nach dem Positionieren.
           Merken das sich noch eine Scheibe auf dem Sensor zum quittieren der Scheibe befindet.
      *)
      IF ( Antrieb.bpDone
           AND toflAuslaufsensor.Q ) OR ( Antrieb.wpBetriebsart = HANDMINUS AND bpSensorAuslaufVorAb )
      THEN
        blScheibenMerker := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        Antrieb.rpGeschwindigkeit := 0.0;
        steplEintransportRueckwaertig := STEP_140_E;
      END_IF


      (* Fehlerbehandlung:
         - Einlaufsensor
      *)
      IF ( tonlEinlaufsensor.Q ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_130_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennen ) THEN

        IF (  ilScheibenZaehler = 1 ) THEN

          IF ( ( ABS(rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition) >= rlStreckeBisZurVerzoegerung )) THEN
            IF blReduzierteGeschwindigkeit THEN
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
            ELSE
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit25;
            END_IF
          END_IF

        ELSE
          IF blReduzierteGeschwindigkeit THEN
            Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
          ELSE
            Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
          END_IF

        END_IF

      END_IF

      // Geschwindigkeit reduzieren
      IF ( bpSensorEinlaufVorAb ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
      END_IF

      // Wartezeit zuruecksetzen wenn mehrere Scheiben eingefahren werden
      IF ( bprtScheibe ) THEN
        dwpWartezeit := 0;
      END_IF

      bprtScheibe := FALSE;

      IF ( tonlAuslaufsensor.Q ) THEN // entprellt: Flackern quittiert keine zweite Scheibe
        steplEintransportRueckwaertig := STEP_120_E;
      END_IF

      // Freigabe für den Fremdprozess
      IF ( ( ilScheibenZaehler <= 0 )
           AND NOT bpSensorEinlauf
           AND NOT toflAuslaufsensor.Q )
      THEN
        bpFreigabeFremdprozess := TRUE;
      END_IF

      IF ( Antrieb.bpDone ) OR ( Antrieb.wpBetriebsart = HANDMINUS AND bpSensorEinlaufVorAb )   THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        Antrieb.rpGeschwindigkeit := 0.0;
        steplEintransportRueckwaertig := STEP_140_E;
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor
      *)
      IF ( tonlEinlaufsensor.Q ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_140_E:
      (* Hinweis:
         - Sicherstellen das der Antrieb steht
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        IF ( tonlEinlaufsensor.Q ) THEN
          tonlMaximaleZeitAuslaufsensorFreiFahren ( IN:= FALSE);
          steplEintransportRueckwaertig := STEP_300_E;
        ELSE
          tonlMaximaleZeitAuslaufsensorFreiFahren ( IN:= FALSE );
          IF (     bpSensorAuslauf
               OR ( bpSensorAuslauf AND InGlasTransportNachfolger.bEinlaufsensor ) )
             AND bpSensorEinlaufVorAb
          THEN
            bpUebergrosseScheibeUebergang := TRUE;
            IF blScheibenMerker THEN
              bprtScheibe := TRUE;
              blScheibenMerker := FALSE;
            END_IF
            steplEintransportRueckwaertig := STEP_1000_E;
          ELSE
            steplEintransportRueckwaertig := STEP_200_E;
          END_IF
        END_IF
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  AUSLAUFLAUFSENSOR FREI FAHREN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      tonlMaximaleZeitAuslaufsensorFreiFahren ( IN:= bpSensorAuslauf, PT :=T#10S );

      bprtScheibe := FALSE;

      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflAuslaufsensor.Q )
      THEN

        IF ( blScheibenMerker ) THEN
          bprtScheibe := TRUE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransportRueckwaertig := STEP_210_E;

      END_IF

      IF ( toflAuslaufsensor.Q )THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung:
         - Einlaufsnesor belegt (Maximal Glas - Sensor auf der Fremdanlage)
         - Zeit- Ueberwachung
      *)
      IF ( tonlEinlaufsensor.Q ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

      IF ( tonlMaximaleZeitAuslaufsensorFreiFahren.Q ) THEN
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_210_E:
      (* Anmerkung:
         - Pruefen ob nicht noch eine Scheibe auf dem Einlaufsensor liegt.
           Sonst versuchen den Sensor frei zufahren
         - Merken der Eintransportstrecke
      *)
      bprtScheibe := FALSE;

      IF (  NOT bpSensorAuslauf
           AND NOT InGlasTransportNachfolger.bEinlaufsensor )
      THEN
        bpOutBereitZumEintransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransportRueckwaertig := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Uberwachung
      *)
      tonlSchrittueberwachung( IN := TRUE,
                               PT := T#5s );

      IF ( tonlSchrittueberwachung.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_300_E:
      (* Anmerkung:
         - -Einlaufsensor freifahren
      *)
      tonlMaximaleZeitEinlaufsensorFreiFahren ( IN:= bpSensorAuslauf, PT :=T#10S );

      bprtScheibe := FALSE;

      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflEinlaufsensor.Q )
      THEN

        IF blScheibenMerker THEN
          bprtScheibe := TRUE;
          blScheibenMerker := FALSE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransportRueckwaertig := STEP_1000_E;
      END_IF

      IF ( toflEinlaufsensor.Q )THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart := HANDPLUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsnesor belegt (Maximal Glas - Sensor auf der Fremdanlage)
         - Zeit- Ueberwachung
      *)
      IF ( bpSensorAuslauf AND NOT ( eGlastyp = eScheibe_Maximal ) ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

      IF ( tonlMaximaleZeitEinlaufsensorFreiFahren.Q ) THEN
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplEintransportRueckwaertig := STEP_900_E;
      END_IF

    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpFehler    := TRUE;
      bprtScheibe := FALSE;

      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;

      bpOutBereitZumEintransport := FALSE;


    // EINTRANSPORT RÜCKWÄRTIG =====================
    STEP_1000_E:
      bpStationBelegt := pAuftrag.bLetzteScheibe;

      bpOutBereitZumEintransport := FALSE;
      bprtScheibe := FALSE;
      bpDone := TRUE;

  // EINTRANSPORT RÜCKWÄRTIG =====================
  END_CASE
ELSE

  IF (steplEintransportRueckwaertig > STEP_0_E) THEN
    bpDone := FALSE;
    bprtScheibe := FALSE;
    bpFreigabeFremdprozess := FALSE;
    bpOutBereitZumEintransport := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
    steplEintransportRueckwaertig := STEP_0_E;
  END_IF

END_IF
END_ACTION