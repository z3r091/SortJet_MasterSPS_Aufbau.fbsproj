(* METADATA
{
	"v3Meta": {
		"objectGuid": "7955c67a-d244-4584-99f3-3105176a9532",
		"subObjects": {
			"set": {
				"objectGuid": "5bee3828-f9f0-4ff6-8bbd-7776959bfe22"
			},
			"get": {
				"objectGuid": "9fb27e5c-8dc6-4d5b-a84c-0ab66af3ee0d"
			}
		}
	}
}
*)
PROPERTY_Set bStarteSicherheitskreisReset : BOOL
VAR
END_VAR
// Anforderung vom MMI: Sicherheitsrelais der Station quittieren (nur Varianten mit eigenem Sicherheitsrelais werten aus)
IF ( bStarteSicherheitskreisReset ) THEN
  blStarteSicherheitskreisReset := TRUE;
END_IF
END_PROPERTY
PROPERTY_Get bStarteSicherheitskreisReset : BOOL
VAR
END_VAR
bStarteSicherheitskreisReset := blStarteSicherheitskreisReset;END_PROPERTY
