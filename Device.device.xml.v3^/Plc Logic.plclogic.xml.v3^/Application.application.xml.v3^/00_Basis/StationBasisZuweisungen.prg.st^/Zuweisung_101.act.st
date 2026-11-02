(* METADATA
{
  "v3Meta": {
    "objectGuid": "51c9bc00-b1a7-48c3-ab96-ac2ea4b83acf"
  }
}
*)
ACTION Zuweisung_101
// Zuweisung der MK's
starrShuttleBasisParameter[cSHUTTLE_101].stMKs REF= apgMKShuttle101;

// Antriebsparameter zuweisen  
starrShuttleBasisParameter[cSHUTTLE_101].stAntriebsparameter.stGlastransport                   REF= apgInfoShuttle101Glastransport;
starrShuttleBasisParameter[cSHUTTLE_101].stAntriebsparameter.stGlastransportSlave              REF= apgInfoShuttle101GlastransportSlave;
starrShuttleBasisParameter[cSHUTTLE_101].stAntriebsparameter.stWandverstellung                 REF= apgInfoShuttle101Dickenverstellung;
starrShuttleBasisParameter[cSHUTTLE_101].stParameterStationskomponenten.stGlastransportShuttle REF= apgMKShuttle101Glastransport;
starrShuttleBasisParameter[cSHUTTLE_101].stParameterStationskomponenten.stKippen               REF= apgMKShuttle101Kippen;
starrShuttleBasisParameter[cSHUTTLE_101].stParameterStationskomponenten.stWandverstellung      REF= apgMKShutte101Scheibenfuehrung;

starrShuttleBasisParameter[cSHUTTLE_101].stAntriebsparameter.stQuerfahrt REF= apgInfoShuttle101Querfahrt;
starrShuttleBasisParameter[cSHUTTLE_101].stAntriebsparameter.stKippen    REF= apgInfoShuttle101Kippen;

starrShuttleBasisParameter[cSHUTTLE_101].stParameterStationskomponenten.stZentralSchmierung REF= apgMKShuttleZentralschmierung[cSHUTTLE_101];

(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Transfershuttle des dynamischen Speichers  zuweisen
FOR wlIndex := cSHUTTLE_151 TO cSHUTTLE_154 DO
  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.Station[wlIndex]                  := Rueckwaertig;
  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[wlIndex]            := eGlastransport_Default;
  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.Kippen[wlIndex]                   := eKippen_Position_90Grad;
  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.KippenNachEintransport[wlIndex]   := eKippen_Position_90Grad;
  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[wlIndex] := TRUE;

  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aAustransporte.Station[wlIndex]                  := Vorwaertig;
  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aAustransporte.Glastransport[wlIndex]            := eGlastransport_AufAuslauf;
  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aAustransporte.Kippen[wlIndex]                   := eKippen_Position_90Grad;
  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aAustransporte.KippenNachAustransport[wlIndex]   := eKippen_Position_84Grad;
  starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[wlIndex] := TRUE;
END_FOR

// Station 203
starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_202]                  := Vorwaertig;
starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_202]            := eGlastransport_AufAuslauf;
starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.Kippen[cSTATION_202]                   := eKippen_Position_84Grad;
starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.KippenNachEintransport[cSTATION_202]   := eKippen_Default;
starrShuttleBasisParameter[cSHUTTLE_101].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_202] := TRUE;
END_ACTION