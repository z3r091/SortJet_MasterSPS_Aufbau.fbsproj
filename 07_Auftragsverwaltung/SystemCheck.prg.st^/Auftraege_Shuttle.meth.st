(* METADATA
{
	"v3Meta": {
		"objectGuid": "9ff2d478-3fef-409c-b42e-3dce6a33e4ba"
	}
}
*)
METHOD PRIVATE Auftraege_Shuttle : BOOL
VAR_INPUT
  wpAutomatikkreis : WORD;
END_VAR

(***************************************************************************************************)
(* SYSTEMCHECK - AUTOMATIKKREIS 1 *)
(***************************************************************************************************)

Auftraege_Shuttle := FALSE;

FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
   IF wpAutomatikkreis = starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis[1] THEN
     IF starrShuttleBasisParameter[wlIndex].stMKs.eStationsTyp = eInputshuttle THEN//101,102
       CASE starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].wTransferstationsNr1 OF    
   
         cERSTE_STATION..cLETZTE_STATION:
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eGlastransport := eGlastransport_AufAuslauf;
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition := eKippen_Position_84Grad;
           Auftraege_Shuttle := TRUE; 
		   
         cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE,
         cSPEICHER_1..cSPEICHER_2:
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eGlastransport := eGlastransport_AufAuslauf;
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition := eKippen_Position_90Grad;//1.5
           Auftraege_Shuttle := TRUE;
       
       ELSE
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eGlastransport := eGlastransport_AufAuslauf;
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition := eKippen_Default;
           Auftraege_Shuttle := TRUE;
       
       END_CASE
        
     ELSIF starrShuttleBasisParameter[wlIndex].stMKs.eStationsTyp = eOutputshuttle THEN//103,104
       CASE starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].wTransferstationsNr1 OF
		   
         cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE,
         cSPEICHER_1:
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eGlastransport := eGlastransport_AufEinlaufVorab;
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition := eKippen_Position_90Grad;//1.5
           Auftraege_Shuttle := TRUE;

         cERSTE_STATION..cLETZTE_STATION:
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eGlastransport := eGlastransport_AufAuslauf;
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition := eKippen_Position_84Grad;
           Auftraege_Shuttle := TRUE;
       
       ELSE
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eGlastransport := eGlastransport_AufEinlaufVorab;
           starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition := eKippen_Default;
           Auftraege_Shuttle := TRUE;
       
       END_CASE 
     ELSE
       starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eGlastransport := eGlastransport_AufEinlaufVorab;
       starrShuttleBasisParameter[wlIndex].pAuftrag[cWAND_1].stAuftragsOptionen.eKippen_SollPosition := eKippen_Default;
       Auftraege_Shuttle := TRUE;
   
     END_IF  
   END_IF
END_FOR
END_METHOD