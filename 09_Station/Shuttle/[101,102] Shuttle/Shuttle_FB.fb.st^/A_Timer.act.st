(* METADATA
{
  "v3Meta": {
    "objectGuid": "c3e7bbb5-36b7-4dbe-a15c-079769d6a01d"
  }
}
*)
ACTION A_Timer
(***************************************************************************************************)
(* TIMER, SETTINGS, ETC. *)
(***************************************************************************************************)
(* Verfahrueberwachung:
   - Sensorik- Ueberwachung (Entprellen)
     => Sollte eimn Sensor geschaltet haben ggf. das andere Shuttle sperren um einen Auffahr- Unfall zu vermeiden
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  atoflSensorEinlauf[wlIndex](IN := in_bSensorEinlauf[wlIndex] ,         PT := ZEIT_SENSOR_ENTPRELLEN);
  atoflSensorAuslauf[wlIndex](IN := in_bSensorAuslauf[wlIndex] ,         PT := ZEIT_SENSOR_ENTPRELLEN);
  atoflSensorAUslaufStopp[wlIndex](IN:= in_bSensorAuslaufStopp[wlIndex], PT := ZEIT_SENSOR_ENTPRELLEN);
END_FOR
END_ACTION