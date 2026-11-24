(* METADATA
{
	"v3Meta": {
		"objectGuid": "58c82cd7-6b73-4ba5-a034-1c0e45575beb"
	}
}
*)
ACTION GlasPositionierungGreifer
//-------------------------------------------------------------------------------------------------
// AKTION GLAS POSITIONIEREN FUER DEN GREIFER
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Scheibe vor dem Austransport mit dem Greifer um rpWegGlasUebergabeposition ueber den Sensor
     der Greiferseite positionieren (Restwegpositionierung)
   - Ist der Sensor der Greiferseite schon belegt, steht die Scheibe durch die Vorab-Ansteuerung
     bereits in Position: es wird nicht neu positioniert
*)
IF (     bpStarteGlasPositionierungGreifer
     AND bpFreigabe
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplGlasPositionierungGreifer := STEP_900_E;
  END_IF

  CASE steplGlasPositionierungGreifer OF
    // GLAS POSITIONIEREN GREIFER ==============================
    STEP_0_E:
      (* Hinweis:
         - Antrieb bereit
      *)
      bpGlasPositionierungGreiferAbgeschlossen := FALSE;

      IF (     Antrieb.bpReglerBereit
           AND blAntriebsKopplungAktiv )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        tonlUeberwachungGreiferBetrieb( IN := FALSE );
        steplGlasPositionierungGreifer := STEP_10_E;
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlUeberwachungGreiferBetrieb( IN := NOT ( Antrieb.bpReglerBereit AND blAntriebsKopplungAktiv ),
                                      PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlUeberwachungGreiferBetrieb.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplGlasPositionierungGreifer := STEP_900_E;
      END_IF

    // GLAS POSITIONIEREN GREIFER ==============================
    STEP_10_E:
      (* Hinweis:
         - Sensor der Greiferseite belegt: Scheibe steht bereits in Position (Vorab-Ansteuerung)
         - Sensor frei: Scheibe neu auf den Sensor positionieren
      *)
      rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

      IF (    (     bpGlasPositionierungEinlaufseite AND bpSensorEinlauf )
           OR ( NOT bpGlasPositionierungEinlaufseite AND bpSensorAuslauf ) )
      THEN
        steplGlasPositionierungGreifer := STEP_1000_E;
      ELSE
        steplGlasPositionierungGreifer := STEP_100_E;
      END_IF

    // GLAS POSITIONIEREN GREIFER ==============================
    STEP_100_E:
      (* Hinweis:
         - Sensor der Greiferseite frei: Restwegpositionierung ueber den Sensor der Greiferseite
           => Auslaufseite: positiv, steigende Flanke Sensor 2
           => Einlaufseite: negativ, steigende Flanke Sensor 1
      *)
      rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      IF ( bpGlasPositionierungEinlaufseite ) THEN
        Antrieb.rpZielposition := - ( rpWegGlasUebergabeposition - pAuftrag.rModellVersatzVorne );
        Antrieb.wpRestwegMode  := Negativ_Steigend_Sensor1;
      ELSE
        Antrieb.rpZielposition := ( rpWegGlasUebergabeposition - pAuftrag.rModellVersatzVorne );
        Antrieb.wpRestwegMode  := Positiv_Steigend_Sensor2;
      END_IF

      Antrieb.wpBetriebsart := RESTWEG;

      steplGlasPositionierungGreifer := STEP_110_E;

    // GLAS POSITIONIEREN GREIFER ==============================
    STEP_110_E:
      (* Hinweis:
         - Vorabsensor belegt: langsamer fahren
         - Positionierung abgeschlossen, Sensor der Greiferseite belegt
      *)
      IF (    (     bpGlasPositionierungEinlaufseite AND bpSensorEinlaufVorab )
           OR ( NOT bpGlasPositionierungEinlaufseite AND bpSensorAuslaufVorab ) )
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit15;
      END_IF

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF (    (     bpGlasPositionierungEinlaufseite AND bpSensorEinlauf )
             OR ( NOT bpGlasPositionierungEinlaufseite AND bpSensorAuslauf ) )
        THEN
          steplGlasPositionierungGreifer := STEP_1000_E;
        ELSE
          IF ( bpGlasPositionierungEinlaufseite ) THEN
            wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_SCHALTET_NICHT;
          ELSE
            wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_SCHALTET_NICHT;
          END_IF
          steplGlasPositionierungGreifer := STEP_900_E;
        END_IF
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung: Sensor schaltet nicht innerhalb der Stationslaenge
      *)
      IF ( ABS( rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition ) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF ( bpGlasPositionierungEinlaufseite ) THEN
          wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_SCHALTET_NICHT;
        ELSE
          wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_SCHALTET_NICHT;
        END_IF
        steplGlasPositionierungGreifer := STEP_900_E;
      END_IF

    // GLAS POSITIONIEREN GREIFER ==============================
    STEP_900_E:
      bpFehler := TRUE;

    // GLAS POSITIONIEREN GREIFER ==============================
    STEP_1000_E:
      bpGlasPositionierungGreiferAbgeschlossen := TRUE;

  // GLAS POSITIONIEREN GREIFER ==============================
  END_CASE

ELSE

  IF ( steplGlasPositionierungGreifer > STEP_0_E ) THEN
    bpGlasPositionierungGreiferAbgeschlossen := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    tonlUeberwachungGreiferBetrieb( IN := FALSE );
    steplGlasPositionierungGreifer := STEP_0_E;
  END_IF

END_IF
END_ACTION