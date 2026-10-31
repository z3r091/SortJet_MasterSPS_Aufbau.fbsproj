(* METADATA
{
	"v3Meta": {
		"objectGuid": "729fe2ea-084a-4a7e-9ac5-2a2b782fb230"
	}
}
*)
ACTION Austransport_MasterSlave
(***************************************************************************************************)
(* AUSTRANSPORT MASTER SLAVE *)
(***************************************************************************************************)

IF ( bpAustransport
  AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplAustransport := STEP_900_E;
  END_IF
  
  IF ( Antrieb_Slave.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplAustransport := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler ) THEN
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplAustransport := STEP_900_E;
  END_IF

  CASE steplAustransport OF
(*AUSTRANSPORT ====================*)
    STEP_0_E:
      (*  Anmerkung:
          - Initialisierung Variablen
      *)
      bpDone                     := FALSE;
      bprtScheibe                := FALSE;
      bpStationBelegt            := FALSE;
      bpOutBereitZumAustransport := FALSE;

      tonlAntriebNichtBetriebsBereit( IN := FALSE );
      tonlMaximaleZeitSensorAnfahren( IN := FALSE );

      rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge  := pAuftrag.rAuftragsLaenge,
                                               rpGlasbreite  := pAuftrag.rAuftragsHoehe,
                                               rpGlasstaerke := pAuftrag.rAuftragsDicke ) );

      blReduzierteGeschwindigkeit := ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht );

	  // Sicherstellen das die Slavekopplung aktiv ist
      IF ( blAntriebsKopplungAktiv ) THEN
        // Zeit für Statistik
        tlWarteZeitAufnahme := TIME();
        steplAustransport := STEP_10_E;
	  END_IF

(*AUSTRANSPORT ====================*)
    STEP_10_E:
      (* ---------------------------------------------------------------------------------------
      //  WARTEN AUF FREIGABE ZUM GLASTRANSPORT
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*) 

      Antrieb.rpGeschwindigkeit  := 0.0 ;

      bpOutBereitZumEintransport := bpUebergrosseScheibeUebergang;
      
      IF ( InGlasTransportNachfolger.bBereitZumEintransport  ) AND 
        ( NOT bpUebergrosseScheibeUebergang OR InGlasTransportVorgaenger.bBereitZumAustransport )
      THEN
        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeitAufnahme);

        IF ( NOT pAuftrag.bErsteScheibe ) THEN
          steplAustransport := STEP_20_E;
        ELSE
          steplAustransport := STEP_100_E;
        END_IF

      END_IF

(*AUSTRANSPORT ==============================*)
    STEP_20_E:
      (* Hinweis:
         - Pruefen ob der Auslaufsensor belegt ist.
           => Auslaufsensor nicht belegt, Glas auf den Auslaufsensor positionieren
           => Auslaufsesnor belegt, Glas bereit zum Austransport
      *)
      IF ( NOT bpSensorAuslauf ) THEN
        rlPositionAntriebBeiStart      := Antrieb.rpIstPosition;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVorpositionieren;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        IF ( bpSensorAuslaufVorAb ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        END_IF

        Antrieb.rpZielposition    := ppParameterBaustein.rWegUeberAuslaufAustransport - pAuftrag.rModellVersatzVorne;
        Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransport := STEP_30_E;
      ELSE
        steplAustransport := STEP_100_E;

      END_IF

(*AUSTRANSPORT ==============================*)
    STEP_30_E:
      (*  Hinweis:
          - Wird der Vorstop- Sensor ueberfahren die Geschwindigkeit des
            Antriebsdrosseln.
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        steplAustransport := STEP_40_E;
      END_IF

      (* Fehlerbehandlung:
         - kein Glas auf der Station ( Stationslaemge abfahren)
         - Auslaufsensor wurde belegt 
      *)
      IF (ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_UND_AUSLAUFVORAB_SCHALTEN_NICHT;
        steplAustransport := STEP_900_E;
      END_IF

(*AUSTRANSPORT ==============================*)
    STEP_40_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit sollte der Vorabstop- Sensor belegt worden sein
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.rpGeschwindigkeit  := rgGeschwindigkeit10;
      END_IF

      (* Anmerkung:
         - Vorpositionieren abgeschlossen
           => Auslaufsensor muss belegt sein
      *)
      IF (  Antrieb.bpDone
        AND bpSensorAuslauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransport := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Glas moeglicherweise verkeilt da der Auslaufsensor nicht schaltet
           bzw. nicht angefahren wird (Stationslaemge abfahren)
      *)
      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rUeberwachungAuslaufsensor ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT_WEG_UEBERWACHUNG;
        steplAustransport := STEP_900_E;
      END_IF

      IF (  Antrieb.bpDone
        AND NOT bpSensorAuslauf )
      THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplAustransport := STEP_900_E;
      END_IF

(*AUSTRANSPORT ==============================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  STARTEN DES AUSTRANSPORTS
      // 
      // ---------------------------------------------------------------------------------------*) 

      ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);
       
      Antrieb.wpMaster := InGlasTransportNachfolger.wAchsID;

		// Wenn der Vorgänger "Rückwärtig" fährt, muss der Antrieb "invertiert" gekoppelt werdem, da es sonst in der falsche Richtung fährt
		IF InGlasTransportVorgaenger.bTransportRueckwaertig THEN
		 Antrieb.wpBetriebsart := INVERTIERTER_SYNC_AUF_MASTER;		
      ELSE
        Antrieb.wpBetriebsart := SYNC_AUF_MASTER;			  
      END_IF
				
      IF ( Antrieb.bpDone ) THEN
        bpSlaveAktiv := TRUE;
        bpOutBereitZumAustransport := TRUE;
        steplAustransport := STEP_110_E;
      END_IF

(*AUSTRANSPORT ====================*)
    STEP_110_E:
      bprtScheibe := FALSE;
      tonlMaximaleZeitSensorAnfahren( IN:= TRUE, PT :=T#60S );

      IF ( toflAuslaufsensor.Q ) THEN
        steplAustransport := STEP_120_E;
      END_IF
	  
	 (* Fehlerbehandlung:
         - Auslaufsensor schaltet nicht
      *)
      IF ( tonlMaximaleZeitSensorAnfahren.Q ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplAustransport := STEP_900_E;
      END_IF

(*AUSTRANSPORT ====================*)
    STEP_120_E:
      (* Hinweis:
         - Scheibenzaehlen 
      *)
      IF ( NOT toflAuslaufsensor.Q ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler -1;

        IF  ( ilScheibenZaehler <= 0 ) THEN
          Antrieb.rpGeschwindigkeit := REAL#0;
          Antrieb.wpBetriebsart     := KEINE_FUNKTION;

          steplAustransport := STEP_130_E;

        ELSE
          steplAustransport := STEP_110_E;

        END_IF

      END_IF

(*AUSTRANSPORT ====================*)
    STEP_130_E:
      (* Hinweis:
         - Scheibentrigger ( Scheibenzaehler ) zurueck setzen
         - Warten bis der Antrieb steht und der Einlaufsensor der Folgestation nicht mehr belegt ist
      *)
      bprtScheibe := FALSE;
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
        IF bpSensorAuslauf THEN
          steplAustransport := STEP_140_E;
        ELSE
          bpOutBereitZumEintransport := FALSE;
          steplAustransport := STEP_1000_E;
        END_IF
      END_IF

(*AUSTRANSPORT ====================*)
    STEP_140_E:
      (* Anmerkung:
         - Pruefen ob der Auslaufsensor angefahren wurde
      *) 
      IF (  NOT toflAuslaufsensor.Q
        AND NOT InGlasTransportNachfolger.bEinlaufsensor )
      THEN
        bpOutBereitZumAustransport := FALSE;
        bpOutBereitZumEintransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplAustransport := STEP_1000_E;
      END_IF

      IF ( toflAuslaufsensor.Q ) THEN

        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

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

      (* Fehlerbehandlung
         - Einlaufsensor belegt
         - Verfahrweg- Ueberwachung 
      *)
      IF ( bpSensorEinlauf ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplAustransport := STEP_900_E;
      END_IF

      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rUeberwachungAuslaufsensor ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplAustransport := STEP_900_E;
      END_IF

(*AUSTRANSPORT ====================*)
    STEP_900_E:
      (* Fehlerbehandlung:
         - Fehlerschritt
      *)
      bpFehler    := TRUE;
      bprtScheibe := FALSE;
	  
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
	  
      bpOutBereitZumEintransport := FALSE;
      bpOutBereitZumAustransport := FALSE;

(*AUSTRANSPORT ====================*)
    STEP_1000_E:
      bpUebergrosseScheibeUebergang := FALSE;
      bprtScheibe := FALSE;
      bpDone := TRUE;

(*AUSTRANSPORT ====================*)
  END_CASE
ELSE

  IF ( steplAustransport > STEP_0_E ) THEN
    bpDone := FALSE;
    bprtScheibe := FALSE;
    rlGefahreneStreckeEintransport := 0.0;

    bpOutBereitZumAustransport := FALSE;
    bpOutBereitZumEintransport := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
    steplAustransport := STEP_0_E;
  END_IF

END_IF
END_ACTION