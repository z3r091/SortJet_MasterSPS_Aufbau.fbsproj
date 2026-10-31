(* METADATA
{
  "v3Meta": {
    "objectGuid": "60b6ea4b-319e-4cbc-b276-a980379624c0"
  }
}
*)
FUNCTION SWAP_DINT : DINT
VAR_INPUT

  (* REAL *)
  dipWert : DINT;

END_VAR

VAR

  (* BYTE *)
  aInByte  : ARRAY [0..3] OF BYTE ;
  aOutByte : ARRAY [0..3] OF BYTE ;

END_VAR
SysMemCpy( ADR(aInByte), ADR(dipWert),4 );

aOutByte[0] := aInByte[2];
aOutByte[1] := aInByte[3];
aOutByte[2] := aInByte[0];
aOutByte[3] := aInByte[1];

SysMemCpy( ADR(SWAP_DINT), ADR(aOutByte),4 );
END_FUNCTION