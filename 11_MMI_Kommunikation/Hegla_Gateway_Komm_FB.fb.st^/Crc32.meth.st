(* METADATA
{
  "v3Meta": {
    "objectGuid": "6b6b9ff1-a382-43e7-9f9f-17942cf7a836"
  }
}
*)
METHOD Crc32 : DWORD
VAR_INPUT
  pbpValue : POINTER TO BYTE;
   dwpSize  : DWORD;
END_VAR
VAR
  dwlCrc  : DWORD := 16#FFFFFFFF;
  ilIndex : INT;
END_VAR

(* Funktion zur Berechnung einer CRC32-Prüfsumme *)
dwlCrc := 16#FFFFFFFF;


FOR ilIndex:=1 TO DWORD_TO_INT( dwpSize (*-2*) ) DO
  dwlCrc := SHR(dwlCrc, 8) XOR adwgCrcTable[ ( dwlCrc AND 16#FF ) XOR pbpValue^ ];
  pbpValue := pbpValue + 1;
END_FOR

dwlCrc := dwlCrc XOR 16#FFFFFFFF;

Crc32 := dwlCrc;
END_METHOD