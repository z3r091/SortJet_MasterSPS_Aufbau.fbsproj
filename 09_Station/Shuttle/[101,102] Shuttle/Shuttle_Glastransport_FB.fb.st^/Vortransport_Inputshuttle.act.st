(* METADATA
{
	"v3Meta": {
		"objectGuid": "4cdacd77-985d-4986-9472-a0339eee8879"
	}
}
*)
ACTION Vortransport_Inputshuttle
(***************************************************************************************************)
(* AKTION: VORTRANSPORT *)
(***************************************************************************************************)
IF ( bpVortransport
  AND NOT bpEintransport
  AND NOT bpRueckwaertsEintransportieren
  AND bpAutomatikAktiv )
THEN
  CASE steplVortransport OF
(*VORTRANSPORT ==============================*)
    STEP_0_E:
	  
	 IF ( blAntriebsKopplungAktiv ) THEN
        steplVortransport := STEP_5_E;
	 END_IF
	 
(*VORTRANSPORT ==============================*)
    STEP_5_E:
      IF ( bpSensorAuslauf ) THEN
        steplVortransport := STEP_1000_E;
      ELSE
        steplVortransport := STEP_10_E;
      END_IF

(*VORTRANSPORT ==============================*)
    STEP_10_E:
      (* Hinweis:
          - Glas vorfahren
      *)
      IF ( NOT bpSensorAuslauf ) THEN

        rlAntriebIstPositionBeiStart := ABS( Antrieb.rpIstPosition );

        IF ( bpSensorAuslaufVorab ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
        END_IF

        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielposition    := ( ppParameterBaustein.rWegUeberAuslauf - pAuftrag.rModellVersatzVorne );

        Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
        Antrieb.wpBetriebsart     := RESTWEG;

        steplVortransport := STEP_20_E;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_BELEGT_RESTWEGPOSITIONIERUNG;

        steplVortransport := STEP_900_E;

      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)

      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
        steplVortransport := STEP_900_E;
      END_IF

(*VORTRANSPORT ==============================*)
    STEP_20_E:
      (* Hinweis:
         - Restweg- Positionierung abgeschlossen auf den Auslauf-Sensor
      *)
      IF ( Antrieb.bpDone
       AND bpSensorAuslauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_30_E;
      END_IF

      (* Fehlerbehandlung:
         - Glas moeglicherweise verkeilt \ gebrochen da der Auslaufsensor nicht schaltet
           bzw. nicht angefahren wird (Stationslaemge abfahren)
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - ABS(Antrieb.rpIstPosition)) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplVortransport := STEP_900_E;
      END_IF

      IF (  Antrieb.bpDone
        AND NOT bpSensorAuslauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplVortransport := STEP_900_E;
      END_IF

(*VORTRANSPORT ==============================*)
    STEP_30_E:
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_1000_E;
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
  IF (steplVortransport > STEP_0_E) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplVortransport := STEP_0_E;
  END_IF
END_IF
END_ACTION