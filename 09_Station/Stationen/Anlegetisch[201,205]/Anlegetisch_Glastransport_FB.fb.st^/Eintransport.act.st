(* METADATA
{
	"v3Meta": {
		"objectGuid": "96d228cf-d746-4fe5-9c98-31003f1298ea"
	}
}
*)
ACTION Eintransport
(***************************************************************************************************)
(* AKTION: EINTRANSPORT VSG *)
(***************************************************************************************************)
IF ( bpEintransport
  AND bpAutomatikAktiv )
THEN

  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplEintransport := STEP_900_E;
  END_IF

  CASE steplEintransport OF
  (*EINTRANSPORT =====================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen setzen
      *)
      bpDone := FALSE;
      steplEintransport := STEP_10_E;

(*EINTRANSPORT =====================*)
    STEP_10_E:

      (* Anmerkung:
         - Warten bis die Vorgaengerstation bereit zum Austransport ist [Master-Slave-Kopplung / Soll-Geschwindigkeits- Kopplung]         
      *)
      Antrieb.rpGeschwindigkeit  := 0.0;

      bpOutBereitZumEintransport := TRUE; // Analogkopplung der Brechanlage; die Folgen uns solange, bis wir das GlasAbruf wegnehmen

      IF ( InGlasTransportVorgaenger.bBereitZumAustransport ) THEN
        steplEintransport := STEP_20_E;
      END_IF

(*EINTRANSPORT =====================*)
    STEP_20_E:

     IF NOT bpSensorEinlauf THEN

       rlPositionAntriebBeiStart := ABS(Antrieb.rpIstPosition);

       Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
       Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
       Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

	   IF ( eGlastyp = cMAXSCHEIBE ) THEN
         Antrieb.rpZielPosition := ppParameterBaustein.rWegEinlaufsensorZuVorStopSensor;
	   ELSE
         Antrieb.rpZielPosition := pAuftrag.rAuftragsLaenge - ppParameterBaustein.rWegUeberEinlaufEintransport;
	   END_IF

       Antrieb.wpRestwegMode     := cRestwegPositivAufDieSteigendeFlankeVonSensor1;
       Antrieb.wpBetriebsart     := RESTWEG;

       steplEintransport := STEP_30_E;
     ELSE
       steplEintransport := STEP_1000_E;

     END_IF

(*EINTRANSPORT =====================*)
    STEP_30_E:

      IF ( bpSensorEinlauf ) THEN
        steplEintransport := STEP_40_E;
      END_IF

      (* Fehlerbehandlung
         - Auslaufsensor
         - Antrieb
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplEintransport := STEP_900_E;
      END_IF
		
      IF ( ABS(rlPositionAntriebBeiStart - ABS(Antrieb.rpIstPosition))>  ppParameterBaustein.rLaengeStation * 3 ) THEN (* so viel da die ProLam sehr lang ist *)
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplEintransport := STEP_900_E;
      END_IF

(*EINTRANSPORT =====================*)
    STEP_40_E:

      IF ( Antrieb.bpDone ) THEN
		  
	    IF ( eGlastyp <> cMAXSCHEIBE ) THEN
          bpOutBereitZumEintransport := FALSE;
	    END_IF
	   
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_50_E;
      END_IF

(*EINTRANSPORT =====================*)
    STEP_50_E:
      (* Hinweis:
         - Sicherstellen das der Antrieb steht 
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN

        IF ( NOT bpSensorAuslauf AND bpSensorEinlauf ) THEN
          tonlMaximaleZeitAuslaufsensorFreiFahren ( IN:= FALSE);
          steplEintransport := STEP_1000_E;
        ELSE
          IF bpSensorAuslauf THEN
             steplEintransport := STEP_200_E; (* Auslauf freifahren *)
           ELSIF NOT bpSensorEinlauf THEN
             steplEintransport := STEP_300_E; (* Einlauf belegen *)
           END_IF
        END_IF

      END_IF

(*EINTRANSPORT =====================*)
    STEP_200_E:
      (* Anmerkung:
         - Pruefen ob noch eine Scheibe auf dem Einlaufsensor liegt
           Sonst versuchen den Sensor anzufahren  
      *)
      IF ( bpSensorAuslauf )THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSlow;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielPosition := - ppParameterBaustein.rWegUeberEinlauf;

        Antrieb.wpRestwegMode     := cRestwegNegativAufDieFallendeFlankeVonSensor2;
        Antrieb.wpBetriebsart     := RESTWEG;
        steplEintransport := STEP_500_E;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_100_E;

      END_IF

(*EINTRANSPORT =====================*)
    STEP_300_E:
      (* Anmerkung:
         - Pruefen ob noch eine Scheibe auf dem Einlaufsensor liegt
           Sonst versuchen den Sensor anzufahren  
      *)
      IF ( NOT bpSensorEinlauf )THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSlow;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

        Antrieb.rpZielPosition    :=  - ppParameterBaustein.rWegUeberEinlaufEintransport;

        Antrieb.wpRestwegMode     := cRestwegNegativAufDieSteigendeFlankeVonSensor1;
        Antrieb.wpBetriebsart     := RESTWEG;
        steplEintransport := STEP_500_E;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_1000_E;

      END_IF

(*EINTRANSPORT =====================*)
    STEP_500_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplEintransport := STEP_1000_E;
      END_IF

(*EINTRANSPORT =====================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      bpFehler := TRUE;

(*EINTRANSPORT =====================*)
    STEP_1000_E:
      bprtScheibe := FALSE;
      bpDone := TRUE;

(*EINTRANSPORT =====================*)
  END_CASE
ELSE

  IF (steplEintransport > STEP_0_E) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplEintransport := STEP_0_E;
  END_IF

END_IF
END_ACTION