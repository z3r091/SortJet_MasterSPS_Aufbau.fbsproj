(* METADATA
{
	"v3Meta": {
		"objectGuid": "fdbd0502-3da4-4780-aa1a-b043617e0f01"
	}
}
*)
FUNCTION getRealShuttleMaxPos : REAL
VAR_INPUT
  wShuttleNummer : WORD;
END_VAR

getRealShuttleMaxPos := aShuttle[wShuttleNummer].Querfahrt.Antrieb.rpMaxPosition;
END_FUNCTION