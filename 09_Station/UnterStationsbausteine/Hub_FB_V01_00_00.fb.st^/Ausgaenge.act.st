(* METADATA
{
	"v3Meta": {
		"objectGuid": "d5367713-3a47-4c7d-81e2-e8033d1c223a"
	}
}
*)
ACTION Ausgaenge
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSGAENGE
//-------------------------------------------------------------------------------------------------
(* Anmerkung:
   - Realisierung durch ein ENUM
*)
IF ( NOT in_bSensorNichtUnten AND in_bSensorNichtOben ) THEN
  epHubStatus := eHub_Unten;

ELSIF ( NOT in_bSensorNichtOben AND in_bSensorNichtUnten ) THEN
  epHubStatus := eHub_Oben;

ELSIF ( NOT in_bSensorNichtUnten AND NOT in_bSensorNichtOben ) THEN
  epHubStatus := eHub_Fehler;

ELSE
  epHubStatus := eHub_Undefiniert;

END_IF

// Bremse lösen
out_bBremseLoesen := out_bHubAbSetzen OR out_bHubAufSetzen;
END_ACTION