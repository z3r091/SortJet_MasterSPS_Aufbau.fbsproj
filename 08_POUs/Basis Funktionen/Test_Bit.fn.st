(* METADATA
{
  "v3Meta": {
    "objectGuid": "11f8d1c7-e430-45e8-b008-435e58887318"
  }
}
*)
FUNCTION Test_Bit : Bool
VAR_INPUT
  in  : WORD; // Die Eingangsvariable (z. B. BYTE, WORD, DWORD)
  b   : WORD;    // Die zu prüfende Bitposition
END_VAR
VAR
  W   : WORD := 1;
END_VAR

;
END_FUNCTION