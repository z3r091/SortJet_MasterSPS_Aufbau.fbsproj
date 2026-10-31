(* METADATA
{
  "v3Meta": {
    "objectGuid": "ffff6e5b-1373-484c-86bb-e254ccadcc5f"
  }
}
*)
ACTION Anlegen
(***************************************************************************************************)
(* AKTION ANLEGEN *)
(***************************************************************************************************)
IF( BasisStationsParameter.bAnlegen
  AND blBetriebsartAutomatik )
THEN

  CASE steplAnlegen OF
(*ANLEGEN ==================================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen initalisieren
         - Starten des Anlegevorgangs
         - Sicherung des Geblaeses muss in Ordnung sein [Oeffner-Kontakt]
      *)
      BasisStationsParameter.eStatusAuftrag := eAuftragAktiv;

      IF ( in_bMotorschutzGeblaese_Ok )

      THEN
        out_bAmpelSignalGruen  := FALSE;
        steplAnlegen := STEP_10_E;

      ELSE
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAnlegen := STEP_900_E;

      END_IF

(*ANLEGEN ==============================*)
    STEP_10_E:
      (* Hinweis:
         - Höhenkontrolle auf Position fahren
      *)
      IF BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen THEN
        Messachse.rpZielPosition := ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset );
      ELSE                             
        Messachse.rpZielPosition := BasisStationsParameter.stMKs.stGlasdaten[cWAND_1].rlMinGlasHoehe;
      END_IF
      Messachse.bpPositionierung := TRUE;

      steplAnlegen := STEP_20_E;

(*ANLEGEN ==============================*)
    STEP_20_E:
      (* Anmerkung:
         - Korrekte Stati der Zylinder und Achsen abfragen
      *)
      IF ( ( Messachse.bpDone ) OR NOT BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen )
      THEN
        Messachse.bpPositionierung    := FALSE;
        out_bDrosselklappeOeffnen     := TRUE;

        steplAnlegen := STEP_100_E;

      END_IF
  
      
(*ANLEGEN ==============================*)
    STEP_100_E:
      (* Anmerkung:
         - Warten bis der Bediener die Scheibe angelegt und quittierthat
         - Geblaese starten wenn dieses nicht schon gestartet ist
           => Belegen des Einlaufsensors
      *)
      IF ( Glastransport.bpSensorEinlauf AND NOT Glastransport.bpSensorAuslaufVorab ) THEN
        out_bAmpelSignalGruen  := TRUE;
        out_bSignalScheibeAufgegeben  := TRUE;
      ELSE
        out_bAmpelSignalGruen        := gbFlashbit05sec;
        out_bSignalScheibeAufgegeben := gbFlashbit05sec;
      END_IF


      IF ( BasisStationsParameter.InGlasTransportVorgaenger[cWAND_1].bBereitZumAustransport ) THEN

        out_bAmpelSignalGruen  := FALSE;
        out_bSignalScheibeAufgegeben := FALSE;

        BasisStationsParameter.dwWartezeit[cWAND_1] := TIME_TO_DWORD(TIME()- tlZeitBereitAnzulegen);

        out_bDrosselklappeOeffnen := FALSE;

        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

        steplAnlegen := STEP_1000_E;

      END_IF
(*
      IF ( rtlFussleisteStart.Q AND ( ( Glastransport.bpSensorEinlauf AND NOT Glastransport.bpSensorAuslauf ) ) ) THEN

        out_bAmpelSignalGruen  := FALSE;
        out_bSignalScheibeAufgegeben := FALSE;

        BasisStationsParameter.dwWartezeit[cWAND_1] := TIME_TO_DWORD(TIME()- tlZeitBereitAnzulegen);

        out_bDrosselklappeOeffnen := FALSE;

        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

        steplAnlegen := STEP_1000_E;

      END_IF
*)
      (* HINWEIS:
        - Der Auslauf- Sensor am Anlegetisch muss frei sein, um mit dem Einschleusen des Glases zu beginnen
      *)
      IF (  Glastransport.bpSensorAuslauf
        AND rtlFussleisteStart.Q )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_EINTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerExtern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten
                  );
      END_IF

      (* HINWEIS:
        - Der Einlaufsensor am Anlegetisch muss belegt sein
      *)
      IF ( NOT Glastransport.bpSensorEinlauf
        AND rtlFussleisteStart.Q )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_ANLEGEN_SENSOR_EINLAUF_NICHT_BELEGT,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerExtern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten
                  );
      END_IF

      (* Hinweis:
         - Knebelschlater [Glastransport zurueck]
      *)
      IF ( in_bKnebelGlastransportZurueck
        AND tonlFreigabeErhalten.Q )
      THEN
        Glastransport.bpScheibeZurueckFahren := in_bKnebelGlastransportZurueck;
        Glastransport.bpScheibeVorFahren     := FALSE;
	  ELSIF ( in_bKnebelGlastransportVor
        AND tonlFreigabeErhalten.Q )
      THEN
        Glastransport.bpScheibeVorFahren := in_bKnebelGlastransportVor;
        Glastransport.bpScheibeZurueckFahren := FALSE;
      ELSE
        Glastransport.bpScheibeZurueckFahren := FALSE;
        Glastransport.bpScheibeVorFahren     := FALSE;
      END_IF
      
(*ANLEGEN ==================================*)
    STEP_900_E:
      BasisStationsParameter.eStatusAuftrag := eAuftragFehler;

      BasisStationsParameter.bFehler := TRUE;

(*ANLEGEN ==================================*)
    STEP_1000_E:
      epTypeHoehenmessung := Modus_Positionieren_Auf_Oberkante_2_Sensoren;

      BasisStationsParameter.bAnlegenAbgeschlossen := TRUE;

(*ANLEGEN ==================================*)
  END_CASE
ELSE

  IF( steplAnlegen > STEP_0_E )THEN

    BasisStationsParameter.bAnlegenAbgeschlossen := FALSE;
    out_bAmpelSignalGruen         := FALSE;
    out_bSignalScheibeAufgegeben  := FALSE;
    out_bAmpelSignalRot           := FALSE;
    Messachse.bpPositionierung    := FALSE;

    steplAnlegen := STEP_0_E;
  END_IF

END_IF
END_ACTION