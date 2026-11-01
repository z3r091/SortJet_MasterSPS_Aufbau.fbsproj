(* METADATA
{
  "v3Meta": {
    "objectGuid": "95cfa97d-3505-45e8-8403-9078fc951b25"
  }
}
*)
ACTION Austransport
(***************************************************************************************************)
(* AKTION AUSTRANSPORT *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bAustransport[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpAustransport             := FALSE;
    Glastransport.bpAustransportRueckwaertig := FALSE;
    Glastransport.bpVortransport             := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Glastransport.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF
  
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpStartKippenAuf := FALSE;
    Kippen.bpStartKippenAb  := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF
    
  IF ( Rollenleiste.bpFehler ) THEN
    Rollenleiste.bpStarteOeffnen    := FALSE;
    Rollenleiste.bpStarteSchliessen := FALSE;
    BasisStationsParameter.wFehlerNummer := Rollenleiste.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF


  CASE steplAustransport OF
    (*AUSTRANSPORT =========================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;

      Kippen.bpStartKippenAb  := FALSE;
      Kippen.bpStartKippenAuf := FALSE;

      // Pruefen ob die Querfahrt die Zielposition erreicht hat
      IF ( blZielPositionErreicht ) THEN
        steplAustransport := STEP_10_E;   
      END_IF
    (*AUSTRANSPORT =========================*)
    STEP_10_E:
      (* ---------------------------------------------------------------------------------------
      //  KIPP- POSITION BESTIMMEN
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)
      
      Glastransport.pAuftrag       := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpVortransport := BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bVortransport;

      // Austransport- Position festlegen
      CASE BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition OF

        eKippen_Position_0Grad: 
          IF ( NOT ( Kippen.epKippStatus = eKippen_Position_0Grad )) THEN
            Kippen.bpStartKippenAb := TRUE;
            steplAustransport := STEP_20_E;
         
          ELSE
            steplAustransport := STEP_40_E;
         
          END_IF

        eKippen_Position_90Grad:
          IF ( NOT ( Kippen.epKippStatus = eKippen_Position_90Grad )) THEN
            Kippen.bpStartKippenAuf := TRUE;
            steplAustransport := STEP_30_E;
         
          ELSE
            steplAustransport := STEP_40_E;
         
          END_IF

      END_CASE

    (*AUSTRANSPORT =========================*)
    STEP_20_E:
      (* Hinweis:
         - "Auf" -kippen abgeschlossen
      *)
      IF ( Kippen.bpDone AND ( Kippen.epKippStatus = eKippen_Position_0Grad ) ) THEN
        Kippen.bpStartKippenAuf := FALSE;
        Kippen.bpStartKippenAb  := FALSE;

        steplAustransport := STEP_40_E;
      END_IF

    (*AUSTRANSPORT =========================*)
    STEP_30_E:
      (* Hinweis:
         - "Ab" -kippen abgeschlossen
      *)
      IF ( Kippen.bpDone AND ( Kippen.epKippStatus = eKippen_Position_90Grad ) ) THEN
        Kippen.bpStartKippenAuf := FALSE;
        Kippen.bpStartKippenAb  := FALSE;

        steplAustransport := STEP_40_E;
      END_IF

    (*AUSTRANSPORT =========================*)
    STEP_40_E:
      (* Anmerkung:
         - Vortransport ggf. vorzeitigabbrechen wenn er Glas-Empfaenger schon bereit zum  
      *)
      Glastransport.bpAbbruchVortransport := BasisStationsParameter.InGlasTransportNachfolger[cWAND_1].bBereitZumEintransport;
      
      IF ( Glastransport.bpDone OR NOT BasisStationsParameter.stMKs.stStationsOptionen.stGlastransport.bVortransport ) THEN
        Glastransport.bpAbbruchVortransport := FALSE;
        Glastransport.bpVortransport        := FALSE;
        steplAustransport := STEP_100_E;
      END_IF

    (*AUSTRANSPORT =========================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  STARTEN DES AUSTRANSPORTS
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      Glastransport.pAuftrag        := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpAustransport  := TRUE;

      steplAustransport := STEP_110_E;

    (*AUSTRANSPORT =========================*)
    STEP_110_E:
      IF (  Glastransport.bpFreigabeFremdprozess
           AND BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsInformationen.cBIT_SRCSTATION_EMPTY )
      THEN
        //  Position nach Austransport
        CASE BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachAustransport OF
        
          eKippen_Position_0Grad: 
            Kippen.bpStartKippenAb := TRUE;           
        
          eKippen_Position_90Grad:
            Kippen.bpStartKippenAuf := TRUE;           
        
        END_CASE
      END_IF

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpAustransport := FALSE;
        steplAustransport := STEP_120_E;
      END_IF

    (*AUSTRANSPORT =========================*)
    STEP_120_E:
      (* Hinweis:
         - Station in die Grundstellung kippen
      *)
      IF ( BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsInformationen.cBIT_SRCSTATION_EMPTY ) THEN
        //  Position nach Austransport
        CASE BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition_NachAustransport OF
        
          eKippen_Position_0Grad: 
            Kippen.bpStartKippenAb := TRUE;           
        
          eKippen_Position_90Grad:
            Kippen.bpStartKippenAuf := TRUE;           
        
        END_CASE

        Glastransport.bpReferenz := TRUE;

        steplAustransport := STEP_130_E;

      ELSE
        steplAustransport := STEP_200_E;

      END_IF

    (*AUSTRANSPORT =========================*)
    STEP_130_E:
      IF ( Kippen.bpStartKippenAuf ) THEN

        IF ( Kippen.bpDone AND ( Kippen.epKippStatus = eKippen_Position_90Grad ))
           AND Glastransport.bpDone
        THEN
          Kippen.bpStartKippenAuf  := FALSE;
          Kippen.bpStartKippenAb   := FALSE;

          Glastransport.bpReferenz := FALSE;

          steplAustransport := STEP_1000_E; 
        END_IF

      ELSIF (Kippen.bpStartKippenAb ) THEN

        IF ( Kippen.bpDone AND ( Kippen.epKippStatus = eKippen_Position_0Grad ) )
           AND Glastransport.bpDone
        THEN
          Kippen.bpStartKippenAuf  := FALSE;
          Kippen.bpStartKippenAb   := FALSE;


          Glastransport.bpReferenz := FALSE;

          steplAustransport := STEP_1000_E; 
        END_IF

      ELSIF Glastransport.bpDone THEN

        Kippen.bpStartKippenAuf  := FALSE;
        Kippen.bpStartKippenAb   := FALSE;
        
        Glastransport.bpReferenz := FALSE;

        steplAustransport := STEP_1000_E; 

      END_IF

    (*AUSTRANSPORT =========================*)
    STEP_200_E:
      (* Hinweis:
         - Die Position der Antriebe NULLEN um Zaehlerueberlauf (des Gebers) zu verhindern 
      *)
      Glastransport.bpReferenz := TRUE;

      steplAustransport := STEP_210_E;

    (*AUSTRANSPORT =========================*)
    STEP_210_E:
      IF (  Glastransport.bpDone ) THEN
        Glastransport.bpReferenz := FALSE;
        steplAustransport := STEP_1000_E;
      END_IF

    (*AUSTRANSPORT =========================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    (*AUSTRANSPORT =========================*)
    STEP_1000_E:
      BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := TRUE;

  (*AUSTRANSPORT =========================*)
  END_CASE
ELSE

  IF ( steplAustransport > STEP_0_E ) THEN
    Kippen.bpStartKippenAuf := FALSE;
    Kippen.bpStartKippenAb  := FALSE;

    Glastransport.bpAbbruchVortransport := FALSE;
    Glastransport.bpAustransport        := FALSE;
    Glastransport.bpVortransport        := FALSE;
    Glastransport.bpReferenz            := FALSE;

    BasisStationsParameter.bAustransportAbgeschlossen[cWAND_1] := FALSE;

    steplAustransport := STEP_0_E;
  END_IF

END_IF
END_ACTION