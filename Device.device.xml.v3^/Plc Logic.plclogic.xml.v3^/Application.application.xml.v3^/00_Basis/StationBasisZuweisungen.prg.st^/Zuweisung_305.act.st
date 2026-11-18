(* METADATA
{
	"v3Meta": {
		"objectGuid": "1eb663c8-b9f8-4b76-a432-de5bea4a687b"
	}
}
*)
ACTION Zuweisung_305
// Zuweisung der MK's
starrFaecherwagenBasisParameter[cSTATION_305].stMKs REF= apgMKFaecherwagenstation[cSTATION_305];

// Zuweisung Sammel-IOs
// in_bDruckluftOK: wird zyklisch beim Aufruf in StationsAufrufe (MainTask) uebergeben - nicht hier (SlowTask, Mehrfach-Task-Zugriff auf E/As)
END_ACTION