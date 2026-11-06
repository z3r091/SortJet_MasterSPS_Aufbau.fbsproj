(* METADATA
{
  "v3Meta": {
    "objectGuid": "e2d26e6b-cff2-4031-affb-248ab2534f79"
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

// Eintransport
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.Station[cFREMDANLAGE_EINLAUF_1]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cFREMDANLAGE_EINLAUF_1]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cFREMDANLAGE_EINLAUF_1] := TRUE;

// Austransport
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_204]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_205].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_204] := FALSE;
END_ACTION