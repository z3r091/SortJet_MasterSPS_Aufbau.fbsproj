(* METADATA
{
	"v3Meta": {
		"objectGuid": "4ef0e008-b855-479b-8668-0ef9f9c61855"
	}
}
*)
ACTION Vermessen_OberUndUnterkante_2_Sensoren
(***************************************************************************************************)
(* AKTION: SCHEIBE VERMESSEN OBER UND UNTERKANTE 2 SENSOREN *)
(***************************************************************************************************)

IF( bpVermessen_OberUndUnterkante_2_Sensoren ) THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_MESSACHSE;
    steplOberUndUnterkante_2_Sensoren := STEP_900_E;
  END_IF


  CASE steplOberUndUnterkante_2_Sensoren OF
// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_0_E:
      // Variablen zuruecksetzen
      bpDone := FALSE;

      tonlEndschalterFreifahren(IN := FALSE);
      tonlWarteSchrittEndschalterFreifahren(IN := FALSE);
      toflHardwareEndschalterFrei(IN:=FALSE);
	   tonlTimeoutUnterkante(IN := FALSE);	 
		
      bpVermessenAbgeschlossen := FALSE;

		epGlashoehenTypMode2 := eGlasHoheKeinStatus;
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      IF ( Antrieb.bpMinSchalterBelegt OR Antrieb.bpMaxSchalterBelegt ) THEN
        steplOberUndUnterkante_2_Sensoren := STEP_10_E;
      ELSE
        steplOberUndUnterkante_2_Sensoren := STEP_50_E;
      END_IF

// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_10_E:
      // Endschalter freifahren
      tonlEndschalterFreifahren(IN := TRUE, PT:= T#10S);

      toflHardwareEndschalterFrei( IN := (  Antrieb.bpMinSchalterBelegt
                                         OR Antrieb.bpMaxSchalterBelegt ),
                                  PT := t#1s);

      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      IF (  Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDPLUS;
      END_IF

      IF (  Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDMINUS;
      END_IF

      // Endschalter min. 1 sec freifahren
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplOberUndUnterkante_2_Sensoren := STEP_20_E;
      END_IF

      // Fehlerbehandlung:
      // Endschalter wird nicht frei 
      IF ( tonlEndschalterFreifahren.Q
        AND NOT Antrieb.bpMinSchalterBelegt )
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_MESSACHSE_ENDSCHALTER_NICHT_FREI;
        steplOberUndUnterkante_2_Sensoren := STEP_900_E;
      END_IF

// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_20_E:
      // Erzwungene Pause, damit der Lenze Antrieb wieder ordnungsgemäß schaltet
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT:= T#2s);

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        steplOberUndUnterkante_2_Sensoren := STEP_50_E;
      END_IF

// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_50_E:
      // Achse Positionieren
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      Antrieb.rpZielposition    := Antrieb.rpMinPosition ;
      Antrieb.wpBetriebsart     := ABSOLUT;
		
      steplOberUndUnterkante_2_Sensoren := STEP_60_E;
		
// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_60_E:

      IF ( Antrieb.bpDone AND NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
		  
		  IF in_bSensorUnterkante THEN          
		    // Sensor vor der Messung schon belegt -> wiederholen -> Hand anlegen
          Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
		    epGlashoehenTypMode2 := eGlasMessungWiederholen;
          steplOberUndUnterkante_2_Sensoren := STEP_1000_E;
			  
		  ELSE
          steplOberUndUnterkante_2_Sensoren := STEP_100_E;
			  
		  END_IF
      END_IF

(* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< STARTEN DER SUCHE NACH DER UNTERKANTE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  *)
// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_100_E:
     // Starten der Positionierung
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      Antrieb.rpZielposition    := Antrieb.rpMaxPosition ;
      Antrieb.wpBetriebsart     := ABSOLUT;
		
      steplOberUndUnterkante_2_Sensoren := STEP_110_E;
		
// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_110_E:
	   // Timeout Unterkante
	   tonlTimeoutUnterkante(IN := TRUE, PT := T#10S);	 
	 
      // Untere Glaskante gefunden
      IF in_bSensorUnterkante THEN
        rlScheibenunterkante := Antrieb.rpIstPosition;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
		  
        steplOberUndUnterkante_2_Sensoren := STEP_120_E;
		  
		ELSIF Antrieb.bpDone 
        OR tonlTimeoutUnterkante.Q
      THEN
		  // Sensor wurde nicht belegt. Messung nicht abgeschlossen -> wiederholen
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
		  epGlashoehenTypMode2 := eGlasMessungWiederholen;
        steplOberUndUnterkante_2_Sensoren := STEP_999_E;
			
		END_IF
		
(* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SUCHE NACH DER OBERKANTE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  *)
// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_120_E:
      // Antrieb zum Scheibenende verlangsamen
      Antrieb.rpVerzoegerung :=( ppAntriebsInformationen.rpMaxVerzoegerung * 2 );
      IF ( Antrieb.rpIstPosition > ( rpErwarteteScheibenHoehe - ppParameterBaustein.rAbstandSensorenOberUndUnterkante 
                                     + rlScheibenunterkante - rlOffsetMaximumFrueherBremsen ) ) 
      THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      ELSE
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit40;
      END_IF
 
      // Messung erfolgreich
      IF NOT in_bSensorOben THEN
        rlScheibenoberkante := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplOberUndUnterkante_2_Sensoren := STEP_130_E;
		  
		ELSIF Antrieb.bpDone THEN
		  // Sensor wurde nicht frei. Messung nicht abgeschlossen -> wiederholen
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
		  epGlashoehenTypMode2 := eGlasMessungWiederholen;
        steplOberUndUnterkante_2_Sensoren := STEP_998_E;
			
		END_IF

// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_130_E:
	   // Messergebnis berechnen
	   rlMessErgebnis := (rlScheibenoberkante - rlScheibenunterkante + ppParameterBaustein.rAbstandSensorenOberUndUnterkante);
		
		// Messpunkte nicht plausibel
		IF ( rlScheibenoberkante <= rlScheibenunterkante ) THEN
		  epGlashoehenTypMode2 := eGlasMessungWiederholen;
		    steplOberUndUnterkante_2_Sensoren := STEP_995_E;
		  
		// Prüfen ob das Messergebnis plausibel ist
		ELSIF ( ( rlMessErgebnis <= 0 ) OR ( rlMessErgebnis > ( Antrieb.rpMaxPosition ) ) ) THEN
		  epGlashoehenTypMode2 := eGlasMessungWiederholen;
		    steplOberUndUnterkante_2_Sensoren := STEP_994_E;
		  
      ELSE	
		  // Messergebnis plausibel 
		  IF ( ABS( rlMessErgebnis - rpErwarteteScheibenHoehe ) <= ppParameterBaustein.rToleranz )  THEN
            epGlashoehenTypMode2 := eGlasHoeheOK;
        ELSE
          IF ( ( rlMessErgebnis - rpErwarteteScheibenHoehe ) > ppParameterBaustein.rToleranz ) THEN
            epGlashoehenTypMode2 := eGlasZuHoch;
        
          ELSE
            epGlashoehenTypMode2 := eGlasZuNiedrig;
		  	 
          END_IF
        
        END_IF
		    steplOberUndUnterkante_2_Sensoren := STEP_1000_E;
		END_IF
		

// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_900_E:
      bpFehler := TRUE;

// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
    STEP_1000_E:
      bpDone := TRUE;
      bpVermessenAbgeschlossen := TRUE;

// VERMESSEN OBER UNTERKANTE 2 SENSOREN ====================
  END_CASE
ELSE
  IF( steplOberUndUnterkante_2_Sensoren > STEP_0_E )THEN
    bpDone := FALSE;
    bpVermessenAbgeschlossen := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplOberUndUnterkante_2_Sensoren := STEP_0_E;
  END_IF
END_IF
END_ACTION