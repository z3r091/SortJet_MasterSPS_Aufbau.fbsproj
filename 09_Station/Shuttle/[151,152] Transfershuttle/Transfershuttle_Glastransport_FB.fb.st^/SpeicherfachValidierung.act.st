(* METADATA
{
  "v3Meta": {
    "objectGuid": "01fba52a-b70b-450c-b266-fef267e8352e"
  }
}
*)
ACTION SpeicherfachValidierung
(* @TEXT_IMPLEMENTATION := 'ST' *)
(***************************************************************************************************)
(* S T A R T - Validierung eines Speicherfachs *)
(***************************************************************************************************)

(* Betriebsmodus:
   - Speicherfach wird ueberprueft ob beide Luftabfragen frei und somit kein Glas uebersteht
*)
IF (  bpSpeicherfachValidierung ) THEN

  (* Fehlerbehandlung
     - Antrieb [Glastransport]
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplSpeicherfachValidierung := STEP_900_E;
  END_IF


  CASE steplSpeicherfachValidierung OF
    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_0_E:

      (* Initialisierung:
         - Variablen
      *)

      blSchnittstelle_bAnforderungTransportVerbund := FALSE;
      bpSpeicherfachValidierungAbgeschlossen := FALSE;

      (* Antrieb:
         - Antrieb ist bereit zum verfahren
      *)
      IF ( Antrieb.bpReglerBereit )THEN
        rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;

        Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.wpBetriebsart    := KEINE_FUNKTION;

        steplSpeicherfachValidierung := STEP_20_E;
      END_IF


    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_20_E:

      IF ( bpTransfershuttleVerbundAktiv ) THEN

        blSchnittstelle_bAnforderungTransportVerbund := TRUE;

        IF ( stpInTransportVerbund.bBereitZumTransportVerbund ) THEN
          steplSpeicherfachValidierung := STEP_30_E;
        END_IF

      ELSE
        steplSpeicherfachValidierung := STEP_30_E;

      END_IF

    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_30_E:
      (* Hinweis:
         - Timer zuruecksetzen
      *)
      tonlEinlaufsensorTesten(IN:= FALSE);
      tonlAuslaufsensorTesten(IN:= FALSE);

      tonlWartenAufAnheben(IN := FALSE);
      tonlUeberwachungSensorFreifahren(IN := FALSE);

      steplSpeicherfachValidierung := STEP_100_E;

    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_100_E:
      (* Pruefung:
         - Luftsensoren frei und schalten 
      *)
      blScheibenKontrolleAuslaufseiteEin := TRUE;
      blScheibenKontrolleEinlaufseiteEin := TRUE;
      tonlEinlaufsensorTesten(IN := NOT bpSensorScheibenKontrolleEinlaufseiteFrei, PT := t#5s);
      tonlAuslaufsensorTesten(IN := NOT bpSensorScheibenKontrolleAuslaufseiteFrei, PT := t#5s);

      IF  ( bpSensorScheibenKontrolleEinlaufseiteFrei
            AND bpSensorScheibenKontrolleAuslaufseiteFrei )
      THEN
        steplSpeicherfachValidierung := STEP_110_E;
      END_IF

      (* Fehlerbehandlung
         - Einlaufseite frei
         - Auslaufseite frei
      *)
      IF ( tonlEinlaufsensorTesten.Q ) THEN
        wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_WIRD_NICHT_FREI;
        steplSpeicherfachValidierung := STEP_110_E;
      END_IF

      IF ( tonlAuslaufsensorTesten.Q ) THEN
        wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_WIRD_NICHT_FREI;
        steplSpeicherfachValidierung := STEP_110_E;
      END_IF

    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_110_E:
      (* Anmerkung:
         - Prüfen ob Glas über den Einlauf oder Ausluaf steht, 
           falls ja Systemcheck als nicht erfolgreich beenden        
      *)
      out_bShuttleAnheben := TRUE;
      out_bScheibenKontrolleAuslaufseiteAuf := TRUE;
      out_bScheibenKontrolleEinlaufseiteAuf := TRUE;

      tonlWartenAufAnheben(IN := NOT blBereitZumGlastransport, PT := t#10s);

      IF ( blBereitZumGlastransport ) THEN
        steplSpeicherfachValidierung := STEP_120_E;
      END_IF

      (* Fehlerbehandlung:
         - Druckluft
         - Glastransport oben
         - Ein- Aus- Laufsensoren
      *)
      IF ( tonlWartenAufAnheben.Q ) THEN
        (* Glastransport oben *)
        IF ( NOT blSensorGlastransportOben ) THEN
          wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_OBEN;
        (* Luftsensoren oben *)
        ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_OBEN;
        (* Luftsensoren oben *)
        ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_OBEN;
        (* Druckluft Ok *)
        ELSIF NOT blDruckluftEinlaufSeiteOK THEN
          wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_EINLAUF_NICHT_OK;
        (* Druckluft Ok *)
        ELSIF ( NOT blDruckluftAuslaufSeiteOK ) THEN
          wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_AUSLAUF_NICHT_OK;
        ELSE
          wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
        END_IF

        steplSpeicherfachValidierung := STEP_900_E;

      END_IF

    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_120_E:
      (* Anmerkung:
         - Prüfen ob Glas ueber den Einlauf- bzw. Auslauf- Sensor steht       
      *)
      IF (      blAuslaufSensor
           AND NOT blEinlaufSensor )
      THEN

        IF ( bgMKSpeicherfachValidierungSensorFreifahrenAktiv ) THEN
          steplSpeicherfachValidierung :=  STEP_130_E;

        ELSE
          wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_NICHT_FREI;
          steplSpeicherfachValidierung := STEP_900_E;

        END_IF

      ELSIF (   blEinlaufSensor
              AND NOT blAuslaufSensor  )
      THEN

        IF ( bgMKSpeicherfachValidierungSensorFreifahrenAktiv ) THEN
          steplSpeicherfachValidierung :=  STEP_140_E;

        ELSE
          wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_NICHT_FREI;
          steplSpeicherfachValidierung := STEP_900_E;

        END_IF

      ELSIF ( blEinlaufSensor
              AND   blAuslaufSensor  )
      THEN
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT;
        steplSpeicherfachValidierung := STEP_900_E;

      ELSE
        steplSpeicherfachValidierung := STEP_800_E;

      END_IF

    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_130_E:
      (* Uberwachung:
         - Zeitliche Ueberwachung bis wann der Sensor frei sein muss
      *)
      tonlUeberwachungSensorFreifahren( IN := TRUE,
                                        PT := cZEIT_SENSORIK_FREIFAHREN );

      (* Anmerkung:
         - Auslaufsensor frei gefahren
      *)
      IF (  NOT blAuslaufSensor
           AND NOT Antrieb.bpAntrieblaeuft  )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplSpeicherfachValidierung := STEP_800_E;
      END_IF

      (* Anmerkung:
         - Auslaufsensor ist belegt
      *)
      IF ( blAuslaufSensor ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung ;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung ;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        Antrieb.wpBetriebsart := HANDMINUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung
         - Wegüberwachung
         - Einlaufsensor angefahren
      *)
      IF ( tonlUeberwachungSensorFreifahren.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_NICHT_FREI;
        steplSpeicherfachValidierung := STEP_900_E;
      END_IF

      IF ( blEinlaufSensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := SEL( blAuslaufSensor, cMELDUNG_SENSOR_EINLAUF_BELEGT, cMELDUNG_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT );
        steplSpeicherfachValidierung := STEP_900_E;
      END_IF

    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_140_E:
      (* Uberwachung:
         - Zeitliche Ueberwachung bis wann der Sensor frei sein muss
      *)
      tonlUeberwachungSensorFreifahren( IN := TRUE,
                                        PT := cZEIT_SENSORIK_FREIFAHREN );

      (* Anmerkung:
         - Einlaufsensor frei gefahren
      *)
      IF (  NOT blEinlaufSensor
           AND NOT Antrieb.bpAntrieblaeuft  )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplSpeicherfachValidierung := STEP_800_E;
      END_IF

      (* Anmerkung:
         - Einlaufsensor ist belegt
      *)
      IF ( blEinlaufSensor ) THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung ;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung ;
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;

        Antrieb.wpBetriebsart     := HANDPLUS;

      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

      END_IF

      (* Fehlerbehandlung
          - Wegüberwachung
          - Auslaufsensor angefahren
      *)
      IF ( tonlUeberwachungSensorFreifahren.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_NICHT_FREI;
        steplSpeicherfachValidierung := STEP_900_E;
      END_IF

      IF ( blAuslaufSensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := SEL( blEinlaufSensor, cMELDUNG_SENSOR_AUSLAUF_BELEGT, cMELDUNG_SENSOR_EINLAUF_UND_AUSLAUF_BELEGT);
        steplSpeicherfachValidierung := STEP_900_E;
      END_IF

    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_800_E:
      (* Anmerkung:
         - alles beenden und Shuttle absenken
     *)
      out_bShuttleAnheben := FALSE;

      out_bScheibenKontrolleAuslaufseiteAuf       := FALSE;
      out_bScheibenKontrolleEinlaufseiteAuf       := FALSE;

      blScheibenKontrolleEinlaufseiteEin := FALSE;
      blScheibenKontrolleAuslaufseiteEin := FALSE;

      steplSpeicherfachValidierung := STEP_1000_E;

    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)

      blSchnittstelle_bAnforderungTransportVerbund := FALSE;
      out_bShuttleAnheben := FALSE;

      out_bScheibenKontrolleAuslaufseiteAuf := FALSE;
      out_bScheibenKontrolleEinlaufseiteAuf := FALSE;

      blScheibenKontrolleEinlaufseiteEin := FALSE;
      blScheibenKontrolleAuslaufseiteEin := FALSE;

      bpFehler := TRUE;


    (* SPEICHERFACH VALIDIERUNG ==================================================*)
    STEP_1000_E:
      bpSpeicherfachValidierungAbgeschlossen := TRUE;


  (* SPEICHERFACH VALIDIERUNG ==================================================*)

  END_CASE

ELSE
  IF ( steplSpeicherfachValidierung > STEP_0_E ) THEN
    bpSpeicherfachValidierungAbgeschlossen := FALSE;

    out_bShuttleAnheben := FALSE;

    blSchnittstelle_bAnforderungTransportVerbund := FALSE;

    out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
    out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;

    blScheibenKontrolleEinlaufseiteEin := FALSE;
    blScheibenKontrolleAuslaufseiteEin := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    tonlUeberwachungSensorFreifahren( IN := FALSE );
    steplSpeicherfachValidierung := STEP_0_E;
  END_IF
END_IF

(***************************************************************************************************)
(* E N D E - Validierung eines Speicherfachs *)
(***************************************************************************************************)
END_ACTION