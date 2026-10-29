(* METADATA
{
	"v3Meta": {
		"objectGuid": "508223db-73a6-4fc3-902d-ab2988c6447f"
	}
}
*)
ACTION Zuweisung_205
// Zuweisung der MK's
starrStationBasisParameter[cSTATION_205].stMKs REF= apgMKStation205;

// Antriebsparameter zuweisen
starrStationBasisParameter[cSTATION_205].stAntriebsparameter.stGlastransport[1]      := apgInfoStation205Glastransport;
starrStationBasisParameter[cSTATION_205].stAntriebsparameter.stGlastransportSlave[1] := apgInfoStation205Glastransport_Slave;
starrStationBasisParameter[cSTATION_205].stAntriebsparameter.stMessachse             := apgInfoStation205Messachse;


// Parameter der Stationskomponenten zuweisen  
starrStationBasisParameter[cSTATION_205].stParameterStationskomponenten.stGlastransport[1] := apgMKStation205Glastransport;
starrStationBasisParameter[cSTATION_205].stParameterStationskomponenten.stMessachse        := apgMKStation205Messachse;


(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Austransport
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_204]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_202] := FALSE;
END_ACTION