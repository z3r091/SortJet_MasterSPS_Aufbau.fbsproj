(* METADATA
{
	"v3Meta": {
		"objectGuid": "034bf102-e631-49b1-befd-54869e87df20"
	}
}
*)
ACTION Austansport_Default_Luftabfrage
//-------------------------------------------------------------------------------------------------
// AKTION: AUSTRANSPORT [DEFAULT- LUFTABFRAGE]
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Abhandlung des Austransport mit einer default Luftabfrage.
*)
IF (  blAustransportDefaultLuftabfrage
     AND bpAutomatikAktiv )
THEN

  (* Ausnahmefehler:
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.rpGeschwindigkeit := REAL#0;
    Antrieb.wpBetriebsart     := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplAustransportDefaultLuftabfrage := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplAustransportDefaultLuftabfrage := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplAustransportDefaultLuftabfrage OF
    // AUSTRANSPORT ===========================================================================
    STEP_0_E:
      blMeldungAuslaufAbfrageBelegt := FALSE;
      blAbgeschlossenAustransport   := FALSE;
      bprtScheibe                   := FALSE;

      bpOutBereitZumAustransport := FALSE;

      tonlAntriebNichtFreigegeben(IN:=FALSE);

      tonlWartenAufAnheben(IN:=FALSE);
      tonlWartenAufSenken(IN:=FALSE);

      tonlEinlaufsensorTesten(IN:= FALSE);
      tonlAuslaufsensorTesten(IN:= FALSE);

      rlAntriebspositionBeiAuslaufSensorBelegung := REAL#0;

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge  := pAuftrag.rAuftragsLaenge,
                                                 rpGlasbreite  := pAuftrag.rAuftragsHoehe,
                                                 rpGlasstaerke := pAuftrag.rAuftragsDicke ) );

        blReduzierteGeschwindigkeit := ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht );

        steplAustransportDefaultLuftabfrage := STEP_10_E;
      END_IF

    // AUSTRANSPORT ===========================================================================
    STEP_10_E:
      (* Hinweis:
         - Ueberpruefung ob die Luftsensoren frei sind und richtig durchschalten
           => Einlauf- Auslauf- Sensoren
      *)
      blScheibenKontrolleAuslaufseiteEin := TRUE;
      blScheibenKontrolleEinlaufseiteEin := TRUE;

      tonlEinlaufsensorTesten(IN := NOT bpSensorScheibenKontrolleEinlaufSeiteFrei, PT := t#5s);
      tonlAuslaufsensorTesten(IN := NOT bpSensorScheibenKontrolleAuslaufseiteFrei, PT := t#5s);

      IF  ( bpSensorScheibenKontrolleEinlaufSeiteFrei
            AND bpSensorScheibenKontrolleAuslaufseiteFrei )
      THEN
        steplAustransportDefaultLuftabfrage := STEP_30_E;
      END_IF

      (* Hinweis:
         - Richtungsabhaengig: der Sensor der Ausgangsseite darf belegt sein (Scheibe steht schon bereit),
           der Sensor der Eingangsseite wird per Restweg freigefahren
           => vorwaerts: Ausgang = Auslauf, Eingang = Einlauf
           => rueckwaerts: Ausgang = Einlauf, Eingang = Auslauf
      *)
      IF ( NOT bpRueckwaertsAustransportieren ) THEN

        // Auslaufsensor belegt: Scheibe steht bereit (Shuttle durch das Vorab-Heben schon oben)
        IF (  tonlAuslaufsensorTesten.Q
             AND NOT tonlEinlaufsensorTesten.Q
             AND bpSensorScheibenKontrolleEinlaufSeiteFrei )
        THEN
          IF NOT pAuftrag.bErsteScheibe THEN
            blMeldungAuslaufAbfrageBelegt := TRUE;
          END_IF
          steplAustransportDefaultLuftabfrage := STEP_30_E;
        END_IF

        IF ( tonlEinlaufsensorTesten.Q ) THEN
          rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

          IF ( blReduzierteGeschwindigkeit ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
            Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
            Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          ELSE
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
            Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
            Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
          END_IF

          // Einlaufsensor per Restweg freifahren
          Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberEinlaufAustransport;
          IF bpOptionTransfershuttleMitUltraschallSensoren THEN
            Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
          ELSE
            Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
          END_IF
          Antrieb.wpBetriebsart     := RESTWEG;

          steplAustransportDefaultLuftabfrage := STEP_20_E;
        END_IF

      ELSE

        // Einlaufsensor belegt: Scheibe steht bereit (Shuttle durch das Vorab-Heben schon oben)
        IF (  tonlEinlaufsensorTesten.Q
             AND NOT tonlAuslaufsensorTesten.Q
             AND bpSensorScheibenKontrolleAuslaufseiteFrei )
        THEN
          IF NOT pAuftrag.bErsteScheibe THEN
            blMeldungEinlaufAbfrageBelegt := TRUE;
          END_IF
          steplAustransportDefaultLuftabfrage := STEP_30_E;
        END_IF

        IF ( tonlAuslaufsensorTesten.Q ) THEN
          rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

          IF ( blReduzierteGeschwindigkeit ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
            Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
            Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          ELSE
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
            Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
            Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
          END_IF

          // Auslaufsensor per Restweg freifahren
          Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberAuslaufAustransport;
          IF bpOptionTransfershuttleMitUltraschallSensoren THEN
            Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
          ELSE
            Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;
          END_IF
          Antrieb.wpBetriebsart     := RESTWEG;

          steplAustransportDefaultLuftabfrage := STEP_25_E;
        END_IF

      END_IF

    // AUSTRANSPORT ==============================
    STEP_20_E:
      // ---------------------------------------------------------------------------------------
      //  EINLAUFSENSOR FREIFAHREN
      //
      //  Hinweis:
      //  - Einlaufsensor belegt und diesen per Restweg frei fahren
      //  - Ueberwachung des gegenueberliegenden Sensors (Auslauf) und der Wegstrecke
      // ---------------------------------------------------------------------------------------
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( NOT blEinlaufSensor ) THEN
          (* Hinweis:
             - Sensorik war beim pruefen belegt ( Vorabanheben )
          *)
          tonlEinlaufsensorTesten(IN:= FALSE);
          tonlAuslaufsensorTesten(IN:= FALSE);

          steplAustransportDefaultLuftabfrage := STEP_0_E;
        ELSE
          wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
          steplAustransportDefaultLuftabfrage := STEP_900_E;
        END_IF

      END_IF

      // Ausnahmesituation:
      //   - Auslaufsensor angefahren
      //   - Wegstrecke überfahren
      IF ( blAuslaufSensor ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        bpAnforderungBetriebsstopp  := TRUE;

        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        wpFehlerNr := SEL( blEinlaufSensor, cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_BELEGT, cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT );
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rMaxPosEinlaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_25_E:
      // ---------------------------------------------------------------------------------------
      //  AUSLAUFSENSOR FREIFAHREN [RUECKWAERTS]
      //
      //  Hinweis:
      //  - Auslaufsensor belegt und diesen per Restweg frei fahren
      //  - Ueberwachung des gegenueberliegenden Sensors (Einlauf) und der Wegstrecke
      // ---------------------------------------------------------------------------------------
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( NOT blAuslaufSensor ) THEN
          tonlEinlaufsensorTesten(IN:= FALSE);
          tonlAuslaufsensorTesten(IN:= FALSE);

          steplAustransportDefaultLuftabfrage := STEP_0_E;
        ELSE
          wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
          steplAustransportDefaultLuftabfrage := STEP_900_E;
        END_IF

      END_IF

      // Ausnahmesituation:
      //   - Einlaufsensor angefahren
      //   - Wegstrecke ueberfahren
      IF ( blEinlaufSensor ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        bpAnforderungBetriebsstopp  := TRUE;

        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        wpFehlerNr := SEL( blAuslaufSensor, cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_BELEGT, cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT );
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rMaxPosAuslaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_30_E:
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

      tonlWartenAufAnheben(IN:= NOT blBereitZumGlastransport ,PT:=t#10s);

      IF ( blBereitZumGlastransport ) THEN

        IF ( NOT bpRueckwaertsAustransportieren ) THEN
          steplAustransportDefaultLuftabfrage := STEP_40_E;
        ELSE
          steplAustransportDefaultLuftabfrage := STEP_400_E;
        END_IF

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

        steplAustransportDefaultLuftabfrage := STEP_900_E;
        bpOutBereitZumAustransport  := FALSE;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_40_E:
      (* Hinweis:
         - Warten bis das Shuttle bereit ist zum Eintransportieren
      *)
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      IF IsBetweenWORD(pAuftrag.wTransferstationsNr2, cERSTE_FAECHERWAGENSTATIONS_NR, cLETZTE_FAECHERWAGENSTATIONS_NR) THEN
        IF ( InGlasTransportVorgaenger.bBereitZumAustransport AND InGlasTransportNachfolger.bBereitZumEintransport ) THEN
          IF ( pAuftrag.bErsteScheibe ) THEN
            steplAustransportDefaultLuftabfrage := STEP_100_E;
          ELSE
            steplAustransportDefaultLuftabfrage := STEP_50_E;
          END_IF
        END_IF
      ELSE
        IF ( InGlasTransportNachfolger.bBereitZumEintransport ) THEN
          IF ( pAuftrag.bErsteScheibe ) THEN
            steplAustransportDefaultLuftabfrage := STEP_100_E;
          ELSE
            steplAustransportDefaultLuftabfrage := STEP_50_E;
          END_IF
        END_IF
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_50_E:
      (* Hinweis:
         - Scheibe auf den Auslaufsensor positionieren
         - Auslaufsensor schon belegt: erst per Restweg freifahren (STEP_70), danach erneut positionieren
      *)
      rlAntriebsPositionBeiStart  := Antrieb.rpIstPosition;

      IF ( bpSensorScheibenKontrolleAuslaufseiteFrei ) THEN

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgAutoGeschwindigkeitTSVortransport;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.rpZielPosition    := ( ppParameterBaustein.rWegUeberAuslaufAustransport - pAuftrag.rModellVersatzVorne );

        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
        ELSE
          Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor2;
        END_IF
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportDefaultLuftabfrage := STEP_80_E;

      ELSE

          IF ( blReduzierteGeschwindigkeit ) THEN
            Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
            Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          ELSE
            Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
            Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
          END_IF

        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

        Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberAuslaufAustransport;

        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
        ELSE
          Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;
        END_IF
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportDefaultLuftabfrage := STEP_70_E;

      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_70_E:
      (* Hinweis:
         - Auslaufsensor per Restweg freigefahren: erneut positionieren
         - Ueberwachung des gegenueberliegenden Sensors (Einlauf) und der Wegstrecke
      *)
      blMeldungAuslaufAbfrageBelegt := FALSE;

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpSensorScheibenKontrolleAuslaufseiteFrei ) THEN
          steplAustransportDefaultLuftabfrage := STEP_50_E;
        ELSE
          wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
          steplAustransportDefaultLuftabfrage := STEP_900_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor
      *)
      IF ( NOT bpSensorScheibenKontrolleEinlaufSeiteFrei ) THEN
        bpAnforderungBetriebsstopp := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rMaxPosAuslaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_80_E:
      (* Hinweis:
         - Aufgrund von Problemen hier auf NOT DONE abfragen
      *)
      IF ( NOT Antrieb.bpDone ) THEN
        steplAustransportDefaultLuftabfrage := STEP_90_E;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_90_E:
      (* Hinweis:
         - Merken wann der Auslaufsensor angefahren wurde
      *)
      ftriglAuslaufsensorBelegt(CLK:= bpSensorScheibenKontrolleAuslaufseiteFrei );

      IF ( ftriglAuslaufsensorBelegt.Q ) THEN
        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
      END_IF

      (* Hinweis:
         - Austransport wurde abgeschlossen
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_100_E;

      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rlLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_100_E:
      // Starten des Austransports
      //    - Soll-Wertkopplung [Transfershuttle - Outputshuttle]
      //    - Scheibenzaehler initialisieren
      //    - Bit zum Austransport setzen
      rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      ilScheibenZaehler := WORD_TO_INT( pAuftrag.wAnzahlScheiben );

      IF bpOptionMasterSlaveAustransport THEN
        // Master-Slave: auf den Nachfolger koppeln, bereit erst nach erfolgter Kopplung (STEP_105)
        Antrieb.wpMaster      := InGlasTransportNachfolger.wAchsID;
        Antrieb.wpBetriebsart := SYNC_AUF_MASTER;
        steplAustransportDefaultLuftabfrage := STEP_105_E;
      ELSE
        Antrieb.wpBetriebsart := HANDPLUS;
        bpOutBereitZumAustransport := TRUE;
        steplAustransportDefaultLuftabfrage := STEP_110_E;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_105_E:
      IF ( Antrieb.bpDone ) THEN
        bpSlaveAktiv := TRUE;
        bpOutBereitZumAustransport := TRUE;
        steplAustransportDefaultLuftabfrage := STEP_110_E;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_110_E:
      (* Hinweis:
         - Sicherstellen das der Auslaufsensor belegt, wenn mit der Quittierung der Scheiben
           gestartet wird.
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit  := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( tonlAuslaufsensorBelegt.Q ) THEN
        steplAustransportDefaultLuftabfrage := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rlLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_120_E:
      (* Hinweis [ WECHSEL- SCHRITT ]:
         - Auslaufsensor wurde frei
            => Scheibenzaehler dekrementieren
      *)
      Antrieb.rpGeschwindigkeit :=  InGlasTransportNachfolger.rGeschwindigkeit;
      bprtScheibe := FALSE;

      IF ( tonlAuslaufsensorFrei.Q ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;
        // Wegueberwachung fuer die naechste Scheibe starten
        rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;
        steplAustransportDefaultLuftabfrage := STEP_130_E;
      END_IF


    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_130_E:
      (* Hinweis [ WECHSEL- SCHRITT ]:
         - Scheibenzaehler pruefen
           => 0   -> Austransport beenden
           => > 1 -> Weitere Scheiben auf die Folgestation fahren
      *)
      Antrieb.rpGeschwindigkeit :=  InGlasTransportNachfolger.rGeschwindigkeit;
      bprtScheibe := FALSE;

      IF ( ilScheibenZaehler <= 0 ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung * 1.5;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_140_E;
      ELSE

        IF ( NOT bpSensorScheibenKontrolleAuslaufseiteFrei ) THEN
          steplAustransportDefaultLuftabfrage := STEP_120_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Naechste Scheibe erreicht den Auslaufsensor nicht: mehr als die Stationslaenge gefahren
         - Steht der Antrieb (Nachfolger mit Geschwindigkeit 0), laeuft die Ueberwachung nicht ab
      *)
      IF (  ( ilScheibenZaehler > 0 )
           AND ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rlLaengeStation ) )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_140_E:
      (* Hinweis:
         - Antrieb steht
         - Pruefen des Auslaufsensors
         - Master-Slave- Kopplung ist beendet (Antrieb nicht mehr synchron)
      *)
      bpSlaveAktiv := FALSE;

      IF ( NOT toflAntriebLaeuft.Q ) THEN

        IF ( NOT bpSensorScheibenKontrolleAuslaufseiteFrei ) THEN
          bpScheibeFaehrtUeberAuslauf := TRUE;
          rlAntriebsPositionBeiStart:= Antrieb.rpIstPosition;
          steplAustransportDefaultLuftabfrage := STEP_150_E;

        ELSE
          steplAustransportDefaultLuftabfrage := STEP_170_E;

        END_IF

      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_150_E:
      (* Hinweis:
         - Auslaufsensor per Restweg freifahren
      *)
      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

      Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberAuslaufAustransport;

      IF bpOptionTransfershuttleMitUltraschallSensoren THEN
        Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
      ELSE
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor2;
      END_IF
      Antrieb.wpBetriebsart     := RESTWEG;

      steplAustransportDefaultLuftabfrage := STEP_160_E;

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_160_E:
      (* Hinweis:
         - Freifahren abgeschlossen
         - Ueberwachung des gegenueberliegenden Sensors (Einlauf) und der Wegstrecke
      *)
      IF ( Antrieb.bpDone ) THEN
        bpScheibeFaehrtUeberAuslauf := FALSE;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        IF ( blAuslaufSensor ) THEN
          wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_NICHT_FREI;
          steplAustransportDefaultLuftabfrage := STEP_900_E;
        ELSE
          steplAustransportDefaultLuftabfrage := STEP_170_E;
        END_IF

      END_IF

      // Prozess:
      //   - Ausnahmefehler
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rStopFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_NICHT_FREI;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      IF ( blEinlaufSensor ) THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_BELEGT;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_170_E:
      (* Hinweis:
         - Eigener Auslaufsensor frei: erst absenken, wenn auch der Einlaufsensor des Nachfolgers frei ist
           (die Scheibe liegt sonst noch im Uebergang)
      *)
      IF ( NOT InGlasTransportNachfolger.bEinlaufsensor ) THEN
        steplAustransportDefaultLuftabfrage := STEP_800_E;
      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ==========================================
    STEP_400_E:
      // ---------------------------------------------------------------------------------------
      //  AUSTRANSPORT RUECKWERTS [HANDMINUS]
      //
      //  Hinweis:
      // - Warten bis der Glas-Empfaenger bereit ist zum Eintransport ist
      // ---------------------------------------------------------------------------------------

      Antrieb.wpBetriebsart := KEINE_FUNKTION;
      bpOutBereitZumAustransport := FALSE;
      bprtScheibe := FALSE;

      IF IsBetweenWORD(pAuftrag.wTransferstationsNr2, cERSTE_FAECHERWAGENSTATIONS_NR, cLETZTE_FAECHERWAGENSTATIONS_NR) THEN
        IF ( InGlasTransportVorgaenger.bBereitZumEintransport AND InGlasTransportNachfolger.bBereitZumEintransport ) THEN
          IF ( NOT pAuftrag.bErsteScheibe ) THEN
            steplAustransportDefaultLuftabfrage := STEP_410_E;
          ELSE
            steplAustransportDefaultLuftabfrage := STEP_460_E;
          END_IF
        END_IF
      ELSE
        IF ( InGlasTransportVorgaenger.bBereitZumEintransport ) THEN
          IF ( NOT pAuftrag.bErsteScheibe ) THEN
            steplAustransportDefaultLuftabfrage := STEP_410_E;
          ELSE
            steplAustransportDefaultLuftabfrage := STEP_460_E;
          END_IF
        END_IF
      END_IF


    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_410_E:
      (* Hinweis:
         - Scheibe auf den Einlaufsensor positionieren
         - Einlaufsensor schon belegt: erst per Restweg freifahren (STEP_70), danach erneut positionieren
      *)
      rlAntriebsPositionBeiStart  := Antrieb.rpIstPosition;

      IF ( bpSensorScheibenKontrolleEinlaufseiteFrei ) THEN

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgAutoGeschwindigkeitTSVortransport;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.rpZielPosition    := - ( ppParameterBaustein.rWegUeberEinlaufAustransport - pAuftrag.rModellVersatzVorne );

        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        ELSE
          Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor1;
        END_IF
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportDefaultLuftabfrage := STEP_440_E;

      ELSE

          IF ( blReduzierteGeschwindigkeit ) THEN
            Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
            Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          ELSE
            Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
            Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
          END_IF

        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

        Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberEinlaufAustransport;

        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
        ELSE
          Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
        END_IF
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportDefaultLuftabfrage := STEP_430_E;

      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_430_E:
      (* Hinweis:
         - Einlaufsensor per Restweg freigefahren: erneut positionieren
         - Ueberwachung des gegenueberliegenden Sensors (Auslauf) und der Wegstrecke
      *)
      blMeldungEinlaufAbfrageBelegt := FALSE;

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpSensorScheibenKontrolleEinlaufseiteFrei ) THEN
          steplAustransportDefaultLuftabfrage := STEP_410_E;
        ELSE
          wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
          steplAustransportDefaultLuftabfrage := STEP_900_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor
      *)
      IF ( NOT bpSensorScheibenKontrolleAuslaufSeiteFrei ) THEN
        bpAnforderungBetriebsstopp := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rMaxPosEinlaufSensorFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_440_E:
      (* Hinweis:
         - Aufgrund von Problemen hier auf NOT DONE abfragen
      *)
      IF ( NOT Antrieb.bpDone ) THEN
        steplAustransportDefaultLuftabfrage := STEP_450_E;
      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_450_E:
      (* Hinweis:
         - Merken wann der Einlaufsensor angefahren wurde
      *)
      ftriglEinlaufsensorBelegt(CLK:= bpSensorScheibenKontrolleEinlaufseiteFrei );

      IF ( ftriglEinlaufsensorBelegt.Q ) THEN
        rlAntriebspositionBeiAuslaufSensorBelegung := Antrieb.rpIstPosition;
      END_IF

      (* Hinweis:
         - Austransport wurde abgeschlossen
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_460_E;

      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rlLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_460_E:
      // Starten des Austransports
      //    - Soll-Wertkopplung [Transfershuttle - Outputshuttle]
      //    - Scheibenzaehler initialisieren
      //    - Bit zum Austransport setzen
      rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      ilScheibenZaehler := WORD_TO_INT( pAuftrag.wAnzahlScheiben );

      IF bpOptionMasterSlaveAustransport THEN
        // Master-Slave: auf den Vorgaenger koppeln, bereit erst nach erfolgter Kopplung (STEP_105)
        Antrieb.wpMaster      := InGlasTransportVorgaenger.wAchsID;
        Antrieb.wpBetriebsart := SYNC_AUF_MASTER;
        steplAustransportDefaultLuftabfrage := STEP_465_E;
      ELSE
        Antrieb.wpBetriebsart := HANDMINUS;
        bpOutBereitZumAustransport := TRUE;
        steplAustransportDefaultLuftabfrage := STEP_470_E;
      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_465_E:
      IF ( Antrieb.bpDone ) THEN
        bpSlaveAktiv := TRUE;
        bpOutBereitZumAustransport := TRUE;
        steplAustransportDefaultLuftabfrage := STEP_470_E;
      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_470_E:
      (* Hinweis:
         - Sicherstellen das der Einlaufsensor belegt, wenn mit der Quittierung der Scheiben
           gestartet wird.
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit  := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( tonlEinlaufsensorBelegt.Q ) THEN
        steplAustransportDefaultLuftabfrage := STEP_480_E;
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rlLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_480_E:
      (* Hinweis [ WECHSEL- SCHRITT ]:
         - Einlaufsensor wurde frei
            => Scheibenzaehler dekrementieren
      *)
      Antrieb.rpGeschwindigkeit :=  InGlasTransportVorgaenger.rGeschwindigkeit;
      bprtScheibe := FALSE;

      IF ( tonlEinlaufsensorFrei.Q ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;
        // Wegueberwachung fuer die naechste Scheibe starten
        rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;
        steplAustransportDefaultLuftabfrage := STEP_490_E;
      END_IF


    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_490_E:
      (* Hinweis [ WECHSEL- SCHRITT ]:
         - Scheibenzaehler pruefen
           => 0   -> Austransport beenden
           => > 1 -> Weitere Scheiben auf die Folgestation fahren
      *)
      Antrieb.rpGeschwindigkeit :=  InGlasTransportVorgaenger.rGeschwindigkeit;
      bprtScheibe := FALSE;

      IF ( ilScheibenZaehler <= 0 ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung * 1.5;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_500_E;
      ELSE

        IF ( NOT bpSensorScheibenKontrolleEinlaufseiteFrei ) THEN
          steplAustransportDefaultLuftabfrage := STEP_480_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Naechste Scheibe erreicht den Einlaufsensor nicht: mehr als die Stationslaenge gefahren
         - Steht der Antrieb (Vorgaenger mit Geschwindigkeit 0), laeuft die Ueberwachung nicht ab
      *)
      IF (  ( ilScheibenZaehler > 0 )
           AND ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rlLaengeStation ) )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_500_E:
      (* Hinweis:
         - Antrieb steht
         - Pruefen des Einlaufsensors
         - Master-Slave- Kopplung ist beendet (Antrieb nicht mehr synchron)
      *)
      bpSlaveAktiv := FALSE;

      IF ( NOT toflAntriebLaeuft.Q ) THEN

        IF ( NOT bpSensorScheibenKontrolleEinlaufseiteFrei ) THEN
          bpScheibeFaehrtUeberEinlauf := TRUE;
          rlAntriebsPositionBeiStart:= Antrieb.rpIstPosition;
          steplAustransportDefaultLuftabfrage := STEP_510_E;

        ELSE
          steplAustransportDefaultLuftabfrage := STEP_525_E;

        END_IF

      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_510_E:
      (* Hinweis:
         - Einlaufsensor per Restweg freifahren
      *)
      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

      Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberEinlaufAustransport;

      IF bpOptionTransfershuttleMitUltraschallSensoren THEN
        Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
      ELSE
        Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
      END_IF
      Antrieb.wpBetriebsart     := RESTWEG;

      steplAustransportDefaultLuftabfrage := STEP_520_E;

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_520_E:
      (* Hinweis:
         - Freifahren abgeschlossen
         - Ueberwachung des gegenueberliegenden Sensors (Auslauf) und der Wegstrecke
      *)
      IF ( Antrieb.bpDone ) THEN
        bpScheibeFaehrtUeberEinlauf := FALSE;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        IF ( blEinlaufSensor ) THEN
          wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_NICHT_FREI;
          steplAustransportDefaultLuftabfrage := STEP_900_E;
        ELSE
          steplAustransportDefaultLuftabfrage := STEP_525_E;
        END_IF

      END_IF

      // Prozess:
      //   - Ausnahmefehler
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rStopFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_NICHT_FREI;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

      IF ( blAuslaufSensor ) THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_BELEGT;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ===========================================
    STEP_525_E:
      (* Hinweis:
         - Eigener Einlaufsensor frei: erst absenken, wenn auch der Auslaufsensor des Vorgaengers frei ist
           (die Scheibe liegt sonst noch im Uebergang)
      *)
      IF ( NOT InGlasTransportVorgaenger.bAuslaufsensor ) THEN
        steplAustransportDefaultLuftabfrage := STEP_800_E;
      END_IF

    // AUSTRANSPORT ============================================================================
    STEP_800_E:
      (* Hinweis:
         - Loesen der Transportkopplung unter den Transfershuttle, wenn diese aktiv ist
      *)
      IF ( bpTransfershuttleVerbundAktiv ) THEN
        blSchnittstelle_bAnforderungTransportVerbund := FALSE;
      END_IF

      (* Hinweis:
         - Sensorik und Shuttle absenken
      *)
      out_bShuttleAnheben := FALSE;

      out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
      blScheibenKontrolleAuslaufseiteEin    := FALSE;
      out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
      blScheibenKontrolleEinlaufseiteEin    := FALSE;

      tonlWartenAufSenken(IN := NOT bpBereitZumVerfahren, PT := t#10s);

      IF ( bpBereitZumVerfahren ) THEN
        steplAustransportDefaultLuftabfrage := STEP_810_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport oben
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

        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

    // AUSTRANSPORT ============================================================================
    STEP_810_E:
      (* Hinweis:
         - Referenz erst starten wenn der Slave abgekoppelt hat
      *)
      IF ( bpTransfershuttleVerbundAktiv ) THEN

        blSchnittstelle_bAnforderungTransportVerbund := FALSE;

        IF ( NOT stpInTransportVerbund.bMasterSlaveVerbundAktiv ) THEN
          steplAustransportDefaultLuftabfrage := STEP_820_E;
        END_IF

      ELSE
        steplAustransportDefaultLuftabfrage := STEP_820_E;

      END_IF

    // AUSTRANSPORT ============================================================================
    STEP_820_E:
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;

      steplAustransportDefaultLuftabfrage := STEP_830_E;

    // AUSTRANSPORT ============================================================================
    STEP_830_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_1000_E;
      END_IF

    // AUSTRANSPORT ============================================================================
    STEP_900_E:
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;
      bpSlaveAktiv               := FALSE;

      bpFehler := TRUE;

    // AUSTRANSPORT ============================================================================
    STEP_1000_E:
      bprtScheibe := FALSE;
      blAbgeschlossenAustransport :=TRUE;

  // AUSTRANSPORT ============================================================================
  END_CASE
ELSE
  IF ( steplAustransportDefaultLuftabfrage > STEP_0_E ) THEN
    blAbgeschlossenAustransport := FALSE;
    bpOutBereitZumEintransport  := FALSE;
    bpOutBereitZumAustransport  := FALSE;
    bpSlaveAktiv                := FALSE;

    out_bShuttleAnheben := FALSE;

    out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
    blScheibenKontrolleAuslaufseiteEin    := FALSE;
    out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
    blScheibenKontrolleEinlaufseiteEin    := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplAustransportDefaultLuftabfrage := STEP_0_E;
  END_IF

END_IF
END_ACTION