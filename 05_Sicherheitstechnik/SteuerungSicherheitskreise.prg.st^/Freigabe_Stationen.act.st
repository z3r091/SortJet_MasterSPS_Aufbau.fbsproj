(* METADATA
{
	"v3Meta": {
		"objectGuid": "6a266cdc-7ac6-4c35-838d-01904d46f31d"
	}
}
*)
ACTION Freigabe_Stationen
(***************************************************************************************************)
(* BAUSTEIN: FREIGABEN SHUTTLE [SICHERHEITSKREIS] *)
(***************************************************************************************************)
// Freigaben Shuttle 
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  ablSicherheitskreisFreigabeShuttle[wlIndex] := NOT starrShuttleBasisParameter[wlIndex].bAuftragAktiv
                                                  OR starrShuttleBasisParameter[wlIndex].bFehler;
END_FOR

(***************************************************************************************************)
(* BAUSTEIN: FREIGABEN STATIONEN [SICHERHEITSKREIS] *)
(***************************************************************************************************)
// Freigabe für den Sicherheitskreis setzen
FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  ablSicherheitskreisFreigabeStation[wlIndex] := ( NOT starrStationBasisParameter[wlIndex].bAuftragAktiv                                                 // Es d arf kein Auftrag aktiv sein
                                                    OR starrStationBasisParameter[wlIndex].bSKFreigabeBeiAktivemAuftrag )                                // Ausnahme wenn Anlegen oder Abnehemen aktiv ist
																   AND NOT ( ( Job_Stationen.AuftragsdatenWand[wlIndex, cWAND_1].wAuftrag = eStation_Belegt )      // Station ist belegt und muss erst leergefahren werden
                                                   AND starrStationBasisParameter[wlIndex].stMKs.stStationsOptionen.bStationLeerfahrenBeiSkAnforderung )	        
                                                   OR starrStationBasisParameter[wlIndex].bFehler;

END_FOR

(***************************************************************************************************)
(* BAUSTEIN: SICHERHEITSKREIS FREIGABE SETZEN *)
(***************************************************************************************************)
(*
  Start
  │
  ▼
Sicherheitskreis[SK2].bpFreigabeStationen := TRUE
  │
  ▼
Gehört Station zu SK2?
 ┌───────────────┐
 │    NEIN       │
 │   (überspringen) 
 └───────┬───────┘
         │ JA
         ▼
 Gehört Durchgang zur Station?
 ┌───────────────┐
 │     NEIN      │
 │ (nur Station-Check)
 └───────┬───────┘
         │ JA
         ▼
   Prüfen:
   - ablSicherheitskreisFreigabeStation[wlIndex] ?
   - bSKOeffnenBlockierenDurchgang ?
         │
   ┌─────┴───────────────┐
   │ irgendeine Bedingung │
   │    = FALSE ?         │
   └─────┬───────────────┘
         │ JA
         ▼
Sicherheitskreis[SK2].bpFreigabeStationen := FALSE
         │
         └────────► Ende
         │ NEIN
         ▼
(alles ok → bleibt TRUE)

*)
// Freigabe für den Sicherheitskreis anhand der Stationskonfig setzen
FOR wlIndexSK := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO
  Sicherheitskreis[wlIndexSK].bpFreigabeStationen := TRUE;
  
  // Check Station
  FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
	IF checkSafetyCircuits(starrStationBasisParameter[wlIndex], wlIndexSK ) THEN // Prüfen ob die Station zu dem Sicherheitskreis gehört
		
	  FOR wlIndexDurchgang := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
	    // Durchgang in dem Sicherheitskreis
	    IF ( apgMKDurchgang[wlIndexDurchgang].eZuBlockierenderSK = wlIndexSK ) THEN
			// Es wird auf Freigabe STation und Öffnen Blockieren geschaut
         IF NOT ablSicherheitskreisFreigabeStation[wlIndex] 
			   OR starrStationBasisParameter[wlIndex].bSKOeffnenBlockierenDurchgang // z.B. Sensor belegt bei einer Station mit Durchgang
        THEN
           Sicherheitskreis[wlIndexSK].bpFreigabeStationen := FALSE;
	      END_IF
		
		 // Durchgang nicht in dem Sicherheitskreis
		 ELSE	
	      // Es wird nur auf Freigabe Station geschaut
         IF NOT ablSicherheitskreisFreigabeStation[wlIndex] THEN
           Sicherheitskreis[wlIndexSK].bpFreigabeStationen := FALSE;
	      END_IF
		
	    END_IF
		 
	  END_FOR				

	END_IF
	
  END_FOR

  // Check Shuttle
  FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
	IF checkSafetyCircuits(starrShuttleBasisParameter[wlIndex], wlIndexSK ) THEN // Prüfen ob die Station zu dem Sicherheitskreis gehört
	  IF NOT ablSicherheitskreisFreigabeShuttle[wlIndex] THEN
        Sicherheitskreis[wlIndexSK].bpFreigabeStationen := FALSE;
	  END_IF
	END_IF
  END_FOR
  
END_FOR
END_ACTION