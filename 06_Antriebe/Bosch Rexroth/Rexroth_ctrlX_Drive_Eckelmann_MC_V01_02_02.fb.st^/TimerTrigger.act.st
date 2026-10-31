(* METADATA
{
  "v3Meta": {
    "objectGuid": "3499e106-2e80-4a0d-b507-279f4e7a646f"
  }
}
*)
ACTION TimerTrigger
FOR wlFlankenerkennung := eSensoren.Sensor_1 TO eSensoren.Sensor_9 DO
  bRising[wlFlankenerkennung]  := blSensoren[wlFlankenerkennung] AND NOT blSensorenVorzyklus[wlFlankenerkennung];
  bFalling[wlFlankenerkennung] := NOT blSensoren[wlFlankenerkennung] AND blSensorenVorzyklus[wlFlankenerkennung];
  blSensorenVorzyklus[wlFlankenerkennung] := blSensoren[wlFlankenerkennung];
END_FOR;
END_ACTION