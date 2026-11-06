(* METADATA
{
  "v3Meta": {
    "objectGuid": "508223db-73a6-4fc3-902d-ab2988c6447f"
  }
}
*)
ACTION Zuweisung_204
// Zuweisung der MK's
starrStationBasisParameter[cSTATION_204].stMKs REF= apgMKStation204;

// Antriebsparameter zuweisen
starrStationBasisParameter[cSTATION_204].stAntriebsparameter.stGlastransport             REF= apgInfoStation204Glastransport;
starrStationBasisParameter[cSTATION_204].stAntriebsparameter.stGlastransportSlave        REF= apgInfoStation204Glastransport_Slave;
starrStationBasisParameter[cSTATION_204].stAntriebsparameter.stGlastransportY            REF= apgInfoStation204GlastransportY;
starrStationBasisParameter[cSTATION_204].stAntriebsparameter.stGlastransportYSlave       REF= apgInfoStation204GlastransportY_Slave;

// Parameter der Stationskomponenten zuweisen
starrStationBasisParameter[cSTATION_204].stParameterStationskomponenten.stGlastransport  REF= apgMKStation204Glastransport;
starrStationBasisParameter[cSTATION_204].stParameterStationskomponenten.stGlastransportY REF= apgMKStation204GlastransportY;

// Hinweis:
// - Zuweisung der Transportrichtungen im Automatik-Betrieb fuer die Glastransporte
// - Achsrichtung: ueber welche Achse der Eckuebergabe mit der Nachbarstation transportiert wird

// Eintransport
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_203]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_203]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.Achsrichtung[cSTATION_203]             := eAchsrichtung_X;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_203] := TRUE;

starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_205]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_205]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.Achsrichtung[cSTATION_205]             := eAchsrichtung_Y;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_205] := TRUE;

// Austransport
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_206]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aAustransporte.Achsrichtung[cSTATION_206]             := eAchsrichtung_X;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_206] := FALSE;
END_ACTION