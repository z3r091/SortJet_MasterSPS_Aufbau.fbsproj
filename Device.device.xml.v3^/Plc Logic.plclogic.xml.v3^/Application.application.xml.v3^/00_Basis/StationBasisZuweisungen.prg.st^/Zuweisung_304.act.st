(* METADATA
{
	"v3Meta": {
		"objectGuid": "50ec10ce-5886-414e-95bc-f0e33c3a8c61"
	}
}
*)
ACTION Zuweisung_304
// Zuweisung der MK's
starrFaecherwagenBasisParameter[cSTATION_304].stMKs REF= apgMKFaecherwagenstation[cSTATION_304];

// Zuweisung Sammel-IOs
aFaecherwagenstation[cSTATION_304].in_bDruckluftOK := StatusAnlage.in_bDruckluft_FW_OK;
END_ACTION