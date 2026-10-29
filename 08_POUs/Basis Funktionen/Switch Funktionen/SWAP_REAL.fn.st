(* METADATA
{
	"v3Meta": {
		"objectGuid": "ba889dae-5568-4c09-9bf3-2bdc011b0f01"
	}
}
*)
FUNCTION SWAP_REAL : REAL
VAR_INPUT

  (* REAL *)
  rpWert : REAL;

END_VAR

VAR

  (* BYTE *)
  aInByte  : ARRAY [0..3] OF BYTE ;
  aOutByte : ARRAY [0..3] OF BYTE ;

END_VAR
SysMemCpy( ADR(aInByte), ADR(rpWert),4 );

(*
aOutByte[0] := aInByte[3];
aOutByte[1] := aInByte[2];
aOutByte[2] := aInByte[1];
aOutByte[3] := aInByte[0];
*)

aOutByte[0] := aInByte[1];
aOutByte[1] := aInByte[0];
aOutByte[2] := aInByte[3];
aOutByte[3] := aInByte[2];



SysMemCpy( ADR(SWAP_REAL), ADR(aOutByte),4 );
END_FUNCTION