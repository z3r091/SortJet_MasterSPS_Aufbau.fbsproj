(* METADATA
{
	"v3Meta": {
		"objectGuid": "443bc09b-b8af-4511-9c3a-ed00ec4cc080"
	}
}
*)
FUNCTION VisuHand_Set : BOOL
VAR_IN_OUT
  stH     : VisuHand_Station_ST;
END_VAR
VAR_INPUT
  wZeile  : WORD;
  sText   : STRING(30);
  dwFarbe : DWORD;
END_VAR
IF wZeile >= 1 AND wZeile <= 7 THEN
  stH.asStatus[wZeile]  := sText;
  stH.adwStatus[wZeile] := dwFarbe;
END_IF
VisuHand_Set := TRUE;
END_FUNCTION