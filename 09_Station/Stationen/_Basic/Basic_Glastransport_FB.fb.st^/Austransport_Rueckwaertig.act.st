(* METADATA
{
	"v3Meta": {
		"objectGuid": "f9629f78-ff2b-499a-99d8-be8fde7e1987"
	}
}
*)
ACTION Austransport_Rueckwaertig
(***************************************************************************************************)
(* AKTION: AUSTRANSPORT RÜCKWÄRTIG*)
(***************************************************************************************************)

IF ( bpAustransportRueckwaertig
  AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplAustransportRueckwaertig := STEP_900_E;
  END_IF
  
  IF ( Antrieb_Slave.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplAustransportRueckwaertig := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler ) THEN
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplAustransportRueckwaertig := STEP_900_E;
  END_IF

  CASE steplAustransportRueckwaertig OF
(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
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
        steplAustransportRueckwaertig := STEP_10_E;
	  END_IF

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_10_E:
      (* ---------------------------------------------------------------------------------------
      //  WARTEN AUF FREIGABE ZUM GLASTRANSPORT
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*) 

      Antrieb.rpGeschwindigkeit  := REAL#0 ;

	  bpOutBereitZumEintransport := bpUebergrosseScheibeUebergang;
	  
      IF ( InGlasTransportVorgaenger.bBereitZumEintransport ) 
        AND ( NOT bpUebergrosseScheibeUebergang OR InGlasTransportNachfolger.bBereitZumAustransport )
      THEN
        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeitAufnahme);

        IF ( NOT pAuftrag.bErsteScheibe ) THEN
          steplAustransportRueckwaertig := STEP_20_E;
        ELSE
          steplAustransportRueckwaertig := STEP_100_E;
        END_IF

      END_IF

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_20_E:
      (* Hinweis:
         - Pruefen ob der Auslaufsensor belegt ist.
           => Auslaufsensor nicht belegt, Glas auf den Auslaufsensor positionieren
           => Auslaufsesnor belegt, Glas bereit zum Austransport
      *)
      IF ( NOT bpSensorEinlauf ) THEN
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

        IF ( bpSensorEinlaufVorAb ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        END_IF

        Antrieb.rpZielposition    := ppParameterBaustein.rWegUeberAuslaufAustransport - pAuftrag.rModellVersatzVorne;
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplAustransportRueckwaertig := STEP_30_E;

      ELSE
        steplAustransportRueckwaertig := STEP_100_E;

      END_IF

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_30_E:
      (*  Hinweis:
          - Wird der Vorstop- Sensor ueberfahren die Geschwindigkeit des
            Antriebsdrosseln.
      *)
      IF ( bpSensorEinlaufVorAb ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        steplAustransportRueckwaertig := STEP_40_E;
      END_IF

      (* Fehlerbehandlung:
         - kein Glas auf der Station ( Stationslaemge abfahren)
         - Auslaufsensor wurde belegt 
      *)
      IF (ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_UND_EINLAUFVORAB_SCHALTEN_NICHT;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_40_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit sollte der Vorabstop- Sensor belegt worden sein
      *)
      IF ( bpSensorEinlaufVorAb ) THEN
        Antrieb.rpGeschwindigkeit  := rgGeschwindigkeit10;
      END_IF

      (* Anmerkung:
         - Vorpositionieren abgeschlossen
           => Auslaufsensor muss belegt sein
      *)
      IF (  Antrieb.bpDone
        AND bpSensorEinlauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransportRueckwaertig := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Glas moeglicherweise verkeilt da der Auslaufsensor nicht schaltet
           bzw. nicht angefahren wird (Stationslaemge abfahren)
      *)
      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rUeberwachungAuslaufsensor ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  STARTEN DES AUSTRANSPORTS
      //         
      //  Hinweis:
      // - Betriebsart: Handplus
      // ---------------------------------------------------------------------------------------*)

      ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

      rlPositionAntriebBeiStart   := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit  := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF blReduzierteGeschwindigkeit THEN
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      END_IF

      Antrieb.wpBetriebsart      := HANDMINUS;

      bpOutBereitZumAustransport := TRUE;

      steplAustransportRueckwaertig := STEP_110_E;

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_110_E:
      bprtScheibe := FALSE;
      tonlMaximaleZeitSensorAnfahren( IN:= TRUE, PT :=T#60S );
      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( toflEInlaufsensor.Q ) THEN
        steplAustransportRueckwaertig := STEP_120_E;
      END_IF
	  
	 (* Fehlerbehandlung:
         - Auslaufsensor schaltet nicht
      *)
      IF ( tonlMaximaleZeitSensorAnfahren.Q ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_120_E:
      (* Hinweis:
         - Scheibenzaehlen 
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportVorgaenger.rGeschwindigkeit;

      IF ( NOT toflEinlaufsensor.Q ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler -1;

        IF  ( ilScheibenZaehler <= 0 ) THEN
          Antrieb.rpGeschwindigkeit := REAL#0;
          Antrieb.wpBetriebsart     := KEINE_FUNKTION;

          steplAustransportRueckwaertig := STEP_130_E;

        ELSE
          steplAustransportRueckwaertig := STEP_110_E;

        END_IF

      END_IF

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_130_E:
      (* Hinweis:
         - Scheibentrigger ( Scheibenzaehler ) zurueck setzen
         - Warten bis der Antrieb steht und der Einlaufsensor der Folgestation nicht mehr belegt ist
      *)
      bprtScheibe := FALSE;
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
        steplAustransportRueckwaertig := STEP_140_E;
      END_IF

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_140_E:
      (* Anmerkung:
         - Pruefen ob der Einlaufsensor angefahren wurde
      *) 
      IF (  NOT toflEinlaufsensor.Q
        AND NOT InGlasTransportVorgaenger.bAuslaufsensor )
      THEN
        bpOutBereitZumAustransport := FALSE;
        bpOutBereitZumEintransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplAustransportRueckwaertig := STEP_1000_E;
      END_IF

      IF ( toflEinlaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDPLUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung
         - Einlaufsensor belegt
         - Verfahrweg- Ueberwachung 
      *)
      IF ( bpSensorAuslauf ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

      IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rUeberwachungAuslaufsensor ) THEN
        wpFehlerNr := cMELDUNG_AUSTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplAustransportRueckwaertig := STEP_900_E;
      END_IF

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_900_E:
      (* Fehlerbehandlung:
         - Fehlerschritt
      *)
      bpFehler    := TRUE;
      bprtScheibe := FALSE;
	  
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
	  
      bpOutBereitZumAustransport := FALSE;
      bpOutBereitZumEintransport := FALSE;

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
    STEP_1000_E:
      bprtScheibe := FALSE;
	  bpUebergrosseScheibeUebergang := FALSE;
      bpDone := TRUE;

(*AUSTRANSPORT RÜCKWÄRTIG ====================*)
  END_CASE
ELSE

  IF ( steplAustransportRueckwaertig > STEP_0_E ) THEN
    bpDone := FALSE;
    bprtScheibe := FALSE;
    rlGefahreneStreckeEintransport := 0.0;

    bpOutBereitZumEintransport := FALSE;
    bpOutBereitZumAustransport := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
    steplAustransportRueckwaertig := STEP_0_E;
  END_IF

END_IF
END_ACTION