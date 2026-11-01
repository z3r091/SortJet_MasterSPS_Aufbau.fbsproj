(* METADATA
{
  "v3Meta": {
    "objectGuid": "389b713c-1c94-40ba-a43c-d7e5339b8bcd"
  }
}
*)
FUNCTION SWAP_DWORD : DWORD
VAR_INPUT

  // REAL
  dwpWert : DWORD;

END_VAR

VAR

  // BYTE
  aInByte  : ARRAY [0..3] OF BYTE ;
  aOutByte : ARRAY [0..3] OF BYTE ;

END_VAR
SysMemCpy( ADR(aInByte), ADR(dwpWert),4 );

aOutByte[0] := aInByte[3];
aOutByte[1] := aInByte[2];
aOutByte[2] := aInByte[1];
aOutByte[3] := aInByte[0];

SysMemCpy( ADR(SWAP_DWORD), ADR(aOutByte),4 );
END_FUNCTION