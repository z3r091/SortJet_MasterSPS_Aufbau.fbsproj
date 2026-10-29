(* METADATA
{
	"v3Meta": {
		"objectGuid": "627ff357-d751-45e3-8052-8ab0ee975266"
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
Kippen.ppAntriebsInformationen             REF= BasisStationsParameter.stAntriebsparameter.stKippen;
Querfahrt.ppAntriebsInformationen          REF= BasisStationsParameter.stAntriebsparameter.stQuerfahrt;
Drehen.ppAntriebsInformationen             REF= BasisStationsParameter.stAntriebsparameter.stDrehen;

// Antriebsparameter zuweisen  
Glastransport.ppParameterBaustein          REF= BasisStationsParameter.stParameterStationskomponenten.stGlastransport[1];
Kippen.ppParameterBaustein                 REF= BasisStationsParameter.stParameterStationskomponenten.stKippen[1];
Querfahrt.ppParameterBaustein              REF= BasisStationsParameter.stParameterStationskomponenten.stQuerfahrt;
Drehen.ppParameterBaustein                 REF= BasisStationsParameter.stParameterStationskomponenten.stDrehen;

// Aktuelle Position initialisieren
argZuletztQuittiertePositionShuttle[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS] := Querfahrt.rpAktuellePosition;

(* Hinweis:
   - Einige Bausteine einmalig aufrufen damit die Referenz auf Antriebe geschrieben wird
*)
Glastransport();
Kippen();
Querfahrt();
Drehen();
END_ACTION