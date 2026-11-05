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
starrStationBasisParameter[cSTATION_205].stAntriebsparameter.stGlastransport             REF= apgInfoStation205Glastransport;
starrStationBasisParameter[cSTATION_205].stAntriebsparameter.stGlastransportSlave        REF= apgInfoStation205Glastransport_Slave;
starrStationBasisParameter[cSTATION_205].stAntriebsparameter.stGlastransportY            REF= apgInfoStation205GlastransportY;
starrStationBasisParameter[cSTATION_205].stAntriebsparameter.stGlastransportYSlave       REF= apgInfoStation205GlastransportY_Slave;

// Parameter der Stationskomponenten zuweisen
starrStationBasisParameter[cSTATION_205].stParameterStationskomponenten.stGlastransport  REF= apgMKStation205Glastransport;
starrStationBasisParameter[cSTATION_205].stParameterStationskomponenten.stGlastransportY REF= apgMKStation205GlastransportY;

// Hinweis:
// - Zuweisung der Transportrichtungen im Automatik-Betrieb fuer die Glastransporte
// - Achsrichtung: ueber welche Achse der Eckuebergabe mit der Nachbarstation transportiert wird

// Eintransport
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_203]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_203]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.Achsrichtung[cSTATION_203]             := eAchsrichtung_X;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_203] := TRUE;

starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_204]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_204]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.Achsrichtung[cSTATION_204]             := eAchsrichtung_Y;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_204] := TRUE;

// Austransport
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_206]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aAustransporte.Achsrichtung[cSTATION_206]             := eAchsrichtung_X;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_206] := FALSE;
END_ACTION