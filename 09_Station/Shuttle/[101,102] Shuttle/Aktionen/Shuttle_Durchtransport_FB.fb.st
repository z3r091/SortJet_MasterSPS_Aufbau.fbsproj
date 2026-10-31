(* METADATA
{
  "v3Meta": {
    "objectGuid": "fde90b53-97e1-44a2-93b0-a69a2d65f26b"
  }
}
*)
FUNCTION_BLOCK Shuttle_Durchtransport_FB EXTENDS Basic_Shuttle_Aktion_FB
VAR
END_VAR
(***************************************************************************************************)
(* DURCHTRANSPORT WAND 1 *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bDurchtransport[wWand]
  AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpDurchtransport := FALSE;
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
(*DURCHTRANSPORT ==============================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen         
      *)
      BasisStationsParameter.bEintransportAbgeschlossen[wWand] := FALSE;

      steplAktion := STEP_10_E;

(*DURCHTRANSPORT ==============================*)
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob die Geblase aktiv sind
         - Quellstation pruefen
      *)
      IF ( bpGeblaeseAktiv ) THEN

        IF ( NOT bpVorAbAuftragAktiv ) THEN

          (* Hinweis:
             - Anstellen der Dicken-/ Wandverstellung in Abhängigkeit der Glasdicke 
          *)
          Wandverstellung.epSollStellung         := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung;
          Wandverstellung.bpStartePositionierung := TRUE;


          Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition;
          Kippen.bpPositionieren := TRUE;
          
          steplAktion := STEP_20_E;
        END_IF

      END_IF

(*DURCHTRANSPORT ==============================*)
    STEP_20_E:
      (* Verfahrauftrag ans Shuttle uebergeben [Verfahrueberwachung]:
         - Pruefen ob das Shuttel zum verfahren freigegeben ist, wenn ja Zielposition
           aus dem Auftrag uebergeben.
      *)
      IF ( bpZielPositionErreicht ) THEN
        steplAktion := STEP_30_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(BasisStationsParameter.rAktuellePositionQuerfahrt);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[wWand].rVorabPosition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplAktion := STEP_900_E;
      END_IF

(*DURCHTRANSPORT ==============================*)
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
		
(*DURCHTRANSPORT ==============================*)
    STEP_40_E:
      (* ---------------------------------------------------------------------------------------
      //  KIPP- VORGANG ABSCHLIESSEN
      //         
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------*)

      IF ( Kippen.bpDone OR NOT Kippen.bpPositionieren )
        AND ( Kippen.epKippStatus = BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition)
      THEN
        Kippen.bpPositionieren  := FALSE;
        steplAktion := STEP_100_E;
      END_IF

(*DURCHTRANSPORT ==============================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  STARTEN DES DURCHTRANSPORTS 
      // ---------------------------------------------------------------------------------------*)

      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[wWand];
      Glastransport.bpDurchtransport := TRUE;

      steplAktion := STEP_110_E;

(*DURCHTRANSPORT ==============================*)
    STEP_110_E:
      (* Hinweis:
         - Quittierung der Scheibe
      *)
      bprtScheibe := Glastransport.bprtScheibe;

      (* Hinweis:
         - Eintransport der Scheiben abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpDurchtransport := FALSE;
        steplAktion := STEP_200_E;
      END_IF

(*DURCHTRANSPORT ==============================*)
    STEP_200_E:
	  (* Hinweis:
        - Kippen ansteuern
      *)
      bprtScheibe := Glastransport.bprtScheibe;

      Kippen.epZielPosition := BasisStationsParameter.pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachAustransport;
	    Kippen.bpPositionieren := TRUE;
	  
      steplAktion := STEP_210_E;
		
(*DURCHTRANSPORT ==============================*)
    STEP_210_E:
      (* Hinweis:
         - Quittierung der Scheibe
      *)
      bprtScheibe := Glastransport.bprtScheibe;
	  
	  (* Hinweis:
        - Kippen abschließen
      *)
	  IF Kippen.bpDone THEN
	    Kippen.bpPositionieren := FALSE;
        steplAktion := STEP_1000_E;
	  END_IF

(*DURCHTRANSPORT ==============================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*DURCHTRANSPORT ==============================*)
    STEP_1000_E:
      bprtScheibe := FALSE;
      BasisStationsParameter.bDurchtransportAbgeschlossen[wWand] := TRUE;

(*DURCHTRANSPORT ==============================*)
  END_CASE
ELSE

  IF (steplAktion > STEP_0_E) THEN

    BasisStationsParameter.bDurchtransportAbgeschlossen[wWand] := FALSE;
    bprtScheibe := FALSE;

    Glastransport.bpDurchtransport := FALSE;
	
	  Kippen.bpPositionieren := FALSE;
    Wandverstellung.bpStartePositionierung := FALSE;

    steplAktion := STEP_0_E;
  END_IF

END_IF
END_FUNCTION_BLOCK