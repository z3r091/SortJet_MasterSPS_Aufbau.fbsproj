(* METADATA
{
	"v3Meta": {
		"objectGuid": "9ed7362d-6e8b-45fc-aaf5-a3cbb726335b"
	}
}
*)
FUNCTION AutomatikkreisBestimmen : Automatikkreis_EN
VAR_INPUT
  wpMmiNummer : WORD;
END_VAR
VAR
  Basis : REFERENCE TO StationBasisParameter_ST;
END_VAR

// Hinweis:
// - Erster Automatikkreis der Station (Shuttle, TS, Station, Faecherwagen, Fremdanlage) ueber getBasis
// - Unbekannte Nummer oder nicht zugewiesene MK => 0
AutomatikkreisBestimmen := 0;

Basis REF= getBasis( wpMmiNummer );

IF NOT __ISVALIDREF( Basis ) THEN
  RETURN;
END_IF

IF NOT __ISVALIDREF( Basis.stMKs ) THEN
  RETURN;
END_IF

AutomatikkreisBestimmen := Basis.stMKs.eaAutomatikkreis[cERSTER_AUTOMATIKKREIS];
END_FUNCTION