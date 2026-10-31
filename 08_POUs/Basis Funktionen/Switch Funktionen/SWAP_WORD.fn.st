(* METADATA
{
  "v3Meta": {
    "objectGuid": "f5bf0334-c8db-496d-a0a5-3bfc853a0111"
  }
}
*)
FUNCTION SWAP_WORD : WORD
VAR_INPUT

  (* BOOELAN *)
  wpWert : WORD;

END_VAR
VAR

  (* BYTE *)
  aInByte  : ARRAY [0..1] OF BYTE ;
  aOutByte : ARRAY [0..1] OF BYTE ;

END_VAR
SysMemCpy( ADR(aInByte), ADR(wpWert),2 );

aOutByte[0] := aInByte[1];
aOutByte[1] := aInByte[0];

SysMemCpy( ADR(SWAP_WORD), ADR(aOutByte),2 );
END_FUNCTION