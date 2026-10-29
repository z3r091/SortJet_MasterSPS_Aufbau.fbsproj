(* METADATA
{
	"v3Meta": {
		"objectGuid": "e28ff899-9cd6-4232-8b9f-d72fc4ed8c44"
	}
}
*)
ACTION Abnehmen
(***************************************************************************************************)
(* ABNEHMEN*)
(***************************************************************************************************)
(*
Eigentlich Inspektion aber für die paar Schritte wollte ich keine neu Aktion machen zumal ehh fast der gleiche Ablauf wie beim Abnehmen besteht
*)


IF ( BasisStationsParameter.bAbnehmen
  AND blBetriebsartAutomatik )
THEN
  (* Fehlerbehandlung
     - Kippen
  *)
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplAbnehmen := STEP_900_E;
  END_IF
  
  CASE steplAbnehmen OF
(* ABNEHMEN =====================*)
    STEP_50_E:
      out_bAmpelSignalGruen                  := gbFlashbit05sec;
      out_bSignalScheibeAbnehmen             := gbFlashbit05sec;

      (* Hinweis:
         - Erst die Lichtschranke unterbrechen und zur Station gehen
      *)
      IF ( tonlFreigabeErhalten.Q ) THEN (* NOT *)
        steplAbnehmen := STEP_200_E;
      END_IF

(* ABNEHMEN =====================*)
    STEP_200_E:
      out_bAmpelSignalGruen        := gbFlashbit05sec;
      out_bSignalScheibeAbnehmen   := gbFlashbit05sec;
      ilDimmstufe                  := 1; // ggf. anpassen 

      IF in_bTasterQuittierungGlasAbgenommen //Inspektion abgeschlossen, Glas OK an das MMI schicken und Anlegeauftrag starten durch MMI            
      THEN 
        
        out_bSignalScheibeGlasbruch     := FALSE;
        out_bAmpelSignalGruen           := FALSE;
        out_bSignalScheibeAbnehmen      := FALSE;
        
        
        ilDimmstufe := 7; // ggf. anpassen 
        
        steplAbnehmen := STEP_1000_E;
        
      END_IF
      
      IF in_bTasterGlasbruch 
        AND NOT Glastransport.bpSensorEinlaufVorAb  
        AND NOT Glastransport.bpSensorEinlauf 
        AND NOT Glastransport.bpSensorAuslaufVorAb  
      THEN
      ;
      
      END_IF
        

  END_CASE
ELSE
  IF (steplAbnehmen > STEP_0_E) THEN
    out_bDrosselklappeOeffnen   := FALSE;
    out_bSignalScheibeAbnehmen  := FALSE;
    out_bAmpelSignalGruen       := FALSE;
    out_bSignalScheibeGlasbruch := FALSE;

    Messachse.bpPositionierung  := FALSE;
    Kippen.bpPositionieren      := FALSE;
	
    BasisStationsParameter.bAbnehmenAbgeschlossen := FALSE;

    steplAbnehmen := STEP_0_E;
  END_IF
END_IF
END_ACTION