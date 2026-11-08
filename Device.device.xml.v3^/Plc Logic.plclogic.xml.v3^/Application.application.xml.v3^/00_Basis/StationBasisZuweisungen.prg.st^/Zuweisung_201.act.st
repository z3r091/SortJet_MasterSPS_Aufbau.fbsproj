(* METADATA
{
	"v3Meta": {
		"objectGuid": "0d6757e1-53e1-48aa-88ce-f4bfba7d69cc"
	}
}
*)
ACTION Zuweisung_201
// Zuweisung der MK's
starrStationBasisParameter[cSTATION_201].stMKs REF= apgMKStation201;

// Antriebsparameter zuweisen
starrStationBasisParameter[cSTATION_201].stAntriebsparameter.stGlastransport         REF= apgInfoStation201Glastransport;
starrStationBasisParameter[cSTATION_201].stAntriebsparameter.stGlastransportSlave    REF= apgInfoStation201Glastransport_Slave;
starrStationBasisParameter[cSTATION_201].stAntriebsparameter.stMessachse             REF= apgInfoStation201Messachse;


// Parameter der Stationskomponenten zuweisen  
starrStationBasisParameter[cSTATION_201].stParameterStationskomponenten.stGlastransport    REF= apgMKStation201Glastransport;
starrStationBasisParameter[cSTATION_201].stParameterStationskomponenten.stMessachse        REF= apgMKStation201Messachse;


(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Austransport
starrStationBasisParameter[cSTATION_201].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_202]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_201].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_202] := FALSE;
END_ACTION