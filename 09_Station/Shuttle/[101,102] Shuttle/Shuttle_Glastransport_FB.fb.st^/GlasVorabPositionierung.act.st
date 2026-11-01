(* METADATA
{
  "v3Meta": {
    "objectGuid": "3deafaa9-98a9-45ec-a54e-2057b9ccc9da"
  }
}
*)
ACTION GlasVorabPositionierung
(***************************************************************************************************)
(* AKTION GLAS VORABPOSITIONIEREN *)
(***************************************************************************************************)
(* Hinweis:
   - Positionieren des Glases 
*)
IF (  bpStarteVorabPositionierung
     AND bpAutomatikAktiv )
THEN

  (* Ausnahmefehler
    - ANTRIEB
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplVorabpositionieren := STEP_900_E;
  END_IF

  CASE steplVorabpositionieren OF
    (* GLAS VORPOSITIONIEREN ====================*)
    STEP_0_E:
      (* Hinweis:
         - Pruefen ob der Antrieb bereit zum verfahren ist
      *)
      bpDone := FALSE;

      IF ( Antrieb.bpReglerBereit 
           AND blAntriebsKopplungAktiv )
      THEN
        steplVorabpositionieren := STEP_10_E;
      END_IF

    (* GLAS VORPOSITIONIEREN ====================*)
    STEP_10_E:
      (* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< POSITIONIEREN UEBER DEN AUSLAUFSENSOR [AUSLAUFSEITE] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
         
         Hinweis:
         - Sicherstellen das der Auslaufsensor nicht belegt ist
         - Geschwindigkreit reduzieren wenn der Vorabstob schon belegt ist 
           [Besseres Ergebnis fuer die Restwegpositionierung]
      *)
      IF ( NOT bpSensorAuslauf ) THEN

        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        IF ( bpSensorAuslaufVorab ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
        END_IF

        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpZielposition    := ( ppParameterBaustein.rWegUeberAuslauf - pAuftrag.rModellVersatzHinten );
        Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplVorabpositionieren := STEP_20_E;

      ELSE

        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

        steplVorabpositionieren := STEP_100_E;

      END_IF

    (* GLAS VORPOSITIONIEREN ====================*)
    STEP_20_E:
      (* Vorabstop- Sensor:
         - Langsame Autotransportgeschwindigkeit in 20.0 m/min 
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
      END_IF

      IF ( Antrieb.bpDone
           AND bpSensorAuslauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVorabpositionieren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung
         - Auslaufsensor schaltet nicht [Wegueberwachung]
         - Antrieb
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) >  ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplVorabpositionieren := STEP_900_E;
      END_IF

      IF ( Antrieb.bpDone
           AND NOT bpSensorAuslauf )
      THEN
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVorabpositionieren := STEP_900_E;
      END_IF

      IF ( bpSensorAuslaufStopp ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplVorabpositionieren := STEP_900_E;
      END_IF

    (* GLAS POSITIONIEREN ====================*)
    STEP_100_E:
      (* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< AUSLAUFSENSOR FREI FAHREN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
         Hinweis:
         - Versuchen den Auslaufsensor frei zufahren
      *)
      // TODO Option zum auslauf freifahren / ansonsten nur auslaufstopp   // toflAuslaufsensorFrei
      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflAuslaufsensorSTOP.Q )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplVorabpositionieren := STEP_110_E;

      END_IF

      IF ( toflAuslaufsensorSTOP.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung
         - Einlaufsensor belegt
         - Verfahrweg- Ueberwachung 
      *)
      IF ( bpSensorEinlauf ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplVorabpositionieren := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        bpOutBereitZumAustransport := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_NICHT_FREI;
        steplVorabpositionieren := STEP_900_E;
      END_IF

    (* GLAS POSITIONIEREN ====================*)
    STEP_110_E:
      (*  Hinweis:
         - Zum Anfang springen
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        steplVorabpositionieren := STEP_1000_E;
      END_IF

    (* GLAS VORPOSITIONIEREN ====================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bpFehler := TRUE;

    (* GLAS VORPOSITIONIEREN ====================*)
    STEP_1000_E:
      bpDone := TRUE;

  (* GLAS VORPOSITIONIEREN ====================*)

  END_CASE
ELSE
  IF ( steplVorabpositionieren > STEP_0_E ) THEN

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    bpDone := FALSE;

    steplVorabpositionieren := STEP_0_E;
  END_IF
END_IF
END_ACTION