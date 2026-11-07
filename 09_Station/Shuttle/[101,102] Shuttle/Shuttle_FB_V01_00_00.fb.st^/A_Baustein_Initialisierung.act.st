(* METADATA
{
	"v3Meta": {
		"objectGuid": "c0a5a054-7b97-4a36-8c19-6c7df892d50a"
	}
}
*)
ACTION A_Baustein_Initialisierung
//-------------------------------------------------------------------------------------------------
// BAUSTEIN INITIALISIERUNG
//-------------------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
//  ZUWEISUNGEN
//
//  Hinweis:
// - Null-Pointer-Exception vermeiden
// ---------------------------------------------------------------------------------------

(* Hinweis:
   - POINTER der Bausteine [Geblaese, Scheibenmessung, Glastransport, Stoessel, Querfahrt , etc]:
*)
Zentralschmierung.ppParameterBaustein                 REF= BasisStationsParameter.stParameterStationskomponenten.stZentralSchmierung;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Greifer[wlIndex].ppParameterGreifer                 REF= BasisStationsParameter.stParameterStationskomponenten.stGreifer[wlIndex];
  Glastransport[wlIndex].ppParameterBaustein          REF= BasisStationsParameter.stParameterStationskomponenten.stGlastransportShuttle[wlIndex];
  Kippen.ppParameterBaustein                          REF= BasisStationsParameter.stParameterStationskomponenten.stKippen[wlIndex];
  Wandverstellung[wlIndex].ppParameterBaustein        REF= BasisStationsParameter.stParameterStationskomponenten.stWandverstellung[wlIndex];
END_FOR

(* Hinweis:
   - Antriebsinformationen [Geblaese, Scheibenmessung, Glastransport]:
*)
Querfahrt.ppAntriebsInformationen                      REF= BasisStationsParameter.stAntriebsparameter.stQuerfahrt;
Kippen.ppAntriebsInformationen                         REF= BasisStationsParameter.stAntriebsparameter.stKippen;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Greifer[wlIndex].ppAntriebsInformationen             REF= BasisStationsParameter.stAntriebsparameter.stGreifer[wlIndex];
  Glastransport[wlIndex].ppAntriebsInformationen       REF= BasisStationsParameter.stAntriebsparameter.stGlastransport[wlIndex];
  Glastransport[wlIndex].ppAntriebsInformationenSlave  REF= BasisStationsParameter.stAntriebsparameter.stGlastransportSlave[wlIndex];
  Wandverstellung[wlIndex].ppAntriebsInformationen     REF= BasisStationsParameter.stAntriebsparameter.stWandverstellung[wlIndex];
END_FOR

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
   - Geblaese
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Geblaese[wlIndex].bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGeblase[wlIndex];
END_FOR

(* Hinweis:
   - Riemen
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Glastransport[wlIndex].bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGlastransport[wlIndex];
END_FOR

(* Hinweis:
   - Glasfuehrung
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Wandverstellung[wlIndex].bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bTransportVerstellung[wlIndex];
END_FOR

(* Hinweis:
   - Kippen
*)
Kippen.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1];

// Aktivierungen
Zentralschmierung.bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bDLSSchmiersystem;

(* Hinweis:
   - Greifer [Ausbaustufe]: Parameter und Antriebsinformationen nur zuweisen, wenn der Greifer vorhanden ist
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Greifer[wlIndex].bpAktivieren := BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex];
END_FOR

(* Hinweis:
   - Einige Bausteine einmalig aufrufen damit die Referenz auf Antriebe geschrieben wird
*)
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  Greifer[wlIndex]( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
  Glastransport[wlIndex]( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
  Wandverstellung[wlIndex]( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
END_FOR
Kippen( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
Querfahrt( stStationsNummern := BasisStationsParameter.stMKs.stStationsNummern );
END_ACTION