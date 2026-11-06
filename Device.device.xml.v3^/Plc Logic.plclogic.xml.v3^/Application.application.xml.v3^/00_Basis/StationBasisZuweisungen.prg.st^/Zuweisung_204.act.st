(* METADATA
{
  "v3Meta": {
    "objectGuid": "e2d26e6b-cff2-4031-affb-248ab2534f79"
  }
}
*)
ACTION Zuweisung_204
// Zuweisung der MK's
starrStationBasisParameter[cSTATION_204].stMKs REF= apgMKStation204;

// Antriebsparameter zuweisen
starrStationBasisParameter[cSTATION_204].stAntriebsparameter.stGlastransport[1]      := apgInfoStation204Glastransport;
starrStationBasisParameter[cSTATION_204].stAntriebsparameter.stGlastransportSlave[1] := apgInfoStation204Glastransport_Slave;
starrStationBasisParameter[cSTATION_204].stAntriebsparameter.stMessachse             := apgInfoStation204Messachse;


// Parameter der Stationskomponenten zuweisen  
starrStationBasisParameter[cSTATION_204].stParameterStationskomponenten.stGlastransport[1] := apgMKStation204Glastransport;
starrStationBasisParameter[cSTATION_204].stParameterStationskomponenten.stMessachse        := apgMKStation204Messachse;


(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Eintransport
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.Station[cFREMDANLAGE_EINLAUF_1]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cFREMDANLAGE_EINLAUF_1]            := eGlastransport_AufAuslaufVorab;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cFREMDANLAGE_EINLAUF_1] := TRUE;

// Austransport
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aAustransporte.Station[cSTATION_205]                  := Vorwaertig;
starrStationBasisParameter[cSTATION_204].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSTATION_205] := FALSE;
END_ACTION