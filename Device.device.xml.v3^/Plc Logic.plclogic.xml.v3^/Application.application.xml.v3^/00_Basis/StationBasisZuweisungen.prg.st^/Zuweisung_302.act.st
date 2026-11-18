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
// in_bDruckluftOK: wird zyklisch beim Aufruf in StationsAufrufe (MainTask) uebergeben - nicht hier (SlowTask, Mehrfach-Task-Zugriff auf E/As)
END_ACTION