(* METADATA
{
  "v3Meta": {
    "objectGuid": "858e0521-02c9-487e-906a-ece949caeb63"
  }
}
*)
ACTION SensorenFreifahren
(***************************************************************************************************)
(* AKTION SENSORIK FREI FAHREN NACH VERFAHRABBRUCH *)
(***************************************************************************************************)
(* Hinweis:
   - Kommt es zu einem Verfahrabbruch aufgrund des Einlauf- bzw. Auslauf- Sensors muss dieser
     frei gefahren werden, damit der Verfahrbefehl neu gesendet werden kann
*)
artlVerfahrabbruchSensorik[cWAND_1]( CLK := ( Querfahrt.bpAbbruchPositionierung AND (atoflSensorEinlauf[cWAND_1].Q OR atoflSensorAUslaufStopp[cWAND_1].Q ) ));

IF ( artlVerfahrabbruchSensorik[cWAND_1].Q ) THEN
  Glastransport[cWAND_1].bpStarteSensorFreiFahren := NOT Glastransport[cWAND_1].bpStarteSensorFreiFahren;
END_IF
END_ACTION