(* METADATA
{
  "v3Meta": {
    "objectGuid": "5639b462-9059-4633-88bd-eface16bcdf3"
  }
}
*)
ACTION GlasVorabPositionierung_Rueckwaertig
//-------------------------------------------------------------------------------------------------
// AKTION GLAS VORABPOSITIONIEREN RUECKWAERTS
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Positionieren des Glases
*)
IF (  bpStarteVorabPositionierungRueckwaertig
     AND bpAutomatikAktiv )
THEN

  (* Ausnahmefehler:
     - ANTRIEB
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplVorabpositionierenRueckwaertig := STEP_900_E;
  END_IF

  CASE steplVorabpositionierenRueckwaertig OF
    // GLAS VORPOSITIONIEREN ====================
    STEP_0_E:
      (* Hinweis:
         - Pruefen ob der Antrieb bereit zum verfahren ist
      *)
      bpDone := FALSE;

      IF ( Antrieb.bpReglerBereit 
           AND blAntriebsKopplungAktiv )
      THEN
        steplVorabpositionierenRueckwaertig := STEP_10_E;
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit AND blAntriebsKopplungAktiv ),
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplVorabpositionierenRueckwaertig := STEP_900_E;
      END_IF

    // GLAS VORPOSITIONIEREN ====================
    STEP_10_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< POSITIONIEREN UEBER DEN EINLAUFSENSOR [EINLAUFSEITE] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Sicherstellen das der Einlaufsensor nicht belegt ist
      //   - Geschwindigkreit reduzieren wenn der Vorabstob schon belegt ist
      //     [Besseres Ergebnis fuer die Restwegpositionierung]
      IF ( NOT bpSensorEinlauf ) THEN

        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        IF ( bpSensorEinlaufVorab ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
        END_IF

        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        // Ziel = Flankenposition + Zielwert, rueckwaerts deshalb negativ
        Antrieb.rpZielposition    := - ( ppParameterBaustein.rWegUeberEinlaufRueck - pAuftrag.rModellVersatzVorne );
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplVorabpositionierenRueckwaertig := STEP_20_E;

      ELSE

        (* Hinweis:
           - Die Scheibe steht undefiniert auf dem Einlaufsensor (es war kein Eintransport):
             erst zurueck, den Sensor freifahren, dann neu anfahren
        *)
        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        steplVorabpositionierenRueckwaertig := STEP_5_E;

      END_IF

    // GLAS VORPOSITIONIEREN ====================
    STEP_5_E:
      (* Hinweis:
         - Einlaufsensor freifahren (zurueck), danach in STEP_10 neu anfahren
      *)
      IF ( NOT toflEinlaufsensorFrei.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVorabpositionierenRueckwaertig := STEP_6_E;

      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor belegt
         - Verfahrweg- Ueberwachung
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplVorabpositionierenRueckwaertig := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_NICHT_FREI;
        steplVorabpositionierenRueckwaertig := STEP_900_E;
      END_IF

    // GLAS VORPOSITIONIEREN ====================
    STEP_6_E:
      (* Hinweis:
         - Warten bis der Antrieb steht, dann den Sensor neu anfahren
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        steplVorabpositionierenRueckwaertig := STEP_10_E;
      END_IF

    // GLAS VORPOSITIONIEREN ====================
    STEP_20_E:
      // Vorabstop- Sensor:
      //   - Langsame Autotransportgeschwindigkeit in 20.0 m/min
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
      END_IF

      IF ( Antrieb.bpDone
           AND bpSensorEinlauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVorabpositionierenRueckwaertig := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufsensor schaltet nicht [Wegueberwachung]
         - Antrieb
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) >  ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplVorabpositionierenRueckwaertig := STEP_900_E;
      END_IF

      IF ( Antrieb.bpDone
           AND NOT bpSensorEinlauf )
      THEN
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVorabpositionierenRueckwaertig := STEP_900_E;
      END_IF

      IF ( bpSensorEinlaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplVorabpositionierenRueckwaertig := STEP_900_E;
      END_IF

    // GLAS POSITIONIEREN ====================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< EINLAUFSENSOR FREI FAHREN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Versuchen den Einlaufsensor frei zufahren
      // TODO Option zum einlauf freifahren / ansonsten nur einlaufstopp   // toflEinlaufsensorFrei
      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflEinlaufsensorSTOP.Q )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplVorabpositionierenRueckwaertig := STEP_110_E;

      END_IF

      IF ( toflEinlaufsensorSTOP.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor belegt
         - Verfahrweg- Ueberwachung
      *)
      IF ( bpSensorAuslauf ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplVorabpositionierenRueckwaertig := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_NICHT_FREI;
        steplVorabpositionierenRueckwaertig := STEP_900_E;
      END_IF

    // GLAS POSITIONIEREN ====================
    STEP_110_E:
      (* Hinweis:
         - Zum Anfang springen
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        steplVorabpositionierenRueckwaertig := STEP_1000_E;
      END_IF

    // GLAS VORPOSITIONIEREN ====================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpFehler := TRUE;

    // GLAS VORPOSITIONIEREN ====================
    STEP_1000_E:
      bpDone := TRUE;

  // GLAS VORPOSITIONIEREN ====================

  END_CASE
ELSE
  IF ( steplVorabpositionierenRueckwaertig > STEP_0_E ) THEN

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    bpDone := FALSE;

    tonlAntriebNichtFreigegeben( IN := FALSE );
    steplVorabpositionierenRueckwaertig := STEP_0_E;
  END_IF
END_IF
END_ACTION