(* METADATA
{
	"v3Meta": {
		"objectGuid": "dfcb45a0-2101-41d2-aaa7-f1a51c527b1b"
	}
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Geblaese_Motorstarter_FB_V01_00_00 EXTENDS Geblaese_Schuetz_FB_V01_00_00
VAR_INPUT

END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR

//-------------------------------------------------------------------------------------------------
// MASTER AUFRUFEN
//-------------------------------------------------------------------------------------------------
SUPER^(BasisStationsParameter := BasisStationsParameter);
END_FUNCTION_BLOCK