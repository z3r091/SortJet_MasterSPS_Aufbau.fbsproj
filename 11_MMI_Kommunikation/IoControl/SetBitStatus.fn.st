(* METADATA
{
  "v3Meta": {
    "objectGuid": "e3d893c7-2aa8-4b16-bd4f-cc2db28304fb"
  }
}
*)
FUNCTION SetBitStatus : BYTE
VAR_INPUT
  ucpValue : BYTE;
  wpBitPos : WORD;
  bpStatus : BOOL;
END_VAR
VAR
  uclRet : BYTE;
END_VAR
(* Bit in eine Word setzen *)
uclRet := ucpValue;

CASE wpBitPos OF

  0:uclRet.0  := bpStatus;

  1:uclRet.1  := bpStatus;

  2:uclRet.2  := bpStatus;

  3:uclRet.3  := bpStatus;

  4:uclRet.4  := bpStatus;

  5:uclRet.5  := bpStatus;

  6:uclRet.6  := bpStatus;

  7:uclRet.7  := bpStatus;

END_CASE

SetBitStatus := uclRet;
END_FUNCTION