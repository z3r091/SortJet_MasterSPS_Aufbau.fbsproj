(* METADATA
{
	"v3Meta": {
		"objectGuid": "f55699bd-423e-450f-9568-477ca85fd454"
	}
}
*)
ACTION Zuweisung_207
// Zuweisung der MK's
starrStationBasisParameter[cSTATION_207].stMKs REF= apgMKStation207;

// Antriebsparameter zuweisen  
starrStationBasisParameter[cSTATION_207].stAntriebsparameter.stGlastransport            REF= apgInfoStation207Glastransport;

// Parameter der Stationskomponenten zuweisen  
starrStationBasisParameter[cSTATION_207].stParameterStationskomponenten.stGlastransport REF= apgMKStation207Glastransport;

(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Eintransport
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_207]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_207] := TRUE;

// Austransport
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aAustransporte.Station[cERSTE_FREMDANLAGE_AUSLAUF]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cERSTE_FREMDANLAGE_AUSLAUF] := TRUE;
END_ACTION