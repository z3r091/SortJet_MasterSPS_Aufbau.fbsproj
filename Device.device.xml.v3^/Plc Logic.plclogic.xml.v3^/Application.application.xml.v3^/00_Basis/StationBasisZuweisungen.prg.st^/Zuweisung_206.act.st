(* METADATA
{
	"v3Meta": {
		"objectGuid": "ec549a81-8212-4c0f-885a-b7f66d397584"
	}
}
*)
ACTION Zuweisung_206
// Zuweisung der MK's
starrStationBasisParameter[cSTATION_206].stMKs REF= apgMKStation206;

// Antriebsparameter zuweisen
starrStationBasisParameter[cSTATION_206].stAntriebsparameter.stGlastransport               REF= apgInfoStation206Glastransport;
starrStationBasisParameter[cSTATION_206].stAntriebsparameter.stGlastransportSlave          REF= apgInfoStation206Glastransport_Slave;
starrStationBasisParameter[cSTATION_206].stAntriebsparameter.stQuerfahrt                   REF= apgInfoStation206Querfahrt;
starrStationBasisParameter[cSTATION_206].stAntriebsparameter.stKippen                      REF= apgInfoStation206Kippen;

// Parameter der Stationskomponenten zuweisen
starrStationBasisParameter[cSTATION_206].stParameterStationskomponenten.stGlastransport    REF= apgMKStation206Glastransport;
starrStationBasisParameter[cSTATION_206].stParameterStationskomponenten.stQuerfahrt        REF= apgMKStation206Querfahrt;
starrStationBasisParameter[cSTATION_206].stParameterStationskomponenten.stKippen           REF= apgMKStation206Kippen;

(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Eintransport von der Eckuebergabe 204
starrStationBasisParameter[cSTATION_206].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_204]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_206].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_204]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_206].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_204] := TRUE;

// Austransport an die Drehstation 207
starrStationBasisParameter[cSTATION_206].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_207]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_206].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_207] := FALSE;
END_ACTION