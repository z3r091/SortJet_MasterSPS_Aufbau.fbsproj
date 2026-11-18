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

// Zuweisung Sammel-IOs
// in_bDruckluftOK: wird zyklisch beim Aufruf in StationsAufrufe (MainTask) uebergeben - nicht hier (SlowTask, Mehrfach-Task-Zugriff auf E/As)
END_ACTION