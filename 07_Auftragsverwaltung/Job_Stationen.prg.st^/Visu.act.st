(* METADATA
{
	"v3Meta": {
		"objectGuid": "ba58e9e7-a53f-4b72-9d20-33bd7cca2a1a"
	}
}
*)
ACTION Visu
// *************************************************************************************************
// Daten in das VisoArray kopieren
FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  VisuAuftragsdaten[wlIndex].eStation := TO_WORD(AuftragsdatenStation[wlIndex].wAuftrag);
  FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
    VisuAuftragsdaten[wlIndex].eWand[wlIndexWand] := TO_WORD(AuftragsdatenWand[wlIndex, wlIndexWand].wAuftrag);
  END_FOR
END_FOR
END_ACTION