(* METADATA
{
	"v3Meta": {
		"objectGuid": "24e44f33-0a00-4274-9468-a98b666d255a"
	}
}
*)
ACTION ScheibenNeuAusrichten
(***************************************************************************************************)
(* SCHEIBEN IM SPEICHER NEU AUSRICHTEN *)
(***************************************************************************************************)
IF (  bpScheibenNeuAusrichten )
THEN

  wpgFehlerdaten[0] := stStationsNummern.NummerExtern;

  (* Hinweis:
     - Starten der Schrittkette 
  *)
  CASE steplScheibenNeuAusrichten OF
(*SCHEIBEN NEU AUSRICHTEN ==============================*)
    STEP_0_E:
      bpDone:= FALSE;
      blSchnittstelle_bAnforderungTransportVerbund := FALSE;
      tonlWartenAufAnheben( IN := FALSE );

      steplScheibenNeuAusrichten := STEP_20_E;

(*EINTRANSPORT ==============================*)
    STEP_20_E:
      (* ---------------------------------------------------------------------------------------
      //  EINTRANSPORT IM TRANSFERSHUTTLE VERBUND
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      IF ( bpTransfershuttleVerbundAktiv ) THEN

       blSchnittstelle_bAnforderungTransportVerbund := TRUE;

        IF ( stpInTransportVerbund.bBereitZumTransportVerbund ) THEN
          steplScheibenNeuAusrichten := STEP_30_E;
        END_IF

      ELSE
        steplScheibenNeuAusrichten := STEP_30_E;

      END_IF

(*SCHEIBEN NEU AUSRICHTEN ==============================*)
    STEP_30_E:
      (* Anmerkung:
         - Pneumatik ansteuern
      *)
      out_bShuttleAnheben := TRUE;

      out_bScheibenKontrolleAuslaufseiteAuf := TRUE;
      out_bScheibenKontrolleEinlaufseiteAuf := TRUE;
      
      blScheibenKontrolleAuslaufseiteEin := TRUE;
      blScheibenKontrolleEinlaufseiteEin := TRUE;

      tonlWartenAufAnheben(IN := NOT blBereitZumGlastransport, PT := t#10s);

      IF ( blBereitZumGlastransport OR blBereitZumBreitenGlastransport ) THEN
        steplScheibenNeuAusrichten := STEP_100_E;
      END_IF


      (* Fehlerbehandlung:
         - Pruefen der Komponenten
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

        SpsHinweis( eFehler_Station, 
                    wpFehlerNr, 
                    stStationsNummern.NummerIntern, 
                    AutomatikkreisBestimmen(stStationsNummern.NummerIntern), 
                    wpgFehlerdaten );

        steplScheibenNeuAusrichten := STEP_800_E;
 
      END_IF

(*SCHEIBEN NEU AUSRICHTEN ==============================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  STARTEN DER NEU AUSRICHTUNG [POSITIONIERUNG] 
      //         
      //  Hinweis:
      // - Transport in "Positive" Richtung
      // ---------------------------------------------------------------------------------------*)

      rlAntriebsPositionBeiStart := ABS(Antrieb.rpIstPosition);

      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      IF ( blEinlaufSensor ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit10;

        Antrieb.rpZielPosition    := ppParameterBaustein.rWegUeberEinlaufEintransport;
        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor1;
        ELSE
          Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor1;
        END_IF
      ELSE        
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;

        Antrieb.rpZielPosition    := (-1) * ppParameterBaustein.rWegUeberEinlaufEintransport;
        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        ELSE
          Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor1;
        END_IF

      END_IF

      Antrieb.wpBetriebsart := RESTWEG;

      steplScheibenNeuAusrichten := STEP_110_E;

(*SCHEIBEN NEU AUSRICHTEN ==============================*)
    STEP_110_E:
      (* Hinweis:
         - Antrieb verfahren
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        steplScheibenNeuAusrichten := STEP_800_E;
      END_IF

      (* Hinweis:
         - Keine Scheibe im Fach
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - ABS (Antrieb.rpIstPosition)) > ppParameterBaustein.rlLaengeStation * 1.5 ) THEN
        wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station, 
                    cMELDUNG_STATION_KEINE_SCHEIBE_GEFUNDEN, 
                    stStationsNummern.NummerIntern, 
                    AutomatikkreisBestimmen(stStationsNummern.NummerIntern), 
                    wpgFehlerdaten );
						  
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplScheibenNeuAusrichten := STEP_800_E;
      END_IF

(*SCHEIBEN NEU AUSRICHTEN ==============================*)
    STEP_800_E:
      (* Hinweis:
         - Ausgaenge zuruecksetzeb
      *)
      out_bShuttleAnheben := FALSE;

      out_bScheibenKontrolleAuslaufseiteAuf := FALSE;
      out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;

      blScheibenKontrolleAuslaufseiteEin := FALSE;
      blScheibenKontrolleEinlaufseiteEin := FALSE;

      steplScheibenNeuAusrichten := STEP_1000_E;

(*SCHEIBEN NEU AUSRICHTEN ==============================*)
     STEP_900_E:
       blSchnittstelle_bAnforderungTransportVerbund := FALSE;
       bpFehler := TRUE;

(*SCHEIBEN NEU AUSRICHTEN ==============================*)
     STEP_1000_E:
       bpDone := TRUE;

(*SCHEIBEN NEU AUSRICHTEN ==============================*)
 END_CASE
ELSE

  IF ( steplScheibenNeuAusrichten > STEP_0_E ) THEN
    bpDone := FALSE;

    out_bShuttleAnheben := FALSE;

    blSchnittstelle_bAnforderungTransportVerbund := FALSE;

    out_bScheibenKontrolleAuslaufseiteAuf := FALSE;
    out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;

    blScheibenKontrolleAuslaufseiteEin := FALSE;
    blScheibenKontrolleEinlaufseiteEin := FALSE;

    steplScheibenNeuAusrichten := STEP_0_E;

  END_IF

END_IF
END_ACTION