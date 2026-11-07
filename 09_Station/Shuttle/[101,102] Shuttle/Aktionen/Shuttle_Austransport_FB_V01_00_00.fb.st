(* METADATA
{
	"v3Meta": {
		"objectGuid": "aea75a09-065c-4155-9284-9233b13eb99a"
	}
}
*)
FUNCTION_BLOCK Shuttle_Austransport_FB_V01_00_00 EXTENDS Basic_Shuttle_Aktion_FB_V01_00_00
VAR_INPUT

  // GREIFER [Ausbaustufe stStationsAufbau.bGreifer]
  bpGreiferAktiv : BOOL;
  Greifer        : REFERENCE TO Shuttle_Greifer_FB_V01_00_00;

END_VAR
VAR

  // BOOL
  blMitGreifer : BOOL; // Austransport mit dem Greifer (Greifer vorhanden und Greiferseite im Auftrag)

  // TIMER
  tonlUeberwachungGreifer : TON;

END_VAR
VAR CONSTANT

  // TIME
  cZEIT_UEBERWACHUNG_GREIFER : TIME := T#120S; // Gesamtueberwachung je Greifer-Schritt (die Wartestellen ueberwacht der Greifer selbst)

END_VAR
//-------------------------------------------------------------------------------------------------
// AKTION AUSTRANSPORT WAND 1
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Es handelt sich hier um einen Austransport in einen Faecherwagen
*)
IF (  BasisStationsParameter.bAustransport[wWand]
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpAustransport := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Glastransport.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF
  
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Kippen.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF
  
  IF ( Wandverstellung.bpFehler ) THEN
    Wandverstellung.bpStartePositionierung := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Wandverstellung.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  IF ( Geblaese.bpFehler ) THEN
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
    steplAktion:=STEP_900_E;
  END_IF

  IF ( blMitGreifer AND Greifer.bpFehler ) THEN
    Greifer.bpPositionieren                       := FALSE;
    Greifer.bpStarteAustransport                  := FALSE;
    Glastransport.bpStarteGlasPositionierungGreifer := FALSE;
    Glastransport.bpStarteKorrekturfahrt          := FALSE;
    BasisStationsParameter.awFehlerInformationen  := Greifer.awpFehlerInformationen;
    BasisStationsParameter.wFehlerNummer          := Greifer.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // AUSTRANSPORT =====================================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      BasisStationsParameter.bAustransportAbgeschlossen[wWand]    := FALSE;

      blMitGreifer :=     bpGreiferAktiv
                      AND ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eGreiferTyp <> eGreiferDefault );

      steplAktion := STEP_10_E;

    // AUSTRANSPORT =====================================
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Zielposition erreicht wurde
      *)
      IF ( bpZielPositionErreicht ) THEN
        steplAktion := STEP_20_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.rAktuellePositionQuerfahrt);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[wWand].rVorabPosition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplAktion := STEP_900_E;

      END_IF

    // AUSTRANSPORT =====================================
    STEP_20_E:
      // ---------------------------------------------------------------------------------------
      //  ANSTEUERUNG KOMPONENTEN
      //
      //  Hinweis:
      //  - Sicherstellen dass das Geblaese aktiv  und keine Vorab- Auftrag aktiv sind
      // ---------------------------------------------------------------------------------------

      IF (  bpGeblaeseAktiv
           AND NOT bpVorAbAuftragAktiv )
      THEN

        (* Hinweis:
           - Anstellen der Dicken-/ Wandverstellung in Abhängigkeit der Glasdicke
        *)
        Wandverstellung.epSollStellung         := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
        Wandverstellung.bpStartePositionierung := FALSE;

        (* Hinweis:
           - Shuttle in die passende Position kippen
        *)
        Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition;
        Kippen.bpPositionieren := TRUE;

        steplAktion := STEP_30_E;

      END_IF

      (* Fehlerbehandlung:
         - Geblaese
      *)
      IF ( Geblaese.bpFehler ) THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplAktion := STEP_900_E;
      END_IF

    // AUSTRANSPORT =====================================
    STEP_30_E:
      (* Hinweis:
         - Wandverstellung gefahren ?
      *)
      IF ( (  Wandverstellung.bpDone OR  NOT Wandverstellung.bpStartePositionierung )
           AND (  Kippen.bpDone OR NOT Kippen.bpPositionieren ) )
      THEN
        Kippen.bpPositionieren := FALSE;

        Wandverstellung.bpStartePositionierung := FALSE;

        IF ( blMitGreifer ) THEN
          steplAktion := STEP_200_E;
        ELSE
          steplAktion := STEP_100_E;
        END_IF
      END_IF

      // Ausnahmesituation
      //   - Komponenten
      IF ( Wandverstellung.bpFehler ) THEN
        Wandverstellung.bpStartePositionierung := FALSE;
        BasisStationsParameter.wFehlerNummer :=  Wandverstellung.wpFehlerNr;
        steplAktion := STEP_900_E;
      END_IF

    // AUSTRANSPORT =====================================
    STEP_50_E:
      (* Hinweis:
         - Kippvorgang beendet
         - Vortransport beendet
           WICHTIG:
         - Wenn der Empfaenger eine Station ist kann der Vortransport abgebrochen werden
      *)
      IF ( Glastransport.bpDone
           OR BasisStationsParameter.InGlasTransportNachfolger[wWand].bBereitZumEintransport )
      THEN

        Glastransport.bpVortransport      := FALSE;
        Glastransport.bpVortransportRueck := FALSE;

        steplAktion := STEP_100_E;
      END_IF

    // AUSTRANSPORT =====================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES AUSTRANSPORTS
      //
      //  Hinweis:
      //  - Unterscheidung ob Rueckwertiger- Transport
      // ---------------------------------------------------------------------------------------
      (* Hinweis:
         - Ein vorzeitig quittierter Eintransport laeuft im Glastransport selbststaendig zu Ende und wird nicht abgebrochen
         - Der Austransport startet erst danach (Ueberwachung durch die Eintransport-Kette selbst)
      *)
      IF ( NOT Glastransport.bpEintransport
           AND NOT Glastransport.bpRueckwaertsEintransportieren )
      THEN
        Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[wWand];

        Glastransport.bpAustransport                 := NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
        Glastransport.bpRueckwaertsAustransportieren := BasisStationsParameter.bRueckwaertsTransportieren[wWand];

        steplAktion := STEP_110_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_110_E:
      (* Hinweis:
         - Scheibenzaehlen waerend der Glastransport arbeitet.
            Verarbeitung im ShuttleJobs Baustein
      *)
      bprtScheibe := Glastransport.bprtScheibe;

      (* Hinweis [Glastransport]:
         - Austransport der Scheiben abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpAustransport                  := FALSE;
        Glastransport.bpRueckwaertsAustransportieren  := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

    // AUSTRANSPORT GREIFER ======================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  AUSTRANSPORT MIT DEM GREIFER [AUSBAUSTUFE]
      //
      //  Hinweis:
      //  - Keine Vorab-Ansteuerung und kein anderer Ablauf des Greifers aktiv
      //  - Scheibe ueber den Sensor der Greiferseite positionieren und den Greifer hinter die Glaskante stellen
      // ---------------------------------------------------------------------------------------
      tonlUeberwachungGreifer( IN := TRUE, PT := cZEIT_UEBERWACHUNG_GREIFER );

      IF (     NOT bpVorAbAuftragAktiv
           AND NOT Greifer.bpAuftragAktiv )
      THEN
        tonlUeberwachungGreifer( IN := FALSE );

        Greifer.epGreiferTyp    := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eGreiferTyp;
        Greifer.pAuftrag        := BasisStationsParameter.pAuftrag[wWand];
        Greifer.rpGlaslaenge    := BasisStationsParameter.pAuftrag[wWand].rAuftragsLaenge;
        Greifer.bpPositionieren := TRUE;

        Glastransport.pAuftrag                          := BasisStationsParameter.pAuftrag[wWand];
        Glastransport.bpGlasPositionierungEinlaufseite  := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eGreiferTyp = eGreiferEinlaufseite );
        Glastransport.rpWegGlasUebergabeposition        := Greifer.rpWegGlasUebergabeposition;
        Glastransport.bpStarteGlasPositionierungGreifer := TRUE;

        steplAktion := STEP_210_E;
      END_IF

      IF ( tonlUeberwachungGreifer.Q ) THEN
        tonlUeberwachungGreifer( IN := FALSE );
        BasisStationsParameter.wFehlerNummer := cMELDUNG_GREIFER_STOESSEL_ABLAUF_ZEITUEBERSCHREITUNG;
        steplAktion := STEP_900_E;
      END_IF

    // AUSTRANSPORT GREIFER ======================
    STEP_210_E:
      (* Hinweis:
         - Weg ueber den Sensor laufend aus dem Greifer uebernehmen (Auftragsdaten im Greifer aktualisiert)
         - Scheibe und Greifer positioniert
      *)
      Glastransport.rpWegGlasUebergabeposition := Greifer.rpWegGlasUebergabeposition;

      tonlUeberwachungGreifer( IN := TRUE, PT := cZEIT_UEBERWACHUNG_GREIFER );

      IF (     Glastransport.bpGlasPositionierungGreiferAbgeschlossen
           AND Greifer.bpPositionierungAbgeschlossen )
      THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Glastransport.bpStarteGlasPositionierungGreifer := FALSE;
        Greifer.bpPositionieren := FALSE;
        steplAktion := STEP_220_E;
      END_IF

      IF ( tonlUeberwachungGreifer.Q ) THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Glastransport.bpStarteGlasPositionierungGreifer := FALSE;
        Greifer.bpPositionieren := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_GREIFER_STOESSEL_ABLAUF_ZEITUEBERSCHREITUNG;
        steplAktion := STEP_900_E;
      END_IF

    // AUSTRANSPORT GREIFER ======================
    STEP_220_E:
      (* Hinweis:
         - Austransport mit dem Greifer starten
      *)
      Greifer.bpStarteAustransport := TRUE;
      steplAktion := STEP_230_E;

    // AUSTRANSPORT GREIFER ======================
    STEP_230_E:
      (* Hinweis:
         - Quittierung der Scheibe
         - Austransport mit dem Greifer abgeschlossen
      *)
      bprtScheibe := Greifer.bprtScheibe;

      tonlUeberwachungGreifer( IN := TRUE, PT := cZEIT_UEBERWACHUNG_GREIFER );

      IF ( Greifer.bpAustransportAbgeschlossen ) THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Greifer.bpStarteAustransport := FALSE;
        steplAktion := STEP_240_E;
      END_IF

      IF ( tonlUeberwachungGreifer.Q ) THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Greifer.bpStarteAustransport := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_GREIFER_STOESSEL_ABLAUF_ZEITUEBERSCHREITUNG;
        steplAktion := STEP_900_E;
      END_IF

    // AUSTRANSPORT GREIFER ======================
    STEP_240_E:
      (* Hinweis:
         - Korrekturfahrt des Glastransports: Sensor der Greiferseite frei fahren
      *)
      bprtScheibe := FALSE;

      Glastransport.bpKorrekturfahrtRueckwaerts := ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eGreiferTyp = eGreiferAuslaufseite );
      Glastransport.bpStarteKorrekturfahrt      := TRUE;

      steplAktion := STEP_250_E;

    // AUSTRANSPORT GREIFER ======================
    STEP_250_E:
      tonlUeberwachungGreifer( IN := TRUE, PT := cZEIT_UEBERWACHUNG_GREIFER );

      IF ( Glastransport.bpKorrekturfahrtAbgeschlossen ) THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Glastransport.bpStarteKorrekturfahrt := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

      IF ( tonlUeberwachungGreifer.Q ) THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Glastransport.bpStarteKorrekturfahrt := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_GREIFER_STOESSEL_ABLAUF_ZEITUEBERSCHREITUNG;
        steplAktion := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_900_E:
      Glastransport.bpAustransport                 := FALSE;
      Glastransport.bpRueckwaertsAustransportieren := FALSE;

      Glastransport.bpVortransport      := FALSE;
      Glastransport.bpVortransportRueck := FALSE;

      BasisStationsParameter.bFehler := TRUE;

    // AUSTRANSPORT ==============================
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[wWand] := TRUE;

  // AUSTRANSPORT ==============================
  END_CASE
ELSE

  IF ( steplAktion > STEP_0_E ) THEN

    (* Hinweis:
       - Zuruecksetzen
    *)
    IF ( NOT BasisStationsParameter.bAustransportAbgeschlossen[wWand] ) THEN
      Kippen.bpPositionieren := FALSE;

      Wandverstellung.bpStartePositionierung := FALSE;

    END_IF

    bprtScheibe := FALSE;

    BasisStationsParameter.bAustransportAbgeschlossen[wWand] := FALSE;

    Glastransport.bpAustransport                 := FALSE;
    Glastransport.bpRueckwaertsAustransportieren := FALSE;

    Glastransport.bpVortransport          := FALSE;
    Glastransport.bpVortransportRueck     := FALSE;

    IF ( blMitGreifer ) THEN
      Greifer.bpPositionieren                         := FALSE;
      Greifer.bpStarteAustransport                    := FALSE;
      Glastransport.bpStarteGlasPositionierungGreifer := FALSE;
      Glastransport.bpStarteKorrekturfahrt            := FALSE;
      tonlUeberwachungGreifer( IN := FALSE );
      blMitGreifer := FALSE;
    END_IF

    steplAktion := STEP_0_E;

  END_IF

END_IF
END_FUNCTION_BLOCK