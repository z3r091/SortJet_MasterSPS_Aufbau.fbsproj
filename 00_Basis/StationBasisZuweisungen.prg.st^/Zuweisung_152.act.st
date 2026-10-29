(* METADATA
{
	"v3Meta": {
		"objectGuid": "41f5393d-bf68-4ef4-aca8-1dae62f52119"
	}
}
*)
ACTION Zuweisung_152
// Zuweisung der MK's
starrTransfershuttleBasisParameter[cSHUTTLE_152].stMKs REF= apgMKTransfershuttle152;

// Antriebsparameter zuweisen  
starrTransfershuttleBasisParameter[cSHUTTLE_152].stAntriebsparameter.stQuerfahrt             REF= apgInfoTransfershuttle152Querfahrt;
starrTransfershuttleBasisParameter[cSHUTTLE_152].stAntriebsparameter.stGlastransport         REF= apgInfoTransfer152Glastransport;
starrTransfershuttleBasisParameter[cSHUTTLE_152].stAntriebsparameter.stGlastransportSlave    REF= apgInfoTransfer152GlastransportSlave;

// Parameter der Stationskomponenten zuweisen  
starrTransfershuttleBasisParameter[cSHUTTLE_152].stParameterStationskomponenten.stGlastransportTransferShuttle    REF= apgTransfer152Glastransport;
starrTransfershuttleBasisParameter[cSHUTTLE_152].stParameterStationskomponenten.stZentralSchmierung               REF= apgMKTransfershuttleZentralschmierung[cSHUTTLE_152];

(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)
// Shuttle 101
starrTransfershuttleBasisParameter[cSHUTTLE_152].stMKs.stSchnittstellendaten.aEintransporte.Station[cSHUTTLE_101] := Vorwaertig;
starrTransfershuttleBasisParameter[cSHUTTLE_152].stMKs.stSchnittstellendaten.aAustransporte.Station[cSHUTTLE_101] := Rueckwaertig;

starrTransfershuttleBasisParameter[cSHUTTLE_152].stMKs.stSchnittstellendaten.aEintransporte.Station[cSHUTTLE_103] := Rueckwaertig;
starrTransfershuttleBasisParameter[cSHUTTLE_152].stMKs.stSchnittstellendaten.aAustransporte.Station[cSHUTTLE_103] := Vorwaertig;
END_ACTION