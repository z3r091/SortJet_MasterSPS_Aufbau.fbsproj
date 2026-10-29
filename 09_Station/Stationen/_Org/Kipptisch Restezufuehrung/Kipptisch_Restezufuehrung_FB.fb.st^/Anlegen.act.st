(* METADATA
{
	"v3Meta": {
		"objectGuid": "ecdaf38a-9cac-4b75-9b8c-73873a1fb8d1"
	}
}
*)
ACTION Anlegen
(***************************************************************************************************)
(* AKTION ANLEGEN *)
(***************************************************************************************************)

rtlTasterGlasAngelegt(CLK := in_bTasterGlasAngelegt);

IF( BasisStationsParameter.bAnlegen
  AND NOT BasisStationsParameter.bAustransport[cWAND_1]
  AND blBetriebsartAutomatik )
THEN


  
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpStartKippenAuf := FALSE;
    Kippen.bpStartKippenAb  := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAnlegen := STEP_900_E;
  END_IF


  CASE steplAnlegen OF
(*ANLEGEN ==================================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen initalisieren
         - Starten des Anlegevorgangs
      *)		
      BasisStationsParameter.eStatusAuftrag := eAuftragAktiv;        
      Kippen.bpStartKippenAb := TRUE;
      steplAnlegen := STEP_10_E;
 

(*ANLEGEN ==============================*)
    STEP_10_E:
      (* Hinweis:
         - Kippen abgeschlossen 0Grad
      *)
      IF ( ( Kippen.bpDone AND ( Kippen.epKippStatus = eKippen_Position_0Grad ) )
        OR NOT Kippen.bpStartKippenAb )
      THEN
        Kippen.bpStartKippenAb := FALSE;

         steplAnlegen := STEP_100_E;
      END_IF

(*ANLEGEN ==============================*)
    STEP_100_E:
      (* Anmerkung:
         - Warten bis der Bediener die Scheibe angelegt und quittierthat
           => Belegen des Einlaufsensors
      *)
      IF ( ( Glastransport.bpSensorEinlauf )
           AND NOT Glastransport.bpSensorAuslauf ) 
       OR ( BasisStationsParameter.wGlastyp[cWAND_1] = eScheibe_Modell ) 
      THEN
        out_bSignalTasterScheibeAnlegen  := TRUE;
      ELSE
        out_bSignalTasterScheibeAnlegen  := gbFlashbit05sec;
      END_IF


		
      // Scheibe wurde angelegt
      IF ( rtlTasterGlasAngelegt.Q 
        AND Glastransport.bpSensorEinlauf ) 
      THEN

        out_bSignalTasterScheibeAnlegen := FALSE;


        BasisStationsParameter.dwWartezeit[cWAND_1] := TIME_TO_DWORD(TIME()- tlZeitBereitAnzulegen);

        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

        steplAnlegen := STEP_1000_E;	

      END_IF	
      (* HINWEIS:
        - Der Auslauf- Sensor am Anlegetisch muss frei sein, um mit dem Einschleusen des Glases zu beginnen
      *)
      IF (  Glastransport.bpSensorAuslauf
        AND rtlTasterGlasAngelegt.Q ) AND ( BasisStationsParameter.wGlastyp[cWAND_1] <> eScheibe_Modell )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );
      END_IF

      (* HINWEIS:
        - Der Einlaufsensor am Anlegetisch muss belegt sein
      *)
      IF ( ( NOT Glastransport.bpSensorEinlauf )
        AND rtlTasterGlasAngelegt.Q ) AND ( BasisStationsParameter.wGlastyp[cWAND_1] <> eScheibe_Modell )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_ANLEGEN_SENSOR_EINLAUF_NICHT_BELEGT,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );
      END_IF

(*ANLEGEN ==================================*)
    STEP_900_E:
      BasisStationsParameter.eStatusAuftrag := eAuftragFehler;

      BasisStationsParameter.bFehler := TRUE;

(*ANLEGEN ==================================*)
    STEP_1000_E:


      BasisStationsParameter.bAnlegenAbgeschlossen := TRUE;

		
(*ANLEGEN ==================================*)
  END_CASE
ELSE

  IF( steplAnlegen > STEP_0_E )THEN

    BasisStationsParameter.bAnlegenAbgeschlossen := FALSE;
    out_bSignalTasterScheibeAnlegen := FALSE;
	


    steplAnlegen := STEP_0_E;
  END_IF

END_IF
END_ACTION