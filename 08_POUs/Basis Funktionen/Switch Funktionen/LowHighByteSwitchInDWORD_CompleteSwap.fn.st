(* METADATA
{
  "v3Meta": {
    "objectGuid": "8525d255-55de-4882-b974-c7e29f794d79"
  }
}
*)
FUNCTION LowHighByteSwitchInDWORD_CompleteSwap : DWORD
VAR_INPUT

  dwInputWord : DWORD;

END_VAR
VAR

  dwByte1 : DWORD;
  dwByte2 : DWORD;
  dwByte3 : DWORD;
  dwByte4 : DWORD;

END_VAR
dwByte1 :=SHR(dwInputWord,24);

dwByte2  :=SHL(dwInputWord,8);
dwByte2  :=SHR(dwByte2,24);
dwByte2  :=SHL(dwByte2,8);

dwByte3  :=SHL(dwInputWord,16);
dwByte3  :=SHR(dwByte3,24);
dwByte3  :=SHL(dwByte3,16);

dwByte4  :=SHL(dwInputWord,24);


LowHighByteSwitchInDWORD_CompleteSwap := dwByte1 OR dwByte2 OR dwByte3 OR dwByte4;
END_FUNCTION