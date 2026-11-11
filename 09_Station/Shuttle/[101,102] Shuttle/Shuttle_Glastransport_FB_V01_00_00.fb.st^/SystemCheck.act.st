(* METADATA
{
	"v3Meta": {
		"objectGuid": "b09abefc-345d-4da0-8fbd-1e1cd6fc184b"
	}
}
*)
ACTION SystemCheck
//-------------------------------------------------------------------------------------------------
// AKTION SYSTEMCHECK
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Glastransport soll einen SystemCheck vollziehen
   - SystemCheck mit Scheibenmessung ueber den Glastransport [Keine autarke Mess-Achse]
     => Mess-Sensor 1 -> Einlaufsensor
     => Mess-Sensor 2 -> Auslaufsensor
*)
IF ( bpCheck ) THEN

  (* Fehlerbehandlung:
     - Antrieb
     - Partner im Verbundcheck meldet Fehler
  *)
  IF (Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplCheck := STEP_900_E;
  END_IF

  IF ( InGlasTransportVorgaenger.bFehler
       AND bpCheckMitVorgaenger )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_SENDER_NICHT_BEREIT;
    steplCheck := STEP_900_E;
  END_IF

  IF ( InGlasTransportNachfolger.bFehler
       AND bpCheckMitNachfolger )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_GLASTRANSPORT_EMPFAENGER_NICHT_BEREIT;
    steplCheck := STEP_900_E;
  END_IF

  CASE ( steplCheck ) OF
    // SYSTEM CHECK=========================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      bpDone := FALSE;
      bpStationBelegt := FALSE;


      rlGefahreneStreckeEintransport := 0.0;

      IF ( Antrieb.bpReglerBereit
           AND blAntriebsKopplungAktiv )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF bpSlaveAntriebVorhanden THEN
          steplCheck := STEP_15_E;
        ELSE
          steplCheck := STEP_5_E;

        END_IF
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit AND blAntriebsKopplungAktiv ),
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK========================= GEHT NICHT WEGEN MASTER SLAVE KOPPLUNG
    STEP_5_E:
      (* Hinweis:
         - Antriebueberpruefen ob bereit zum verfahren. Des Weiteren die aktuelle Position auf dem
           Regler nullen ( Referenz ).
      *)
      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;
        steplCheck := STEP_10_E;
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit ),
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_10_E:
      (* Hinweis:
         - Referenzieren des Antriebs abgeschlossen [Ist-Position = 0  bzw. 1]
      *)
      IF (  ( Antrieb.rpIstPosition <= 1   )
           AND ( Antrieb.rpIstPosition >= -1  ) AND Antrieb.bpDone )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_15_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_15_E:
      // Pruefen ob es sich um einen SystemCheck mit einer Vorganger- Nachfolge- Station handelt oder ob der
      //   default SystemCheck abgehandelt werden soll:
      //   - Nachfolger :  Speicher / Faecherwagen
      //   - Vorgaenger : Station 203 / 206
      //   - Nichts     : Default SystemCheck [Station macht alleine einen SystemCheck]
      IF ( NOT ( bpCheckMitVorgaenger
                 OR bpCheckMitNachfolger) )
      THEN
        steplCheck := STEP_20_E;

      ELSE
        steplCheck := STEP_300_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_20_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<< DEFAULT SYSTEMCHECK >>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Anmerkung:
      //   - Ein- Auslauf- Sensor nicht belegt : Einlaufsensor anfahren / Restweg freifahren / Scheibenmessung
      //   - Auslaufsensor belegt:  Einlaufsensor anfahren / Restweg freifahren / Scheibenmessung
      //   - Einlaufsensor belegt:  Scheibenmessung

      IF NOT ( bpSensorEinlauf OR bpSensorAuslauf ) THEN
        steplCheck:=STEP_30_E;

      ELSIF ( bpSensorAuslauf AND NOT bpSensorEinlauf ) THEN
        bpStationBelegt := TRUE;
        steplCheck:=STEP_30_E;

      ELSIF ( bpSensorEinlauf AND NOT bpSensorAuslauf  ) THEN
        bpStationBelegt := TRUE;
        steplCheck := STEP_30_E;

      ELSE
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;

      END_IF


    // SYSTEM CHECK=========================
    STEP_30_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< DEFAULT - GLAS AUF DEN EINLAUFSENSOR POSITIONIEREN- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Anmerkung:
      //   - Scheiben-Suchfahrt auf den << EINLAUFSENSOR >>. Sollte eine Scheibegefunden werden kann
      //     im Anschluss eine Scheibenlaengenvermessung erfolgen
      //   - Restwegpositionierung -> 50 mm ueber den Einlaufsensor
      IF ( NOT toflEinlaufsensor.Q ) THEN
        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        IF ( bpSensorEinlaufVorab ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
        END_IF

        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielposition    := ppParameterBaustein.rWegUeberSensorSystemCheck;
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplCheck := STEP_40_E;

      ELSE
        bpStationBelegt := TRUE;

        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        IF ( bpSensorEinlaufVorab ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
        END_IF
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielposition    := ppParameterBaustein.rWegUeberEinlauf;
        Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplCheck := STEP_40_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_40_E:
      (* Hinweis:
         - Antrieb hat die Restwegpositionierung auf den Einlaufsensor abgeschlossen
            => Station belegt
         - Antrieb ist die Stationslaenge verfahren und es wurde kein Glas gefunden
            => Station nicht belegt
      *)
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bpStationBelegt := TRUE;
        steplCheck := STEP_100_E;
      END_IF

      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition)
           > ppParameterBaustein.rLaengeStation )
      THEN
        bpStationBelegt := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_100_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< AUSWERTUNG  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Auswertung ob noch ein Fehlverhalten vorliegt
      //     => Auslaufsensor nicht frei geworden
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_800_E;
      END_IF

      (* Fehlerbehandlung:
         - Sensoren
         - Antrieb
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF ( bpSensorEinlauf ) THEN
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        ELSE
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_BELEGT;
        END_IF
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_300_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SYSTEMCHECK MIT VORGAENGER BZW. NACHFOLGER >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

      // Check mit Vorgaenger:
      IF ( bpCheckMitVorgaenger
           AND NOT bpCheckMitNachfolger )
      THEN
        bpOutBereitZumEintransport := TRUE;
        steplCheck := STEP_400_E;
      // Check mit Nachfolger:
      ELSIF( bpCheckMitNachfolger
             AND NOT bpCheckMitVorgaenger )
      THEN
        IF bpRueckwaertsSystemcheck THEN
          steplCheck := STEP_700_E;
        ELSE
          steplCheck := STEP_600_E;
        END_IF
      ELSE

        (* Fehlerbehandlung:
        *)
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_VERBUND_VORGAENGER_NICHT_ERLAUBT;
        steplCheck := STEP_900_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_400_E:
      // ---------------------------------------------------------------------------------------
      // SYSTEM CHECK MIT VORGAENGER
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      bpOutBereitZumEintransport:= TRUE;
      Antrieb.rpGeschwindigkeit := 0.0;

      IF ( InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
        steplCheck := STEP_410_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_410_E:
      (* Anmerkung:
         - Glas wird auf das Shuttle gezogen und es wird eine Glasposition gesendet
      *)
      rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielposition    := ppParameterBaustein.rWegUeberEinlauf;
      Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
      Antrieb.wpBetriebsart     := RESTWEG;

      steplCheck:=STEP_420_E;

    // SYSTEM CHECK=========================
    STEP_420_E:
      (* Anmerkung:
         - Scheibenzaehlen da dies gebraucht wird um im Jobs-Baustein eine Nachricht [Glasposition] abzusetzen.
      *)
      bprtScheibe := FALSE;

      IF ( Antrieb.bpDone
           AND NOT bpSensorEinlauf )
      THEN
        bpOutBereitZumEintransport:= FALSE;
        bprtScheibe := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_20_E;
      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor
         - Glastransportverfahrweg- Ueberwachung
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition ) >= ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_NICHT_FREI;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_600_E:
      // ---------------------------------------------------------------------------------------
      // SYSTEM CHECK MIT NACHFOLGER
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      bpOutBereitZumAustransport := TRUE;

      IF ( InGlasTransportNachfolger.bBereitZumEintransport  ) THEN
        steplCheck := STEP_610_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_610_E:
      (* Hinweis:
         - Soll- Wertkopplung mit einem Transfershuttle
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.wpBetriebsart     := HANDPLUS;

      bpOutBereitZumAustransport:=TRUE;

      steplCheck := STEP_620_E;

    // SYSTEM CHECK=========================
    STEP_620_E:
      (* Anmerkung:
         - Warten bis die Nachfolgestation den SystemCheck beendet hat oder Auslaufsensor frei geworden ist
      *)
      bprtScheibe := FALSE;
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( InGlasTransportNachfolger.bAuslaufsensor ) THEN
        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        steplCheck := STEP_625_E;
      END_IF

      IF ( NOT InGlasTransportNachfolger.bBereitZumAustransport ) THEN
        Antrieb.rpGeschwindigkeit := 0.0;
        bpOutBereitZumAustransport := FALSE;
        steplCheck := STEP_650_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_625_E:
      (* Anmerkung:
         - Warten bis die Nachfolgestation den SystemCheck beendet hat oder Auslaufsensor frei geworden ist
      *)
      Antrieb.rpGeschwindigkeit := InGlasTransportNachfolger.rGeschwindigkeit;

      IF ( NOT InGlasTransportNachfolger.bAuslaufsensor ) THEN
        bprtScheibe := TRUE;
        steplCheck := STEP_620_E;
      END_IF

      IF ( NOT InGlasTransportNachfolger.bBereitZumAustransport ) THEN
        Antrieb.rpGeschwindigkeit := 0.0;
        bpOutBereitZumAustransport := FALSE;
        steplCheck := STEP_650_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_650_E:
      IF NOT Antrieb.bpAntrieblaeuft THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        // Startposition fuer die Wegueberwachung beim Freifahren
        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        steplCheck := STEP_660_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_660_E:

      (* Hinweis:
         - Pruefen ob das Glas zuweit gefahren wurde und den Auslaufsensor nun belegt ist ggf. das
           Glas wider zurueck fahren
      *)
      IF ( toflAuslaufsensor.Q
           OR InGlasTransportNachfolger.bEinlaufsensor
           OR InGlasTransportNachfolger.bAuslaufsensor )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := (ppAntriebsInformationen.rpMaxBeschleunigung);
        Antrieb.rpVerzoegerung    := (ppAntriebsInformationen.rpMaxVerzoegerung);
        Antrieb.wpBetriebsart     := HANDMINUS;

      ELSE
        Antrieb.rpGeschwindigkeit := 0.0;

      END_IF

      (* Hinweis:
         - Pruefen ob das Glas zuweit gefahren wurde und den Auslaufsensor nun belegt ist ggf. das
           Glas wider zurueck fahren
      *)
      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflAuslaufsensor.Q
           AND NOT InGlasTransportNachfolger.bEinlaufsensor
           AND NOT InGlasTransportNachfolger.bAuslaufsensor )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_20_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor
         - Verfahrwegueberwachung
      *)
      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

      IF ( ABS( rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition ) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_NICHT_FREI;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_700_E:
      // ---------------------------------------------------------------------------------------
      // SYSTEM CHECK MIT NACHFOLGER RÜCKWÄRTS
      //
      //  Hinweis:
      // - Das komplette Batch wird zurück auf das Shuttle geholt
      // ---------------------------------------------------------------------------------------

      bpOutBereitZumEintransport := TRUE;

      IF ( InGlasTransportNachfolger.bBereitZumAustransport  ) THEN
        steplCheck := STEP_710_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_710_E:
      (* Hinweis:
         - Scheiben zurück bis auf Einlauf fahren um sicherzustellen das alles wieder auf dem Shuttle ist
      *)
      IF NOT bpSensorEinlauf THEN
        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielposition    := - ppParameterBaustein.rWegUeberEinlauf;
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplCheck := STEP_720_E;

      ELSE
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_720_E:

      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
      END_IF

      (* Anmerkung:
         - Shuttle hat Scheiben zurückgefahren und ist fertig
      *)
      IF ( Antrieb.bpDone ) THEN
        bpStationBelegt := TRUE;
        Antrieb.rpGeschwindigkeit := 0.0;
        steplCheck := STEP_730_E;
      END_IF


      (* Anmerkung:
         - Es sind keine Scheiben auf dem Shuttle
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition)
           > ppParameterBaustein.rLaengeStation )
      THEN
        bpStationBelegt := FALSE;
        Antrieb.rpGeschwindigkeit := 0.0;
        steplCheck := STEP_730_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_730_E:
      (* Anmerkung:
         - Scheiben zurückgefahren ; Sensorik prüfen
      *)
      IF NOT bpSensorAuslauf AND NOT bpSensorEinlauf AND NOT Antrieb.bpAntrieblaeuft THEN
        bpOutBereitZumEintransport := FALSE;
        Antrieb.wpBetriebsart := RESTWEG;
        steplCheck := STEP_100_E;
      END_IF

      IF  bpSensorEinlauf THEN
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

      IF bpSensorAuslauf THEN
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_800_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONAL - SCHEIBENLAENGENVERMSSUNG
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        IF ( bpMessungSystemCheckAktiv
             AND NOT pAuftrag.bModell )
        THEN

          IF ( bpStationBelegt ) THEN
            steplCheck := STEP_810_E;
          ELSE
            steplCheck := STEP_890_E;
          END_IF

        ELSE // ohne Scheibenmesssung

          rlScheibenMessungErgebnis := 1;

          IF ( bpStationBelegt ) THEN
            pAuftrag.stAuftragsOptionen.eGlastransport := eGlastransport_AufEinlauf;
            steplCheck := STEP_850_E;
          ELSE
            steplCheck := STEP_890_E;
          END_IF

        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_810_E:
      (* Anmerkung:
         - Sicherstellen das der Einlaufsensor belegt ist
      *)
      IF ( NOT bpSensorEinlauf ) THEN
        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberSensorSystemCheck;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplCheck := STEP_820_E;

      ELSE
        steplCheck := STEP_830_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_820_E:
      (* Anmerkung:
         - Sicherstellen das der Antrieb nicht mehr laeuft
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_830_E;
      END_IF

      (* Fehlerbehandlung:
         - Sensoren
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_830_E:
      (* Anmerkung:
         - Starten der Glaslaengenvermessung
         - Zuruecksetzen der Scheibenlaenge
         - Verzoegerungsrampe von 500 ms verwenden
      *)
      rlScheibenMessungErgebnis := 0.0;


      Scheibenmessung.bpDrehrichtungsumkehrMessung := bpMessrichtungNegativ;
      Scheibenmessung.bpGlasvermessung             := TRUE;

      IF ( Scheibenmessung.bpGlasmessungAbgeschlossen ) THEN
        Scheibenmessung.bpGlasvermessung := FALSE;
        rlScheibenMessungErgebnis := Scheibenmessung.rpGemesseneGlaslaenge;
        steplCheck := STEP_840_E;
      END_IF

      (* Fehlerbehandlung:
         - Scheibenmessung
      *)
      IF ( Scheibenmessung.bpFehler ) THEN
        Scheibenmessung.bpGlasvermessung := FALSE;
        wpFehlerNr := Scheibenmessung.wpFehlerNr;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_840_E:
      (* Hinweis:
         - Betriebsart des Antriebs zuruecksetzen
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        (* Hinweis:
        *)
        IF bpScheibeNachSystemcheckAufAuslaufsensor THEN
          steplCheck := STEP_845_E;
        ELSE
          steplCheck := STEP_850_E;
        END_IF
      END_IF

    // SYSTEM CHECK=========================
    STEP_845_E:
      (* Hinweis:
         - Glas zurueck auf den Auslaufsensor Positionieren [ Restwegpositionierung negativ auf den Einlaufsensor ]
      *)
      rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberEinlaufRueck;
      Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
      Antrieb.wpBetriebsart     := RESTWEG;

      steplCheck := STEP_846_E;

    // SYSTEM CHECK=========================
    STEP_846_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_890_E;
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Sensorik
      *)
      IF (ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_AUSLAUF_NICHT_FREI;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_900_E;
      END_IF

      IF ( bpSensorAuslauf AND bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_850_E:
      (* Hinweis:
         - Glas positionieren
      *)
      rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSystemcheck;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      CASE pAuftrag.stAuftragsOptionen.eGlastransport OF

          eGlastransport_AufEinlauf,
            eGlastransport_AufEinlaufVorab:

          IF NOT bpSensorEinlauf THEN
            Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
            IF pAuftrag.bLetzteScheibe THEN
              Antrieb.rpZielPosition      := ppParameterBaustein.rWegUeberSensorLetzteScheibe;
            ELSE
              Antrieb.rpZielPosition      := ppParameterBaustein.rWegUeberEinlauf;
            END_IF
          ELSE
            Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
            IF pAuftrag.bLetzteScheibe THEN
              Antrieb.rpZielPosition      := ppParameterBaustein.rWegUeberSensorLetzteScheibe;
            ELSE
              Antrieb.rpZielPosition      := ppParameterBaustein.rWegUeberEinlauf;
            END_IF
          END_IF

          Antrieb.wpBetriebsart     := RESTWEG;

          steplCheck := STEP_860_E;

        eGlastransport_AufAuslauf:

          IF NOT bpSensorAuslauf THEN
            Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberSensorSystemCheck;
            Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
          ELSE
            Antrieb.rpZielPosition    := - ppParameterBaustein.rWegUeberSensorSystemCheck;
            Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor2;
          END_IF

          Antrieb.wpBetriebsart     := RESTWEG;

          steplCheck := STEP_870_E;

        ELSE
          // Falscher Auftrag
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_AUFTRAGSDATEN_UNGUELTIG;
          steplCheck := STEP_900_E;
      END_CASE


    // SYSTEM CHECK=========================
    STEP_860_E:

      IF bpSensorEinlaufVorab THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVerySlow;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_890_E;

        IF ( bpSensorEinlauf ) THEN
          Antrieb.wpBetriebsart := KEINE_FUNKTION;
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT;
          steplCheck := STEP_900_E;
        END_IF
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Sensorik
      *)
      IF (ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_SCHALTET_NICHT;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_900_E;
      END_IF

      IF ( bpSensorAuslaufStopp AND bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_870_E:

      IF bpSensorAuslaufVorab THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVerySlow;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_890_E;


        IF ( bpSensorEinlauf ) THEN
          Antrieb.wpBetriebsart := KEINE_FUNKTION;
          wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_BELEGT;
          steplCheck := STEP_900_E;
        END_IF

      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Sensorik
      *)
      IF (ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_SCHALTET_NICHT;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_900_E;
      END_IF

      IF ( bpSensorAuslaufStopp AND bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SYSTEMCHECK_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_890_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NACHRICHT ABSETZEN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Nachricht fuer die Glaslaenge absetzen
      //     => Nachricht muss auch abgesetzt werden wenn die Station leer ist
      //   - Messstrecke merken fuer einen eventuellen Eintransport
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        IF ( bpStationBelegt ) THEN
          rlGefahreneStreckeEintransport := rlScheibenMessungErgebnis;

          wSps2MmiMessungStationNummer    := stStationsNummern.NummerIntern;
          wSps2MmiMessungSlotNummer       := wpWandNr;
          iSps2MmiMessungScheibenanzahl   := 1;
          rSps2MmiMessungScheibenlaenge   := rlScheibenMessungErgebnis;

          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );
        ELSE

          wSps2MmiMessungStationNummer    := stStationsNummern.NummerIntern;
          wSps2MmiMessungSlotNummer       := wpWandNr;
          iSps2MmiMessungScheibenanzahl   := 0;
          rSps2MmiMessungScheibenlaenge   := 0;

          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

        END_IF

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplCheck := STEP_1000_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_900_E:
      (* Fehlerbehandlung:
         - Dem MMI die fehlerhafte Messung mitteilen
           ( -1 in iSps2MmiMessungScheibenanzahl ist die Fehlererkennung für das MMI )
      *)
      bpFehler := TRUE;

      wSps2MmiMessungStationNummer    := stStationsNummern.NummerIntern;
      wSps2MmiMessungSlotNummer       := wpWandNr;
      iSps2MmiMessungScheibenanzahl   := -1;
      rSps2MmiMessungScheibenlaenge   := 0;

      MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

      steplCheck := STEP_910_E;

    // SYSTEM CHECK=========================
    STEP_910_E:
      bpFehler := TRUE;

    // SYSTEM CHECK=========================
    STEP_1000_E: ;
      bpDone := TRUE;

  // SYSTEM CHECK=========================
  END_CASE
ELSE
  (* Hinweis:
     - SystemCheck zurücksetzen wenn abgebrochen, oder ein Betriebsart
       wechsel stattgefunden hat.
  *)
  IF (steplCheck > STEP_0_E ) THEN
    bpDone := FALSE;
    bprtScheibe := FALSE;

    Scheibenmessung.bpGlasvermessung := FALSE;

    bpOutBereitZumAustransport := FALSE;
    bpOutBereitZumEintransport := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    tonlAntriebNichtFreigegeben( IN := FALSE );
    steplCheck:=STEP_0_E;
  END_IF
END_IF
END_ACTION