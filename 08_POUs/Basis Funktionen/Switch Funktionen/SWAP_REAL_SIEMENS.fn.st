(* METADATA
{
	"v3Meta": {
		"objectGuid": "24a74364-fccd-4a66-8b87-fbfc150829ad"
	}
}
*)
FUNCTION SWAP_REAL_SIEMENS : REAL
VAR_INPUT

  // REAL
  rpWert : REAL;

END_VAR

VAR

  // BYTE
  aInByte  : ARRAY [0..3] OF BYTE ;
  aOutByte : ARRAY [0..3] OF BYTE ;

END_VAR
SysMemCpy( ADR(aInByte), ADR(rpWert),4 );

aOutByte[0] := aInByte[2];
aOutByte[1] := aInByte[3];
aOutByte[2] := aInByte[0];
aOutByte[3] := aInByte[1];
SysMemCpy( ADR(SWAP_REAL_SIEMENS), ADR(aOutByte),4 );
END_FUNCTION