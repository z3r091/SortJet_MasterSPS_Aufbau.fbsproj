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

// Eintransport von der Anlegewand 208: 0 Grad, 84 Grad gekippt
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_208]                  := Rueckwaertig;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_208]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Drehen[cSTATION_208]                   := eDrehPosition0Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.DrehenNachEintransport[cSTATION_208]   := eDrehPosition90Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Kippen[cSTATION_208]                   := eKippen_Position_84Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.KippenNachEintransport[cSTATION_208]   := eKippen_Position_90Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_208] := TRUE;

// Eintransport vom Kipptisch 206: 90 Grad, 84 Grad gekippt
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_206]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_206]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Drehen[cSTATION_206]                   := eDrehPosition90Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.DrehenNachEintransport[cSTATION_206]   := eDrehPosition90Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.Kippen[cSTATION_206]                   := eKippen_Position_84Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.KippenNachEintransport[cSTATION_206]   := eKippen_Position_90Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_206] := TRUE;

// Austransport an das Shuttle 101: 90 Grad, 90 Grad gekippt
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aAustransporte.Station[cSHUTTLE_101]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aAustransporte.Drehen[cSHUTTLE_101]                   := eDrehPosition90Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aAustransporte.DrehenNachAustransport[cSHUTTLE_101]   := eDrehPositionUndefiniert;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aAustransporte.Kippen[cSHUTTLE_101]                   := eKippen_Position_90Grad;
starrStationBasisParameter[cSTATION_207].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSHUTTLE_101] := FALSE;
END_ACTION