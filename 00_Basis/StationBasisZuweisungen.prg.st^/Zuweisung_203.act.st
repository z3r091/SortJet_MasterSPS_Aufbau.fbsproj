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

// Parameter der Stationskomponenten zuweisen  
starrStationBasisParameter[cSTATION_203].stParameterStationskomponenten.stGlastransport    REF= apgMKStation203Glastransport;


(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)
// Eintransport
starrStationBasisParameter[cSTATION_203].stMKs.stSchnittstellendaten.aEintransporte.Station[cFREMDANLAGE_EINLAUF_1]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_203].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cFREMDANLAGE_EINLAUF_1] := TRUE;

// Austransport
starrStationBasisParameter[cSTATION_203].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_202]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_203].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_202] := FALSE;
END_ACTION