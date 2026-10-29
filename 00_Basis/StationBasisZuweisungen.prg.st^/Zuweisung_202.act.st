(* METADATA
{
	"v3Meta": {
		"objectGuid": "e5688ce9-ab5a-4deb-8339-ae5087cb81c6"
	}
}
*)
ACTION Zuweisung_202
// Zuweisung der MK's
starrStationBasisParameter[cSTATION_202].stMKs REF= apgMKStation202;

// Antriebsparameter zuweisen  
starrStationBasisParameter[cSTATION_202].stAntriebsparameter.stGlastransport               REF= apgInfoStation202Glastransport;
starrStationBasisParameter[cSTATION_202].stAntriebsparameter.stGlastransportSlave          REF= apgInfoStation202Glastransport_Slave;
starrStationBasisParameter[cSTATION_202].stAntriebsparameter.stKippen                      REF= apgInfoStation202Kippen;

// Parameter der Stationskomponenten zuweisen  
starrStationBasisParameter[cSTATION_202].stParameterStationskomponenten.stGlastransport    REF= apgMKStation202Glastransport;
starrStationBasisParameter[cSTATION_202].stParameterStationskomponenten.stKippen           REF= apgMKStation202Kippen;

(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Eintransport
starrStationBasisParameter[cSTATION_202].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_201]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_202].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_201] := TRUE;

// Austransport
starrStationBasisParameter[cSTATION_202].stMKs.stSchnittstellendaten.aAustransporte.Station[cSHUTTLE_101]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_202].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSHUTTLE_101] := FALSE;
END_ACTION