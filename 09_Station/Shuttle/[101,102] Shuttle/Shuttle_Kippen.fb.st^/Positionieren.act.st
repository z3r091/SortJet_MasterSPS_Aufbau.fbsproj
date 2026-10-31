(* METADATA
{
  "v3Meta": {
    "objectGuid": "cb845e03-578b-43ee-9c8a-d8a7a75644b7"
  }
}
*)
ACTION Positionieren
(***************************************************************************************************)
(* AKTION: AUFKIPPEN *)
(***************************************************************************************************)
IF ( bpPositionieren )THEN
  (* Fehlerbehandlung:
     - Kippantrieb
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_KIPPEN;
    steplPositionieren := STEP_900_E;
  END_IF

  CASE steplPositionieren OF
(* AUFKIPPEN  ================*)
    STEP_0_E:
      bpDone := FALSE;

	  IF epZielPosition = epKippStatus THEN
         steplPositionieren := STEP_1000_E;
	  ELSE
      IF Antrieb.bpReglerBereit
        AND bpFreigabe
      THEN
         steplPositionieren := STEP_10_E;
      END_IF
	  END_IF  

(* AUFKIPPEN ================*)
    STEP_10_E:
      (* Anmerkung
         - Einlauf- Auslauf- Sensoren duerfen nicht belegt sein beim Kippen
         - Geschwindigkeit muss in U/min angegeben werden
      *)
      IF bpLangsamKippen THEN
         Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
         Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
         Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
      ELSIF bpBetriebsartHand THEN
         Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
         Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
         Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
      ELSE
         Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
         Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
         Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      END_IF
	  
	  CASE epZielPosition OF
		  
        eKippen_Position_0Grad:
          Antrieb.rpZielPosition  := ppParameterBaustein.rPosition0Grad;
		
        eKippen_Position_84Grad:
          Antrieb.rpZielPosition  := ppParameterBaustein.rPosition84Grad;
		
        eKippen_Position_88_5Grad:
          Antrieb.rpZielPosition  := ppParameterBaustein.rPosition88_5Grad;
		
        eKippen_Position_90Grad:
          Antrieb.rpZielPosition  := ppParameterBaustein.rPosition90Grad;
	
		
      END_CASE

      Antrieb.wpBetriebsart   := ABSOLUT;

      steplPositionieren := STEP_20_E;

      (* Fehlerbehandlung:
         - Sensoren
      *)
      IF ( blSensorAuslauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
        steplPositionieren := STEP_900_E;
      END_IF

      IF ( blSensorEinlauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr :=   cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT;
        IF ( blSensorAuslauf ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
        END_IF
        steplPositionieren := STEP_900_E;
      END_IF

(* AUFKIPPEN ================*)
    STEP_20_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        steplPositionieren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Sensoren
      *)
      IF ( blSensorAuslauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
        steplPositionieren := STEP_900_E;
      END_IF

      IF ( blSensorEinlauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr :=   cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT;
        IF ( blSensorAuslauf ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
        END_IF
        steplPositionieren := STEP_900_E;
      END_IF

(* AUFKIPPEN ================*)
    STEP_900_E:
      // Fehlerbehandlung
      IF NOT Antrieb.bpAntrieblaeuft THEN
        steplPositionieren := STEP_910_E;
      END_IF

(* AUFKIPPEN ================*)
    STEP_910_E:
      // Fehlerbehandlung
      bpFehler := TRUE;

(* AUFKIPPEN ================*)
    STEP_1000_E:
    bpDone := TRUE;

(* AUFKIPPEN ================*)
  END_CASE
ELSE
  IF ( steplPositionieren > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    steplPositionieren := STEP_0_E;
  END_IF
end_if
END_ACTION