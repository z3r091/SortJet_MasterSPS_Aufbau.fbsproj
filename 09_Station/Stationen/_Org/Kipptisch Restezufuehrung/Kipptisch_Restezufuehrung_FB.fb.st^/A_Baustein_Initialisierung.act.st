(* METADATA
{
	"v3Meta": {
		"objectGuid": "91d8d702-fd59-426c-8f95-a32d9e489225"
	}
}
*)
ACTION A_Baustein_Initialisierung
(***************************************************************************************************)
(* AKTION INITIALISIERUNG *)
(***************************************************************************************************)
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

(* Hinweis:
   - Einige Bausteine einmalig aufrufen damit die Referenz auf Antriebe geschrieben wird
*)
Glastransport();
Kippen();
Querfahrt();
END_ACTION