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
// in_bDruckluftOK: wird zyklisch beim Aufruf in StationsAufrufe (MainTask) uebergeben - nicht hier (SlowTask, Mehrfach-Task-Zugriff auf E/As)
END_ACTION