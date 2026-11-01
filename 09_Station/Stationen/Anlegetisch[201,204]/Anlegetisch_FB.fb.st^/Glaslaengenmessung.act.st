(* METADATA
{
  "v3Meta": {
    "objectGuid": "2a3c2d77-d365-41ce-ac76-4f873da75c43"
  }
}
*)
ACTION Glaslaengenmessung
//-------------------------------------------------------------------------------------------------
// AKTION: MESSUNG
//-------------------------------------------------------------------------------------------------
IF( BasisStationsParameter.bGlaslaengenmessung
    AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Anschlag.bpFehler ) THEN
    Anschlag.bpStartAusfahren := FALSE;
    Anschlag.bpStartEinfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Anschlag.wpFehlerNr;
    steplGlaslaengenmessung := STEP_900_E;
  END_IF
  
  IF ( Hubrahmen.bpFehler ) THEN
    Hubrahmen.bpStartAusfahren := FALSE;
    Hubrahmen.bpStartEinfahren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplGlaslaengenmessung := STEP_900_E;
  END_IF
  
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpGlaslaengenmessung := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplGlaslaengenmessung := STEP_900_E;
  END_IF


  CASE steplGlaslaengenmessung OF
    // GLASLAENGENMESSUNG ==================================
    STEP_0_E:
      (* Anmerkung:
         - Starten des Anlegeauftrags
         - Sicherung des Geblaeses Oeffner Kontakt
      *)
      BasisStationsParameter.eStatusAuftrag := eAuftragAktiv;

      blMerkerDrosselklappeAuf := FALSE;
            
      out_bAmpelSignalGruenScheibeAnlegen  := FALSE;
      
      steplGlaslaengenmessung := STEP_10_E;      

    // GLASLAENGENMESSUNG ==================================
    STEP_10_E:
      (* Anmerkung:
         - Anschlaege gesenkt
         - Hubrahmen 1 gehoben
         - Glastransport Referenz
      *)
      Hubrahmen.bpStartAusfahren := TRUE;
      Anschlag.bpStartEinfahren  := TRUE;
      Glastransport.bpReferenz   := TRUE;

      IF (  Anschlag.bpDone
           AND Hubrahmen.bpDone
           AND Glastransport.bpDone )
      THEN
        Hubrahmen.bpStartAusfahren := FALSE;
        Anschlag.bpStartEinfahren  := FALSE;
        Glastransport.bpReferenz   := FALSE;

        steplGlaslaengenmessung := STEP_20_E;
      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_20_E:
      (* Anmerkung:
         - Starten der Glaslaengenmessung mittels Riemen
      *)
      IF NOT Glastransport.bpDone THEN
        Glastransport.eGlastyp := BasisStationsParameter.wGlastyp[cWAND_1];
        Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];

        Glastransport.bpGlaslaengenmessung := TRUE;

        steplGlaslaengenmessung := STEP_30_E;
      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_30_E:
      (* Anmerkung:
         - Sollte das Fusspedal betaetigt worden sein ohne das Glas aufgelegt worden ist. Wird dieses durch den Glastransport abgefangen und ein Hinweis ausgegeben.
           Durch drücken des Fusspedals kann der Eintransport erneut gestartet werden.
      *)
      IF ( Glastransport.bpAnforderungMessergebnis AND NOT ( BasisStationsParameter.wGlastyp[cWAND_1] = eScheibe_Modell ) ) THEN
        steplGlaslaengenmessung := STEP_40_E;
      ELSIF ( BasisStationsParameter.wGlastyp[cWAND_1] = eScheibe_Modell ) THEN
        steplGlaslaengenmessung := STEP_50_E;
      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_40_E:
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
        wSPS2MMITRANSPORTSTATE := 1; // Scheibe OK und eingefahren
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        steplGlaslaengenmessung := STEP_100_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsLaenge);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(Glastransport.rpGemesseneGlaslaenge);

        SpsWarnung( eFehler_Station,
                    cMELDUNG_MESSUNG_FALSCHE_GLASLAENGE,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                    BasisStationsParameter.awFehlerInformationen );

        steplGlaslaengenmessung := STEP_200_E;

      END_IF

    // GLASLAENGENMESSUNG !!! Modellbetrieb !!! ==================================
    STEP_50_E:

      IF bpFreigabeScheibe THEN

        bpFreigabeScheibe := FALSE;
        bpKeineFreigabeScheibe := FALSE;

        wSPS2MMITransportstateStation := BasisStationsParameter.awFehlerInformationen[0];
        wSPS2MMITRANSPORTSTATE := 1; // Scheibe OK und eingefahren
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        Glastransport.bpScheibeFreigegeben := TRUE;
        Glastransport.bpScheibeQuittiert   := FALSE;

        steplGlaslaengenmessung := STEP_100_E;
      END_IF

      IF bpKeineFreigabeScheibe THEN

        bpFreigabeScheibe := FALSE;
        bpKeineFreigabeScheibe := FALSE;

        steplGlaslaengenmessung := STEP_200_E;

      END_IF


    // GLASLAENGENMESSUNG ==================================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< PLAUSIBELES MESSERGEBNIS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Anmerkung:
      //   - Beenden der Glastransport- Messfahrt
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpGlaslaengenmessung := FALSE;

        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

        steplGlaslaengenmessung := STEP_1000_E;

      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_200_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< FEHLERHAFTES MESSERGEBNIS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Anmerkung:
      //   - Ampel
      //   - Moeglichkeit Fehlmessung quittieren --> Scheibe freigegeben zum Austransport
      //   - Knebelschalter Glas zurueck auf die Station fahren
      //   - Quittiern
      //     => Nachricht an die Oberflaeche
      //       wSPS2MMITRANSPORTSTATE := 1 ==  Scheibe OK und eingefahren
      Anschlag.bpStartAusfahren := FALSE;
      Anschlag.bpStartEinfahren := FALSE;
      out_bSignalTasterScheibeQuittieren := gbFlashbit05sec;
      out_bAmpelSignalGruenScheibeAnlegen    := gbFlashbit05sec;

      IF ( rtlTasterQuittierung.Q ) THEN
        out_bAmpelSignalGruenScheibeAnlegen    := FALSE;
        out_bSignalTasterScheibeQuittieren := FALSE;

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
      IF ( in_bKnebelRiemenZurueck ) THEN
        steplGlaslaengenmessung := STEP_210_E;
      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_210_E:
      (* Anmerkung [FEHLERHAFTES SCANNERGEBNIS]:
         - Knebelschalter betaetigt -->WICHTIG: wird jetzt der Quittierungstaster betaetigt ist das die Bestaetigung das die Scheibe
           neu angelegt werden kann und neu gescannt werden muss [Auftrag bleibt Aktiv]
      *)
      out_bAmpelSignalGruenScheibeAnlegen := FALSE;

      IF ( NOT Glastransport.bpSensorAuslauf ) THEN
        out_bSignalTasterScheibeQuittieren := TRUE;
      ELSE
        out_bSignalTasterScheibeQuittieren := gbFlashbit05sec;
      END_IF

      IF (  rtlTasterQuittierung.Q
           AND NOT Glastransport.bpSensorAuslauf )
      THEN
        out_bAmpelSignalGruenScheibeAnlegen := FALSE;
        out_bSignalTasterScheibeQuittieren := FALSE;

        blAnlegenErzwingen := TRUE;

        Glastransport.bpScheibeQuittiert := TRUE;

        wSPS2MMITransportstateStation := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        wSPS2MMITRANSPORTSTATE := 0; // Scheibe nicht und wird zurück geholt
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;

        steplGlaslaengenmessung := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Knebelschlater [Glastransport zurueck / Hubpalette heben]
      *)
      IF ( in_bKnebelRiemenZurueck ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        Hubrahmen.bpStartAusfahren := TRUE;

      ELSE
        Hubrahmen.bpStartEinfahren := TRUE;
        Hubrahmen.bpStartAusfahren := FALSE;

      END_IF


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

        steplGlaslaengenmessung := STEP_900_E;
      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_900_E:
      Glastransport.bpScheibeZurueckFahren := FALSE;
      BasisStationsParameter.bFehler        := TRUE;

    // GLASLAENGENMESSUNG ==================================
    STEP_1000_E:
      BasisStationsParameter.bGlaslaengenmessungAbgeschlossen := TRUE;

  // GLASLAENGENMESSUNG ==================================
  END_CASE
ELSE

  IF( steplGlaslaengenmessung > STEP_0_E )THEN
    BasisStationsParameter.bGlaslaengenmessungAbgeschlossen := FALSE;

    out_bAmpelSignalGruenScheibeAnlegen      := FALSE;
    out_bSignalTasterScheibeQuittieren   := FALSE;

    Anschlag.bpStartAusfahren := FALSE;
    Anschlag.bpStartEinfahren := FALSE;

    Hubrahmen.bpStartEinfahren := FALSE;
    Hubrahmen.bpStartAusfahren := FALSE;

    Glastransport.bpScheibeFreigegeben       := FALSE;
    Glastransport.bpScheibeQuittiert         := FALSE;
    Glastransport.bpScheibeZurueckFahren     := FALSE;
    Glastransport.bpGlaslaengenmessung := FALSE;

    steplGlaslaengenmessung := STEP_0_E;
  END_IF

END_IF
END_ACTION