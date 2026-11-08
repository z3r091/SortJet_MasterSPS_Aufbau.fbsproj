(* METADATA
{
	"v3Meta": {
		"objectGuid": "c063edf5-417b-4a06-b1eb-b2a6b64450cf"
	}
}
*)
ACTION Zuweisung_208
// Zuweisung der MK's
starrStationBasisParameter[cSTATION_208].stMKs REF= apgMKStation208;

// Antriebsparameter zuweisen  
starrStationBasisParameter[cSTATION_208].stAntriebsparameter.stGlastransport               REF= apgInfoStation208Glastransport;
starrStationBasisParameter[cSTATION_208].stAntriebsparameter.stGlastransportSlave          REF= apgInfoStation208GlastransportSlave;
starrStationBasisParameter[cSTATION_208].stAntriebsparameter.stMessachse                   REF= apgInfoStation208Messachse;
starrStationBasisParameter[cSTATION_208].stAntriebsparameter.stKippen                      REF= apgInfoStation208Kippen;

// Parameter der Stationskomponenten zuweisen  
starrStationBasisParameter[cSTATION_208].stParameterStationskomponenten.stGlastransport    REF= apgMKStation208Glastransport;
starrStationBasisParameter[cSTATION_208].stParameterStationskomponenten.stMessachse        REF= apgMKStation208Messachse;
starrStationBasisParameter[cSTATION_208].stParameterStationskomponenten.stKippen           REF= apgMKStation208Kippen;

(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Eintransport
// Nicht vorhanden

// Austransport
starrStationBasisParameter[cSTATION_208].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_207]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_208].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_207] := FALSE;
END_ACTION