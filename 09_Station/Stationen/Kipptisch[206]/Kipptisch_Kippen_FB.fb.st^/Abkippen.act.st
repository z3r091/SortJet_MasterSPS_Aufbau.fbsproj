(* METADATA
{
  "v3Meta": {
    "objectGuid": "1763d8dc-f609-4d63-a8e6-f364ff6f2859"
  }
}
*)
ACTION Abkippen
(***************************************************************************************************)
(* AKTION ABKIPPEN *)
(***************************************************************************************************)

IF ( bpStartKippenAb
  AND NOT bpStartKippenAuf
  AND bpFreigabe )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_KIPPEN;
    steplKippenAb := STEP_900_E;
  END_IF


  CASE steplKippenAb OF
(* KIPPEN AB  ================*)
    STEP_0_E:
      bpDone := FALSE;

      IF Antrieb.bpReglerBereit  THEN
		  IF ( Antrieb.rpIstPosition = ppParameterBaustein.rPosition0Grad ) THEN
            steplKippenAb := STEP_1000_E;
		  ELSE		
            steplKippenAb := STEP_10_E;
		  END_IF
      END_IF

(* KIPPEN AB ================*)
    STEP_10_E:
      (* Anmerkung[Sensoren]
         - Einlauf- Auslauf- Sensoren duerfen nicht belegt 
         Anmerkung [Antrieb]:
         - Geschwindigkeit wird in U/min angegeben werden         
      *)
      IF (  NOT bpSensorEinlauf
        AND NOT bpSensorAuslauf )
      THEN

        IF ( bpLangsamKippen ) THEN
           Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
           Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
           Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;

        ELSIF ( bpBetriebsartHand ) THEN
           Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
           Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
           Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;

        ELSE
           Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
           Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
           Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;

        END_IF

        Antrieb.rpZielPosition := ppParameterBaustein.rPosition0Grad;
        Antrieb.wpBetriebsart  := ABSOLUT;

        steplKippenAb := STEP_20_E;
      END_IF

      // Fehlerbehandlung
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
        steplKippenAb := STEP_900_E;
      END_IF

      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr :=  SEL( bpSensorAuslauf, cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT, cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT );
        steplKippenAb := STEP_900_E;
      END_IF

(* KIPPEN AB  ================*)
    STEP_20_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        steplKippenAb := STEP_1000_E;
      END_IF

      // Fehlerbehandlung
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
        steplKippenAb := STEP_900_E;
      END_IF

      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr :=   cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT;
        IF ( bpSensorAuslauf ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
        END_IF
        steplKippenAb := STEP_900_E;

      END_IF

(* KIPPEN AB ================*)
    STEP_900_E:
     IF NOT Antrieb.bpAntrieblaeuft THEN
        steplKippenAb := STEP_910_E;
      END_IF

(* KIPPEN AB ================*)
    STEP_910_E:
      bpFehler := TRUE;

(* KIPPEN AB  ================*)
    STEP_1000_E:
      bpDone := TRUE;

(* KIPPEN AB  ================*)
  END_CASE
ELSE
  IF ( steplKippenAb > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    steplKippenAb := STEP_0_E;
  END_IF
END_IF
END_ACTION