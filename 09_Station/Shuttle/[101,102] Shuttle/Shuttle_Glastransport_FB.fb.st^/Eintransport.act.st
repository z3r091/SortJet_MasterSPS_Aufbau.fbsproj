(* METADATA
{
	"v3Meta": {
		"objectGuid": "ea930443-a30e-41be-99a8-e788ef9294f0"
	}
}
*)
ACTION Eintransport
(***************************************************************************************************)
(* AKTION EINTRANSPORT *)
(***************************************************************************************************)
IF ( bpEintransport
  AND bpAutomatikAktiv )
THEN

  (* Fehlerbehandlung:
     - Antrieb
     - Kopplung Vorgänger
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplEintransport := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplEintransport := STEP_900_E;
  END_IF


  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplEintransport OF
(*EINTRANSPORT ==============================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen initialisieren
      *)
	   tlWarteZeiteAufnahme := TIME();
      tonlAntriebNichtFreigegeben( IN := FALSE );

      bpFreigabeQuerfahrt := FALSE;


      steplEintransport := STEP_5_E;

(*EINTRANSPORT ==============================*)
    STEP_5_E:
      (* Hinweis:
         - Sicherstellen das die Slavekopplung aktiv ist
      *)
      IF ( blAntriebsKopplungAktiv ) THEN
        steplEintransport := STEP_10_E;
      END_IF
	  
(*EINTRANSPORT ==============================*)
    STEP_10_E:
      (* Hinweis:
         - Antriebueberpruefen ob bereit zum verfahren. 
      *)
      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplEintransport := STEP_20_E;
      END_IF

      (* Ueberwachung:
         - Zeitliche Ueberwachung des Schritts
      *)
      tonlAntriebNichtFreigegeben( IN := TRUE,
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================GEHT NICHT WEGEN MASTER SLAVE KOPPLUNG*)
    STEP_20_E:
      (* ---------------------------------------------------------------------------------------
      //  OPTIONAL - REFERENZIEREN DES ANTRIEBS
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;

      steplEintransport := STEP_30_E;

(*EINTRANSPORT ==============================*)
    STEP_30_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_40_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_40_E:
      (* ---------------------------------------------------------------------------------------
      //  KOPPLUNG [ SCHNITTSTELLE ZWISCHEN DEN STATIONEN]
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit  := REAL#0;

      IF ( InGlasTransportVorgaenger.bBereitZumAustransport ) THEN

        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeiteAufnahme);

        IF ( NOT bpTransferstationTransfershuttle ) THEN
          steplEintransport := STEP_100_E;
        ELSE
          steplEintransport := STEP_400_E;
        END_IF

      END_IF

(*EINTRANSPORT ==============================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  STARTEN DES EINTRANSPORT
      //         
      //  Hinweis:
      // - Transport "POSITIVE" Richtung
      // ---------------------------------------------------------------------------------------*)

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
            => Restwegpositionierung (Wenn der Einlaufsensor belegt wurde Zielposition fahren )  
            => Fehlverhalten sollte der Einlaufsensor belegt sein beim Starten der Restweg-Positionierung
      *)
      ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

      rlAntriebIstPositionBeiStart := ABS(Antrieb.rpIstPosition);


      IF ( NOT bpSensorEinlauf ) THEN

        IF (  pAuftrag.bErsteScheibe
          AND pAuftrag.bLetzteScheibe )
        THEN
          rlGeschwindigkeitEintransport := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        ELSE
          rlGeschwindigkeitEintransport := rgGeschwindigkeit40;
        END_IF


        Antrieb.rpGeschwindigkeit := rlGeschwindigkeitEintransport;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        IF ( pAuftrag.bLetzteScheibe ) THEN
			  // Die Scheibe soll am Anfang vom Shuttle stehen bleiben
          IF ( pAuftrag.stAuftragsOptionen.eGlastransport = eGlastransport_AufEinlauf ) THEN 
            Antrieb.rpZielposition    := (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberSensorLetzteScheibe ) - pAuftrag.rModellVersatzVorne);
            Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
			 ELSE
            Antrieb.rpZielPosition    := (( ppParameterBaustein.rWegUeberAuslauf ) - pAuftrag.rModellVersatzVorne);
            Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
			 END_IF
        ELSE
          Antrieb.rpZielposition    := (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberEinlauf ) - pAuftrag.rModellVersatzVorne);
          Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
        END_IF

        Antrieb.wpBetriebsart := RESTWEG;


        steplEintransport := STEP_110_E;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT_RESTWEGPOSITIONIERUNG;

        steplEintransport := STEP_900_E;

      END_IF

(*EINTRANSPORT ==============================*)
    STEP_110_E:

      (* Vorabstop- Sensor:
         - Geschwindigkeit reduzieren
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      bprtScheibe := FALSE;

      (* Hinweis:
         - Scheibe laeuft in die Station ein
      *)
      IF ( bpSensorEinlauf ) THEN
        rlPositionScheibenAnfangErkannt := rlAntriebIstPositionBeiStart := ABS(Antrieb.rpIstPosition);
        steplEintransport := STEP_120_E;
      END_IF

      (* Vorabstop- Sensor:
         - Geschwindigkeit verringern
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition)) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      (* Vorabstop- Sensor:
         - Geschwindigkeit reduzieren
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        Antrieb.rpVerzoegerung    := ( ppAntriebsInformationen.rpMaxVerzoegerung * 1.5 );
      END_IF

      (* Fehlerbehandlung
         - Einlaufsensor schaltet nicht (Unterscheidung ob es die erste Scheibe ist oder eine weitere )
         - Auslaufsensor wird belegt
      *)
	   IF ( pAuftrag.bErsteScheibe ) THEN

	     IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition))>  ppParameterBaustein.rLaengeStation * 2 ) THEN
         Antrieb.wpBetriebsart := KEINE_FUNKTION;
         wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
         steplEintransport := STEP_900_E;
       END_IF

	   ELSE

	     IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition))>  ppParameterBaustein.rUeberwachungEinlaufsensor ) THEN
         Antrieb.wpBetriebsart := KEINE_FUNKTION;
         wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
         steplEintransport := STEP_900_E;
       END_IF

	   END_IF

     IF ( bpSensorAuslaufStopp ) THEN
       Antrieb.wpBetriebsart := KEINE_FUNKTION;
       wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
       steplEintransport := STEP_900_E;
     END_IF

(*EINTRANSPORT ==============================*)
    STEP_120_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler = 1 ) THEN
      	  IF ( ABS( rlPositionScheibenAnfangErkannt - ABS(Antrieb.rpIstPosition)) >= rlStreckeBisZurVerzoegerung ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      	  END_IF

        END_IF

      END_IF


      (* Hinweis:
         - Sensorik frei geworden
      *)
      IF ( NOT toflEinlaufsensorFrei.Q ) THEN

        ilScheibenZaehler := ( ilScheibenZaehler - 1 );
        bprtScheibe := TRUE;

        IF ( ilScheibenZaehler <= 0 ) THEN
         bpFreigabeQuerfahrt := TRUE;
        END_IF

	      steplEintransport := STEP_130_E;
      END_IF

      IF ( Antrieb.bpDone
        AND NOT Antrieb.bpAntrieblaeuft )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpSensorEinlauf ) THEN
          blScheibenMerker := TRUE;
	    	  rlAntriebIstPositionBeiStart := ABS(Antrieb.rpIstPosition);
          steplEintransport := STEP_200_E;

        ELSE
          rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - ABS(Antrieb.rpIstPosition));
          steplEintransport := STEP_1000_E;

        END_IF

      END_IF

      (* Hinweis
         - Geschwindigkeit verringern
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition)) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      (* Vorabstop- Sensor:
         - Langsame Transportgeschwindigkeit 
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        Antrieb.rpVerzoegerung    := ( ppAntriebsInformationen.rpMaxVerzoegerung * 1.5 );
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsnesor belegt
         - Antrieb
      *)
      IF ( bpSensorAuslaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_130_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler = 1 ) THEN
      	  IF ( ABS( rlPositionScheibenAnfangErkannt - ABS(Antrieb.rpIstPosition)) >= rlStreckeBisZurVerzoegerung ) THEN
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

      IF ( bpSensorEinlauf ) THEN
        steplEintransport := STEP_120_E;
      END_IF

      IF ( Antrieb.bpDone ) THEN

        IF ( bpSensorEinlauf ) THEN
          blScheibenMerker := TRUE;
        END_IF

        rlAntriebIstPositionBeiStart := ABS(Antrieb.rpIstPosition);
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;

        steplEintransport := STEP_200_E;

      END_IF

      (* Hinweis
         - Geschwindigkeit verringern
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition)) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      (* Vorabstop- Sensor:
         - Langsame Transportgeschwindigkeit 
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        Antrieb.rpVerzoegerung    := ( ppAntriebsInformationen.rpMaxVerzoegerung * 1.5 );
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsnesor belegt
         - Antrieb
      *)
      IF ( bpSensorAuslaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_200_E:
      (* ---------------------------------------------------------------------------------------
      //  EINLAUFSENSOR FREIFAHREN
      //         
      //  Hinweis:
      // - Transport "POSITIVE" Richtung
      // ---------------------------------------------------------------------------------------*)


      bprtScheibe := FALSE;
	    dwpWartezeit := 0;

      IF ( NOT toflEinlaufsensor.Q ) THEN

        IF ( blScheibenMerker ) THEN
          blScheibenMerker := FALSE;
		      bprtScheibe := TRUE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpOutBereitZumEintransport := FALSE;

        rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - ABS(Antrieb.rpIstPosition));

        steplEintransport := STEP_1000_E;

      ELSIF ( toflEinlaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart := HANDPLUS;

      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Auslaufsnesor belegt
         - Antrtieb
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition))>  ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplEintransport := STEP_900_E;
      END_IF

      IF ( bpSensorAuslaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_400_E:
      (* ---------------------------------------------------------------------------------------
      //  EINTRANSPORT UEBER DEN EINLAUFSENSOR [TRANSFERSHUTTLE] 
      //         
      //  Hinweis:
      //  - Restwegpositionierung 
      //  - Fehlverhalten bei belegtem Sensor belegt 
      // ---------------------------------------------------------------------------------------*)

      (* Hinweis:
         - Wegstrecke zur reduzierung 

      *)
      rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                     rpRampe                := ppAntriebsInformationen.rpMaxVerzoegerung,
                                                                     rpGeschwindigkeit      := ppAntriebsInformationen.rpMaxGeschwindigkeit,
                                                                     rpTrennGeschwindigkeit := rgGeschwindigkeit25 );

        (* Hinweis:
           - Reduzieren der Geschwindigkeit + Beschleunigung nach Glasgewicht
             => Da es passieren kann dass das Glas aus dem  rutschen kann        
        *)
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge := pAuftrag.rAuftragsLaenge,
                                               rpGlasbreite := pAuftrag.rAuftragsHoehe,
                                               rpGlasstaerke := SEL( pAuftrag.rAuftragsDicke > wgUnterteilerMinMaxGlasdicke, GLASSTAERKE_DEFAULT_MIN, GLASSTAERKE_DEFAULT_MAX ) ) );

      IF ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht ) THEN
        Antrieb.rpBeschleunigung    := ppAntriebsInformationen.rpMaxBeschleunigung;  (* ppAntriebsInformationen.wpReduzierteBeschleunigung; *)
        Antrieb.rpVerzoegerung      := ppAntriebsInformationen.rpMaxVerzoegerung;    (* ppAntriebsInformationen.wpReduzierteVerzoegerung;   *)
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

      rlAntriebIstPositionBeiStart := ABS(Antrieb.rpIstPosition);

      IF ( NOT bpSensorEinlauf ) THEN

        IF ( pAuftrag.bLetzteScheibe ) THEN

          // Antrieb.rpZielPosition    := ( pAuftrag.rAuftragsLaenge +  ppParameterBaustein.rWegUeberSensorLetzteScheibe - pAuftrag.rModellVersatzVorne );
          // Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
          Antrieb.rpZielPosition    := ( ppParameterBaustein.rWegUeberAuslauf - pAuftrag.rModellVersatzVorne );
          Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;

        ELSE

          Antrieb.rpZielposition    := ( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberEinlauf - pAuftrag.rModellVersatzVorne );
          Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;

        END_IF
        Antrieb.wpBetriebsart     := RESTWEG;

        steplEintransport := STEP_410_E;

      ELSE
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.wpBetriebsart     := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT_RESTWEGPOSITIONIERUNG;

        steplEintransport := STEP_900_E;

      END_IF


(*EINTRANSPORT ==============================*)
    STEP_410_E:

      bprtScheibe := FALSE;

      IF ( bpSensorEinlauf ) THEN
        rlPositionScheibenAnfangErkannt := rlAntriebIstPositionBeiStart := ABS(Antrieb.rpIstPosition);
        steplEintransport := STEP_420_E;
      END_IF

      (* Hinweis:
         - Geschwindigkeit verringern
      *)
      IF ( ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition)) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung)
        AND NOT blReduzierteGeschwindigkeit )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      (* Vorabstop- Sensor:
         - Geschwindigkeit reduzieren 
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      (* Fehlerbehandlung
         - Einlaufsensor schaltet nicht (Unterscheidung ob es die erste Scheibe ist oder eine weitere )
         - Auslaufsensor wird belegt
      *)
	   IF ( pAuftrag.bErsteScheibe ) THEN

	     IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition))>  ppParameterBaustein.rLaengeStation * 2 ) THEN
         Antrieb.wpBetriebsart := KEINE_FUNKTION;
         wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
         steplEintransport := STEP_900_E;
       END_IF

	   ELSE
	     IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition))>  ppParameterBaustein.rUeberwachungEinlaufsensor ) THEN
         Antrieb.wpBetriebsart := KEINE_FUNKTION;
         wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
         steplEintransport := STEP_900_E;
       END_IF

	   END_IF

     IF ( bpSensorAuslaufStopp ) THEN
       Antrieb.wpBetriebsart := KEINE_FUNKTION;
       wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
       steplEintransport := STEP_900_E;
     END_IF

(*EINTRANSPORT ==============================*)
    STEP_420_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler = 1 ) THEN
      	  IF ( ABS( rlPositionScheibenAnfangErkannt - ABS(Antrieb.rpIstPosition)) >= rlStreckeBisZurVerzoegerung ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit25;
      	  END_IF

        END_IF

      ELSE
        Antrieb.rpGeschwindigkeit := rlGeschwindigkeitEintransport;

      END_IF

      (* Hinweis:
         - Geschwindigkeit verringern
      *)
      IF ( ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition)) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung)
        AND NOT blReduzierteGeschwindigkeit )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      (* Vorabstop- Sensor:
         - Geschwindigkeit reduzieren
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF


      IF ( NOT toflEinlaufsensorFrei.Q ) THEN

        ilScheibenZaehler := ( ilScheibenZaehler - 1 );
        bprtScheibe := TRUE;

        IF ( ilScheibenZaehler <= 0 ) THEN

         bpFreigabeQuerfahrt := TRUE;

       END_IF

	     steplEintransport := STEP_430_E;
      END_IF

      IF ( Antrieb.bpDone AND NOT Antrieb.bpAntrieblaeuft ) THEN
          Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpSensorEinlauf ) THEN
          blScheibenMerker := TRUE;
	    	  rlAntriebIstPositionBeiStart := ABS(Antrieb.rpIstPosition);
          steplEintransport := STEP_440_E;
        ELSE
          rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - ABS(Antrieb.rpIstPosition));
          steplEintransport := STEP_1000_E;
        END_IF

      END_IF


      (* Fehlerbehandlung:
         - Auslaufsnesor belegt
         - Antrieb
      *)
      IF ( bpSensorAuslaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_430_E:
      (* Hinweis:
         - Reduzieren der Geschwindigkeit wenn die Scheibenbeladung getrennt werden muss
      *)
      IF ( bpScheibentrennung  ) THEN

        IF ( ilScheibenZaehler = 1 ) THEN
      	  IF ( ABS( rlPositionScheibenAnfangErkannt - ABS(Antrieb.rpIstPosition)) >= rlStreckeBisZurVerzoegerung ) THEN
            Antrieb.rpGeschwindigkeit := rgGeschwindigkeit25;
      	  END_IF

        END_IF

      ELSE
        Antrieb.rpGeschwindigkeit := rlGeschwindigkeitEintransport;

      END_IF

      (* Hinweis:
         - Geschwindigkeit verringern
      *)
      IF ( ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition)) >= ppParameterBaustein.rWegstreckeBisZurVerzoegerung)
        AND NOT blReduzierteGeschwindigkeit )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
      END_IF

      (* Vorabstop- Sensor:
         - Geschwindigkeit reduzieren 
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

	    IF bprtScheibe THEN
		    dwpWartezeit := 0;
      END_IF

      bprtScheibe := FALSE;

      IF ( bpSensorEinlauf ) THEN
        steplEintransport := STEP_420_E;
      END_IF

      IF ( Antrieb.bpDone ) THEN

        IF ( bpSensorEinlauf ) THEN
          blScheibenMerker := TRUE;
        END_IF

        rlAntriebIstPositionBeiStart := ABS(Antrieb.rpIstPosition);
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplEintransport := STEP_440_E;

      END_IF


      (* Fehlerbehandlung:
         - Auslaufsnesor belegt
         - Antrieb
      *)
      IF ( bpSensorAuslaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_440_E:
      bprtScheibe := FALSE;
	    dwpWartezeit := 0;

      IF ( NOT toflEinlaufsensor.Q ) THEN

        IF ( blScheibenMerker ) THEN
          blScheibenMerker := FALSE;
		      bprtScheibe := TRUE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpOutBereitZumEintransport := FALSE;

        rlGefahreneStreckeEintransport := ABS(rlGefahreneStreckeEintransport - ABS(Antrieb.rpIstPosition));

        steplEintransport := STEP_1000_E;

      ELSIF ( toflEinlaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;

      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Auslaufsnesor belegt
         - Antrtieb
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition))>  ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplEintransport := STEP_900_E;
      END_IF

      IF ( bpSensorAuslaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bprtScheibe := FALSE;
      bpOutBereitZumEintransport := FALSE;
      bpFehler := TRUE;

	    (* Hinweis:
	     - Eintransport setzt sich Autark zurueck
      *)
	    bpEintransport := FALSE;

(*EINTRANSPORT ==============================*)
    STEP_1000_E:
      bpOutBereitZumEintransport := FALSE;
      bprtScheibe := FALSE;
      bpDone := TRUE;

	    (* Hinweis:
	     - Eintransport setzt sich Autark zurueck
      *)
	  bpEintransport := FALSE;

(*EINTRANSPORT ==============================*)
  END_CASE
ELSE
  IF (steplEintransport > STEP_0_E) THEN
    bpDone                                 := FALSE;
    bprtScheibe                            := FALSE;
    blScheibenMerker                       := FALSE;
    bpOutBereitZumEintransport             := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplEintransport := STEP_0_E;
  END_IF
END_IF
END_ACTION