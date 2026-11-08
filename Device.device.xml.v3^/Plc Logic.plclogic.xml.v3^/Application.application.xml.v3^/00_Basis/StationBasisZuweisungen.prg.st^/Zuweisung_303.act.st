(* METADATA
{
	"v3Meta": {
		"objectGuid": "150cb19f-2e3d-4826-8e12-7d1c3a1232ee"
	}
}
*)
ACTION Zuweisung_303
// Zuweisung der MK's
starrFaecherwagenBasisParameter[cSTATION_303].stMKs REF= apgMKFaecherwagenstation[cSTATION_303];
END_ACTION