(* METADATA
{
	"v3Meta": {
		"objectGuid": "a4b12c85-33d1-4e58-8fdf-3218a4b905e2"
	}
}
*)
FUNCTION_BLOCK PositionierAuftragsdatenPruefen
VAR_INPUT

  // STRUCT
  pPositionierAuftragsdaten  : PositionierAuftrag_ST; // Daten fur die Positionierung [Rampen / Soll- Position / Soll- Geschwindigkeit / Stromwerte
  pAntriebsinformationen     : AntriebsInformationen;

END_VAR

VAR_OUTPUT

  // BOOLEAN
  bpErgebnis  : BOOL; // Rueckgabewert der Funktion

END_VAR

VAR

END_VAR
// Zentralestelle zum Ueberpruefen der Verfahrauftragsdaten [Positionieren]

bpErgebnis := TRUE;

Positionen();
// Rampen();
//Geschwindigkeit();
END_FUNCTION_BLOCK