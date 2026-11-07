(* METADATA
{
	"v3Meta": {
		"objectGuid": "478effab-2bb6-4cba-a63b-7b7e6c506f75"
	}
}
*)
FUNCTION VisuUeb_MmText : STRING(40)
VAR_INPUT
  sPrefix : STRING(20);
  rWert   : REAL;
  sEinheit: STRING(10) := ' mm';
END_VAR
VisuUeb_MmText := CONCAT(CONCAT(sPrefix, DINT_TO_STRING(REAL_TO_DINT(rWert))), sEinheit);
END_FUNCTION