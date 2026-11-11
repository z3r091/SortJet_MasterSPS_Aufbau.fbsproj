(* METADATA
{
	"v3Meta": {
		"objectGuid": "120a0490-dc9c-46f0-83eb-c4f1579e8cf5"
	}
}
*)
ACTION Zuweisung_203
// Zuweisung der MK's
starrStationBasisParameter[cSTATION_203].stMKs REF= apgMKStation203;

// Antriebsparameter zuweisen
starrStationBasisParameter[cSTATION_203].stAntriebsparameter.stGlastransport               REF= apgInfoStation203Glastransport;
starrStationBasisParameter[cSTATION_203].stAntriebsparameter.stGlastransportSlave          REF= apgInfoStation203Glastransport_Slave;
starrStationBasisParameter[cSTATION_203].stAntriebsparameter.stKippen                      REF= apgInfoStation203Kippen;
starrStationBasisParameter[cSTATION_203].stAntriebsparameter.stQuerfahrt                   REF= apgInfoStation203Querfahrt;

// Parameter der Stationskomponenten zuweisen
starrStationBasisParameter[cSTATION_203].stParameterStationskomponenten.stGlastransport    REF= apgMKStation203Glastransport;
starrStationBasisParameter[cSTATION_203].stParameterStationskomponenten.stKippen           REF= apgMKStation203Kippen;
starrStationBasisParameter[cSTATION_203].stParameterStationskomponenten.stQuerfahrt        REF= apgMKStation203Querfahrt;


(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)
// Eintransport
// Nicht vorhanden

// Austransport
starrStationBasisParameter[cSTATION_203].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_202]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_203].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_202] := FALSE;
END_ACTION