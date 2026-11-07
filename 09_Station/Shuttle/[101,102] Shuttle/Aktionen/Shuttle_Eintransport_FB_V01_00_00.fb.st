(* METADATA
{
	"v3Meta": {
		"objectGuid": "658aa591-8bd2-427d-a42c-c4e6e57fe5c7"
	}
}
*)
FUNCTION_BLOCK Shuttle_Eintransport_FB_V01_00_00 EXTENDS Basic_Shuttle_Aktion_FB_V01_00_00
VAR_INPUT

  // GREIFER [Ausbaustufe stStationsAufbau.bGreifer]
  bpGreiferAktiv : BOOL;
  Greifer        : REFERENCE TO Shuttle_Greifer_FB_V01_00_00;

END_VAR
VAR

  // BOOL
  blMitGreifer : BOOL; // Eintransport mit dem Greifer (Greifer vorhanden und Greiferseite im Auftrag)

  // TIMER
  tonlUeberwachungGreifer : TON;

END_VAR
VAR CONSTANT

  // TIME
  cZEIT_UEBERWACHUNG_GREIFER : TIME := T#120S; // Gesamtueberwachung je Greifer-Schritt (die Wartestellen ueberwacht der Greifer selbst)

END_VAR
//-------------------------------------------------------------------------------------------------
// EINTRANSPORT WAND 1
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bEintransport[wWand]
     AND bpAutomatikAktiv ) 
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpEintransport := FALSE;
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
    Greifer.bpStarteVorabPositionierungEintransport := FALSE;
    Greifer.bpStarteEintransport                    := FALSE;
    Glastransport.bpStarteKorrekturfahrt            := FALSE;
    BasisStationsParameter.awFehlerInformationen    := Greifer.awpFehlerInformationen;
    BasisStationsParameter.wFehlerNummer            := Greifer.wpFehlerNr;
    steplAktion := STEP_900_E;
  END_IF

  CASE steplAktion OF
    // EINTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      BasisStationsParameter.bEintransportAbgeschlossen[wWand] := FALSE;

      blMitGreifer :=     bpGreiferAktiv
                      AND ( BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eGreiferTyp <> eGreiferDefault );

      steplAktion := STEP_10_E;

    // EINTRANSPORT ==============================
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Geblase aktiv sind
         - Wandverstellung starten
         - Kippen starten
      *)
      IF ( bpGeblaeseAktiv ) THEN

        IF ( NOT bpVorAbAuftragAktiv ) THEN

          Wandverstellung.epSollStellung         := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
          Wandverstellung.bpStartePositionierung := TRUE;

          Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition;
          Kippen.bpPositionieren := TRUE;

          steplAktion := STEP_20_E;
        END_IF

      END_IF

    // EINTRANSPORT ==============================
    STEP_20_E:
      // Verfahrauftrag ans Shuttle uebergeben [Verfahrueberwachung]:
      //   - Pruefen ob das Shuttel zum verfahren freigegeben ist, wenn ja Zielposition
      //     aus dem Auftrag uebergeben.
      IF ( bpZielPositionErreicht ) THEN
        steplAktion := STEP_30_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.rAktuellePositionQuerfahrt);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[wWand].rVorabPosition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplAktion := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_30_E:
      (* Hinweis:
         - Sicherstellen das die Wand auch wirklich ihre Soll-Position erreicht hat
      *)
      Wandverstellung.epSollStellung         := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
      Wandverstellung.bpStartePositionierung := TRUE;

      (* Hinweis:
         - Dickenverstellung-Abschluss
      *)
      IF Wandverstellung.bpDone THEN
        Wandverstellung.bpStartePositionierung := FALSE;
        steplAktion := STEP_40_E;   
      END_IF

    // EINTRANSPORT ==============================
    STEP_40_E:
      (* Hinweis:
         - Kippen abgeschlossen -> pruefen ob Position erreicht
      *)
      IF ( Kippen.bpDone OR NOT Kippen.bpPositionieren )
         AND ( Kippen.epKippStatus = BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition)
      THEN
        Kippen.bpPositionieren  := FALSE;

        IF ( blMitGreifer ) THEN
          steplAktion := STEP_200_E;
        ELSE
          steplAktion := STEP_100_E;
        END_IF
      END_IF

    // EINTRANSPORT ==============================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES EINTRANSPORTS
      //
      //  Hinweis:
      //  - Unterscheidung ob Rueckwertiger- Transport
      // ---------------------------------------------------------------------------------------

      Glastransport.bpRueckwaertsEintransportieren   := BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      Glastransport.bpEintransport                   := NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];


      Glastransport.bpTransferstationTransfershuttle := BasisStationsParameter.bTransferstationTransfershuttle[wWand];
      Glastransport.bpScheibentrennung               := BasisStationsParameter.bScheibentrennen[wWand];
      Glastransport.pAuftrag                         := BasisStationsParameter.pAuftrag[wWand];

      steplAktion := STEP_110_E;

    // EINTRANSPORT ==============================
    STEP_110_E:
      (* Hinweis:
         - Quittierung der Scheibe
      *)
      bprtScheibe := Glastransport.bprtScheibe;

      (* Hinweis:
         - Eintransport der Scheiben abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpEintransport := FALSE;
        Glastransport.bpRueckwaertsEintransportieren := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

      (* Hinweis:
         - Eintransport vorzeitig quittieren damit die Querfahrt starten kann
      *)
      IF (  BasisStationsParameter.pAuftrag[wWand].bLetzteScheibe
           AND Glastransport.bpFreigabeQuerfahrt )
      THEN
        steplAktion := STEP_1000_E;
      END_IF

    // EINTRANSPORT GREIFER ======================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  EINTRANSPORT MIT DEM GREIFER [AUSBAUSTUFE]
      //
      //  Hinweis:
      //  - Greifer an die Wandseite stellen, sofern er nicht schon vorpositioniert ist
      // ---------------------------------------------------------------------------------------
      Greifer.epGreiferTyp := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eGreiferTyp;
      Greifer.pAuftrag     := BasisStationsParameter.pAuftrag[wWand];

      Greifer.bpStarteVorabPositionierungEintransport := NOT Greifer.bpVorpositioniertEintransport;

      steplAktion := STEP_210_E;

    // EINTRANSPORT GREIFER ======================
    STEP_210_E:
      (* Hinweis:
         - Greifer vorpositioniert, Eintransport mit dem Greifer starten
      *)
      tonlUeberwachungGreifer( IN := TRUE, PT := cZEIT_UEBERWACHUNG_GREIFER );

      IF (    Greifer.bpVorabPositionierungEintransportAbgeschlossen
           OR Greifer.bpVorpositioniertEintransport )
      THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Greifer.bpStarteVorabPositionierungEintransport := FALSE;
        Greifer.bpStarteEintransport := TRUE;
        steplAktion := STEP_220_E;
      END_IF

      IF ( tonlUeberwachungGreifer.Q ) THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Greifer.bpStarteVorabPositionierungEintransport := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_GREIFER_STOESSEL_ABLAUF_ZEITUEBERSCHREITUNG;
        steplAktion := STEP_900_E;
      END_IF

    // EINTRANSPORT GREIFER ======================
    STEP_220_E:
      (* Hinweis:
         - Quittierung der Scheibe
         - Uebergrosse Scheibe: Korrekturfahrt des Glastransports auf Anforderung des Greifers
      *)
      bprtScheibe := Greifer.bprtScheibe;

      tonlUeberwachungGreifer( IN := TRUE, PT := cZEIT_UEBERWACHUNG_GREIFER );

      IF ( Greifer.bpKorrekturfahrtAnfordern ) THEN
        Glastransport.bpKorrekturfahrtRueckwaerts := Greifer.bpKorrekturfahrtRueckwaerts;
        Glastransport.bpStarteKorrekturfahrt      := TRUE;
      ELSE
        Glastransport.bpStarteKorrekturfahrt      := FALSE;
      END_IF

      IF ( Greifer.bpEintransportAbgeschlossen ) THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Greifer.bpStarteEintransport         := FALSE;
        Glastransport.bpStarteKorrekturfahrt := FALSE;
        steplAktion := STEP_1000_E;
      END_IF

      IF ( tonlUeberwachungGreifer.Q ) THEN
        tonlUeberwachungGreifer( IN := FALSE );
        Greifer.bpStarteEintransport         := FALSE;
        Glastransport.bpStarteKorrekturfahrt := FALSE;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_GREIFER_STOESSEL_ABLAUF_ZEITUEBERSCHREITUNG;
        steplAktion := STEP_900_E;
      END_IF

    // EINTRANSPORT ==============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // EINTRANSPORT ==============================
    STEP_1000_E:
      bprtScheibe := FALSE;
      BasisStationsParameter.bEintransportAbgeschlossen[wWand] := TRUE;

  // EINTRANSPORT ==============================
  END_CASE
ELSE

  IF (steplAktion > STEP_0_E) THEN

    BasisStationsParameter.bEintransportAbgeschlossen[wWand] := FALSE;
    bprtScheibe := FALSE;

    Kippen.bpPositionieren := FALSE;
    Wandverstellung.bpStartePositionierung := FALSE;

    IF ( blMitGreifer ) THEN
      Greifer.bpStarteVorabPositionierungEintransport := FALSE;
      Greifer.bpStarteEintransport                    := FALSE;
      Glastransport.bpStarteKorrekturfahrt            := FALSE;
      tonlUeberwachungGreifer( IN := FALSE );
      blMitGreifer := FALSE;
    END_IF

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK