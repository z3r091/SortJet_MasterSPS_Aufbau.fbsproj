(* METADATA
{
  "v3Meta": {
    "objectGuid": "f8c036c1-64f4-4aee-adbe-77c22f5d828c"
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