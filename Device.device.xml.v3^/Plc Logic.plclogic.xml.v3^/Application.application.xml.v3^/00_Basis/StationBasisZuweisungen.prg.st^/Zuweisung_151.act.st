(* METADATA
{
  "v3Meta": {
    "objectGuid": "626f2663-471d-49fb-b0f4-9d1f3bb0bf7f"
  }
}
*)
ACTION Zuweisung_151
// Zuweisung der MK's
starrTransfershuttleBasisParameter[cSHUTTLE_151].stMKs REF= apgMKTransfershuttle151;

// Antriebsparameter zuweisen  
starrTransfershuttleBasisParameter[cSHUTTLE_151].stAntriebsparameter.stQuerfahrt             REF= apgInfoTransfershuttle151Querfahrt;
starrTransfershuttleBasisParameter[cSHUTTLE_151].stAntriebsparameter.stGlastransport         REF= apgInfoTransfer151Glastransport;

// Parameter der Stationskomponenten zuweisen  
starrTransfershuttleBasisParameter[cSHUTTLE_151].stParameterStationskomponenten.stGlastransportTransferShuttle    REF= apgTransfer151Glastransport;
starrTransfershuttleBasisParameter[cSHUTTLE_151].stParameterStationskomponenten.stZentralSchmierung               REF= apgMKTransfershuttleZentralschmierung[cSHUTTLE_151];

(* Hinweis:
   - Zuweisung der Transportrichtungen im Automatik-Betrieb für die Glastransporte
   - Zuweisungen der Kipp-Stati für die Übernahme/Übergabe an/von der jeweiligen Station
*)
// Shuttle 101
starrTransfershuttleBasisParameter[cSHUTTLE_151].stMKs.stSchnittstellendaten.aEintransporte.Station[cSHUTTLE_101] := Vorwaertig;
starrTransfershuttleBasisParameter[cSHUTTLE_151].stMKs.stSchnittstellendaten.aAustransporte.Station[cSHUTTLE_101] := Rueckwaertig;

starrTransfershuttleBasisParameter[cSHUTTLE_151].stMKs.stSchnittstellendaten.aEintransporte.Station[cSHUTTLE_103] := Rueckwaertig;
starrTransfershuttleBasisParameter[cSHUTTLE_151].stMKs.stSchnittstellendaten.aAustransporte.Station[cSHUTTLE_103] := Vorwaertig;
END_ACTION