(* METADATA
{
	"v3Meta": {
		"objectGuid": "5b62d882-9f50-417a-9f62-9cbdd29d47f6"
	}
}
*)
ACTION Glaslaengenmessung
(***************************************************************************************************)
(* AKTION: MESSUNG *)
(***************************************************************************************************)
IF( BasisStationsParameter.bGlaslaengenmessung
  AND blBetriebsartAutomatik )
THEN
  (* Fehlerbehandlung
     - Glastransport
  *)
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpGlaslaengenmessung := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplGlaslaengenmessung := STEP_900_E;
  END_IF

  CASE steplGlaslaengenmessung OF
(* GLASLAENGENMESSUNG ==================================*)
    STEP_0_E:
      (* Anmerkung:
         - Starten des Anlegeauftrags
         - Sicherung des Geblaeses Oeffner Kontakt 
      *)

      IF ( in_bMotorschutzGeblaese_Ok ) THEN

        BasisStationsParameter.eStatusAuftrag := eAuftragAktiv;

        out_bDrosselklappeOeffnen    := FALSE;
        out_bSignalScheibeAufgegeben := FALSE;

        steplGlaslaengenmessung := STEP_10_E;

      ELSE
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplGlaslaengenmessung := STEP_900_E;

      END_IF

      
(* GLASLAENGENMESSUNG ==================================*)
    STEP_10_E:
      (* Anmerkung
         - Starten der Glaslaengenmessung mittels Riemen
      *)
      Glastransport.pAuftrag  := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpGlaslaengenmessung := TRUE;

      steplGlaslaengenmessung := STEP_20_E;

(* GLASLAENGENMESSUNG ==================================*)
    STEP_20_E:
      (* Anmerkung:
         - Sollte das Fusspedal betaetigt worden sein ohne das Glas aufgelegt worden ist. Wird dieses durch den Glastransport abgefangen und ein Hinweis ausgegeben.
           Durch drücken des Fusspedals kann der Eintransport erneut gestartet werden. 
      *)
      IF ( Glastransport.bpAnforderungMessergebnis ) THEN
        steplGlaslaengenmessung := STEP_30_E;
      END_IF

(* GLASLAENGENMESSUNG ==================================*)
    STEP_30_E:
      (* Hinweis:
         - Auswertung des Messergebnisses
         - Ergebnis
           => TRUE  : Nachricht an die Oberflaeche [Schritt 100]
           => FALSE : Hinweis- Meldung [Schritt 200]
      *)
      IF ( ABS( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsLaenge - Glastransport.rpGemesseneGlaslaenge ) <= Glastransport.ppParameterBaustein.rMesstoleranz )  THEN

        Glastransport.bpScheibeFreigegeben := TRUE;
        Glastransport.bpScheibeQuittiert   := FALSE;

        wSPS2MMITransportstateStation := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        wSPS2MMITRANSPORTSTATE := 1; (* Scheibe OK und eingefahren *)
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        steplGlaslaengenmessung := STEP_100_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsLaenge);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(Glastransport.rpGemesseneGlaslaenge);

        SpsWarnung( eFehler_Station, cMELDUNG_MESSUNG_FALSCHE_GLASLAENGE, BasisStationsParameter.stMKs.stStationsNummern.NummerExtern, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsParameter.awFehlerInformationen );
        steplGlaslaengenmessung := STEP_200_E;

      END_IF

(* GLASLAENGENMESSUNG ==================================*)
    STEP_100_E:
      (* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< PLAUSIBELES MESSERGEBNIS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
         
         Anmerkung:
         - Beenden der Glastransport- Messfahrt
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpGlaslaengenmessung := FALSE;

        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

        steplGlaslaengenmessung := STEP_1000_E;

      END_IF

      (* Fehlerbehandlung
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpGlaslaengenmessung := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplGlaslaengenmessung := STEP_900_E;
      END_IF

(* GLASLAENGENMESSUNG ==================================*)
    STEP_200_E:
      (* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< FEHLERHAFTES MESSERGEBNIS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
         
         Anmerkung:
         - Ampel
         - Moeglichkeit Fehlmessung quittieren --> Scheibe freigegeben zum Austransport
         - Knebelschalter Glas zurueck auf die Station fahren 
         - Quittiern
           => Nachricht an die Oberflaeche
             wSPS2MMITRANSPORTSTATE := 1 ==  Scheibe OK und eingefahren 
      *)
      out_bSignalScheibeFehlmessung := gbFlashbit05sec;
      out_bAmpelSignalGruen    := gbFlashbit05sec;

      IF ( rtlTasterQuittierung.Q ) THEN
        out_bAmpelSignalGruen    := FALSE;
        out_bSignalScheibeFehlmessung := FALSE;

        Glastransport.bpScheibeFreigegeben := FALSE;
        Glastransport.bpScheibeQuittiert   := TRUE;

        wSPS2MMITransportstateStation := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        wSPS2MMITRANSPORTSTATE        := 1;
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

        steplGlaslaengenmessung := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Scheibe zurueck fahren [Anlegen wiederholen]
      *)
      IF ( in_bKnebelGlastransportZurueck ) THEN
        steplGlaslaengenmessung := STEP_210_E;
      END_IF

(* GLASLAENGENMESSUNG ==================================*)
    STEP_210_E:
      (* Anmerkung [FEHLERHAFTES SCANNERGEBNIS]:
         - Knebelschalter betaetigt -->WICHTIG: wird jetzt der Quittierungstaster betaetigt ist das die Bestaetigung das die Scheibe 
           neu angelegt werden kann und neu gescannt werden muss [Auftrag bleibt Aktiv]
      *)
      out_bAmpelSignalGruen := FALSE;

      IF ( NOT Glastransport.bpSensorAuslaufVorab ) THEN
        out_bSignalScheibeFehlmessung := TRUE;
      ELSE
        out_bSignalScheibeFehlmessung := gbFlashbit05sec;
      END_IF

      IF (  rtlTasterQuittierung.Q
        AND NOT Glastransport.bpSensorAuslauf )
      THEN
        out_bAmpelSignalGruen := FALSE;
        out_bSignalScheibeFehlmessung := FALSE;

        Glastransport.bpScheibeQuittiert := TRUE;

        wSPS2MMITransportstateStation := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        wSPS2MMITRANSPORTSTATE := 0; (* Scheibe nicht und wird zurück geholt *)
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;

        steplGlaslaengenmessung := STEP_1000_E;
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

(* GLASLAENGENMESSUNG ==================================*)
    STEP_900_E:
      Glastransport.bpScheibeZurueckFahren     := FALSE;
      BasisStationsParameter.bFehler := TRUE;

(* GLASLAENGENMESSUNG ==================================*)
    STEP_1000_E:
      BasisStationsParameter.bGlaslaengenmessungAbgeschlossen := TRUE;

(* GLASLAENGENMESSUNG ==================================*)
  END_CASE
ELSE

  IF( steplGlaslaengenmessung > STEP_0_E )THEN
    BasisStationsParameter.bGlaslaengenmessungAbgeschlossen := FALSE;

    out_bAmpelSignalGruen         := FALSE;
    out_bSignalScheibeAufgegeben  := FALSE;
    out_bSignalScheibeFehlmessung := FALSE;

    Glastransport.bpScheibeFreigegeben   := FALSE;
    Glastransport.bpScheibeQuittiert     := FALSE;
    Glastransport.bpScheibeZurueckFahren := FALSE;
    Glastransport.bpGlaslaengenmessung   := FALSE;

    steplGlaslaengenmessung := STEP_0_E;
  END_IF

END_IF
END_ACTION