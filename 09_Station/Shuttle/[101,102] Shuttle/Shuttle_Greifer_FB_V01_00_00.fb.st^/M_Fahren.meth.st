(* METADATA
{
	"v3Meta": {
		"objectGuid": "e13d7eec-f935-4189-863d-44ba43cdb40b"
	}
}
*)
METHOD PRIVATE M_Fahren
VAR_INPUT
  epBetriebsart     : AntriebsBetriebsart_EN; // ABSOLUT, RELATIV, HANDPLUS, HANDMINUS
  rpZielPosition    : REAL;                   // Ziel [mm] bzw. relativer Weg bei RELATIV
  rpGeschwindigkeit : REAL;                   // [mm/s]
END_VAR

(* Hinweis:
   - Fahrauftrag an die Greiferachse mit maximaler Beschleunigung / Verzoegerung
*)
Antrieb.rpZielPosition    := rpZielPosition;
Antrieb.rpGeschwindigkeit := rpGeschwindigkeit;
Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
Antrieb.wpBetriebsart     := epBetriebsart;
END_METHOD