(* METADATA
{
	"v3Meta": {
		"objectGuid": "e5f7802b-eee7-40e3-8c63-753d03990f1b"
	}
}
*)
ACTION Systemcheck
(***************************************************************************************************)
(* AKTION SYTEMCHECK *)
(***************************************************************************************************)
IF( blBetriebartCheck )THEN
	
  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpReferenz := FALSE;
    Glastransport.bpCheck    := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF

 IF ( Kippen.bpFehler ) THEN
   Kippen.bpStartKippenAuf := FALSE;
   Kippen.bpStartKippenAb  := FALSE;
   Kippen.bpLangsamKippen  := FALSE;
   BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
   steplCheck := STEP_900_E;
 END_IF
 

  CASE ( steplCheck ) OF
(*SYSTEM CHECK =========================*)
    STEP_0_E:
      (* Hinweis:
         - Riemen aufkoppeln [Master- Slave Betrieb]
      *)
      BasisStationsParameter.bCheckAbgeschlossen := FALSE;
      BasisStationsParameter.bStationBelegt[cWAND_1]  := FALSE;

      (* Hinweis:
         - Sollte es sich z.B. um eine Station handeln die in einen anderen SK transportiert 
           kann die <<Freigabe>> [Hardware-] entzogen sein wenn dieser geoeffnet ist.
      *)
      IF ( BasisStationsParameter.bFreigabe ) THEN
        steplCheck := STEP_10_E;
      END_IF
	  
(*SYSTEM CHECK =========================*)
    STEP_10_E:
      (* Hinweis:
         - Referenzieren der Antriebe ( Position auf 0 (NULL) setzen )
         - Setzen der Master-Slave- Kopplung Riemen / Rollen
      *)
      Glastransport.bpReferenz := TRUE;

      IF (  Glastransport.bpDone ) THEN
        Glastransport.bpReferenz := FALSE;

        steplCheck := STEP_20_E;
      END_IF

(*SYSTEM CHECK =========================*)
    STEP_20_E:
      (* Hinweis:
         - Starten des SystemCheck
         - Pruefen des Kipp-Status
      *)
      CASE Kippen.epKippStatus OF

        eKippen_Position_0Grad:
          Glastransport.bpCheckMitVorgaenger := FALSE;
          Glastransport.bpCheckMitNachfolger := FALSE;
          
          BasisStationsParameter.bStationBelegt[cWAND_1] :=    Glastransport.bpSensorEinlauf
                                                            OR Glastransport.bpSensorAuslauf 
                                                            OR Glastransport.bpSensorEinlaufVorAb 
                                                            OR Glastransport.bpSensorAuslaufVorAb;
                                                            
          rSps2MmiMessungScheibenlaenge   := -1;
          wSps2MmiMessungStationNummer    := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
          wSps2MmiMessungSlotNummer       := 1;
          iSps2MmiMessungScheibenanzahl   := BOOL_TO_INT(BasisStationsParameter.bStationBelegt[cWAND_1]);
         
          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );         
         
	        steplCheck := STEP_800_E;
         

        eKippen_Position_90Grad:
          Glastransport.bpCheckMitVorgaenger := FALSE;
          Glastransport.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];

          Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
          Glastransport.bpCheck  := TRUE;

          steplCheck := STEP_30_E;


        eKippen_Fehler:
          Glastransport.bpCheckMitVorgaenger := FALSE;
          Glastransport.bpCheckMitNachfolger := FALSE;
          
          BasisStationsParameter.bStationBelegt[cWAND_1] := FALSE;
          
          // Hoch kippen und Systemcheck starten
          Kippen.bpStartKippenAuf := TRUE;
          Kippen.bpLangsamKippen  := TRUE;
          steplCheck := STEP_25_E;

      END_CASE
      
(*SYSTEM CHECK =========================*)
    STEP_25_E:
      IF ( Kippen.bpDone ) THEN
        Kippen.bpStartKippenAuf := FALSE;
        Kippen.bpStartKippenAb  := FALSE;
        Kippen.bpLangsamKippen  := FALSE;

        Glastransport.bpCheckMitVorgaenger := FALSE;
        Glastransport.bpCheckMitNachfolger := FALSE;
        
        Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
        Glastransport.bpCheck  := TRUE;
          
        steplCheck := STEP_30_E;
      END_IF
      
(*SYSTEM CHECK =========================*)
    STEP_30_E:
      (* Hinweis:
         - Warten bis Check fertig
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1] := Glastransport.bpStationBelegt;

      IF ( Glastransport.bprtScheibe ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben + 1;
      END_IF

      IF ( ftlGlastransportCheckMitNachfolger.Q ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben - 1;
      END_IF

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpCheck := FALSE;
        IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
          steplCheck := STEP_40_E;
        ELSE
          steplCheck := STEP_50_E;          
        END_IF
      END_IF

(*SYSTEM CHECK =========================*)
    STEP_40_E:
      (* Hinweis:
         - Pruefen ob die Station belegt ist
      *)
      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        Kippen.bpStartKippenAuf := TRUE;
        Kippen.bpLangsamKippen  := TRUE;
        
        steplCheck := STEP_100_E;
      ELSE
        steplCheck := STEP_800_E;
      END_IF
      
      
(*SYSTEM CHECK =========================*)
    STEP_50_E:
      (* Hinweis:
         - Pruefen ob die Station belegt ist
      *)
      Kippen.bpStartKippenAb := TRUE;
      Kippen.bpLangsamKippen := TRUE;
        
      steplCheck := STEP_100_E;

(*SYSTEM CHECK =========================*)
    STEP_100_E:
      IF ( Kippen.bpDone ) THEN
        Kippen.bpStartKippenAuf := FALSE;
        Kippen.bpStartKippenAb  := FALSE;
        Kippen.bpLangsamKippen  := FALSE;

        steplCheck := STEP_800_E;
      END_IF


(*SYSTEM CHECK =========================*)
   STEP_800_E:
      (* ---------------------------------------------------------------------------------------
      //  AUSWERTEN DES BELADUNGSSTATUS MIT DEN MMI DATEN
      //         
      //  Hinweis:
      // - Nachricht an den Bediener senden wenn die Daten nicht passen
      // ---------------------------------------------------------------------------------------*)

      steplCheck := STEP_1000_E;
	  
      IF ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben = 0 ) AND BasisStationsParameter.bStationBelegt[cWAND_1] THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );
      END_IF

      IF ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben <> 0 ) AND NOT BasisStationsParameter.bStationBelegt[cWAND_1] THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_KEINE_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );
      END_IF
   
(*SYSTEM CHECK =========================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*SYSTEM CHECK =========================*)
    STEP_1000_E:
	  // Auftrag für erneuten Automatikbetrieb setzen
      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Belegt;
      ELSE
	    BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Kein_Auftrag;
      END_IF
	  
      BasisStationsParameter.bCheckAbgeschlossen := TRUE;

(*SYSTEM CHECK =========================*)
  END_CASE

ELSE

 IF (steplCheck > STEP_0_E ) THEN

    Kippen.bpStartKippenAb  := FALSE;
    Kippen.bpStartKippenAuf := FALSE;
    Kippen.bpLangsamKippen  := FALSE;

    BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]   := FALSE;
    BasisStationsParameter.bCheckMitNachfolger[cWAND_1]   := FALSE;

    Glastransport.bpReferenz := FALSE;
    Glastransport.bpCheck    := FALSE;


    BasisStationsParameter.bCheckAbgeschlossen := FALSE;

    steplCheck := STEP_0_E;
  END_IF

END_IF
END_ACTION