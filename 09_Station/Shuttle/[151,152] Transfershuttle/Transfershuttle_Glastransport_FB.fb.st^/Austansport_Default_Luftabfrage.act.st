(* METADATA
{
  "v3Meta": {
    "objectGuid": "034bf102-e631-49b1-befd-54869e87df20"
  }
}
*)
ACTION Austansport_Default_Luftabfrage
(***************************************************************************************************)
(* AKTION: AUSTRANSPORT [DEFAULT- LUFTABFRAGE] *)
(***************************************************************************************************)
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
(* AUSTRANSPORT =========================================================================== *)
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
      rlAntriebspositionBeiEinlaufSensorBelegung := REAL#0;

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge  := pAuftrag.rAuftragsLaenge,
                                                 rpGlasbreite  := pAuftrag.rAuftragsHoehe,
                                                 rpGlasstaerke := pAuftrag.rAuftragsDicke ) );

        blReduzierteGeschwindigkeit := ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht );

        steplAustransportDefaultLuftabfrage := STEP_10_E;
      END_IF

(* AUSTRANSPORT =========================================================================== *)
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

      (* Ausnahmesituation:
         - Auslaufsensor ist belegt
           => Versuchen diesen Frei-Zufahren
           => Shuttle durch das Vorab-Heben schon oben
      *)
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
        wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_WIRD_NICHT_FREI;
        steplAustransportDefaultLuftabfrage := STEP_20_E;
      END_IF

(*AUSTRANSPORT ==============================*)
     STEP_20_E:
       (* ---------------------------------------------------------------------------------------
       //  EINLAUFSENSOR FREIFAHREN
       //         
       //  Hinweis:
       //  - Einlaufsensor belegt und diesen frei fahren
       // ---------------------------------------------------------------------------------------*)
       IF (  NOT Antrieb.bpAntrieblaeuft
         AND NOT blEinlaufSensor )
       THEN
         Antrieb.wpBetriebsart := KEINE_FUNKTION;

         (* Hinweis:
            - Sensorik war beim pruefen belegt ( Vorabanheben )
         *)
         tonlEinlaufsensorTesten(IN:= FALSE);
         tonlAuslaufsensorTesten(IN:= FALSE);

         steplAustransportDefaultLuftabfrage := STEP_0_E;

       END_IF

       IF ( NOT tonlEinlaufWirklichFrei.Q )THEN

         IF ( blReduzierteGeschwindigkeit ) THEN
           Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
           Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpReduzierteBeschleunigung;
           Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpReduzierteVerzoegerung;
         ELSE
           Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
           Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpMaxBeschleunigung;
           Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpMaxVerzoegerung;
         END_IF

         Antrieb.wpBetriebsart    := HANDPLUS;

       ELSE
         Antrieb.wpBetriebsart := KEINE_FUNKTION;

       END_IF

       (* Ausnahmesituation:
          - Auslaufsensor angefahren
          - Wegstrecke überfahren
       *)
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

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
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

         (* Glastransport oben *)
         IF ( NOT blSensorGlastransportOben ) THEN
           wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_OBEN;
         (* Luftsensoren oben *)
         ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteOben ) THEN
           wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_OBEN;
         (* Luftsensoren oben *)
         ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteOben ) THEN
           wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_OBEN;
         (* Druckluft Ok *)
         ELSIF NOT blDruckluftEinlaufSeiteOK THEN
           wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_EINLAUF_NICHT_OK;
         (* Druckluft Ok *)
         ELSIF ( NOT blDruckluftAuslaufSeiteOK ) THEN
           wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_AUSLAUF_NICHT_OK;
         ELSE
           wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
         END_IF

         steplAustransportDefaultLuftabfrage := STEP_900_E;
         bpOutBereitZumAustransport  := FALSE;
       END_IF

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_40_E:
      (* Hinweis:
         - Warten bis das Shuttle bereit ist zum Eintransportieren
      *)
      Antrieb.wpBetriebsart := KEINE_FUNKTION;
      
      // Bereit zum Austransport melden, aber nur wenn es nicht mit FW Stationen ist UND kein Master/Slave ist (Austransport ISO relevant, Glasabruf kommt nur wenn Bereit Signal vorhanden)
      bpOutBereitZumAustransport := NOT IsBetweenWORD(pAuftrag.wTransferstationsNr2, cERSTE_FAECHERWAGENSTATIONS_NR, cLETZTE_FAECHERWAGENSTATIONS_NR) AND NOT bpOptionMasterSlaveAustransport;
      
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

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_50_E:
      (* Hinweis:
         - Scheibepositionieren
      *)
      rlAntriebsPositionBeiStart  := Antrieb.rpIstPosition;

      IF ( bpSensorScheibenKontrolleAuslaufseiteFrei ) THEN

        rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgAutoGeschwindigkeitTSVortransport ;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberAuslaufAustransport;

        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
        ELSE
          Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor2;
        END_IF
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportDefaultLuftabfrage := STEP_80_E;

      ELSE

        (* Anmerkung:
          - Scheibe zurueck ueber den Auslaufsensor positionieren und erneut die Restweg-Positionierung starten
        *)
        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

        Antrieb.wpBetriebsart     := HANDMINUS;

        steplAustransportDefaultLuftabfrage := STEP_70_E;

      END_IF

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_70_E:
      (* Hinweis:
         - Ueberwachung -> ggf. Fehlerbehandlung
      *)
      blMeldungAuslaufAbfrageBelegt := FALSE;

      IF bpSensorScheibenKontrolleAuslaufseiteFrei THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
      END_IF 

      IF (  bpSensorScheibenKontrolleAuslaufseiteFrei AND NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_50_E;
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

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_80_E:
      (* Hinweis:
         - Aufgrund von Problemen hier auf NOT DONE abfragen
      *)
      IF ( NOT Antrieb.bpDone ) THEN
        steplAustransportDefaultLuftabfrage := STEP_90_E;
      END_IF

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
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

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_100_E:
      (* Starten des Austransports
          - Soll-Wertkopplung [Transfershuttle - Outputshuttle]
          - Scheibenzaehler initialisieren
          - Bit zum Austransport setzen
      *)
      rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      IF bpOptionMasterSlaveAustransport THEN
        Antrieb.wpMaster := InGlasTransportNachfolger.wAchsID;
        Antrieb.wpBetriebsart     := SYNC_AUF_MASTER;
      ELSE
        Antrieb.wpBetriebsart     := HANDPLUS;
      END_IF

      ilScheibenZaehler := WORD_TO_INT( pAuftrag.wAnzahlScheiben );

      IF NOT bpOptionMasterSlaveAustransport THEN
        bpOutBereitZumAustransport := TRUE;
        steplAustransportDefaultLuftabfrage := STEP_110_E;
      ELSE
        steplAustransportDefaultLuftabfrage := STEP_105_E;
      END_IF

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_105_E:
      IF ( Antrieb.bpDone ) THEN
        bpSlaveAktiv := TRUE;
        bpOutBereitZumAustransport := TRUE;
        steplAustransportDefaultLuftabfrage := STEP_110_E;
      END_IF

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_110_E:
      (* Hinweis:
         - Sicherstellen das der Auslaufsensor belegt, wenn mit der Quittierung der Scheiben
           gestartet wird.
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit  := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( NOT toflAuslaufsensor.Q ) THEN
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

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_120_E:
      (* Hinweis [ WECHSEL- SCHRITT ]:
         - Auslaufsensor wurde frei
            => Scheibenzaehler dekrementieren
      *)
      Antrieb.rpGeschwindigkeit :=  InGlasTransportNachfolger.rGeschwindigkeit;
      bprtScheibe := FALSE;

      IF ( toflAuslaufsensor.Q ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;
        steplAustransportDefaultLuftabfrage := STEP_130_E;
      END_IF

      IF ( NOT InGlasTransportNachfolger.bBereitZumEintransport ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_140_E;
      END_IF

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
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

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_140_E:
      (* Hinweis:
         - Antrieb steht
         - Pruefen des Auslaufsensors
      *)
      IF ( NOT toflAntriebLaeuft.Q ) THEN

        IF ( NOT bpSensorScheibenKontrolleAuslaufseiteFrei ) THEN
          bpScheibeFaehrtUeberAuslauf := TRUE;
          rlAntriebsPositionBeiStart:= Antrieb.rpIstPosition;
          tonlSensorScheibenKontrolleAuslaufSeiteFrei(IN := FALSE);
          steplAustransportDefaultLuftabfrage := STEP_150_E;

        ELSE
          steplAustransportDefaultLuftabfrage := STEP_800_E;

        END_IF

      END_IF

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_150_E:
      (* Hinweis:
         - Auslaufsensor freifahren
      *)
      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

      Antrieb.wpBetriebsart     := HANDMINUS;

      steplAustransportDefaultLuftabfrage := STEP_160_E;

(* AUSTRANSPORT [HANDPLUS - DEFAULT LUFTABFRAGE] =========================================== *)
    STEP_160_E:
      IF ( toflAuslaufsensor.Q ) THEN
        bpScheibeFaehrtUeberAuslauf := FALSE;
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        IF ( blAuslaufSensor ) THEN
          wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_NICHT_FREI;
          steplAustransportDefaultLuftabfrage := STEP_900_E;
        ELSE
          steplAustransportDefaultLuftabfrage := STEP_800_E;
        END_IF

      END_IF

      (* Prozess:
         - Ausnahmefehler
      *)
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

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
     STEP_400_E:
      (* ---------------------------------------------------------------------------------------
      //  AUSTRANSPORT RUECKWERTS [HANDMINUS]
      //         
      //  Hinweis:
      // - Warten bis der Glas-Empfaenger bereit ist zum Eintransport ist
      // ---------------------------------------------------------------------------------------*)

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


(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_410_E:
      (* Hinweis:
         - Scheibenvorpositionieren
      *)
      rlAntriebsPositionBeiStart  := Antrieb.rpIstPosition;

      IF ( bpSensorScheibenKontrolleEinlaufSeiteFrei ) THEN

        rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        ELSE
          Antrieb.rpGeschwindigkeit := rgAutoGeschwindigkeitTSVortransport;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberEinlaufAustransport;

        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        ELSE
          Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor1;
        END_IF
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportDefaultLuftabfrage := STEP_440_E;

      ELSE

        (* Anmerkung:
          - Scheibe zurueck ueber den Sensor positionieren und erneut die Restweg-Positionierung starten
        *)
        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.rpZielPosition    := ( ppParameterBaustein.rMaxPosAuslaufSensorFreiFahren);
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportDefaultLuftabfrage := STEP_420_E;

      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_420_E:
      (* Hinweis:
         - Aufgrund von Problemen hier auf NOT DONE abfragen
      *)
      IF ( NOT Antrieb.bpDone ) THEN
        steplAustransportDefaultLuftabfrage := STEP_430_E;
      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_430_E:
      (* Hinweis:
         - Ueberwachung -> ggf. Fehlerbehandlung
      *)
      IF (  bpSensorScheibenKontrolleEinlaufSeiteFrei ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_410_E;

      ELSIF (Antrieb.bpDone
        AND NOT bpSensorScheibenKontrolleEinlaufSeiteFrei )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplAustransportDefaultLuftabfrage := STEP_900_E;

      END_IF

      IF ( NOT bpSensorScheibenKontrolleAuslaufseiteFrei ) THEN
        bpAnforderungBetriebsstopp := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_440_E:
      (* Hinweis:
         - Aufgrund von Problemen hier auf NOT DONE abfragen
      *)
      IF ( NOT Antrieb.bpDone ) THEN
        steplAustransportDefaultLuftabfrage := STEP_450_E;
      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_450_E:
      (* Hinweis:
         - Merken wann der Einlaufsensor angefahren wurde
      *)
      ftriglEinlaufsensorBelegt(CLK:= bpSensorScheibenKontrolleEinlaufSeiteFrei );

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
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_460_E:
      (* Starten des Austransports
          - Soll-Wertkopplung 
          - Scheibenzaehler initialisieren
          - Bit zum Austransport setzen
      *)
      rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      IF bpOptionMasterSlaveAustransport THEN
        Antrieb.wpMaster := InGlasTransportVorgaenger.wAchsID;
        Antrieb.wpBetriebsart     := SYNC_AUF_MASTER;
      ELSE
        Antrieb.wpBetriebsart     := HANDMINUS;
      END_IF

      ilScheibenZaehler := WORD_TO_INT( pAuftrag.wAnzahlScheiben );

      IF NOT bpOptionMasterSlaveAustransport THEN
        bpOutBereitZumAustransport := TRUE;
        steplAustransportDefaultLuftabfrage := STEP_470_E;
      ELSE
        steplAustransportDefaultLuftabfrage := STEP_465_E;
      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_465_E:
      IF ( Antrieb.bpDone ) THEN
        bpSlaveAktiv := TRUE;
        bpOutBereitZumAustransport := TRUE;
        steplAustransportDefaultLuftabfrage := STEP_470_E;
      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_470_E:
      (* Hinweis:
         - Sicherstellen das der Auslaufsensor belegt, wenn mit der Quittierung der Scheiben
           gestartet wird.
      *)
      Antrieb.rpGeschwindigkeit  := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( NOT toflEinlaufsensor.Q ) THEN
        steplAustransportDefaultLuftabfrage := STEP_480_E;
      END_IF

       (* Fehlerbehandlung:
         - Wegueberwachung
      *)

      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rlLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_480_E:
      (* Hinweis [ WECHSEL- SCHRITT ]:
         - Auslaufsensor wurde frei
            => Scheibenzaehler dekrementieren
      *)
      Antrieb.rpGeschwindigkeit :=  InGlasTransportVorgaenger.rGeschwindigkeit;
      bprtScheibe := FALSE;

      IF ( toflEinlaufsensor.Q ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1 ;
        steplAustransportDefaultLuftabfrage := STEP_490_E;
      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
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
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_500_E;
      ELSE

        IF ( NOT bpSensorScheibenKontrolleEinlaufSeiteFrei ) THEN
          steplAustransportDefaultLuftabfrage := STEP_480_E;
        END_IF

      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_500_E:
      (* Hinweis:
         - Antrieb steht
         - Pruefen des Auslaufsensors
      *)
      IF ( NOT toflAntriebLaeuft.Q ) THEN

        rlAntriebsPositionBeiStart:= Antrieb.rpIstPosition;

        IF ( NOT bpSensorScheibenKontrolleEinlaufSeiteFrei ) THEN

          tonlSensorScheibenKontrolleEinlaufSeiteFrei(IN := FALSE);
          steplAustransportDefaultLuftabfrage := STEP_510_E;

        ELSE
          steplAustransportDefaultLuftabfrage := STEP_530_E;

        END_IF

      END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_510_E:
      (* Hinweis:
         - Auslaufsensor freifaheren
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

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_520_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( blEinlaufSensor ) THEN
          wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_NICHT_FREI;
          steplAustransportDefaultLuftabfrage := STEP_900_E;
        ELSE
          steplAustransportDefaultLuftabfrage := STEP_800_E;
        END_IF

      END_IF

      (* Fehlerbehandlung
         - Wegueberwachung
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rStopFreiFahren ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_NICHT_FREI;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

     IF ( blAuslaufSensor ) THEN
       bpAnforderungBetriebsstopp := TRUE;
       Antrieb.rpGeschwindigkeit := REAL#0;
       Antrieb.wpBetriebsart     := KEINE_FUNKTION;
       wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_BELEGT;
       steplAustransportDefaultLuftabfrage := STEP_900_E;
     END_IF

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_530_E:
     (* Hinweis:
        Transfershuttle müssen auch fertig sein!
        Besonderheit: die Transfershuttle positionieren nach einem Austransport die 
        noch im Speicher gebliebenen Gläser neu über die Luftschrnake damit neue Gläser hinzu
        gestellt werden können 
     *)
      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

      rlZielPosition            := (-1 * ( ppParameterBaustein.rWegUeberEinlaufEintransport));
      Antrieb.rpZielPosition    := rlZielPosition;
      IF bpOptionTransfershuttleMitUltraschallSensoren THEN
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
      ELSE
        Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor1;
      END_IF
      Antrieb.wpBetriebsart := RESTWEG;

      steplAustransportDefaultLuftabfrage := STEP_540_E;

(* AUSTRANSPORT [HANDMINUS - DEFAULT LUFTABFRAGE] ========================================== *)
    STEP_540_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_1000_E;
      END_IF

      (* Keine Scheibe gefunden im Fach
         - Wegueberwachung
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition)> ppParameterBaustein.rgAbstandLuftAbfrageAuslaufShuttle ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_1000_E;
      END_IF


      IF ( blAuslaufSensor ) THEN
        bpAnforderungBetriebsstopp := TRUE;
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_BELEGT;
        steplAustransportDefaultLuftabfrage := STEP_900_E;
      END_IF

(* AUSTRANSPORT ============================================================================ *)
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
         (* Glastransport unten *)
         IF ( NOT blSensorGlastransportUnten ) THEN
           wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_UNTEN;
         (* Luftsensoren unten *)
         ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteUnten ) THEN
           wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_UNTEN;
         (* Luftsensoren unten *)
         ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteUnten ) THEN
           wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_UNTEN;
         ELSE
           wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
         END_IF

         steplAustransportDefaultLuftabfrage := STEP_900_E;
       END_IF

(* AUSTRANSPORT ============================================================================ *)
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

(* AUSTRANSPORT ============================================================================ *)
    STEP_820_E:
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;

      steplAustransportDefaultLuftabfrage := STEP_830_E;

(* AUSTRANSPORT ============================================================================ *)
    STEP_830_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportDefaultLuftabfrage := STEP_1000_E;
       END_IF

(* AUSTRANSPORT ============================================================================ *)
     STEP_900_E:
       bpOutBereitZumEintransport := FALSE;
       bpOutBereitZumAustransport := FALSE;

       bpFehler := TRUE;

(* AUSTRANSPORT ============================================================================ *)
     STEP_1000_E:
       bprtScheibe := FALSE;
       blAbgeschlossenAustransport :=TRUE;

(* AUSTRANSPORT ============================================================================ *)
 END_CASE
ELSE
  IF ( steplAustransportDefaultLuftabfrage > STEP_0_E ) THEN
    blAbgeschlossenAustransport := FALSE;
    bpOutBereitZumEintransport  := FALSE;
    bpOutBereitZumAustransport  := FALSE;

    out_bShuttleAnheben := FALSE;

    out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
    blScheibenKontrolleAuslaufseiteEin    := FALSE;
    out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
    blScheibenKontrolleEinlaufseiteEin    := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    tonlSensorScheibenKontrolleAuslaufSeiteFrei( IN := FALSE );
    tonlSensorScheibenKontrolleEinlaufSeiteFrei( IN := FALSE );
    steplAustransportDefaultLuftabfrage := STEP_0_E;
  END_IF

END_IF
END_ACTION