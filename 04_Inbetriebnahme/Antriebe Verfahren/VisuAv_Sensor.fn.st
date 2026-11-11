(* METADATA
{
	"v3Meta": {
		"objectGuid": "a0c6e368-f3e1-4acc-8315-ee5d3cbd1ca5"
	}
}
*)
FUNCTION VisuAv_Sensor : eSensoren
VAR_INPUT
  wNummer : WORD; // 1..9 aus der Visu
END_VAR
// Sensornummer aus der Visu auf eSensoren abbilden (eSensoren ist strict), ungueltig = Sensor_1
CASE wNummer OF
  2: VisuAv_Sensor := eSensoren.Sensor_2;
  3: VisuAv_Sensor := eSensoren.Sensor_3;
  4: VisuAv_Sensor := eSensoren.Sensor_4;
  5: VisuAv_Sensor := eSensoren.Sensor_5;
  6: VisuAv_Sensor := eSensoren.Sensor_6;
  7: VisuAv_Sensor := eSensoren.Sensor_7;
  8: VisuAv_Sensor := eSensoren.Sensor_8;
  9: VisuAv_Sensor := eSensoren.Sensor_9;
ELSE
  VisuAv_Sensor := eSensoren.Sensor_1;
END_CASE
END_FUNCTION