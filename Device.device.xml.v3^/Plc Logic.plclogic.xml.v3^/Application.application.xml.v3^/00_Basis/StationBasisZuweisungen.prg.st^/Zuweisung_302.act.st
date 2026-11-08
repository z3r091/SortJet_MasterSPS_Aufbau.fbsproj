(* METADATA
{
	"v3Meta": {
		"objectGuid": "bc82e65a-c6a0-47b9-a190-18e8260f866e"
	}
}
*)
ACTION Zuweisung_302
// Zuweisung der MK's
starrFaecherwagenBasisParameter[cSTATION_302].stMKs REF= apgMKFaecherwagenstation[cSTATION_302];
END_ACTION