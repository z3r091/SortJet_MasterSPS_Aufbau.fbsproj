(* METADATA
{
  "v3Meta": {
    "objectGuid": "afd60ed2-fb3c-4a14-bad8-2d5352fcbeab"
  }
}
*)
ACTION Messung
(***************************************************************************************************)
(* AKTION: MESSUNG *)
(***************************************************************************************************)
IF ( bpGlasvermessung ) THEN

  (* Ausnahmesituation:
     - ANTRIEB
  *)
  IF ( ppAntrieb.bpFehler) THEN
    ppAntrieb.wpBetriebsart  := KEINE_FUNKTION;
    steplGlasvermessung := STEP_900_E;
  END_IF

  CASE steplGlasvermessung OF
(* GLASVERMESSUNG ================================ *)
    STEP_0_E:
      (* Hinweis:
         - Pruefen des Antriebs vor der Scheibenmessung
      *)
      rlScheibenmessungErgebnis  := 0.0;
      rlMessergebnisMerker       := 0.0;
      rpGemesseneGlaslaenge      := 0.0;
      bpGlasmessungAbgeschlossen := FALSE;

      IF ( ppAntrieb.bpReglerBereit ) THEN
        ppAntrieb.rpGeschwindigkeit := REAL#0;
        ppAntrieb.wpBetriebsart  := KEINE_FUNKTION;

        steplGlasvermessung := STEP_10_E;
      END_IF

(* GLASVERMESSUNG ================================ *)
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob der Sensor belegt ist
      *)
      IF pbpEinlaufSensor THEN 
        steplGlasvermessung := STEP_20_E;		
      ELSE
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_BELEGT_RESTWEGPOSITIONIERUNG;
        bpFehler := TRUE;	
        steplGlasvermessung := STEP_900_E;		
      END_IF
	 	 
(* GLASVERMESSUNG ================================ *)
    STEP_20_E:
      (* Anmerkung:
         - Starten der Glaslaengenvermessung 
      *)
      rlPositionAntriebBeiStart := ppAntrieb.rpIstPosition;

      ppAntrieb.rpGeschwindigkeit := SEL( ( ppAntriebsInformationen.rpGeschwindigkeitMessen > 1 ),   ppAntriebsInformationen.rpHandGeschwindigkeit, ppAntriebsInformationen.rpGeschwindigkeitMessen);

      ppAntrieb.rpBeschleunigung                    := ppAntriebsInformationen.rpMaxBeschleunigung;
      ppAntrieb.rpVerzoegerung                      := ppAntriebsInformationen.rpMaxVerzoegerung;
      ppAntrieb.rpRuckzeit                          := ppAntriebsInformationen.rpMaxRuckzeit;
		  ppAntrieb.eSensorAuswahl_Messung_1            := eSensoren.Sensor_1;
      ppAntrieb.eSensorAuswahl_Messung_2            := eSensoren.Sensor_2;
      ppAntrieb.bpDrehrichtungsumkehrMessung        := bpDrehrichtungsumkehrMessung ;
      ppAntrieb.bpAuswahlSensorVorabScheibenmessung := bpAuswahlSensorVorabScheibenmessung;

      ppAntrieb.wpBetriebsart := AntriebsBetriebsart_EN.SCHEIBENMESSUNG;

      steplGlasvermessung := STEP_30_E;

(* GLASVERMESSUNG ================================ *)
    STEP_30_E:
      (* Hinweis:
          - Damit der Auslaufsensoren mit dem Glas nicht zu weit überfahren werden, vorher schon die Geschwindigkeit verringern.
            Dazu den Abstand der beiden Sensoren minus min. Scheibenlänge (z.B. 350) das sollte reichen um die Max. Geschwindigkeit zu verringeren          
      *)
      rlBremsWeg := ( ( ppAntrieb.rpIstGeschwindigkeit * ppAntrieb.rpIstGeschwindigkeit ) / 2 / ppAntrieb.rpVerzoegerung );

      IF ( ABS(ppAntrieb.rpIstPosition - rlPositionAntriebBeiStart) >=
         ABS(rpMessstrecke - ( rpFaktorBremswegverlaengern * rlBremsWeg ) - rpErwarteteScheibenLaenge))
      THEN
        ppAntrieb.rpGeschwindigkeit := rgGeschwindigkeit10;
      END_IF

      IF ( pbpVorstopSensor )  THEN
          ppAntrieb.rpGeschwindigkeit := rgGeschwindigkeit05;
      END_IF

      (* Anmerkung:
         - Messergebnis meldet OK
         - Sobald wechsel auf cKeine_Funktion wird Messergebniss abgelöscht, daher schon vorher abfragen
      *)
      rtlMessung_OK(CLK := ppAntrieb.bpMessungOk);
	    IF (rtlMessung_OK.Q)THEN
		    rlMessergebnisMerker := ppAntrieb.rpMessErgebnis;
		  END_IF
      
      (* Anmerkung:
         - Scheibenmessung wurde abgeschlossen
         - Ausgabe der gemessenen Glaslaenge
      *)
      IF ( ppAntrieb.bpDone ) THEN
        IF ( rlMessergebnisMerker = 0 ) THEN
          rlMessergebnisMerker := ppAntrieb.rpMessErgebnis;
        END_IF
        ppAntrieb.wpBetriebsart := KEINE_FUNKTION;

        steplGlasvermessung := STEP_50_E;
      ELSE
        
        // Ausnahmesituation
        rlGefahrenerWeg := ABS(ppAntrieb.rpIstPosition - rlPositionAntriebBeiStart);
        
        // Auslaufsensor schaltet nicht -> Messstrecke + 50mm abgefahren und Auslaufsensor hat nicht geschaltet
        IF ( rlGefahrenerWeg > ( rpMessstrecke + 50 ) ) 
          AND NOT ppAntrieb.blSensoren[ppAntrieb.eSensorAuswahl_Messung_2]
        THEN 
          ppAntrieb.wpBetriebsart := KEINE_FUNKTION;
          wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
          steplGlasvermessung := STEP_900_E;
        END_IF
		    
        // Einlaufsensor wird nicht frei 
        CASE epGlastyp OF 
        
          // Default Scheibe -> Messstrecke + 50mm abgefahren und Einlaufsensor hat immernoch geschaltet
          eScheibe_Default:         
            IF ( rlGefahrenerWeg > ( rpMessstrecke + 50 ) ) 
              AND  ppAntrieb.blSensoren[ppAntrieb.eSensorAuswahl_Messung_1]
            THEN 
              ppAntrieb.wpBetriebsart := KEINE_FUNKTION;
              wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
              steplGlasvermessung := STEP_900_E;
            END_IF           
             
          // Max Scheibe -> Max Glas Länge + 50mm abgefahren und Einlaufsensor hat immer noch geschaltet
		      eScheibe_Maximal:       
            IF ( rlGefahrenerWeg > ( starrStationBasisParameter[stStationsNummern.NummerSPS].stMKs.stGlasdaten[cWAND_1].rlMaxGlasLaenge + 50 ) ) 
              AND  ppAntrieb.blSensoren[ppAntrieb.eSensorAuswahl_Messung_1]
            THEN 
              ppAntrieb.wpBetriebsart := KEINE_FUNKTION;
              wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_EINLAUF_NICHT_FREI;
              steplGlasvermessung := STEP_900_E;
            END_IF        
          
        END_CASE
       
     END_IF	

(* GLASVERMESSUNG ================================ *)
    STEP_50_E:
      (* Hinweis:
          - Messrgbnis prüfen
      *)
      IF  (rlMessergebnisMerker <> 0 ) THEN		  
        rpGemesseneGlaslaenge := ABS( rpMessstrecke + rlMessergebnisMerker );
        steplGlasvermessung := STEP_1000_E;
      ELSE
        wpFehlerNr := cMELDUNG_MESSUNG_FEHLMESSUNG;
        steplGlasvermessung := STEP_900_E;
	    END_IF

(* GLASVERMESSUNG ================================ *)
    STEP_900_E:
      bpFehler := TRUE;

(* GLASVERMESSUNG ================================ *)
    STEP_1000_E:
      bpGlasmessungAbgeschlossen := TRUE;

(* GLASVERMESSUNG ================================ *)
  END_CASE

ELSE

  IF ( steplGlasvermessung  > STEP_0_E ) THEN
    ppAntrieb.wpBetriebsart := KEINE_FUNKTION;
    bpGlasmessungAbgeschlossen := FALSE;
    steplGlasvermessung := STEP_0_E;
  END_IF

END_IF
END_ACTION