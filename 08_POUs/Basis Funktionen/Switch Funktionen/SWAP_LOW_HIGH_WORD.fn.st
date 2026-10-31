(* METADATA
{
  "v3Meta": {
    "objectGuid": "88f4a337-90ad-4f2e-9ea2-c1124a4e2a48"
  }
}
*)
FUNCTION SWAP_LOW_HIGH_WORD : DWORD
VAR_INPUT
  IN : DWORD;
END_VAR
VAR
END_VAR
(* Hinweis:
   Diese Funktion tauscht das LOW-WORD und das HIGH- WORD;
*)
SWAP_LOW_HIGH_WORD := ROL(IN, 16);
END_FUNCTION