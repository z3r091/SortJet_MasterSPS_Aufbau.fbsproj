(* METADATA
{
  "v3Meta": {
    "objectGuid": "e67e0f61-2f01-43cf-b061-ff8e137e7c84"
  }
}
*)
ACTION A_Baustein_Initialisierung
//-------------------------------------------------------------------------------------------------
// AKTION INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
// Antriebsparameter zuweisen  
Glastransport.ppAntriebsInformationen      REF= BasisStationsParameter.stAntriebsparameter.stGlastransport[1];
Glastransport.ppAntriebsInformationenSlave REF= BasisStationsParameter.stAntriebsparameter.stGlastransportSlave[1];
Kippen.ppAntriebsInformationen             REF= BasisStationsParameter.stAntriebsparameter.stKippen;
Querfahrt.ppAntriebsInformationen          REF= BasisStationsParameter.stAntriebsparameter.stQuerfahrt;     

// Stationssparameter zuweisen  
Glastransport.ppParameterBaustein          REF= BasisStationsParameter.stParameterStationskomponenten.stGlastransport[1];
Kippen.ppParameterBaustein                 REF= BasisStationsParameter.stParameterStationskomponenten.stKippen[1];
Querfahrt.ppParameterBaustein              REF= BasisStationsParameter.stParameterStationskomponenten.stQuerfahrt;

// ---------------------------------------------------------------------------------------
//  INITIALISIERUNG DES BAUSTEIN AUFBAUS
//
//  Hinweis:
// - Komponenten aktivieren bzw. deaktivieren
// ---------------------------------------------------------------------------------------

(* Hinweis:
   - Querfahrt
*)
Querfahrt.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt;

(* Hinweis:
   - Riemen
*)
Glastransport.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGlastransport[cWAND_1];

(* Hinweis:
   - Riemen
*)
Kippen.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1];

// Aktivierungen
Geblaese.bpAktivieren        := BasisStationsParameter.stMKs.stStationsAufbau.bGeblase[cWAND_1];
Hub.bpAktivieren             := BasisStationsParameter.stMKs.stStationsAufbau.bHub;
Roellchenleiste.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bRoellchenleiste[cWAND_1];
Wandverstellung.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bWandverstellung[cWAND_1];

(* Hinweis:
   - Einige Bausteine einmalig aufrufen damit die Referenz auf Antriebe geschrieben wird
*)
Glastransport( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
Kippen( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
Querfahrt( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
END_ACTION