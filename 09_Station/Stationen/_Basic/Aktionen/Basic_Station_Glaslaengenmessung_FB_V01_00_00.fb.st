(* METADATA
{
	"v3Meta": {
		"objectGuid": "2c6643f2-e17f-4649-8f5f-9e9d8f38f605"
	}
}
*)
FUNCTION_BLOCK Basic_Station_Glaslaengenmessung_FB_V01_00_00 EXTENDS Basic_Station_Aktion_FB_V01_00_00
(* Hinweis:
   - Glaslaengenmessung der Station: startet die Messfahrt im Glastransport, wertet das Ergebnis aus und fragt
     bei einer Fehlmessung den Bediener (Quittieren, Scheibe zurueckfahren und neu anlegen)
   - Bei einer Modellscheibe entscheidet das MMI ueber die Freigabe der Scheibe
   - Hubrahmen und Anschlag nur mit den Ausbaustufen bHubrahmen und bAnschlag, sonst muessen sie nicht uebergeben werden
   - Der Glastransport wird vor jeder Messung referenziert
*)
VAR_IN_OUT

  // BOOLEAN
  blAnlegenErzwingen    : BOOL; // Anlegen soll erzwungen werden (Scheibe wird neu angelegt)
  bpFreigabeScheibe     : BOOL; // MMI: Scheibe wurde erfolgreich vermessen (Modellscheibe)
  bpKeineFreigabeScheibe : BOOL; // MMI: Scheibe wurde nicht erfolgreich vermessen (Modellscheibe)

END_VAR
VAR_INPUT

  // BOOLEAN
  bpTasterQuittierung : BOOL; // Station: Taster Fehlmessung quittieren (steigende Flanke)
  bpKnebelZurueck     : BOOL; // Station: Knebel Scheibe zurueckfahren

  // Bausteine
  Anschlag  : REFERENCE TO ZylinderPneumatik_Anschlag_FB_V01_00_00;
  Hubrahmen : REFERENCE TO ZylinderPneumatik_Riemen_FB_V01_00_00;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpAnlegenLampe     : BOOL; // Ampel gruen / Signal Scheibe aufgegeben
  bpSignalFehlmessung : BOOL; // Taster Fehlmessung quittieren (blinkt)
  bpBedienerEingriff : BOOL; // Aktion wartet auf den Bediener, Handfunktionen (Knebel, Hubrahmen) muessen im Automatikbetrieb greifen

END_VAR
VAR

  // BOOLEAN
  blAnschlagFehler     : BOOL;
  blAnschlagFertig     : BOOL; // Anschlag fertig oder nicht vorhanden
  blHubrahmenFehler    : BOOL;
  blHubrahmenFertig    : BOOL; // Hubrahmen fertig oder nicht vorhanden
  blSensorAuslaufLampe : BOOL; // Sensor fuer die Lampe: Vorab-Sensor, wenn die Station damit misst
  blModellscheibe      : BOOL;

END_VAR
//-------------------------------------------------------------------------------------------------
// GLASLAENGENMESSUNG
//-------------------------------------------------------------------------------------------------
blAnschlagFehler  := FALSE;
blAnschlagFertig  := TRUE;
blHubrahmenFehler := FALSE;
blHubrahmenFertig := TRUE;

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
  blAnschlagFehler := Anschlag.bpFehler;
  blAnschlagFertig := Anschlag.bpDone;
END_IF

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
  blHubrahmenFehler := Hubrahmen.bpFehler;
  blHubrahmenFertig := Hubrahmen.bpDone;
END_IF

IF ( BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bScheibenmessungSensorVorabAuslauf ) THEN
  blSensorAuslaufLampe := Glastransport.bpSensorAuslaufVorAb;
ELSE
  blSensorAuslaufLampe := Glastransport.bpSensorAuslauf;
END_IF

blModellscheibe := ( BasisStationsParameter.wGlastyp[cWAND_1] = eScheibe_Modell );

IF( BasisStationsParameter.bGlaslaengenmessung
    AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
    IF ( blAnschlagFehler ) THEN
      Anschlag.bpStartAusfahren := FALSE;
      Anschlag.bpStartEinfahren := FALSE;
      BasisStationsParameter.wFehlerNummer := Anschlag.wpFehlerNr;
      steplAktion := STEP_900_E;
    END_IF
  END_IF

  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
    IF ( blHubrahmenFehler ) THEN
      Hubrahmen.bpStartAusfahren := FALSE;
      Hubrahmen.bpStartEinfahren := FALSE;
      BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
      steplAktion := STEP_900_E;
    END_IF
  END_IF

  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpGlaslaengenmessung := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // GLASLAENGENMESSUNG ==================================
    STEP_0_E:
      (* Anmerkung:
         - Starten des Anlegeauftrags
         - Sicherung des Geblaeses muss in Ordnung sein [Oeffner-Kontakt]
      *)
      bpFehler := FALSE;

      IF ( bpGeblaeseFehler ) THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAktion := STEP_900_E;

      ELSE
        BasisStationsParameter.eStatusAuftrag := eAuftragAktiv;

        bpAnlegenLampe := FALSE;

        steplAktion := STEP_10_E;

      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_10_E:
      (* Anmerkung:
         - Glastransport referenzieren (vor jeder Messung)
         - Mit Anschlag oder Hubrahmen: Anschlaege gesenkt, Hubrahmen gehoben
      *)
      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        Hubrahmen.bpStartAusfahren := TRUE;
      END_IF

      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
        Anschlag.bpStartEinfahren := TRUE;
      END_IF

      Glastransport.bpReferenz := TRUE;

      IF (     blAnschlagFertig
           AND blHubrahmenFertig
           AND Glastransport.bpDone )
      THEN
        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
          Hubrahmen.bpStartAusfahren := FALSE;
        END_IF

        IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
          Anschlag.bpStartEinfahren := FALSE;
        END_IF

        Glastransport.bpReferenz := FALSE;

        steplAktion := STEP_20_E;
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

        steplAktion := STEP_30_E;
      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_30_E:
      (* Anmerkung:
         - Sollte das Fusspedal betaetigt worden sein ohne das Glas aufgelegt worden ist. Wird dieses durch den Glastransport abgefangen und ein Hinweis ausgegeben.
           Durch druecken des Fusspedals kann der Eintransport erneut gestartet werden.
      *)
      IF ( Glastransport.bpAnforderungMessergebnis AND NOT blModellscheibe ) THEN
        steplAktion := STEP_40_E;
      ELSIF ( blModellscheibe ) THEN
        steplAktion := STEP_50_E;
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

        wSPS2MMITransportstateStation := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSPS2MMITRANSPORTSTATE := 1; // Scheibe OK und eingefahren
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        steplAktion := STEP_100_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsLaenge );
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD( Glastransport.rpGemesseneGlaslaenge );

        SpsWarnung( eFehler_Station,
                    cMELDUNG_MESSUNG_FALSCHE_GLASLAENGE,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ),
                    BasisStationsParameter.awFehlerInformationen );

        steplAktion := STEP_200_E;

      END_IF

    // GLASLAENGENMESSUNG !!! Modellbetrieb !!! ==================================
    STEP_50_E:
      IF ( bpFreigabeScheibe ) THEN

        bpFreigabeScheibe      := FALSE;
        bpKeineFreigabeScheibe := FALSE;

        wSPS2MMITransportstateStation := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSPS2MMITRANSPORTSTATE := 1; // Scheibe OK und eingefahren
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        Glastransport.bpScheibeFreigegeben := TRUE;
        Glastransport.bpScheibeQuittiert   := FALSE;

        steplAktion := STEP_100_E;
      END_IF

      IF ( bpKeineFreigabeScheibe ) THEN

        bpFreigabeScheibe      := FALSE;
        bpKeineFreigabeScheibe := FALSE;

        steplAktion := STEP_200_E;

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

        steplAktion := STEP_1000_E;

      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_200_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< FEHLERHAFTES MESSERGEBNIS >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Anmerkung:
      //   - Ampel
      //   - Moeglichkeit Fehlmessung quittieren --> Scheibe freigegeben zum Austransport
      //   - Knebelschalter Glas zurueck auf die Station fahren (Handfunktionen greifen im Automatikbetrieb)
      //   - Quittiern
      //     => Nachricht an die Oberflaeche
      //       wSPS2MMITRANSPORTSTATE := 1 ==  Scheibe OK und eingefahren
      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
        Anschlag.bpStartAusfahren := FALSE;
        Anschlag.bpStartEinfahren := FALSE;
      END_IF

      bpSignalFehlmessung := gbFlashbit05sec;
      bpAnlegenLampe      := gbFlashbit05sec;

      IF ( bpTasterQuittierung ) THEN
        bpAnlegenLampe      := FALSE;
        bpSignalFehlmessung := FALSE;

        Glastransport.bpScheibeFreigegeben := FALSE;
        Glastransport.bpScheibeQuittiert   := TRUE;

        wSPS2MMITransportstateStation := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSPS2MMITRANSPORTSTATE        := 1;
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        BasisStationsParameter.eStatusAuftrag := eAuftragErfolgreich;

        steplAktion := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Scheibe zurueck fahren [Anlegen wiederholen]
      *)
      IF ( bpKnebelZurueck ) THEN
        steplAktion := STEP_210_E;
      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_210_E:
      (* Anmerkung [FEHLERHAFTES SCANNERGEBNIS]:
         - Knebelschalter betaetigt -->WICHTIG: wird jetzt der Quittierungstaster betaetigt ist das die Bestaetigung das die Scheibe
           neu angelegt werden kann und neu gescannt werden muss [Auftrag bleibt Aktiv]
         - Knebel und Hubrahmen werden von den Handfunktionen der Station bedient
      *)
      bpAnlegenLampe := FALSE;

      IF ( NOT blSensorAuslaufLampe ) THEN
        bpSignalFehlmessung := TRUE;
      ELSE
        bpSignalFehlmessung := gbFlashbit05sec;
      END_IF

      IF (  bpTasterQuittierung
           AND NOT Glastransport.bpSensorAuslauf )
      THEN
        bpAnlegenLampe      := FALSE;
        bpSignalFehlmessung := FALSE;

        blAnlegenErzwingen := TRUE;

        Glastransport.bpScheibeQuittiert := TRUE;

        wSPS2MMITransportstateStation := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSPS2MMITRANSPORTSTATE := 0; // Scheibe nicht und wird zurueck geholt
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSPORTSTATE );

        BasisStationsParameter.eStatusAuftrag := eAuftragWiederholen;

        steplAktion := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Hubpalette senkt / hebt nicht in der vorgeschriebenen Zeit bzw. Sensor schaltet nicht
      *)
      IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        IF ( blHubrahmenFehler ) THEN
          Hubrahmen.bpStartEinfahren := FALSE;
          Hubrahmen.bpStartAusfahren := FALSE;

          BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
          BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;

          steplAktion := STEP_900_E;
        END_IF
      END_IF

    // GLASLAENGENMESSUNG ==================================
    STEP_900_E:
      bpFehler := TRUE;
      BasisStationsParameter.bFehler := TRUE;

    // GLASLAENGENMESSUNG ==================================
    STEP_1000_E:
      BasisStationsParameter.bGlaslaengenmessungAbgeschlossen := TRUE;

  // GLASLAENGENMESSUNG ==================================
  END_CASE

  // Waehrend ein fehlerhaftes Messergebnis quittiert oder die Scheibe zurueckgefahren wird: Handfunktionen greifen
  bpBedienerEingriff := ( steplAktion = STEP_200_E ) OR ( steplAktion = STEP_210_E );

ELSE

  bpBedienerEingriff := FALSE;

  IF( steplAktion > STEP_0_E )THEN
    BasisStationsParameter.bGlaslaengenmessungAbgeschlossen := FALSE;

    bpFehler            := FALSE;
    bpAnlegenLampe      := FALSE;
    bpSignalFehlmessung := FALSE;

    IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
      Anschlag.bpStartAusfahren := FALSE;
      Anschlag.bpStartEinfahren := FALSE;
    END_IF

    IF ( BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
      Hubrahmen.bpStartEinfahren := FALSE;
      Hubrahmen.bpStartAusfahren := FALSE;
    END_IF

    Glastransport.bpScheibeFreigegeben   := FALSE;
    Glastransport.bpScheibeQuittiert     := FALSE;
    Glastransport.bpScheibeZurueckFahren := FALSE;
    Glastransport.bpGlaslaengenmessung   := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK