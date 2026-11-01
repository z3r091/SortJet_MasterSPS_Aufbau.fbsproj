(* METADATA
{
  "v3Meta": {
    "objectGuid": "8b9d975c-7e90-480d-86e6-03c013b1dcd4"
  }
}
*)
ACTION Eintransport
//-------------------------------------------------------------------------------------------------
// AKTION: EINTRANSPORT
//-------------------------------------------------------------------------------------------------

rtlMessungOK( CLK := Antrieb.bpMessungOk );

IF ( rtlMessungOK.Q AND ( ilIndexScheibenmessung <= 10 ) AND bpOptionScheibenmessungEintransport ) THEN
  rlScheibenmessung[ilIndexScheibenmessung] := Antrieb.rpMessErgebnis;
  ilIndexScheibenmessung := ilIndexScheibenmessung + 1;
END_IF

IF ( bpEintransport
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF ( Antrieb_Slave.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT_SLAVE;
    steplEintransport := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler ) THEN
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplEintransport := STEP_900_E;
  END_IF


  CASE steplEintransport OF
    // EINTRANSPORT =====================
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
      IF ( bpOptionSlaveAntrieb ) THEN
        IF blAntriebsKopplungAktiv THEN
          steplEintransport := STEP_20_E;
        END_IF
      ELSE
        // Antrieb nur referenzieren wenn Schwellwert überschritten oder nicht referenziert
        IF ( ABS(Antrieb.rpIstPosition) > rgSchwellwertReferenzieren ) OR NOT Antrieb.bpIstReferenziert THEN
          Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
          steplEintransport := STEP_10_E;
        ELSE
          steplEintransport := STEP_20_E;
        END_IF
      END_IF

    // EINTRANSPORT ====================
    STEP_10_E:
      (* Hinweis:
         - Antrieb ist referenziert
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_20_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_20_E:
      // ---------------------------------------------------------------------------------------
      //  KOPPLUNG ZWISCHEN DEN STATIONEN
      //
      //  Hinweis:
      // - Warten bis die Vorgaengerstation breit zum Austransport ist
      // ---------------------------------------------------------------------------------------

      bpOutBereitZumEintransport := TRUE;
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpMaxGeschwindigkeit;

      IF ( InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
        dwpWartezeit := TIME_TO_DWORD(TIME()- tlWarteZeitAufnahme);
        ilScheibenZaehler := WORD_TO_INT(pAuftrag.wAnzahlScheiben);

        steplEintransport := STEP_100_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  EINTRANSPORT UEBER DEN EINLAUFSENSOR
      //
      //  Hinweis:
      // - Transport in "Positive" Richtung
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Wird die Scheibenbeladung getrennt, berechnen ab welcher Strecke der Antrieb seine
           Geschwindigkeit reduzieren muss
      *)
      IF ( bpScheibentrennen ) THEN

        rlStreckeBisZurVerzoegerung := WegZumScheibenTrennenBestimmen( rpAuftragsLaenge       := pAuftrag.rAuftragsLaenge,
                                                                       rpRampe                := ppAntriebsInformationen.rpMaxVerzoegerung,
                                                                       rpGeschwindigkeit      := ppAntriebsInformationen.rpMaxGeschwindigkeit,
                                                                       rpTrennGeschwindigkeit := rgGeschwindigkeit30 );
      END_IF

      IF ( blReduzierteGeschwindigkeit ) THEN
        Antrieb.rpBeschleunigung    := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpGeschwindigkeit   := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
        Antrieb.rpVerzoegerung      := ppAntriebsInformationen.rpReduzierteVerzoegerung;
      ELSE
        Antrieb.rpGeschwindigkeit   := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        Antrieb.rpVerzoegerung      := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung    := ppAntriebsInformationen.rpMaxBeschleunigung;
      END_IF

      // Antriebsposition merken
      rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

      IF ( NOT bpSensorEinlauf ) THEN

        IF ( pAuftrag.bLetzteScheibe ) THEN

          // Es sind Auftragsoptionen für den Glastransport vorhanden -> Scheibe soll am Anfang der Station stehen bleiben
          IF ( pAuftrag.stAuftragsOptionen.eGlastransport = eGlastransport_AufEinlaufVorab ) THEN
            Antrieb.rpZielPosition := (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberEinlaufEintransport ) - pAuftrag.rModellVersatzVorne); 

          ELSE

            IF ( pAuftrag.bErsteScheibe ) THEN
              Antrieb.rpZielPosition    := (( ppParameterBaustein.rWegEinlaufsensorZuVorStopSensor ) - pAuftrag.rModellVersatzVorne);
            ELSE
              Antrieb.rpZielPosition    := (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberEinlauf ) - pAuftrag.rModellVersatzVorne);
            END_IF

          END_IF

        ELSE
          Antrieb.rpZielPosition := (( pAuftrag.rAuftragsLaenge + ppParameterBaustein.rWegUeberEinlaufEintransport ) - pAuftrag.rModellVersatzVorne);
        END_IF

        Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
        Antrieb.wpBetriebsart := RESTWEG;

        steplEintransport := STEP_110_E;

      ELSE
        Antrieb.rpGeschwindigkeit   := rgGeschwindigkeit20;
        Antrieb.rpVerzoegerung      := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung    := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.wpBetriebsart := HANDPLUS;
        steplEintransport := STEP_110_E;
      END_IF


    // EINTRANSPORT =====================
    STEP_110_E:
      IF ( bpSensorAuslaufVorAb ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      // Sicherstellen das der Einlaufsensor auch überfahren wurde
      IF ( bpSensorEinlauf ) THEN
        bprtScheibe := FALSE;
        rlPositionScheibenAnfangErkannt := rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
        steplEintransport := STEP_120_E;
      END_IF

      // Ausnahmesituation
      //   - Einlaufsensor schaltet nicht
      //   - Auslaufsensor wird belegt
      IF ( pAuftrag.bErsteScheibe ) THEN

        IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition)
             >  ( ppParameterBaustein.rLaengeStation * 4 ) )
        THEN
          Antrieb.wpBetriebsart := KEINE_FUNKTION;
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
          steplEintransport := STEP_900_E;
        END_IF

      ELSE

        IF ( ABS(rlPositionAntriebBeiStart - Antrieb.rpIstPosition)
             >  (ppParameterBaustein.rUeberwachungEinlaufsensor) )
        THEN
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
          steplEintransport := STEP_900_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor
         - Einlaufsensor schaltet nicht
      *)
      IF ( bpSensorAuslauf ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

      tonlMaximaleZeitSensorAnfahren( IN:= TRUE, PT :=T#60S );
      IF ( tonlMaximaleZeitSensorAnfahren.Q ) THEN
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
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
      IF ( bpSensorAuslaufVorAb ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      bprtScheibe := FALSE;

      IF ( NOT toflEinlaufsensor.Q ) THEN
        bprtScheibe := TRUE;
        ilScheibenZaehler := ilScheibenZaehler - 1;
        steplEintransport := STEP_130_E;
      END_IF


      (* Hinweis:
         - Es kann passieren aufgrund von falschen Scheibendaten das Glas auf dem Einlaufsensor stehen bleibt nach dem Positionieren.
           Merken das sich noch eine Scheibe auf dem Sensor zum quittieren der Scheibe befindet.
      *)
      IF ( Antrieb.bpDone
           AND toflEinlaufsensor.Q ) OR ( Antrieb.wpBetriebsart = HANDPLUS AND bpSensorAuslaufVorAb )  
      THEN
        blScheibenMerker := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        Antrieb.rpGeschwindigkeit := 0.0;
        steplEintransport := STEP_140_E;
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor
      *)
      IF ( bpSensorAuslauf ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
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
      IF ( bpSensorAuslaufVorAb ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
      END_IF

      // Wartezeit zuruecksetzen wenn mehrere Scheiben eingefahren werden
      IF ( bprtScheibe ) THEN
        dwpWartezeit := 0;
      END_IF

      bprtScheibe := FALSE;

      IF ( bpSensorEinlauf ) THEN
        steplEintransport := STEP_120_E;
      END_IF

      // Freigabe für den Fremdprozess
      IF ( ( ilScheibenZaehler <= 0 )
           AND NOT bpSensorAuslauf
           AND NOT toflEinlaufsensor.Q
           AND pAuftrag.bLetzteScheibe )
      THEN
        bpFreigabeFremdprozess := TRUE;
      END_IF

      IF ( Antrieb.bpDone ) OR ( Antrieb.wpBetriebsart = HANDPLUS AND bpSensorAuslaufVorAb )   THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        Antrieb.rpGeschwindigkeit := 0.0;
        steplEintransport := STEP_140_E;
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor
      *)
      IF ( bpSensorAuslauf ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_140_E:
      (* Hinweis:
         - Sicherstellen das der Antrieb steht
         - Auslaufsensor Freifahren
         - Einlaufsensor Freifahren
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        IF ( bpSensorAuslauf ) THEN
          tonlMaximaleZeitAuslaufsensorFreiFahren ( IN:= FALSE);
          steplEintransport := STEP_300_E;
        ELSE
          tonlMaximaleZeitEinlaufsensorFreiFahren ( IN:= FALSE );
          IF ( bpSensorEinlauf 
               OR ( bpSensorEinlauf AND InGlasTransportVorgaenger.bAuslaufsensor ) ) 
             AND bpSensorAuslaufVorab 
          THEN
            bpUebergrosseScheibeUebergang := TRUE;
            IF blScheibenMerker THEN
              bprtScheibe := TRUE; 
              blScheibenMerker := FALSE;
            END_IF
            steplEintransport := STEP_1000_E; 
          ELSE
            steplEintransport := STEP_200_E;
          END_IF
        END_IF
      END_IF

    // EINTRANSPORT =====================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  EINLAUFLAUFSENSOR FREI FAHREN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      tonlMaximaleZeitEinlaufsensorFreiFahren ( IN:= bpSensorEinlauf, PT :=T#10s );

      bprtScheibe := FALSE;

      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflEinlaufsensor.Q )
      THEN

        IF ( blScheibenMerker ) THEN
          bprtScheibe := TRUE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_210_E;

      END_IF

      IF ( toflEinlaufsensor.Q )THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDPLUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsnesor belegt (Maximal Glas - Sensor auf der Fremdanlage)
         - Zeit- Ueberwachung
      *)
      IF ( bpSensorAuslauf ) THEN
        bpScheibeFaehrtUeberAuslauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

      IF ( tonlMaximaleZeitEinlaufsensorFreiFahren.Q ) THEN
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_210_E:
      (* Anmerkung:
         - Pruefen ob nicht noch eine Scheibe auf dem Einlaufsensor liegt.
           Sonst versuchen den Sensor frei zufahren
         - Merken der Eintransportstrecke
      *)
      bprtScheibe := FALSE;

      IF (  NOT bpSensorEinlauf
           AND NOT InGlasTransportVorgaenger.bAuslaufsensor )
      THEN
        bpOutBereitZumEintransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Uberwachung
      *)
      tonlSchrittueberwachung( IN := TRUE,
                               PT := T#5s );

      IF ( tonlSchrittueberwachung.Q ) THEN
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_300_E:
      (* Anmerkung:
         - -Auslaufsensor freifahren
      *)
      tonlMaximaleZeitAuslaufsensorFreiFahren ( IN:= bpSensorEinlauf, PT :=T#10s );

      bprtScheibe := FALSE;

      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflAuslaufsensor.Q )
      THEN

        IF blScheibenMerker THEN
          bprtScheibe := TRUE; 
          blScheibenMerker := FALSE;
        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_1000_E;
      END_IF

      IF ( toflAuslaufsensor.Q )THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        IF blReduzierteGeschwindigkeit THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsnesor belegt (Maximal Glas - Sensor auf der Fremdanlage)
         - Zeit- Ueberwachung
      *)
      IF ( bpSensorEinlauf AND NOT ( eGlastyp = eScheibe_Maximal ) ) THEN
        bpScheibeFaehrtUeberEinlauf := TRUE;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF

      IF ( tonlMaximaleZeitAuslaufsensorFreiFahren.Q ) THEN
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplEintransport := STEP_900_E;
      END_IF

    // EINTRANSPORT =====================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpFehler    := TRUE;
      bprtScheibe := FALSE;

      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;

      bpOutBereitZumEintransport := FALSE;


    // EINTRANSPORT =====================
    STEP_1000_E:
      bpStationBelegt := pAuftrag.bLetzteScheibe;

      bpOutBereitZumEintransport := FALSE;
      bprtScheibe := FALSE;
      bpDone := TRUE;

  // EINTRANSPORT =====================
  END_CASE
ELSE

  IF (steplEintransport > STEP_0_E) THEN
    bpDone := FALSE;
    bprtScheibe := FALSE;
    bpFreigabeFremdprozess := FALSE;
    bpOutBereitZumEintransport := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    Antrieb_Slave.wpBetriebsart := KEINE_FUNKTION;
    steplEintransport := STEP_0_E;
  END_IF

END_IF
END_ACTION