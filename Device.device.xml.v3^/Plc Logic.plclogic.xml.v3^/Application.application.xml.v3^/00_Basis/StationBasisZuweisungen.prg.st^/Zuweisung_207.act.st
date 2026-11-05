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
starrStationBasisParameter[cSTATION_207].stAntriebsparameter.stGlastransportSlave       REF= apgInfoStation207GlastransportSlave;
starrStationBasisParameter[cSTATION_207].stAntriebsparameter.stDrehen                   REF= apgInfoStation207Drehen;
starrStationBasisParameter[cSTATION_207].stAntriebsparameter.stKippen                   REF= apgInfoStation207Kippen;
starrStationBasisParameter[cSTATION_207].stAntriebsparameter.stQuerfahrt                REF= apgInfoStation207Querfahrt;

// Parameter der Stationskomponenten zuweisen  
starrStationBasisParameter[cSTATION_207].stParameterStationskomponenten.stGlastransport REF= apgMKStation207Glastransport;
starrStationBasisParameter[cSTATION_207].stParameterStationskomponenten.stDrehen        REF= apgMKStation207Drehen;
starrStationBasisParameter[cSTATION_207].stParameterStationskomponenten.stKippen        REF= apgMKStation207Kippen;
starrStationBasisParameter[cSTATION_207].stParameterStationskomponenten.stQuerfahrt     REF= apgMKStation207Querfahrt;

(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Eintransport
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_208]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_208]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_208] := TRUE;

// Austransport
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aAustransporte.Station[cERSTE_FREMDANLAGE_AUSLAUF]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cERSTE_FREMDANLAGE_AUSLAUF] := TRUE;
END_ACTION