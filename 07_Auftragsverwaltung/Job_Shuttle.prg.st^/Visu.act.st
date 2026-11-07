(* METADATA
{
	"v3Meta": {
		"objectGuid": "1e9e5d8c-b3c6-4e22-b591-305900ce7097"
	}
}
*)
ACTION Visu
//-------------------------------------------------------------------------------------------------
// Daten in das VisoArray kopieren
//-------------------------------------------------------------------------------------------------

FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  VisuAuftragsdaten[wlIndex].eStation := TO_WORD(AuftragsdatenStation[wlIndex].wAuftrag);
  FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
    VisuAuftragsdaten[wlIndex].eWand[wlIndexWand] := TO_WORD(AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag);
  END_FOR
END_FOR

FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  VisuAuftragsdaten[wlIndex].eStation := TO_WORD(AuftragsdatenTransfershuttle[wlIndex].wAuftrag);  
END_FOR
END_ACTION