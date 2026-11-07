(* METADATA
{
	"v3Meta": {
		"objectGuid": "56360386-0d3d-4215-b0eb-4981ce1dd4c7"
	}
}
*)
ACTION Eintransport_Default_Luftabfrage
// @TEXT_IMPLEMENTATION := 'ST'
//-------------------------------------------------------------------------------------------------
// AKTION: EINTRANSPORT [DEFAULT- LUFTABFRAGE]
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Abhandlung des Eintransport mit einer default Luftabfrage.

     WICHTIG:
   - Transport in positive Richtung [HANDPLUS]
     => SCHRITT 30
   - Transport in negative Richtung [HANDMINUS]
     => SCHRITT 400
*)
IF (  blEintransportDefaultLuftabfrage
     AND bpAutomatikAktiv )
THEN

  (* Fehlerbehandlung:
     - Antrieb
     - Kopplung Vorgänger
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplEintransportDefaultLuftabfrage := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplEintransportDefaultLuftabfrage := STEP_900_E;
  END_IF

  CASE steplEintransportDefaultLuftabfrage OF
    // EINTRANSPORT ================================
    STEP_0_E:
      (* Anmerkung:
         - Variablen initialisieren
      *)
      blAbgeschlossenEintransport := FALSE;
      bpScheibeFaehrtUeberAuslauf := FALSE;
      bpScheibeFaehrtUeberEinlauf := FALSE;
      bpAnforderungBetriebsstopp  := FALSE;
      bprtScheibe                 := FALSE;
      blScheibenMerker            := FALSE;
      blFehlerAusloesen           := FALSE;

      blMeldungEinlaufAbfrageBelegt       := FALSE;
      blSensorPruefungEinlaufsensorBelegt := FALSE;

      tonlWartenAufAnheben(IN:=FALSE);
      tonlWartenAufSenken(IN:=FALSE);
      tonlEinlaufsensorTesten(IN:= FALSE);
      tonlAuslaufsensorTesten(IN:= FALSE);
      tonlAntriebNichtFreigegeben(IN:=FALSE);

      IF ( Antrieb.bpReglerBereit )THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge  := pAuftrag.rAuftragsLaenge,
                                                 rpGlasbreite  := pAuftrag.rAuftragsHoehe,
                                                 rpGlasstaerke := pAuftrag.rAuftragsDicke ) );

        blReduzierteGeschwindigkeit := ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht );

        steplEintransportDefaultLuftabfrage := STEP_10_E;
      END_IF

    // EINTRANSPORT ================================
    STEP_10_E:
      (* Hinweis:
         - Ueberpruefung ob die Luftsensoren frei sind und richtig durchschalten
           => Einlauf- Auslauf- Sensoren
      *)
      blScheibenKontrolleAuslaufseiteEin := TRUE;
      blScheibenKontrolleEinlaufseiteEin := TRUE;

      tonlEinlaufsensorTesten(IN := NOT bpSensorScheibenKontrolleEinlaufseiteFrei, PT := t#5s);
      tonlAuslaufsensorTesten(IN := NOT bpSensorScheibenKontrolleAuslaufseiteFrei, PT := t#5s);

      IF  ( bpSensorScheibenKontrolleEinlaufseiteFrei
            AND bpSensorScheibenKontrolleAuslaufseiteFrei ) OR bpOptionTransfershuttleMitUltraschallSensoren
      THEN
        steplEintransportDefaultLuftabfrage := STEP_20_E;

      END_IF

      (* Fehlerbehandlung:
         - Einlaufseite frei
         - Auslaufseite frei
      *)
      IF ( tonlEinlaufsensorTesten.Q ) THEN

        IF (  tonlGlastransportOben.Q
             AND tonlKontrolleEinlaufOben.Q
             AND NOT blAuslaufSensor
             AND NOT bpRueckwaertsEintransportieren )
        THEN
          blMeldungEinlaufAbfrageBelegt       := TRUE;
          blSensorPruefungEinlaufsensorBelegt := TRUE;

          steplEintransportDefaultLuftabfrage := STEP_200_E;
        ELSE
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_WIRD_NICHT_FREI;
          steplEintransportDefaultLuftabfrage := STEP_900_E;

        END_IF

      END_IF

      IF ( tonlAuslaufsensorTesten.Q ) THEN
        wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_WIRD_NICHT_FREI;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ================================
    STEP_20_E:
      (* Anmerkung:
         - Transfershuttle heben
         - Einlauf- Auslauf- Sensoren heben
           Die Variable  << blGlastransportUndAbfragenGehoben >> wird gebildet durch:
         - tonlGlastransportOben.Q  | tonlKontrolleEinlaufOben.Q  | blDruckluftAuslaufSeiteOK
           tonlKontrolleAuslaufOben.Q | blDruckluftEinlaufSeiteOK
      *)
      out_bShuttleAnheben := TRUE;
      out_bScheibenKontrolleAuslaufseiteAuf := TRUE;
      out_bScheibenKontrolleEinlaufseiteAuf := TRUE;

      tonlWartenAufAnheben(IN := NOT blBereitZumGlastransport, PT := t#10s);

      IF ( blBereitZumGlastransport ) THEN

        (* Anmerkung:
           - Unterscheidung ob Handplus- bzw. Handminus- Eintransport werden soll
        *)
        steplEintransportDefaultLuftabfrage := SEL( bpRueckwaertsEintransportieren, STEP_100_E , STEP_400_E );

      END_IF


      (* Fehlerbehandlung:
         - Druckluft
         - Glastransport oben
         - Ein- Aus- Laufsensoren
      *)
      IF ( tonlWartenAufAnheben.Q ) THEN

        // Glastransport oben
        IF ( NOT blSensorGlastransportOben ) THEN
          wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_OBEN;
        // Luftsensoren oben
        ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_OBEN;
        // Luftsensoren oben
        ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_OBEN;
        // Druckluft Ok
        ELSIF NOT blDruckluftEinlaufSeiteOK THEN
          wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_EINLAUF_NICHT_OK;
        // Druckluft Ok
        ELSIF ( NOT blDruckluftAuslaufSeiteOK ) THEN
          wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_AUSLAUF_NICHT_OK;
        ELSE
          wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
        END_IF

        steplEintransportDefaultLuftabfrage := STEP_900_E;
        bpOutBereitZumEintransport := FALSE;

      END_IF

    // EINTRANSPORT ================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  EINTRANSPORT HANDPLUS
      //
      //  Hinweis:
      // - Transport in "Positive" Richtung
      // ---------------------------------------------------------------------------------------

      (* Anmerkung:
         - Variablen nullen / zurueck setzen
      *)
      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit  := REAL#0;

      (* Hinweis:
         - Warten bis der Glas-Sender bereit meldet
      *)
      IF IsBetweenWORD(pAuftrag.wTransferstationsNr2, cERSTE_FAECHERWAGENSTATIONS_NR, cLETZTE_FAECHERWAGENSTATIONS_NR) THEN
        IF ( InGlasTransportVorgaenger.bBereitZumAustransport AND InGlasTransportNachfolger.bBereitZumAustransport ) THEN
          steplEintransportDefaultLuftabfrage := STEP_110_E;
        END_IF
      ELSE
        IF ( InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
          steplEintransportDefaultLuftabfrage := STEP_110_E;
        END_IF
      END_IF


    // EINTRANSPORT ==============================
    STEP_110_E:
      (* Hinweis:
         - Berechnung zum Auftrennen von Scheibenbeladungen auf der Vorgaenger-Station [Shuttle etc.]
           => Aktivieren ueber die Transfershuttle- Parameter
      *)
      IF blReduzierteGeschwindigkeit THEN
        rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                       rpRampe                := ppAntriebsInformationen.rpReduzierteVerzoegerung,
                                                                       rpGeschwindigkeit      := ppAntriebsInformationen.rpReduzierteGeschwindigkeit,
                                                                       rpTrennGeschwindigkeit := rgGeschwindigkeit10 );
      ELSE
        rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                       rpRampe                := ppAntriebsInformationen.rpMaxVerzoegerung,
                                                                       rpGeschwindigkeit      := ppAntriebsInformationen.rpMaxGeschwindigkeit,
                                                                       rpTrennGeschwindigkeit := rgGeschwindigkeit15 );
      END_IF

      (* Hinweis:
         - Anzahl Scheiben
      *)
      ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

      // Antrieb verfahren
      //   - Restweg Positionierung
      rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
        Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      rlZielPosition := (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberEinlaufEintransport ) - pAuftrag.rModellVersatzVorne);
      // Kleine Scheiben tiefer in den Speicher reinfahren, da diese Gefahr laufen, beim Fächerwagen schieben rauszufallen
      IF bpOptionTransfershuttleMitFaecherwagen AND bpOptionTransfershuttleFaecherwagenKurzeScheibenTieferEintransportieren AND ( pAuftrag.rAuftragsLaenge < ( starrTransfershuttleBasisParameter[stStationsNummern.NummerSPS].stMKs.stGlasdaten[cWAND_1].rlMaxGlasLaenge / 2 ) ) THEN
        rlZielPosition := rlZielPosition + 150.0;
      END_IF
      Antrieb.rpZielPosition    := rlZielPosition;

      IF bpOptionTransfershuttleMitUltraschallSensoren THEN
        Antrieb.wpRestwegMode := Positiv_Steigend_Sensor1;
      ELSE
        Antrieb.wpRestwegMode := Positiv_Fallend_Sensor1;
      END_IF

      Antrieb.wpBetriebsart := RESTWEG;

      steplEintransportDefaultLuftabfrage := STEP_140_E;

    // EINTRANSPORT ==============================
    STEP_140_E:
      // Antrieb verfahren
      //   - Ueberwachen des Einlaufsensors
      bprtScheibe := FALSE;

      IF ( blEinlaufsensor ) THEN
        rlPositionScheibenAnfangErkannt := Antrieb.rpIstPosition;
        steplEintransportDefaultLuftabfrage := STEP_150_E;
      END_IF


      // Ausnahmesituation:
      //   - Auslaufsensor angefahren
      IF ( blAuslaufSensor ) THEN

        bpScheibeFaehrtUeberAuslauf := TRUE;
        bpOutBereitZumEintransport  := FALSE;

        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;

        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        blFehlerAusloesen := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_ODER_AUSLAUF_BELEGT_FREIFAHREN;

        steplEintransportDefaultLuftabfrage := STEP_300_E;

      END_IF

      (* Fehlerbehandlung:
         - Weg- Ueberwachung
      *)
      // Die Scheibe kann irgendwo auf der Vorgaengerstation stehen (ohne bekannte Vorgaengerlaenge: eigene Stationslaenge)
      rlMaxStreckeErsteScheibe := InGlasTransportVorgaenger.rLaengeStation;
      IF ( rlMaxStreckeErsteScheibe <= 0.0 ) THEN
        rlMaxStreckeErsteScheibe := ppParameterBaustein.rlLaengeStation;
      END_IF
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > rlMaxStreckeErsteScheibe ) THEN
        bpOutBereitZumEintransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_150_E:
      bprtScheibe := FALSE;

      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler <= 1 ) THEN
          IF ( ABS( rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition) >= rlStreckeBisZurVerzoegerung ) THEN
            IF blReduzierteGeschwindigkeit THEN
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
            ELSE
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
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

      // Scheibenquittung: Einlaufsensor frei => Scheibe ist auf dem TS
      IF ( toflEinlaufsensor.Q ) THEN // Frei-Signal
        bprtScheibe       := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;
        steplEintransportDefaultLuftabfrage := STEP_160_E;
      END_IF

      (* Hinweis:
         - Antrieb verfahren
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        blScheibenMerker       := NOT toflEinlaufsensor.Q;
        steplEintransportDefaultLuftabfrage := STEP_190_E;
      END_IF

      // Ausnahmesituation:
      //   - Auslaufsensor angefahren
      IF ( blAuslaufSensor ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        bpOutBereitZumEintransport  := FALSE;

        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        blScheibenMerker := NOT toflEinlaufsensor.Q;

        steplEintransportDefaultLuftabfrage := STEP_300_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_160_E:
      // Hinweis:
      // - Scheibe quittiert, auf die naechste Scheibe am Einlauf oder das Ende der Positionierung warten
      bprtScheibe := FALSE;

      // Geschwindigkeit reduzieren, wenn die Scheibenbeladung getrennt werden muss
      IF ( bpScheibentrennung ) THEN

        IF ( ilScheibenZaehler <= 1 ) THEN
          IF ( ABS( rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition ) >= rlStreckeBisZurVerzoegerung ) THEN
            IF blReduzierteGeschwindigkeit THEN
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
            ELSE
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
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

      IF ( blEinlaufSensor ) THEN
        steplEintransportDefaultLuftabfrage := STEP_150_E;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        blScheibenMerker       := NOT toflEinlaufsensor.Q;
        steplEintransportDefaultLuftabfrage := STEP_190_E;
      END_IF

      // Ausnahmesituation: Auslaufsensor angefahren
      IF ( blAuslaufSensor ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        bpOutBereitZumEintransport  := FALSE;
        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        blScheibenMerker := NOT toflEinlaufsensor.Q;
        steplEintransportDefaultLuftabfrage := STEP_300_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_190_E:
      bprtScheibe := FALSE;

      (* Hinweis:
         - Antrieb steht
           => Ueberpruefen des Einlaufsensors
      *)
      IF ( NOT toflAntriebLaeuft.Q ) THEN

        IF ( blEinlaufsensor ) THEN
          Antrieb.wpBetriebsart := KEINE_FUNKTION;
          rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

          steplEintransportDefaultLuftabfrage := STEP_200_E;

        ELSE
          Antrieb.wpBetriebsart :=KEINE_FUNKTION;
          steplEintransportDefaultLuftabfrage := STEP_800_E;

        END_IF

      END_IF

      // Ausnahmesituation:
      //   - Auslaufsensor angefahren
      IF ( blAuslaufSensor ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransportDefaultLuftabfrage := STEP_300_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  EINLAUFSENSOR FREIFAHREN
      //
      //  Hinweis:
      //  - Einlaufsensor belegt und diesen frei fahren
      // ---------------------------------------------------------------------------------------

      bprtScheibe := FALSE;
      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT blEinlaufSensor )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        // Scheibenquittung: Scheibe lag nach dem Positionieren noch auf dem Einlaufsensor
        IF ( blScheibenMerker ) THEN
          bprtScheibe       := TRUE;
          ilScheibenZaehler := ilScheibenZaehler - 1;
          blScheibenMerker  := FALSE;
        END_IF

        (* Hinweis:
           - Sensorik war beim pruefen belegt ( Vorabanheben )
        *)
        IF ( blSensorPruefungEinlaufsensorBelegt ) THEN
          tonlEinlaufsensorTesten(IN:= FALSE);
          tonlAuslaufsensorTesten(IN:= FALSE);

          blMeldungEinlaufAbfrageBelegt       := FALSE;
          blSensorPruefungEinlaufsensorBelegt := FALSE;

          steplEintransportDefaultLuftabfrage := STEP_10_E;

        ELSE
          steplEintransportDefaultLuftabfrage := STEP_800_E;

        END_IF

      END_IF

      IF ( NOT tonlEinlaufWirklichFrei.Q )THEN

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        rlZielPosition := ( ppParameterBaustein.rWegUeberEinlaufEintransport - pAuftrag.rModellVersatzVorne);
        Antrieb.rpZielPosition    := rlZielPosition;
        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
        ELSE
          Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
        END_IF

        Antrieb.wpBetriebsart := RESTWEG;

        steplEintransportDefaultLuftabfrage := STEP_210_E;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      // Ausnahmesituation:
      //   - Auslaufsensor angefahren
      //   - Wegstrecke überfahren
      IF ( blAuslaufSensor ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        bpAnforderungBetriebsstopp  := TRUE;

        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        wpFehlerNr := SEL( blEinlaufSensor, cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT, cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT );
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rMaxPosEinlaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_210_E:
      // Ausnahmesituation:
      //   - Auslaufsensor angefahren
      //   - Wegstrecke überfahren
      (* Hinweis:
         - Antrieb verfahren
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        steplEintransportDefaultLuftabfrage := STEP_200_E;
      END_IF

      IF ( blAuslaufSensor ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        bpAnforderungBetriebsstopp  := TRUE;

        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        wpFehlerNr := SEL( blEinlaufSensor, cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT, cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT );
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rMaxPosEinlaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_300_E:
      // ---------------------------------------------------------------------------------------
      //  AUSLAUFSENSOR FREIFAHREN
      //
      //  Hinweis:
      //  - Sicherstellen das der Antrieb verfahrbereit ist.
      //    Ueberpruefen der Antriebs-Freigabe und der lokalen Freigabe.
      //    => Hardware- und Software- Freigabe
      // ---------------------------------------------------------------------------------------

      bprtScheibe := FALSE;

      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      IF (  Antrieb.bpAntriebFreigegeben AND NOT Antrieb.bpAntrieblaeuft ) THEN
        rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;
        steplEintransportDefaultLuftabfrage := STEP_310_E;
      END_IF

      // Ueberwachung:
      //   - Zeitliche Ueberwachung des Schritts
      tonlAntriebNichtFreigegeben( IN := TRUE,
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        bpAnforderungBetriebsstopp := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_310_E:
      (* Hinweis:
         - Wenn der Antrieb nicht mehr dreht Versuchen dem Sensor frei zu fahren
      *)
      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT blAuslaufSensor )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        // Scheibenquittung: Scheibe lag beim Ueberfahren noch auf dem Einlaufsensor
        IF ( NOT blFehlerAusloesen AND blScheibenMerker ) THEN
          bprtScheibe       := TRUE;
          ilScheibenZaehler := ilScheibenZaehler - 1;
          blScheibenMerker  := FALSE;
        END_IF

        IF ( NOT blFehlerAusloesen ) THEN
          SpsWarnung( eFehler_Station,
                      cMELDUNG_SENSOR_EINLAUF_ODER_AUSLAUF_WURDE_BELEGT,
                      stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(stStationsNummern.NummerSPS),
                      starrTransfershuttleBasisParameter[stStationsNummern.NummerIntern].awFehlerInformationen );
        END_IF

        steplEintransportDefaultLuftabfrage := SEL(blFehlerAusloesen,STEP_800_E, STEP_900_E );
      END_IF

      IF ( blAuslaufSensor )THEN

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
          Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
          Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      // Ausnahmesituation:
      //   - Einlaufsensor angefahren
      //   - Wegstrecke überfahren
      IF ( blEinlaufSensor ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( blAuslaufSensor ) THEN
          bpAnforderungBetriebsstopp := TRUE;
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        END_IF

        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rMaxPosAuslaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpAnforderungBetriebsstopp := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ==================================
    STEP_400_E:
      // ---------------------------------------------------------------------------------------
      //  EINTRANSPORT HANDMINUS
      //
      //  Hinweis:
      // - Transport in "Negative" Richtung
      // ---------------------------------------------------------------------------------------

      (* Anmerkung:
         - Variablen nullen / zurueck setzen
      *)
      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit  := REAL#0;

      (* Hinweis:
         - Warten bis der Glas-Empfaenger bereit meldet
      *)
      IF IsBetweenWORD(pAuftrag.wTransferstationsNr2, cERSTE_FAECHERWAGENSTATIONS_NR, cLETZTE_FAECHERWAGENSTATIONS_NR) THEN
        wpFehlerNr := cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_STATION;
        bpFehler := TRUE;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      ELSE
        IF ( InGlasTransportNachfolger.bBereitZumAustransport ) THEN
          steplEintransportDefaultLuftabfrage := STEP_410_E;
        END_IF
      END_IF

    // EINTRANSPORT ==================================
    STEP_410_E:
      (* Hinweis:
         - Berechnung zum Auftrennen von Scheibenbeladungen auf der Vorgaenger-Station [Shuttle etc.]
           => Aktivieren ueber die Transfershuttle- Parameter
      *)
      IF blReduzierteGeschwindigkeit THEN
        rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                       rpRampe                := ppAntriebsInformationen.rpReduzierteVerzoegerung,
                                                                       rpGeschwindigkeit      := ppAntriebsInformationen.rpReduzierteGeschwindigkeit,
                                                                       rpTrennGeschwindigkeit := rgGeschwindigkeit10 );
      ELSE
        rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                       rpRampe                := ppAntriebsInformationen.rpMaxVerzoegerung,
                                                                       rpGeschwindigkeit      := ppAntriebsInformationen.rpMaxGeschwindigkeit,
                                                                       rpTrennGeschwindigkeit := rgGeschwindigkeit15 );
      END_IF

      (* Hinweis:
         - Anzahl Scheiben
      *)
      ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

      // Antrieb verfahren
      //   - Restweg Positionierung
      rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      rlZielPosition            := - (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberAuslaufEintransport ) - pAuftrag.rModellVersatzVorne);
      Antrieb.rpZielPosition    := rlZielPosition;
      IF bpOptionTransfershuttleMitUltraschallSensoren THEN
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;
      ELSE
        Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
      END_IF

      steplEintransportDefaultLuftabfrage := STEP_420_E;

    // EINTRANSPORT ==============================
    STEP_420_E:
      (* Hinweis:
         - Setzen des Verfahrbefehls
      *)
      IF ( bpFreigabe ) THEN
        Antrieb.wpBetriebsart := RESTWEG;
        steplEintransportDefaultLuftabfrage := STEP_430_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_430_E:
      IF ( blAuslaufsensor ) THEN
        rlPositionScheibenAnfangErkannt := Antrieb.rpIstPosition;
        steplEintransportDefaultLuftabfrage := STEP_440_E;
      END_IF

      // Ausnahmesituation:
      //   - Einlaufsensor angefahren, Fehler da kein Glas vom Shuttle hinzu kam
      IF ( blEinlaufSensor ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        bpOutBereitZumEintransport  := FALSE;

        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;

        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplEintransportDefaultLuftabfrage := STEP_700_E;
      END_IF

      (* Fehlerbehandlung:
         - Weg- Ueberwachung
      *)
      IF (ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rlLaengeStation) THEN
        bpOutBereitZumEintransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_440_E:
      bprtScheibe := FALSE;

      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler <= 1 ) THEN
          IF ( ABS( rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition) >= rlStreckeBisZurVerzoegerung ) THEN
            IF blReduzierteGeschwindigkeit THEN
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
            ELSE
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
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

      // Scheibenquittung: Auslaufsensor (Einlauf in Rueckwaertsrichtung) frei => Scheibe ist auf dem TS
      IF ( toflAuslaufsensor.Q ) THEN // Frei-Signal
        bprtScheibe       := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;
        steplEintransportDefaultLuftabfrage := STEP_445_E;
      END_IF

      (* Hinweis:
         - Antrieb verfahren
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        blScheibenMerker       := NOT toflAuslaufsensor.Q;
        steplEintransportDefaultLuftabfrage := STEP_450_E;
      END_IF

      // Ausnahmesituation:
      //   - Einlaufsensor angefahren
      IF ( blEinlaufSensor ) THEN
        bpOutBereitZumEintransport  := FALSE;
        bpScheibeFaehrtUeberEinlauf := TRUE;
        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        blScheibenMerker := NOT toflAuslaufsensor.Q;
        steplEintransportDefaultLuftabfrage := STEP_600_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_445_E:
      // Hinweis:
      // - Scheibe quittiert, auf die naechste Scheibe am Auslauf oder das Ende der Positionierung warten
      bprtScheibe := FALSE;

      // Geschwindigkeit reduzieren, wenn die Scheibenbeladung getrennt werden muss
      IF ( bpScheibentrennung ) THEN

        IF ( ilScheibenZaehler <= 1 ) THEN
          IF ( ABS( rlPositionScheibenAnfangErkannt - Antrieb.rpIstPosition ) >= rlStreckeBisZurVerzoegerung ) THEN
            IF blReduzierteGeschwindigkeit THEN
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
            ELSE
              Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
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

      IF ( blAuslaufSensor ) THEN
        steplEintransportDefaultLuftabfrage := STEP_440_E;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        blScheibenMerker       := NOT toflAuslaufsensor.Q;
        steplEintransportDefaultLuftabfrage := STEP_450_E;
      END_IF

      // Ausnahmesituation: Einlaufsensor angefahren
      IF ( blEinlaufSensor ) THEN
        bpOutBereitZumEintransport  := FALSE;
        bpScheibeFaehrtUeberEinlauf := TRUE;
        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        blScheibenMerker := NOT toflAuslaufsensor.Q;
        steplEintransportDefaultLuftabfrage := STEP_600_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_450_E:
      bprtScheibe := FALSE;

      (* Hinweis:
         - Antrieb steht
           => Ueberpruefen des Auslaufsensors der nun als Einlauf fungiert
      *)
      IF ( NOT toflAntriebLaeuft.Q ) THEN

        IF ( blAuslaufsensor ) THEN
          Antrieb.wpBetriebsart :=KEINE_FUNKTION;
          rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

          steplEintransportDefaultLuftabfrage := STEP_500_E;

        ELSE
          Antrieb.wpBetriebsart :=KEINE_FUNKTION;
          steplEintransportDefaultLuftabfrage := STEP_800_E;

        END_IF

      END_IF

      // Ausnahmesituation:
      //   - Einlaufsensor angefahren, Scheibe steht über zum Input
      IF ( blEinlaufSensor ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransportDefaultLuftabfrage := STEP_600_E;
      END_IF


    // EINTRANSPORT ==============================
    STEP_500_E:
      // ---------------------------------------------------------------------------------------
      //  AUSLAUFSENSOR FREIFAHREN
      //
      //  Hinweis:
      //  - Auslaufsensor belegt und diesen frei fahren
      // ---------------------------------------------------------------------------------------

      bprtScheibe := FALSE;
      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT blAuslaufSensor )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        // Scheibenquittung: Scheibe lag nach dem Positionieren noch auf dem Auslaufsensor
        IF ( blScheibenMerker ) THEN
          bprtScheibe       := TRUE;
          ilScheibenZaehler := ilScheibenZaehler - 1;
          blScheibenMerker  := FALSE;
        END_IF

        steplEintransportDefaultLuftabfrage := STEP_800_E;
      END_IF

      IF ( blAuslaufSensor )THEN

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart    := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      // Ausnahmesituation:
      //   - Auslaufsensor angefahren
      //   - Wegstrecke überfahren
      IF ( blEinlaufSensor ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        bpAnforderungBetriebsstopp  := TRUE;

        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        wpFehlerNr := SEL( blAuslaufSensor, cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT, cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT );
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rMaxPosEinlaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_600_E:
      // ---------------------------------------------------------------------------------------
      //  EINLAUFSENSOR FREIFAHREN
      //
      //  Hinweis:
      //  - Sicherstellen das der Antrieb verfahrbereit ist.
      //    Ueberpruefen der Antriebs-Freigabe und der lokalen Freigabe.
      //    => Hardware- und Software- Freigabe
      // ---------------------------------------------------------------------------------------

      bprtScheibe := FALSE;

      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      IF (  Antrieb.bpAntriebFreigegeben
           AND NOT Antrieb.bpAntrieblaeuft )
      THEN
        rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;
        steplEintransportDefaultLuftabfrage := STEP_610_E;
      END_IF

      // Ueberwachung:
      //   - Zeitliche Ueberwachung des Schritts
      tonlAntriebNichtFreigegeben( IN := TRUE,
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        bpAnforderungBetriebsstopp := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_610_E:
      (* Hinweis:
         - Wenn der Antrieb nicht mehr dreht Versuchen dem Sensor frei zu fahren
      *)
      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT blEinlaufSensor )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        // Scheibenquittung: Scheibe lag beim Ueberfahren noch auf dem Auslaufsensor
        IF ( NOT blFehlerAusloesen AND blScheibenMerker ) THEN
          bprtScheibe       := TRUE;
          ilScheibenZaehler := ilScheibenZaehler - 1;
          blScheibenMerker  := FALSE;
        END_IF

        IF ( NOT blFehlerAusloesen ) THEN
          SpsWarnung( eFehler_Station,
                      cMELDUNG_SENSOR_EINLAUF_ODER_AUSLAUF_WURDE_BELEGT,
                      stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(stStationsNummern.NummerSPS),
                      starrTransfershuttleBasisParameter[stStationsNummern.NummerIntern].awFehlerInformationen );
        END_IF

        steplEintransportDefaultLuftabfrage := SEL(blFehlerAusloesen,STEP_800_E, STEP_900_E );
      END_IF

      IF ( blEinlaufSensor )THEN

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDPLUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      // Ausnahmesituation:
      //   - Einlaufsensor angefahren
      //   - Wegstrecke überfahren
      IF ( blAuslaufSensor ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( blEinlaufSensor ) THEN
          bpAnforderungBetriebsstopp := TRUE;
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        END_IF

        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rMaxPosAuslaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpAnforderungBetriebsstopp := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplEintransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_700_E:
      // ---------------------------------------------------------------------------------------
      //  EINLAUFSENSOR BELEGT BEIM STARTEN DES EINTRANSPORTS
      //
      //  Hinweis:
      //  - Beim Eintransport wird der Einlaufsensor belegt obwohl noch keine Scheibe
      //    komplett eintransportiert wurde
      // ---------------------------------------------------------------------------------------
      IF ( NOT toflAntriebLaeuft.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( blEinlaufsensor ) THEN
          bpAnforderungBetriebsstopp := TRUE;
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
          bpScheibeFaehrtUeberEinlauf := TRUE;

        ELSE
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;

        END_IF

        steplEintransportDefaultLuftabfrage := STEP_900_E;

      END_IF

    // EINTRANSPORT ===========================================
    STEP_800_E:
      // ---------------------------------------------------------------------------------------
      //  GLASTRANSPORT ABSCHLIESSEN
      //
      //  Hinweis:
      //  - Ausgaenge zurueck setzen ( Abfragen etc. senken)
      // ---------------------------------------------------------------------------------------

      bprtScheibe := FALSE;

      (* Hinweis:
         - Loesen der Transportkopplung unter den Transfershuttle, wenn diese aktiv ist
      *)
      IF ( bpTransfershuttleVerbundAktiv ) THEN
        blSchnittstelle_bAnforderungTransportVerbund := FALSE;
      END_IF


      out_bShuttleAnheben := FALSE;

      bpOutBereitZumEintransport := FALSE;

      out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
      blScheibenKontrolleAuslaufseiteEin    := FALSE;
      out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
      blScheibenKontrolleEinlaufseiteEin    := FALSE;

      tonlWartenAufSenken( IN:= NOT bpBereitZumVerfahren , PT:=T#10S);

      IF ( bpBereitZumVerfahren ) THEN
        steplEintransportDefaultLuftabfrage := STEP_1000_E;
      END_IF


      (* Fehlerbehandlung:
         - Glastransport unten
         - Ein- Aus- Laufsensoren
      *)
      IF ( tonlWartenAufSenken.Q ) THEN
        // Glastransport unten
        IF ( NOT blSensorGlastransportUnten ) THEN
          wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_UNTEN;
        // Luftsensoren unten
        ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteUnten ) THEN
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_UNTEN;
        // Luftsensoren unten
        ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteUnten ) THEN
          wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_UNTEN;
        ELSE
          wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
        END_IF

        steplEintransportDefaultLuftabfrage := STEP_900_E;
        bpOutBereitZumEintransport := FALSE;

      END_IF

    // EINTRANSPORT ==============================
    STEP_900_E:
      bpOutBereitZumEintransport := FALSE;

      Antrieb.rpGeschwindigkeit := REAL#0;
      Antrieb.wpBetriebsart     := KEINE_FUNKTION;

      bpFehler := TRUE;

    // EINTRANSPORT ==============================
    STEP_1000_E:

      blAbgeschlossenEintransport := TRUE;

  // EINTRANSPORT ==============================
  END_CASE

ELSE

  IF steplEintransportDefaultLuftabfrage > STEP_0_E THEN
    blAbgeschlossenEintransport := FALSE;
    bprtScheibe                 := FALSE;
    bpOutBereitZumEintransport  := FALSE;

    out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
    blScheibenKontrolleAuslaufseiteEin    := FALSE;
    out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
    blScheibenKontrolleEinlaufseiteEin    := FALSE;

    out_bShuttleAnheben := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplEintransportDefaultLuftabfrage := STEP_0_E;
  END_IF

END_IF
END_ACTION