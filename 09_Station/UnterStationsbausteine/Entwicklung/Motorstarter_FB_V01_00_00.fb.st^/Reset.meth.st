(* METADATA
{
	"v3Meta": {
		"objectGuid": "5e136676-7d5d-430e-b251-8802f4b156e4"
	}
}
*)
METHOD Reset : BOOL
VAR_INPUT


END_VAR

VAR
  tonlReset : TON;

END_VAR

tonlReset( IN := TRUE , PT :=  T#1500MS );
out_Reset := NOT tonlReset.Q;

Reset := bpMotorstarterOK;
END_METHOD