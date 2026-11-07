(* METADATA
{
	"v3Meta": {
		"objectGuid": "1bac7944-96b9-45d4-af1e-3cbdd11262c8"
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

// Antriebsparameter zuweisen  
Glastransport.ppParameterBaustein          REF= BasisStationsParameter.stParameterStationskomponenten.stGlastransport[1];
Kippen.ppParameterBaustein                 REF= BasisStationsParameter.stParameterStationskomponenten.stKippen[1];
Querfahrt.ppParameterBaustein              REF= BasisStationsParameter.stParameterStationskomponenten.stQuerfahrt;

// Aktuelle Position initialisieren
argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] := Querfahrt.rpAktuellePosition;

// Aktivierungen
Glastransport.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGlastransport[cWAND_1];
Kippen.bpAktivieren        := BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1];
Querfahrt.bpAktivieren     := BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt;
Rollenleiste.bpAktivieren  := BasisStationsParameter.stMKs.stStationsAufbau.bRoellchenleiste[cWAND_1];

(* Hinweis:
   - Einige Bausteine einmalig aufrufen damit die Referenz auf Antriebe geschrieben wird
*)
Glastransport( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
Kippen( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
Querfahrt( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
END_ACTION