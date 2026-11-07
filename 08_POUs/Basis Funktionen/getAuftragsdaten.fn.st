(* METADATA
{
	"v3Meta": {
		"objectGuid": "e09c3e56-23fc-432f-9a18-960dccfa6275"
	}
}
*)
FUNCTION getAuftragsdaten : REFERENCE TO Auftragsdaten_ST
VAR_INPUT

  // WORD
  wpMmiNummer  : WORD; // Stationsnummer, deren aktueller Auftrag geliefert werden soll
  wpWand       : WORD; // Wand (nur Shuttles und Stationen)

END_VAR
// Hinweis:
// - Gegenstueck zu getBasis: liefert den aktuellen Job-Auftrag einer Station
// - Ungueltige Nummer oder Wand => ungueltige Referenz (Aufrufer prueft mit __ISVALIDREF)
CASE wpMmiNummer OF

  cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
    IF ( PruefungWertImIntervall( wpWand, cWAND_1, cANZAHL_WAENDE ) ) THEN
      getAuftragsdaten REF= Job_Shuttle.AuftragsdatenWand[wpMmiNummer, wpWand];
    END_IF

  cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
    getAuftragsdaten REF= Job_Shuttle.AuftragsdatenTransfershuttle[wpMmiNummer];

  cERSTE_STATION..cLETZTE_STATION:
    IF ( PruefungWertImIntervall( wpWand, cWAND_1, cANZAHL_WAENDE ) ) THEN
      getAuftragsdaten REF= Job_Stationen.AuftragsdatenWand[wpMmiNummer, wpWand];
    END_IF

  cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_EINLAUF:
    getAuftragsdaten REF= Job_Fremdanlage.AuftragsdatenFremdanlage[wpMmiNummer];

END_CASE
END_FUNCTION