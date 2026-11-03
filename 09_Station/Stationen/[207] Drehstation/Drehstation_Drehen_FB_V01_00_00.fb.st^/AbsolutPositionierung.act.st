(* METADATA
{
  "v3Meta": {
    "objectGuid": "8a9e4c0e-fdd1-4ecd-91eb-faaae42ab969"
  }
}
*)
ACTION AbsolutPositionierung
//-------------------------------------------------------------------------------------------------
// POSITIONIEREN
//-------------------------------------------------------------------------------------------------

(* Hinweis:
     => Trigger setzen wenn die Positionierung gestartet wird
*)
rtlStartePositionierung(CLK := bpStarteAbsolutPositionierung  );

// => Start der Positionierungs
IF (  bpStarteAbsolutPositionierung ) THEN

  (* Hinweis:
     - Sicherstellen das die Ausgangsvariable <xAusnahmeSituationSensorBelegt> beim ersten
       durchlauf zurueck gesetzt wird
  *)
  IF ( rtlStartePositionierung.Q ) THEN
    bpAusnahmeSituationSensorBelegt := FALSE;
  END_IF

  (* Hinweis:
     - Ausnahmesituationen abfangen
  *)
  IF ( bpAuslaufSensor
       AND NOT bpEinlaufSensor )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_DREHEN_SENSOR_AUSLAUF_BELEGT;

    (* Hinweis:
       - Ausnahmesituation ggf versuchen die Situation zu bereinigen
    *)
    IF ( bpAusnahmeSituationAbfangen ) THEN
      bpAusnahmeSituationSensorBelegt := TRUE;
    ELSE
      steplAbsolutPositionieren := STEP_900_E;
    END_IF

  ELSIF ( bpEinlaufSensor
          AND NOT bpAuslaufSensor  )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_DREHEN_SENSOR_EINLAUF_BELEGT;

    (* Hinweis:
       - Ausnahmesituation ggf versuchen die Situation zu bereinigen
    *)
    IF ( bpAusnahmeSituationAbfangen ) THEN
      bpAusnahmeSituationSensorBelegt := TRUE;
    ELSE
      steplAbsolutPositionieren := STEP_900_E;
    END_IF

  ELSIF ( bpEinlaufSensor
          AND bpAuslaufSensor )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_DREHEN_SENSOR_EINLAUF_AUSLAUF_BELEGT;
    steplAbsolutPositionieren := STEP_900_E;
  END_IF


  (* Ausnahmefehler:
     - Antrieb
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
    steplAbsolutPositionieren := STEP_900_E;
  END_IF


  (* Hinweis:
     - Starten der Schrittkette zum Positionieren
  *)
  CASE steplAbsolutPositionieren OF
    // ABSOLUT POSITIONIEREN =========================
    STEP_0_E:
      (* Hinweis:
         - Variablen zurueck setzen
         - Pruefen ob der Antrieb bereit zum verfahrern ist
      *)
      bpDone              := FALSE;
      bpDrehStatusMelden  := FALSE;
      bpAbsolutPositionierungAbgeschlossen := FALSE;

      epDrehPositionsAlt := epDrehPositionsStatus;

      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.wpBetriebsart     := KEINE_FUNKTION;

      steplAbsolutPositionieren := STEP_10_E;

    // ABSOLUT POSITIONIEREN =========================
    STEP_10_E:
      (* Hinweis:
         - Es darf weder der Einlauf noch der Auslauf- Sensor während der Dreh-Bewegung belegt sein
      *)
      IF NOT ( bpEinlaufSensor OR bpAuslaufSensor ) THEN

        IF ( NOT ( epDrehPositionsStatus = epZielPosition )) THEN

          steplAbsolutPositionieren := STEP_20_E;

        ELSE

          IF ( Arretierung.epStatusZylinder = eZylinderAusgefahren ) THEN
            (* Anmerkung:
               - Melden der Drehposition ans MMI zur Datensynchronisation für den
                 weiteren Automatikabaluf
            *)
            wgSps2MmiDrehStation       := stStationsNummern.NummerIntern;
            wgSps2MmiPosDrehStation    := epDrehPositionsStatus;
            wgSps2MmiOldPosDrehStation := epDrehPositionsAlt;
            MsgToMmi( auftragsnr_w := SB0_SPS_TURNSTATIONPOSITION );
            steplAbsolutPositionieren := STEP_1000_E;
          ELSE
            steplAbsolutPositionieren := STEP_200_E;
          END_IF



        END_IF

      ELSE

        IF ( bpAuslaufSensor AND NOT bpEinlaufSensor ) THEN
          wpFehlerNr := cMELDUNG_DREHEN_SENSOR_AUSLAUF_BELEGT;
          steplAbsolutPositionieren := STEP_900_E;

        ELSIF ( bpEinlaufSensor AND NOT bpAuslaufSensor  ) THEN
          wpFehlerNr := cMELDUNG_DREHEN_SENSOR_EINLAUF_BELEGT;
          steplAbsolutPositionieren := STEP_900_E;

        ELSE
          wpFehlerNr := cMELDUNG_DREHEN_SENSOR_EINLAUF_AUSLAUF_BELEGT;
          steplAbsolutPositionieren := STEP_900_E;

        END_IF

      END_IF

    // ABSOLUT POSITIONIEREN =========================
    STEP_20_E:
      // ---------------------------------------------------------------------------------------
      //  SICHERUNGSBOLZEN EINFAHREN
      //
      //  Hinweis:
      // - Loesen der Arretierung
      // ---------------------------------------------------------------------------------------

      Arretierung.bpStartEinfahren := TRUE;
      steplAbsolutPositionieren := STEP_30_E;

    // ABSOLUT POSITIONIEREN =========================
    STEP_30_E:
      (* Hinweis:
         - Arretierung ist eingefahren
      *)
      IF ( Arretierung.bpDone OR NOT ppParameterBaustein.bArretierung ) THEN
        Arretierung.bpStartEinfahren := FALSE;
        steplAbsolutPositionieren := STEP_35_E;
      END_IF

      (* Fehlerbehandlung:
         - Arretierung [Pneumatik Zylinder]
      *)
      IF ( Arretierung.bpFehler ) THEN
        Arretierung.bpStartEinfahren := FALSE;
        wpFehlerNr := Arretierung.wpFehlerNr;
        steplAbsolutPositionieren := STEP_900_E;
      END_IF

    // ABSOLUT POSITIONIEREN =========================
    STEP_35_E:

      (* Hinweis:
         - Ist der Antrieb Bereit?
      *)
      IF ( Antrieb.bpReglerBereit ) THEN
        steplAbsolutPositionieren := STEP_40_E;
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit ),
                                   PT := T#5S );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplAbsolutPositionieren := STEP_900_E;
      END_IF

    // ABSOLUT POSITIONIEREN =========================
    STEP_40_E:
      // ---------------------------------------------------------------------------------------
      //  ENDSCHALTER PRUEFEN
      //
      //  Hinweis:
      // - Vor dem Verfahren pruefen ob der Antrieb in einem Endschalter steht
      // ---------------------------------------------------------------------------------------

      IF (  NOT Antrieb.bpMinSchalterBelegt
           AND NOT Antrieb.bpMaxSchalterBelegt )
      THEN
        steplAbsolutPositionieren := STEP_100_E;
      ELSE
        steplAbsolutPositionieren := STEP_50_E;
      END_IF

    // ABSOLUT POSITIONIEREN =========================
    STEP_50_E:
      (* Hinweis:
         - Versuchen den Endschalter frei zufahren
           WICHTIG [PROJEKT INTERPANE HOERDT]
         - Geschwindigkeit sehrlangsam
      *)
      tonlEndschalterFreifahren( IN := TRUE, PT:= T#10s);

      toflHardwareEndschalterFrei( IN := ( NOT Antrieb.bpMaxSchalterBelegt
                                           AND NOT Antrieb.bpMinSchalterBelegt),
                                   PT := t#1s);

      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;

      IF ( Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDMINUS;
      END_IF

      IF ( Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDPLUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplAbsolutPositionieren := STEP_60_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei !
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND ( Antrieb.bpMinSchalterBelegt
                 OR  Antrieb.bpMaxSchalterBelegt ))
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_DREHEN_ENDSCHALTER_NICHT_FREI;
        steplAbsolutPositionieren := STEP_900_E;
      END_IF

      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplAbsolutPositionieren := STEP_900_E;
      END_IF

    // ABSOLUT POSITIONIEREN =========================
    STEP_60_E:
      (* Hinweis:
         - Erzwungene Pause, damit der Antrieb wieder ordnungsgemaeß schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT:= T#2s);

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        tonlWarteSchrittEndschalterFreifahren(IN := FALSE );
        steplAbsolutPositionieren := STEP_100_E;
      END_IF

    // ABSOLUT POSITIONIEREN =========================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  PRUEFEN DER ZIEL-POSITION
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      steplAbsolutPositionieren := STEP_110_E;

      CASE epZielPosition OF

        eDrehPosition0Grad:
          rpZielPositionition := ppParameterBaustein.rDrehposition_0_Grad;

        eDrehPosition90Grad:
          rpZielPositionition := ppParameterBaustein.rDrehposition_90_Grad;

        ELSE
          wpFehlerNr := cMELDUNG_DREHEN_UNDEFINIERTE_POSITION;
          steplAbsolutPositionieren := STEP_900_E;

      END_CASE

    // ABSOLUT POSITIONIEREN =========================
    STEP_110_E:
      (* Hinweis:
         - Initialisierung der Daten
      *)
      IF bpBetriebsartHand THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;        
      ELSE
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      END_IF
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielposition    := rpZielPositionition;

      steplAbsolutPositionieren := STEP_120_E;

    // ABSOLUT POSITIONIEREN =========================
    STEP_120_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DER BEWEGUNG
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      Antrieb.wpBetriebsart     := ABSOLUT;

      steplAbsolutPositionieren := STEP_130_E;

    // ABSOLUT POSITIONIEREN =========================
    STEP_130_E:
      (* Hinweis:
         - Drehbewegung abgeschlossen
      *)
      IF ( Antrieb.bpDone ) THEN
        bpDrehStatusMelden := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAbsolutPositionieren := STEP_140_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
        steplAbsolutPositionieren := STEP_900_E;
      END_IF

    // ABSOLUT POSITIONIEREN =========================
    STEP_140_E:
      (* Anmerkung:
         - Setzen der Arretierung
      *)
      bpDrehStatusMelden := FALSE;

      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAbsolutPositionieren := STEP_200_E;
      END_IF

    // ABSOLUT POSITIONIEREN =========================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  ARRETIERUNG AUSFAHREN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------
      CASE epZielPosition OF

          eDrehPosition0Grad,
            eDrehPosition90Grad:

          Arretierung.bpStartAusfahren := TRUE;
          steplAbsolutPositionieren := STEP_210_E;

        ELSE
          wgSps2MmiDrehStation       := stStationsNummern.NummerIntern;
          wgSps2MmiPosDrehStation    := epDrehPositionsStatus;
          wgSps2MmiOldPosDrehStation := epDrehPositionsAlt;
          MsgToMmi( auftragsnr_w := SB0_SPS_TURNSTATIONPOSITION );

          steplAbsolutPositionieren := STEP_1000_E;
      END_CASE

    // ABSOLUT POSITIONIEREN =========================
    STEP_210_E:
      (* Hinweis:
         - Arretierung ist ausgefahren
      *)

      CASE epZielPosition OF

          eDrehPosition0Grad,
            eDrehPosition90Grad:

          IF ( Arretierung.bpDone OR NOT ppParameterBaustein.bArretierung ) THEN
            Arretierung.bpStartAusfahren := FALSE;
            (* Anmerkung:
               - melden der Drehposition ans MMI zur
                   Datensynchronisation für den weiteren Automatikabaluf
            *)
            wgSps2MmiDrehStation       := stStationsNummern.NummerIntern;
            wgSps2MmiPosDrehStation    := epDrehPositionsStatus;
            wgSps2MmiOldPosDrehStation := epDrehPositionsAlt;
            MsgToMmi( auftragsnr_w := SB0_SPS_TURNSTATIONPOSITION );
            steplAbsolutPositionieren := STEP_1000_E;
          END_IF

      END_CASE

      (* Fehlerbehandlung:
         - Arretierung [Pneumatik Zylinder]
      *)
      IF ( Arretierung.bpFehler ) THEN
        Arretierung.bpStartAusfahren := FALSE;
        wpFehlerNr := Arretierung.wpFehlerNr;
        steplAbsolutPositionieren := STEP_900_E;
      END_IF

    // ABSOLUT POSITIONIEREN =========================
    STEP_900_E:
      bpFehler := TRUE;

    // ABSOLUT POSITIONIEREN =========================
    STEP_1000_E:
      bpDone := TRUE;
      bpAbsolutPositionierungAbgeschlossen := TRUE;

  // ABSOLUT POSITIONIEREN =========================
  END_CASE

END_IF

IF ( NOT bpStarteAbsolutPositionierung ) THEN

  IF ( steplAbsolutPositionieren > STEP_0_E ) THEN
    bpDone := FALSE;
    bpAbsolutPositionierungAbgeschlossen := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    Arretierung.bpStartEinfahren := FALSE;
    Arretierung.bpStartAusfahren := FALSE;

    bpDrehStatusMelden := FALSE;

    tonlAntriebNichtFreigegeben( IN := FALSE );
    steplAbsolutPositionieren := STEP_0_E;
  END_IF

END_IF
END_ACTION