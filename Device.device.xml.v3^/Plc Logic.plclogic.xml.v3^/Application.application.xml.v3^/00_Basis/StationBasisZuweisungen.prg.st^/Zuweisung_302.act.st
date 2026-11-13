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

// Zuweisung Sammel-IOs
aFaecherwagenstation[cSTATION_302].in_bDruckluftOK := StatusAnlage.in_bDruckluft_FW_OK;
END_ACTION