(* METADATA
{
  "v3Meta": {
    "objectGuid": "561a369f-5782-4a21-a45c-1ccdb2bcddee"
  }
}
*)
ACTION A_Baustein_Initialisierung
(***************************************************************************************************)
(* BAUSTEIN INITIALISIERUNG *)
(***************************************************************************************************)
// Antriebsparameter zuweisen  
Glastransport.ppAntriebsInformationen      REF= BasisStationsParameter.stAntriebsparameter.stGlastransport[1];
Glastransport.ppAntriebsInformationenSlave REF= BasisStationsParameter.stAntriebsparameter.stGlastransportSlave[1];
Messachse.ppAntriebsInformationen          REF= BasisStationsParameter.stAntriebsparameter.stMessachse;
Kippen.ppAntriebsInformationen             REF= BasisStationsParameter.stAntriebsparameter.stKippen;
                                      
// Antriebsparameter zuweisen         
Glastransport.ppParameterBaustein          REF= BasisStationsParameter.stParameterStationskomponenten.stGlastransport[1];
Messachse.ppParameterBaustein              REF= BasisStationsParameter.stParameterStationskomponenten.stMessachse;
Kippen.ppParameterBaustein                 REF= BasisStationsParameter.stParameterStationskomponenten.stKippen[1];

(* ---------------------------------------------------------------------------------------
//  INITIALISIERUNG DES BAUSTEIN AUFBAUS
//         
//  Hinweis:
// - Komponenten aktivieren bzw. deaktivieren
// ---------------------------------------------------------------------------------------*)

(* Hinweis:
   - Querfahrt
*)
Messachse.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bMessachse;

(* Hinweis:
   - Riemen
*)
Glastransport.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGlastransport[cWAND_1];

(* Hinweis:
   - Riemen
*)
Kippen.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1];

(* Hinweis:
   - Dickenverstellung
*)
Dickenverstellung.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[cWAND_1];

(* Hinweis:
   - Einige Bausteine einmalig aufrufen damit die Referenz auf Antriebe geschrieben wird
*)
Glastransport( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
Messachse( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
Kippen( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
END_ACTION