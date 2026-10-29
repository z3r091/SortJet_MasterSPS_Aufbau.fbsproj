(* METADATA
{
	"v3Meta": {
		"objectGuid": "dbee8b05-fdd6-4211-ad67-4f5fcb61e1f8"
	}
}
*)
ACTION Eintransport
(***************************************************************************************************)
(* AKTION EINTRANSPORT *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bEintransport[cWAND_1]
  AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Glastransport.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpStartKippenAuf := FALSE;
    Kippen.bpStartKippenAb  := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF
  
  IF ( Rollenleiste.bpFehler ) THEN
    Rollenleiste.bpStarteOeffnen    := FALSE;
    Rollenleiste.bpStarteSchliessen := FALSE;
    BasisStationsParameter.wFehlerNummer := Rollenleiste.wpFehlerNr;
    steplEintransport := STEP_900_E;
  END_IF


  CASE steplEintransport OF
(* EINTRANSPORT =========================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;
	  
      Kippen.bpStartKippenAb  := FALSE;
      Kippen.bpStartKippenAuf := FALSE;

      // Pruefen ob die Querfahrt die Zielposition erreicht hat
      IF ( blZielPositionErreicht ) THEN
        steplEintransport := STEP_10_E;   
      END_IF
   
(* EINTRANSPORT =========================*)
    STEP_10_E:
      (* Hinweis:
         - Rollenleiste
		 - Kippen
      *)
      IF ( BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke <= wgMKScheibenDicke13mm )THEN
        Rollenleiste.bpStarteOeffnen    := FALSE;
        Rollenleiste.bpStarteSchliessen := TRUE;
      ELSE
        Rollenleiste.bpStarteOeffnen    := TRUE;
        Rollenleiste.bpStarteSchliessen := FALSE;
      END_IF

      // Eintransport- Position festlegen
	  CASE BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition OF

        eKippen_Position_0Grad: 
          IF ( NOT ( Kippen.epKippStatus = eKippen_Position_0Grad )) THEN
            Kippen.bpStartKippenAb := TRUE;
            steplEintransport := STEP_20_E;
         
          ELSE
            steplEintransport := STEP_100_E;
         
          END_IF

        eKippen_Position_90Grad:
          IF ( NOT ( Kippen.epKippStatus = eKippen_Position_90Grad )) THEN
            Kippen.bpStartKippenAuf := TRUE;
            steplEintransport := STEP_30_E;
         
          ELSE
            steplEintransport := STEP_100_E;
         
          END_IF

      END_CASE

(* EINTRANSPORT =========================*)
    STEP_20_E:
      (* Hinweis:
         - Kippen abgeschlossen 0Grad
      *)
      IF ( ( Kippen.bpDone AND ( Kippen.epKippStatus = eKippen_Position_0Grad ) )
        OR NOT Kippen.bpStartKippenAb )
      THEN
        Kippen.bpStartKippenAb := FALSE;
        Kippen.bpStartKippenAb := FALSE;

        steplEintransport := STEP_100_E;
      END_IF

(* EINTRANSPORT =========================*)
    STEP_30_E:
      (* Hinweis:
         - Kippen abgeschlossen 90Grad
      *)
      IF ( ( Kippen.bpDone AND ( Kippen.epKippStatus = eKippen_Position_90Grad ) )
        OR NOT Kippen.bpStartKippenAuf  )
      THEN
        Kippen.bpStartKippenAb := FALSE;
        Kippen.bpStartKippenAb := FALSE;

        steplEintransport := STEP_100_E;
      END_IF

(* EINTRANSPORT =========================*)
    STEP_100_E:
      (* Hinweis:
         - Eintransport starten
      *)
      IF ( Rollenleiste.bpDone  )THEN
        Glastransport.eGlastyp        := BasisStationsParameter.wGlasTyp[cWAND_1];
        Glastransport.pAuftrag        := BasisStationsParameter.pAuftrag[cWAND_1];

        Glastransport.bpScheibentrennen := BasisStationsParameter.bScheibentrennen[cWAND_1];
        Glastransport.bpEintransport    := TRUE;

        Rollenleiste.bpStarteOeffnen    := FALSE;
        Rollenleiste.bpStarteSchliessen := FALSE;

		IF BasisStationsParameter.pAuftrag[cWAND_1].bLetzteScheibe THEN
          steplEintransport := STEP_300_E;			 
		ELSE
          steplEintransport := STEP_200_E;			
		END_IF
		
      END_IF

(* EINTRANSPORT =========================*)
    STEP_200_E:
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpEintransport := FALSE;
        steplEintransport := STEP_1000_E;
      END_IF

(* EINTRANSPORT =========================*)
    STEP_300_E:
      (* Hinweis:
         - Eintransport "Letzte Scheibe"
      *)
      IF (  Glastransport.bpFreigabeFremdprozess ) AND BasisStationsParameter.pAuftrag[cWAND_1].bLetzteScheibe THEN
		//  Position nach Eintransport
	    CASE BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachEintransport OF
        
          eKippen_Position_0Grad: 
            Kippen.bpStartKippenAb := TRUE;           
        
          eKippen_Position_90Grad:
            Kippen.bpStartKippenAuf := TRUE;
            Kippen.bpLangsamKippen  := FALSE;
            IF BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsDicke < 3 AND BasisStationsParameter.pAuftrag[cWAND_1].rAuftragsHoehe > 1200 THEN
             Kippen.bpLangsamKippen := TRUE;
			END_IF
        
        END_CASE   

        steplEintransport := STEP_310_E;
      END_IF

(* EINTRANSPORT =========================*)
    STEP_310_E:
      (* Hinweis:
         - Kipp- Bewegung abgeschlossen
      *)
      IF Kippen.bpDone THEN
        Kippen.bpStartKippenAuf := FALSE;
        Kippen.bpStartKippenAb  := FALSE;

        steplEintransport := STEP_320_E;
      END_IF

(* EINTRANSPORT =========================*)
    STEP_320_E:
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpEintransport := FALSE;
        steplEintransport := STEP_1000_E;
      END_IF


(* EINTRANSPORT =========================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*EINTRANSPORT =========================*)
     STEP_1000_E:
       BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := TRUE;

(*EINTRANSPORT =========================*)
  END_CASE
ELSE

  IF (steplEintransport > STEP_0_E) THEN

    Kippen.bpStartKippenAuf := FALSE;
    Kippen.bpStartKippenAb  := FALSE;
	Kippen.bpLangsamKippen  := FALSE;

    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpEintransport             := FALSE;
    Glastransport.bpEintransportRueckwaertig := FALSE;

    Rollenleiste.bpStarteOeffnen    := FALSE;
    Rollenleiste.bpStarteSchliessen := FALSE;

    BasisStationsParameter.bEintransportAbgeschlossen[cWAND_1] := FALSE;

    steplEintransport := STEP_0_E;
  END_IF

END_IF
END_ACTION