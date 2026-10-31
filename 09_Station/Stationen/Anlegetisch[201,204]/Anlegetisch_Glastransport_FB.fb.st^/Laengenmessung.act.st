(* METADATA
{
  "v3Meta": {
    "objectGuid": "d999b8e5-a7d9-405b-9e49-33cfbb3791a5"
  }
}
*)
ACTION Laengenmessung
(***************************************************************************************************)
(* AKTION LÄNGENVERMESSUNG  *)
(***************************************************************************************************)
IF ( bpGlaslaengenmessung
  AND bpAutomatikAktiv)
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Scheibenmessung.bpGlasvermessung := FALSE;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplGlaslaengenMessung := STEP_900_E;
  END_IF

  
  CASE steplGlaslaengenMessung OF
(* GLASLAENGENMESSUNG =============================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen setzen 
         - Pruefen ob der Antrieb bereit zum verfahren ist
      *)
      rpGemesseneGlaslaenge := 0;

      bpScheibeQuittiert   := FALSE;
      bpScheibeFreigegeben := FALSE;
      bpAnforderungMessergebnis := FALSE;

      Antrieb.rpGeschwindigkeit := REAL#0;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.wpBetriebsart     := KEINE_FUNKTION;
      
      rlPositionAntriebBeiStart := Antrieb.rpIstPosition;
      
      IF ( ( eGlastyp = cMAXSCHEIBE )
        OR ( eGlastyp = cMODELLSCHEIBE ) )
      THEN
        steplGlaslaengenMessung := STEP_10_E;
      ELSE
        steplGlaslaengenMessung := STEP_100_E;
      END_IF


(* GLASLAENGENMESSUNG =============================*)
    STEP_10_E:
      (* Hinweis:
         - Vorgehen bei einer maximalen Scheibe
      *)
      bpOutBereitZumAustransport := TRUE;
      Antrieb.rpGeschwindigkeit := 0.0;

      IF ( ( eGlastyp = cMODELLSCHEIBE )
        AND InGlasTransportNachfolger.bBereitZumEintransport )
      THEN
        steplGlaslaengenMessung := STEP_200_E;

      ELSIF ( InGlasTransportNachfolger.bBereitZumEintransport
        AND NOT ( eGlastyp = cMODELLSCHEIBE ) )
      THEN
        steplGlaslaengenMessung := STEP_100_E;
      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_100_E:
      (* Anmerkung:
         - Starten der Glaslaengenvermessung 
      *)
      rpGemesseneGlaslaenge := 0.0;

      Scheibenmessung.ppAntrieb                 REF= Antrieb;
      Scheibenmessung.pbpVorstopSensor          REF= bgFALSE;
      Scheibenmessung.rpMessstrecke             := ppParameterBaustein.rMessstrecke;
      Scheibenmessung.rpErwarteteScheibenLaenge := pAuftrag.rAuftragsLaenge;

      Scheibenmessung.bpGlasvermessung := TRUE;

      IF ( Scheibenmessung.bpGlasmessungAbgeschlossen ) THEN
        Scheibenmessung.bpGlasvermessung := FALSE;
        rpGemesseneGlaslaenge := Scheibenmessung.rpGemesseneGlaslaenge;
        steplGlaslaengenMessung := STEP_110_E;
      END_IF

      (* Fehlerbehandlung
        - Scheibenmessung
        - Wegüberschreitung
      *)
      IF ( Scheibenmessung.bpFehler ) THEN
        Scheibenmessung.bpGlasvermessung := FALSE;
        wpFehlerNr := Scheibenmessung.wpFehlerNr;
        steplGlaslaengenMessung := STEP_900_E;
      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_110_E:
      (* Hinweis:
         - Auslaufsensor muss nach der Messung belegt sein
           => Pruefen des Messergebnisses          
      *)
      IF ( bpSensorAuslauf ) THEN
        bpAnforderungMessergebnis := TRUE;

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplGlaslaengenMessung := STEP_400_E;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplGlaslaengenMessung := STEP_900_E;

      END_IF

(* GLASLAENGENMESSUNG !!! Modellbetrieb !!! =============================*)
    STEP_200_E:
      (* Hinweis:
         - Scheibe mittels Restwegpositionierung auf den Doppelkipptisch fahren
           -> Welche Schwingen mitfahren, wird in der Steuerung 201 entschieden und entsprechend gekoppelt
      *)
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpGeschwindigkeitMessen;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;

      (* Sicherstellen, dass das Glas komplett auf den Doppelkipptisch gefahren wird *)
      Antrieb.rpZielPosition     := ( ppParameterBaustein.rWegUeberAuslauf + pAuftrag.rAuftragsLaenge )
                                     - pAuftrag.rModellVersatzVorne
                                     (* + pAuftrag.rModellVersatzHinten *) ;
      Antrieb.wpRestwegMode      := Positiv_Steigend_Sensor2;
      Antrieb.wpBetriebsart      := RESTWEG;

      steplGlaslaengenMessung := STEP_210_E;

(* GLASLAENGENMESSUNG !!! Modellbetrieb !!! =============================*)
    STEP_210_E:
      (* Hinweis:
         - Scheibe mittels Restwegpositionierung auf den Doppelkipptisch fahren
           -> Welche Schwingen mitfahren, wird in der Steuerung 201 entschieden und entsprechend gekoppelt
      *)
      IF Antrieb.bpDone THEN

        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplGlaslaengenMessung := STEP_400_E;

      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_400_E:
      (* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< WARTEN AUF DAS MESSERGEBNIS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        Anmerkung:
         - Warteschritt ob die Messung okay bzw. fehlerhaft ist
           => Messergebnis OK / Quittiert --> ENDE
           => Kenebel                     --> Glas zurueck fahren
      *)
      IF ( bpScheibeQuittiert
        OR bpScheibeFreigegeben )
      THEN
        bpAnforderungMessergebnis := FALSE;
        steplGlaslaengenMessung := STEP_1000_E;
      END_IF

      IF ( bpScheibeZurueckFahren ) THEN
        bpAnforderungMessergebnis := FALSE;
        steplGlaslaengenMessung := STEP_600_E;
      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_600_E:
      (* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< KNEBEL SCHEIBE ZURUECK FAHREN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

         Hinweis:
         - Scheibe wird zurueck richtung Bediener gefahren
           => Schabe muss nach dem zurueck fahren neu angelegt werden
       *)
      IF ( bpScheibeZurueckFahren ) THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      IF ( bpScheibeQuittiert
        AND NOT bpSensorAuslauf )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplGlaslaengenMessung := STEP_800_E;
      END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_800_E:
       IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
         Antrieb.wpBetriebsart   := KEINE_FUNKTION;
         steplGlaslaengenMessung := STEP_1000_E;
       END_IF

(* GLASLAENGENMESSUNG =============================*)
    STEP_900_E:
      bpOutBereitZumAustransport := FALSE;

      bpFehler := TRUE;

(* GLASLAENGENMESSUNG =============================*)
    STEP_1000_E:
      bpOutBereitZumAustransport := FALSE;
      bpDone := TRUE;

(* GLASLAENGENMESSUNG =============================*)
  END_CASE
ELSE
  IF (steplGlaslaengenMessung > STEP_0_E) THEN
    bpDone := FALSE;
    bpScheibeFreigegeben       := FALSE;
    bpAnforderungMessergebnis  := FALSE;
    bpOutBereitZumAustransport := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    Scheibenmessung.bpGlasvermessung := FALSE;

    steplGlaslaengenMessung := STEP_0_E;
  END_IF
END_IF
END_ACTION