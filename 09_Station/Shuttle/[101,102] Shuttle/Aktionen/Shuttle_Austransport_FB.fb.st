(* METADATA
{
  "v3Meta": {
    "objectGuid": "aea75a09-065c-4155-9284-9233b13eb99a"
  }
}
*)
FUNCTION_BLOCK Shuttle_Austransport_FB EXTENDS Basic_Shuttle_Aktion_FB
VAR
END_VAR
(***************************************************************************************************)
(* AKTION AUSTRANSPORT WAND 1 *)
(***************************************************************************************************)
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

  CASE steplAktion OF
(* AUSTRANSPORT =====================================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen          
      *)
      BasisStationsParameter.bAustransportAbgeschlossen[wWand]    := FALSE;

      Glastransport.bpEintransport := FALSE;

      steplAktion := STEP_10_E;

(* AUSTRANSPORT =====================================*)
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

(* AUSTRANSPORT =====================================*)
    STEP_20_E:
      (* ---------------------------------------------------------------------------------------
      //  ANSTEUERUNG KOMPONENTEN 
      //         
      //  Hinweis:
      //  - Sicherstellen dass das Geblaese aktiv  und keine Vorab- Auftrag aktiv sind 
      // ---------------------------------------------------------------------------------------*)

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

(* AUSTRANSPORT =====================================*)
    STEP_30_E:
      (* Hinweis:
         - Wandverstellung gefahren ? 
      *)
      IF ( (  Wandverstellung.bpDone OR  NOT Wandverstellung.bpStartePositionierung )
        AND (  Kippen.bpDone OR NOT Kippen.bpPositionieren ) )
      THEN
        Kippen.bpPositionieren := FALSE;

        Wandverstellung.bpStartePositionierung := FALSE;

        steplAktion := STEP_100_E; (* STEP_40_E; *)
      END_IF

      (* Ausnahmesituation
         - Komponenten
      *)
      IF ( Wandverstellung.bpFehler ) THEN
        Wandverstellung.bpStartePositionierung := FALSE;
        BasisStationsParameter.wFehlerNummer :=  Wandverstellung.wpFehlerNr;
        steplAktion := STEP_900_E;
     END_IF

(* AUSTRANSPORT =====================================*)
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

(* AUSTRANSPORT =====================================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  STARTEN DES AUSTRANSPORTS 
      //         
      //  Hinweis:
      //  - Unterscheidung ob Rueckwertiger- Transport 
      // ---------------------------------------------------------------------------------------*)
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[wWand];

      Glastransport.bpAustransport                 := NOT BasisStationsParameter.bRueckwaertsTransportieren[wWand];
      Glastransport.bpRueckwaertsAustransportieren := BasisStationsParameter.bRueckwaertsTransportieren[wWand];

      steplAktion := STEP_110_E;

(*AUSTRANSPORT ==============================*)
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

(*AUSTRANSPORT ==============================*)
    STEP_900_E:
      Glastransport.bpAustransport                 := FALSE;
      Glastransport.bpRueckwaertsAustransportieren := FALSE;

      Glastransport.bpVortransport      := FALSE;
      Glastransport.bpVortransportRueck := FALSE;

      BasisStationsParameter.bFehler := TRUE;

(*AUSTRANSPORT ==============================*)
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[wWand] := TRUE;

(*AUSTRANSPORT ==============================*)
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

    steplAktion := STEP_0_E;

  END_IF

END_IF
END_FUNCTION_BLOCK