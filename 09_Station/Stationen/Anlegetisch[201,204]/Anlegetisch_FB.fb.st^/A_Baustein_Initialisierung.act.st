(* METADATA
{
	"v3Meta": {
		"objectGuid": "8f958c44-ae7c-4154-a16d-aa850ff5818d"
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

// Antriebsparameter zuweisen  
Glastransport.ppParameterBaustein       REF= BasisStationsParameter.stParameterStationskomponenten.stGlastransport[1];
Messachse.ppParameterBaustein           REF= BasisStationsParameter.stParameterStationskomponenten.stMessachse;

// Aktivierungen
Glastransport.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
Messachse.bpAktivieren     := BasisStationsParameter.stMKs.stStationsAufbau.bMessachse;
Hubrahmen.bpAktivieren     := BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen;
Anschlag.bpAktivieren      := BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag;

(* Hinweis:
   - Einige Bausteine einmalig aufrufen damit die Referenz auf Antriebe geschrieben wird
*)
Glastransport( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
Messachse( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
END_ACTION