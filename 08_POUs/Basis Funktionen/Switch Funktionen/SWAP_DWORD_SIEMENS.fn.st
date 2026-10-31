(* METADATA
{
  "v3Meta": {
    "objectGuid": "2a9c4065-11ba-4ec5-a5c1-2bac7310293a"
  }
}
*)
FUNCTION SWAP_DWORD_SIEMENS : DWORD
VAR_INPUT

  (* REAL *)
  dwpWert : DWORD;

END_VAR

VAR

  (* BYTE *)
  aInByte  : ARRAY [0..3] OF BYTE ;
  aOutByte : ARRAY [0..3] OF BYTE ;

END_VAR
SysMemCpy( ADR(aInByte), ADR(dwpWert),4 );

aOutByte[0] := aInByte[1];
aOutByte[1] := aInByte[0];
aOutByte[2] := aInByte[3];
aOutByte[3] := aInByte[2];

SysMemCpy( ADR(SWAP_DWORD_SIEMENS), ADR(aOutByte),4 );
END_FUNCTION