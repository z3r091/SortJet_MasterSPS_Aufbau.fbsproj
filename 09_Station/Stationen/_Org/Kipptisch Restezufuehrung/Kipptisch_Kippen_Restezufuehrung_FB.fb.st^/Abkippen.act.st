(* METADATA
{
	"v3Meta": {
		"objectGuid": "c7fe1692-77fe-479d-b43a-92d1962c90b0"
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

  // Ausnahmesituation
  IF ( Antriebseinheit.bpFehler ) THEN
    Antriebseinheit.bpHeben  := FALSE;
    Antriebseinheit.bpSenken := FALSE;
    wpFehlerNr := Antriebseinheit.wpFehlerNr;
    steplKippenAb := STEP_900_E;
  END_IF

  CASE steplKippenAb OF
(* KIPPEN AB  ================*)
    STEP_0_E:
      (* Hinweis
         - Antriebseinheit muss oben sein        
      *)
      bpDone := FALSE;

      IF Antrieb.bpReglerBereit THEN
        IF ( epKippStatus = eKippen_Position_0Grad ) THEN
          steplKippenAb := STEP_100_E;
        ELSE		
          steplKippenAb := STEP_10_E;
        END_IF
      END_IF
      
(* KIPPEN AB ================*)
    STEP_10_E:
      (* Hinweis
         - Antriebseinheit muss oben sein        
      *)
      IF ( Antriebseinheit.bpFreigabeKippen ) THEN
        Antriebseinheit.bpHeben := FALSE;
        steplKippenAb := STEP_20_E;
      ELSE
        Antriebseinheit.bpHeben := TRUE;
      END_IF 
      
(* KIPPEN AB ================*)
    STEP_20_E:
      (* Hinweis[Sensoren]
         - Einlauf- Auslauf- Sensoren duerfen nicht belegt 
         Hinweis [Antrieb]:
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

        steplKippenAb := STEP_30_E;
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
    STEP_30_E:
      (* Hinweis
         - Antrieb meldet done        
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        steplKippenAb := STEP_100_E;
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
      
(* KIPPEN AB  ================*)
    STEP_100_E:
      (* Hinweis
         - Antriebseinheit muss unten sein        
      *)  
      IF Antriebseinheit.in_bAntriebseinheitUnten THEN
        Antriebseinheit.bpSenken := FALSE;
        steplKippenAb := STEP_1000_E;
      ELSE
        Antriebseinheit.bpSenken := TRUE;    
      END_IF
    
(* KIPPEN AB ================*)
    STEP_900_E:
      bpFehler := TRUE;
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
    
    Antriebseinheit.bpHeben  := FALSE;
    Antriebseinheit.bpSenken := FALSE;
    
    steplKippenAb := STEP_0_E;
    
  END_IF
END_IF
END_ACTION