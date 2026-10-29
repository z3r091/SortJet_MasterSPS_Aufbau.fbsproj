(* METADATA
{
	"v3Meta": {
		"objectGuid": "58331703-c161-4204-81e2-c1518bdd5c02"
	}
}
*)
ACTION Zuweisung_102
// Zuweisung der MK's
starrShuttleBasisParameter[cSHUTTLE_102].stMKs REF= apgMKShuttle102;

// Antriebsparameter zuweisen  
starrShuttleBasisParameter[cSHUTTLE_102].stAntriebsparameter.stGlastransport                   REF= apgInfoShuttle102Glastransport;
starrShuttleBasisParameter[cSHUTTLE_102].stAntriebsparameter.stGlastransportSlave              REF= apgInfoShuttle102GlastransportSlave;
starrShuttleBasisParameter[cSHUTTLE_102].stAntriebsparameter.stWandverstellung                 REF= apgInfoShuttle102Dickenverstellung;
starrShuttleBasisParameter[cSHUTTLE_102].stParameterStationskomponenten.stGlastransportShuttle REF= apgMKShuttle102Glastransport;
starrShuttleBasisParameter[cSHUTTLE_102].stParameterStationskomponenten.stKippen               REF= apgMKShuttle102Kippen;
starrShuttleBasisParameter[cSHUTTLE_102].stParameterStationskomponenten.stWandverstellung      REF= apgMKShutte102Scheibenfuehrung;

starrShuttleBasisParameter[cSHUTTLE_102].stAntriebsparameter.stQuerfahrt REF= apgInfoShuttle102Querfahrt;
starrShuttleBasisParameter[cSHUTTLE_102].stAntriebsparameter.stKippen    REF= apgInfoShuttle102Kippen;

starrShuttleBasisParameter[cSHUTTLE_102].stParameterStationskomponenten.stZentralSchmierung REF= apgMKShuttleZentralschmierung[cSHUTTLE_102];

(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)

// Transfershuttle des dynamischen Speichers  zuweisen
FOR wlIndex := cSHUTTLE_151 TO cSHUTTLE_154 DO
  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.Station[wlIndex]                  := Rueckwaertig;
  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[wlIndex]            := eGlastransport_Default;
  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.Kippen[wlIndex]                   := eKippen_Position_90Grad;
  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.KippenNachEintransport[wlIndex]   := eKippen_Position_90Grad;
  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[wlIndex] := TRUE;

  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.Station[wlIndex]                  := Vorwaertig;
  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.Glastransport[wlIndex]            := eGlastransport_AufAuslauf;
  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.Kippen[wlIndex]                   := eKippen_Position_90Grad;
  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.KippenNachAustransport[wlIndex]   := eKippen_Position_84Grad;
  starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[wlIndex] := TRUE;
END_FOR

//150
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.Station[cSHUTTLE_150]                  := Vorwaertig;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSHUTTLE_150]            := eGlastransport_Default;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.Kippen[cSHUTTLE_150]                   := eKippen_Position_84Grad;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.KippenNachEintransport[cSHUTTLE_150]   := eKippen_Position_90Grad;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSHUTTLE_150] := TRUE;
 
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.Station[cSHUTTLE_150]                  := Rueckwaertig;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.Glastransport[cSHUTTLE_150]            := eGlastransport_AufEinlauf;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.Kippen[cSHUTTLE_150]                   := eKippen_Position_90Grad;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.KippenNachAustransport[cSHUTTLE_150]   := eKippen_Default;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[cSHUTTLE_150] := TRUE;

// Station 203
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.Station[cSTATION_202]                  := Vorwaertig;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[cSTATION_202]            := eGlastransport_AufAuslauf;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.Kippen[cSTATION_202]                   := eKippen_Position_84Grad;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.KippenNachEintransport[cSTATION_202]   := eKippen_Default;
starrShuttleBasisParameter[cSHUTTLE_102].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[cSTATION_202] := TRUE;
END_ACTION