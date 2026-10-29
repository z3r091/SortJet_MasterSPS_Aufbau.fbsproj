(* METADATA
{
	"v3Meta": {
		"objectGuid": "aaebde34-a2b4-47dc-a312-326a710f0595"
	}
}
*)
ACTION A_Baustein_Initialisierung
(***************************************************************************************************)
(* AKTION: AUFRUFE *)
(***************************************************************************************************)
// Antriebsparameter zuweisen  
Querfahrt.ppAntriebsInformationen        REF= BasisStationsParameter.stAntriebsparameter.stQuerfahrt;
Glastransport.ppAntriebsInformationen    REF= BasisStationsParameter.stAntriebsparameter.stGlastransport[1];

// Parameter zuweisen
Glastransport.ppParameterBaustein        REF= BasisStationsParameter.stParameterStationskomponenten.stGlastransportTransferShuttle[cWAND_1];
Zentralschmierung.ppParameterBaustein    REF= BasisStationsParameter.stParameterStationskomponenten.stZentralSchmierung;

// Aktivierungen
Glastransport.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
Querfahrt.bpAktivieren     := BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt;
END_ACTION