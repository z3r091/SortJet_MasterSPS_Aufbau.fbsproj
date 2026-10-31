(* METADATA
{
	"v3Meta": {
		"objectGuid": "a9497025-6edc-4561-b581-d931421bc923"
	}
}
*)
ACTION Glashoehenmessung
(***************************************************************************************************)
(* AKTION HÖHENMESSUNG *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bGlashoehenmessung )
THEN

  (* Fehlerbehandlung
     - Anschlag
     - Hubrahmen
  *) 
  IF ( Messachse.bpFehler ) THEN
    Messachse.bpPositionierung      := FALSE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
    steplGlashoehenmessung := STEP_900_E;
  END_IF

  IF ( Glastransport.bpFehler ) THEN
    BasisStationsParameter.wFehlerNummer :=  Glastransport.wpFehlerNr;
    steplGlashoehenmessung := STEP_900_E;
  END_IF

  CASE steplGlashoehenmessung OF
(*HÖHENMESSUNG ==================================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen initalisieren
      *)
      BasisStationsParameter.eStatusAuftrag := eAuftragAktiv;
      BasisStationsParameter.bGlashoehenmessungAbgeschlossen := FALSE;
     
      steplGlashoehenmessung := STEP_20_E;



(* HÖHENMESSUNG ==================================*)
    STEP_20_E:
      (* Hinweis:
         - Für die Steuerschrittkette müssen wir einmal kurz in eAuftragAktiv wechseln bevor
           in Schritt 800 dann eAuftrakErfolgreich gesetzt werden kann
      *)
      IF BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen THEN
         steplGlashoehenmessung := STEP_200_E;
      ELSE
        steplGlashoehenmessung := STEP_800_E;
      END_IF


(* HÖHENMESSUNG ==================================*)
    STEP_200_E:
      (* Hinweis:
         - Messachse nochmal auf Position fahren
      *)
      Messachse.rpZielPosition   := ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset );
      Messachse.bpPositionierung := TRUE;

      steplGlashoehenmessung := STEP_210_E;

(* HÖHENMESSUNG ==================================*)
    STEP_210_E:
      (* Hinweis:
         - Messachse nochmal auf Position fahren
      *)
      IF Messachse.bpDone THEN
        Messachse.bpPositionierung := FALSE;
        
        IF BasisStationsParameter.stMKs.stStationsAufbau.bMessachse THEN
          steplGlashoehenmessung := STEP_300_E;
       ELSE
         steplGlashoehenmessung := STEP_800_E;
		END_IF

      END_IF


(* HÖHENMESSUNG ==================================*)
    STEP_300_E:

      (* Hinweis:
         - Auswertung der Sensorik
      *)
      CASE Messachse.epGlashoehenTyp OF

        eGlasHoeheOK:
          steplGlashoehenmessung := STEP_800_E;

        eGlasZuHoch:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_HOCH,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerExtern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen
                    );
          BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
          steplGlashoehenmessung := STEP_1000_E;

        eGlasZuNiedrig:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_NIEDRIG,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerExtern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen
                    );
          BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
          steplGlashoehenmessung := STEP_1000_E;

      END_CASE

(* HÖHENMESSUNG ==================================*)
    STEP_320_E:
     (*
         Anmerkung:
         - Ampel
         - Moeglichkeit Fehlmessung quittieren --> Scheibe freigegeben zum Austransport
         - Knebelschalter Glas zurueck auf die Station fahren 
         - Quittiern
           => Nachricht an die Oberflaeche
             wSPS2MMITRANSPORTSTATE := 1 ==  Scheibe OK und eingefahren 
      *)
      out_bSignalScheibeAufgegeben := gbFlashbit05sec;
      out_bAmpelSignalGruen    := gbFlashbit05sec;

      IF ( rtlTasterQuittierung.Q ) THEN
        out_bAmpelSignalGruen    := FALSE;
        out_bSignalScheibeAufgegeben := FALSE;

        steplGlashoehenmessung := STEP_800_E;
      END_IF

      (* Hinweis:
         - Scheibe zurueck fahren [Anlegen wiederholen]
      *)
      IF ( in_bKnebelGlastransportZurueck ) THEN
        steplGlashoehenmessung := STEP_330_E;
      END_IF

(* HÖHENMESSUNG ==================================*)
    STEP_330_E:
      out_bAmpelSignalGruen := FALSE;

      IF ( NOT Glastransport.bpSensorAuslauf ) THEN
        out_bSignalScheibeAufgegeben := TRUE;
      ELSE
        out_bSignalScheibeAufgegeben := gbFlashbit05sec;
      END_IF

      IF (  rtlTasterQuittierung.Q ) THEN
        out_bAmpelSignalGruen := FALSE;
        out_bSignalScheibeAufgegeben := FALSE;


        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;

        steplGlashoehenmessung := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Knebelschlater [Glastransport zurueck / Hubpalette heben]
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


(* HÖHENMESSUNG ==================================*)
    STEP_800_E:

      (* Hinweis:
         - Auftragsstatus setzen und beenden
      *)
      BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

      steplGlashoehenmessung := STEP_1000_E;

(*HÖHENMESSUNG ==================================*)
    STEP_900_E:
      Glastransport.bpScheibeZurueckFahren    := FALSE;
      BasisStationsParameter.eStatusAuftrag := eAuftragFehler;

      BasisStationsParameter.bFehler := TRUE;

(*HÖHENMESSUNG ==================================*)
    STEP_1000_E:
      BasisStationsParameter.bGlashoehenmessungAbgeschlossen := TRUE;

(*HÖHENMESSUNG ==================================*)
  END_CASE
ELSE

  IF( steplGlashoehenmessung > STEP_0_E )THEN

    Messachse.bpPositionierung := FALSE;
    Glastransport.bpScheibeZurueckFahren   := FALSE;

    BasisStationsParameter.bGlashoehenmessungAbgeschlossen := FALSE;
    steplGlashoehenmessung := STEP_0_E;
  END_IF

END_IF
END_ACTION