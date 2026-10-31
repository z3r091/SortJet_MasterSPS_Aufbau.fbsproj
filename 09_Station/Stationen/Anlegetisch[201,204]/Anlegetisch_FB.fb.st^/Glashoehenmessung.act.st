(* METADATA
{
	"v3Meta": {
		"objectGuid": "1989a628-2624-4464-9eb3-e10383eaf362"
	}
}
*)
ACTION Glashoehenmessung
(***************************************************************************************************)
(* AKTION HÖHENMESSUNG *)
(***************************************************************************************************)
IF( BasisStationsParameter.bGlashoehenmessung )THEN

  // Ausnahmesituation
  IF ( Messachse.bpFehler ) THEN
    Messachse.bpPositionierung := FALSE;
    Messachse.bpVermessen_Oberkante_1_Sensor := FALSE;
    Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := FALSE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
    steplGlashoehenmessung := STEP_900_E;
  END_IF

  IF ( Anschlag.bpFehler ) THEN
    Anschlag.bpStartAusfahren := FALSE;
    Anschlag.bpStartEinfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Anschlag.wpFehlerNr;
    steplGlashoehenmessung := STEP_900_E;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    Hubrahmen.bpStartAusfahren := FALSE;
    Hubrahmen.bpStartEinfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplGlashoehenmessung := STEP_900_E;
  END_IF

  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpVortransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
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

      rlScheibenHoehe       := 0.0;
      rlAbstandZurNulllinie := 0.0;

      IF ( BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bVortransport ) THEN
        Glastransport.bpVortransport := TRUE;
        steplGlashoehenmessung := STEP_10_E;
      ELSE
        steplGlashoehenmessung := STEP_20_E;
      END_IF

(* HÖHENMESSUNG ==================================*)
    STEP_10_E:
      (* Hinweis:
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpVortransport := FALSE;
        steplGlashoehenmessung := STEP_20_E;
      END_IF

(* HÖHENMESSUNG ==================================*)
    STEP_20_E:
      (* Hinweis:
         - Für die Steuerschrittkette müssen wir einmal kurz in eAuftragAktiv wechseln bevor
           in Schritt 800 dann eAuftrakErfolgreich gesetzt werden kann
      *)
      IF BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenVermessen THEN
        steplGlashoehenmessung := STEP_100_E;
      ELSE
        steplGlashoehenmessung := STEP_800_E;
      END_IF

(* HÖHENMESSUNG ==================================*)
    STEP_100_E:

      (* Hinweis:
         - Je nach gesetzten Modi aus dem Anlegen/Eintransport wird nun entsprechend die Höhe gemessen
      *)
     CASE epTypeHoehenmessung OF

       Modus_Positionieren_Auf_Oberkante_2_Sensoren:
         steplGlashoehenmessung := STEP_200_E;

       Modus_Vermessen_Oberkante_1_Sensor:
         steplGlashoehenmessung := STEP_400_E;

       Modus_Vermessen_OberUndUnterkante_2_Sensoren:
         steplGlashoehenmessung := STEP_600_E;

     END_CASE

(* HÖHENMESSUNG ==================================*)
    STEP_200_E:
      (* Hinweis:
         - Messachse nochmal auf Position fahren
      *)
      IF Messachse.Antrieb.rpMaxPosition < ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) THEN
        Messachse.rpZielPosition := Messachse.Antrieb.rpMaxPosition;
      ELSE
        Messachse.rpZielPosition := ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset );
      END_IF
      Messachse.bpPositionierung := TRUE;

      steplGlashoehenmessung := STEP_210_E;

(* HÖHENMESSUNG ==================================*)
    STEP_210_E:
      (* Hinweis:
         - Messachse nochmal auf Position fahren
      *)
      IF Messachse.bpDone THEN
        Messachse.bpPositionierung := FALSE;
        IF BasisStationsParameter.stMKs.stStationsAufbau.bMessachseAmEndeVomTisch THEN
          steplGlashoehenmessung := STEP_310_E;
        ELSE
          steplGlashoehenmessung := STEP_300_E;
        END_IF
      END_IF


(* HÖHENMESSUNG ==================================*)
    STEP_300_E:

      (* Hinweis:
         - Auswertung der Sensorik
      *)
      IF Messachse.Antrieb.rpMaxPosition >= ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) THEN
      CASE Messachse.epGlashoehenTyp OF

        eGlasHoeheOK:
          steplGlashoehenmessung := STEP_800_E;

        eGlasZuHoch:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_HOCH,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
							 
          BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
          steplGlashoehenmessung := STEP_1000_E;

        eGlasZuNiedrig:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_NIEDRIG,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
							 
          BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
          steplGlashoehenmessung := STEP_1000_E;

      END_CASE
	  ELSE
        steplGlashoehenmessung := STEP_800_E;
	  END_IF


(* HÖHENMESSUNG ==================================*)
    STEP_310_E:

      (* Hinweis:
         - Auswertung der Sensorik
      *)
      IF Messachse.Antrieb.rpMaxPosition >= ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) THEN
      CASE Messachse.epGlashoehenTyp OF

        eGlasHoeheOK:
          steplGlashoehenmessung := STEP_800_E;

        eGlasZuHoch:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_HOCH,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );

          steplGlashoehenmessung := STEP_320_E;

        eGlasZuNiedrig:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_NIEDRIG,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
							 
          steplGlashoehenmessung := STEP_320_E;

      END_CASE
	  ELSE
        steplGlashoehenmessung := STEP_800_E;
	  END_IF


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
      out_bSignalTasterScheibeQuittieren := gbFlashbit05sec;
      out_bAmpelSignalGruenScheibeAnlegen    := gbFlashbit05sec;

      IF ( rtlTasterQuittierung.Q ) THEN
        out_bAmpelSignalGruenScheibeAnlegen    := FALSE;
        out_bSignalTasterScheibeQuittieren := FALSE;

        steplGlashoehenmessung := STEP_800_E;
      END_IF

      (* Hinweis:
         - Scheibe zurueck fahren [Anlegen wiederholen]
      *)
      IF ( in_bKnebelRiemenZurueck ) THEN
        steplGlashoehenmessung := STEP_330_E;
      END_IF

(* HÖHENMESSUNG ==================================*)
    STEP_330_E:
      out_bAmpelSignalGruenScheibeAnlegen := FALSE;

      IF ( NOT Glastransport.bpSensorAuslauf ) THEN
        out_bSignalTasterScheibeQuittieren := TRUE;
      ELSE
        out_bSignalTasterScheibeQuittieren := gbFlashbit05sec;
      END_IF

      IF (  rtlTasterQuittierung.Q ) THEN
        out_bAmpelSignalGruenScheibeAnlegen := FALSE;
        out_bSignalTasterScheibeQuittieren := FALSE;

	    blAnlegenErzwingen:= TRUE;

        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;

        steplGlashoehenmessung := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Knebelschlater [Glastransport zurueck / Hubpalette heben]
      *)
      IF ( in_bKnebelRiemenZurueck ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        Hubrahmen.bpStartAusfahren := tonlKnebelZurueck.Q;

      ELSE
        Hubrahmen.bpStartEinfahren := TRUE;
        Hubrahmen.bpStartAusfahren := FALSE;

      END_IF
      Glastransport.bpAnforderungHandfunktion := TRUE;

      IF (  Hubrahmen.epStatusZylinder = eZylinderAusgefahren ) THEN
        Glastransport.bpScheibeZurueckFahren := in_bKnebelRiemenZurueck;
      ELSE
        Glastransport.bpScheibeZurueckFahren := FALSE;
      END_IF

      (* Fehlerbehandlung:
         - Hubpalette senkt / heben nicht in der vorgeschriebenen Zeit bzw. Sensor schaltet nicht
      *)
      IF ( Hubrahmen.bpFehler ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        Hubrahmen.bpStartAusfahren := FALSE;

        BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
        BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;

        steplGlashoehenmessung := STEP_900_E;
      END_IF


(* HÖHENMESSUNG ==================================*)
    STEP_400_E:
      (* Hinweis:
         - Messachse auf Position fahren
      *)
      Messachse.rpZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe - Messachse.ppParameterBaustein.rStreckePositionieren;
      Messachse.bpPositionierung := TRUE;

      steplGlashoehenmessung := STEP_410_E;

(* HÖHENMESSUNG ==================================*)
    STEP_410_E:
      (* Hinweis:
         - Messachse nochmal auf Position fahren
      *)
      IF Messachse.bpDone THEN
        Messachse.bpPositionierung := FALSE;
        steplGlashoehenmessung := STEP_420_E;
      END_IF

(* HÖHENMESSUNG ==================================*)
    STEP_420_E:
      (* Hinweis:
         - Messung starten
      *)
      Messachse.rpZielPosition := BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe;
      Messachse.bpVermessen_Oberkante_1_Sensor := TRUE;

      steplGlashoehenmessung := STEP_430_E;

(* HÖHENMESSUNG ==================================*)
    STEP_430_E:
      (* Hinweis:
         - Messende abwarten
      *)
      IF Messachse.bpDone THEN
        Messachse.bpVermessen_Oberkante_1_Sensor := FALSE;
        steplGlashoehenmessung := STEP_500_E;
      END_IF

(* HÖHENMESSUNG ==================================*)
    STEP_500_E:

      (* Hinweis:
         - Auswertung der Messung
      *)
      IF Messachse.Antrieb.rpMaxPosition >= ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) THEN
      CASE Messachse.epGlashoehenTypMode2 OF

        eGlasHoeheOK:
          steplGlashoehenmessung := STEP_800_E;

        eGlasZuHoch:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_HOCH,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
							 
          BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
          steplGlashoehenmessung := STEP_1000_E;

        eGlasZuNiedrig:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_NIEDRIG,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
							 
          BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
          steplGlashoehenmessung := STEP_1000_E;

      END_CASE
	  ELSE
        steplGlashoehenmessung := STEP_800_E;
	  END_IF

(* HÖHENMESSUNG ==================================*)
    STEP_600_E:
      (* Hinweis:
         - Messachse verfahren lassen um Scheibenkanten zu suchen
      *)
		Messachse.rpErwarteteScheibenHoehe := BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe;
      Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := TRUE;

      steplGlashoehenmessung := STEP_610_E;

(* HÖHENMESSUNG ==================================*)
    STEP_610_E:
      (* Hinweis:
         - Scheibenkantensuche abgeschlossen 
      *)
      IF Messachse.bpVermessenAbgeschlossen THEN
        Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := FALSE;

        rlScheibenHoehe := Messachse.rlMessErgebnis;
        rlAbstandZurNulllinie := Messachse.rlScheibenunterkante - Messachse.ppParameterBaustein.rAbstandSensorenOberUndUnterkante;

        steplGlashoehenmessung := STEP_700_E;

         //steplGlashoehenmessung := STEP_800_E;
      END_IF

(* HÖHENMESSUNG ==================================*)
    STEP_700_E:
      (* Hinweis:
         - Auswertung der Scheibenkantensuche
      *)
      IF Messachse.Antrieb.rpMaxPosition >= ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe + Messachse.ppParameterBaustein.rKorrekturOffset ) THEN
      CASE Messachse.epGlashoehenTypMode2 OF

        eGlasHoeheOK:
          steplGlashoehenmessung := STEP_800_E;

        eGlasZuHoch:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_HOCH,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
							 
          BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
          steplGlashoehenmessung := STEP_1000_E;

        eGlasZuNiedrig:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_SCHEIBE_ZU_NIEDRIG,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
							 
          BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
          steplGlashoehenmessung := STEP_1000_E;
			 
		  // Die Glasvermessung war fehlerhaft. Scheibe neu anlgen.
		  eGlasMessungWiederholen:
          BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe);
          SpsWarnung( eFehler_Station,
                      cMELDUNG_MESSUNG_FEHLMESSUNG,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
							 
          BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;
          steplGlashoehenmessung := STEP_1000_E;

      END_CASE
		
	  ELSE
        steplGlashoehenmessung := STEP_800_E;
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
      Glastransport.bpAnforderungHandfunktion := FALSE;
      BasisStationsParameter.eStatusAuftrag := eAuftragFehler;

      BasisStationsParameter.bFehler := TRUE;

(*HÖHENMESSUNG ==================================*)
    STEP_1000_E:
      BasisStationsParameter.bGlashoehenmessungAbgeschlossen := TRUE;

(*HÖHENMESSUNG ==================================*)
  END_CASE
ELSE

  IF( steplGlashoehenmessung > STEP_0_E )THEN

    Messachse.bpPositionierung        := FALSE;
    Glastransport.bpVortransport            := FALSE;
    Glastransport.bpScheibeZurueckFahren    := FALSE;
    Glastransport.bpAnforderungHandfunktion := FALSE;

    BasisStationsParameter.bGlashoehenmessungAbgeschlossen := FALSE;
	  
    Messachse.bpVermessen_Oberkante_1_Sensor := FALSE;
    Messachse.bpVermessen_OberUndUnterkante_2_Sensoren := FALSE;
    steplGlashoehenmessung := STEP_0_E;
  END_IF

END_IF
END_ACTION