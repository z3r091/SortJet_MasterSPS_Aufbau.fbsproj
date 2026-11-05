(* METADATA
{
  "v3Meta": {
    "objectGuid": "12c9ac0e-b17a-4793-9910-dd4830696017"
  }
}
*)
FUNCTION_BLOCK Basic_Station_Aktion_FB_V01_00_00
(* Hinweis:
   - Basis der wandweisen Aktionen einer Station (Ein-, Aus-, Durch-, Vortransport, Messkopplung)
   - Je Wand eine Instanz, die Station ruft sie in einer Schleife ueber die Waende auf
   - Die Komponenten (Kippen, Hub, Verstellungen ...) gibt es je Station nur einmal; die abgeleiteten
     Bausteine bekommen sie als Referenz
*)
VAR_IN_OUT

  // STRUKT
  BasisStationsParameter : StationBasisParameter_ST;

END_VAR
VAR_OUTPUT

  // BOOL
  bpFehler : BOOL; // Status: Schrittkette steht im Fehler
  bpDrosselklappeOeffnen : BOOL; // Anforderung an die Station: Drosselklappe oeffnen, solange der Transport laeuft (die Station entscheidet ueber den Ausgang)

END_VAR
VAR_INPUT

  // BOOL
  bpAutomatikAktiv       : BOOL;
  bpGeblaeseAktiv        : BOOL;
  bpGeblaeseFehler       : BOOL; // Station: Motorschutz des Geblaeses ausgeloest (Station ohne Geblaese-Baustein)
  bpZielPositionErreicht : BOOL;

  // WORD
  wWand : WORD;

  // Bausteine
  Glastransport : REFERENCE TO Basic_Glastransport_FB_V01_00_00;

END_VAR
VAR

  // Steps_TE
  steplAktion : STEPS_TE;

END_VAR
;
END_FUNCTION_BLOCK