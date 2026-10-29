(* METADATA
{
	"v3Meta": {
		"objectGuid": "2f1f2564-8eff-43f7-8c8f-4a939be6a082"
	}
}
*)
FUNCTION VisuUeb_Sensor : DWORD
VAR_INPUT
  bBelegt    : BOOL;
  bVorhanden : BOOL := TRUE;
END_VAR
IF NOT bVorhanden THEN
  VisuUeb_Sensor := 16#00FFFFFF; // transparent
ELSIF bBelegt THEN
  VisuUeb_Sensor := VISU_UEBERSICHT.cFARBE_SENSOR_AN;
ELSE
  VisuUeb_Sensor := VISU_UEBERSICHT.cFARBE_GRAU_HELL;
END_IF
END_FUNCTION