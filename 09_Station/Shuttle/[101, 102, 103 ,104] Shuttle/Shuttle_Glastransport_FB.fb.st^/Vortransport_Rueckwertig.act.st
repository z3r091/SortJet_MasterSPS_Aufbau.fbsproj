(* METADATA
{
	"v3Meta": {
		"objectGuid": "212d1682-b4c4-48ee-bfbf-4dbcb414330f"
	}
}
*)
ACTION Vortransport_Rueckwertig
(***************************************************************************************************)
(* AKTION: VORTRANSPORT [HANDMINUS] *)
(***************************************************************************************************)
IF ( bpVortransportRueck
  AND NOT bpEintransport
  AND NOT bpRueckwaertsEintransportieren
  AND bpAutomatikAktiv )
THEN

  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplVortransportRueckwertig := STEP_900_E;
  END_IF


  CASE steplVortransportRueckwertig OF
(*VORTRANSPORT ==============================*)
    STEP_0_E:
      (* Hinweis:
         - Vortransport nur wenn es keinen Modelversatz gibt
      *)
     bpDone := FALSE;
	   IF ( blAntriebsKopplungAktiv ) THEN
       steplVortransportRueckwertig := STEP_10_E;
     END_IF
	 
(*VORTRANSPORT ==============================*)
    STEP_10_E:
      IF (  NOT bpSensorEinlaufVorab
        AND pAuftrag.rModellVersatzVorne = 0 )
      THEN
        rlAntriebIstPositionBeiStart := ABS(Antrieb.rpIstPosition);

        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVorpositionieren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;

        steplVortransportRueckwertig := STEP_20_E;

      ELSE
        steplVortransportRueckwertig := STEP_1000_E;

      END_IF

      (* Fehlerbehandlung:
         - Sensorik
         - Antrieb
      *)
      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplVortransportRueckwertig := STEP_900_E;
      END_IF

(*VORTRANSPORT ==============================*)
    STEP_20_E:
      (* Hinweis:
         - Glas auf den VorStop- Sensor vorpositionieren
      *)
      IF ( bpSensorEinlaufVorab ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransportRueckwertig := STEP_30_E;
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Sensorik
      *)
      IF ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition)) > ppParameterBaustein.rLaengeStation THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_UND_EINLAUFVORAB_SCHALTEN_NICHT;
        steplVortransportRueckwertig := STEP_900_E;
      END_IF

      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplVortransportRueckwertig := STEP_900_E;
      END_IF

(*VORTRANSPORT ==============================*)
    STEP_30_E:
      (* Hinweis:
         - Pruefen ob das Glas zuweit gefahren wurde und den Auslaufsensor nun belegt ist.
           ggf. das Glas wider zurueck fahren
      *)
      IF (  NOT Antrieb.bpAntrieblaeuft ) THEN

        IF( bpSensorEinlauf ) THEN
          steplVortransportRueckwertig := STEP_40_E;
        ELSE
          steplVortransportRueckwertig := STEP_1000_E;
        END_IF

      END_IF

(*VORTRANSPORT ==============================*)
    STEP_40_E:
      (* Anmerkung:
         - Versuch den Auslaufsensor frei zufahren
      *)
      IF ( NOT toflEinlaufsensor.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransportRueckwertig := STEP_1000_E;
      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;
      END_IF

      (* Fehlerbehandlung
         - Sensorik
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplVortransportRueckwertig := STEP_900_E;
      END_IF

(*VORTRANSPORT ==============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bpFehler := TRUE;

(*VORTRANSPORT ==============================*)
    STEP_1000_E:
      bpDone := TRUE;

(*VORTRANSPORT ==============================*)
  END_CASE
ELSE

  IF (steplVortransportRueckwertig > 0) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplVortransportRueckwertig := STEP_0_E;
  END_IF

END_IF
END_ACTION