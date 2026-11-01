(* METADATA
{
  "v3Meta": {
    "objectGuid": "3b6ea6e4-8fcd-474b-9f1e-9c8a8e0a159e"
  }
}
*)
FUNCTION GetBitStatus : BOOL
VAR_INPUT
  wpWatchIoNr : WORD;
END_VAR
VAR
  wlByteIndex : WORD;
  wlBitIndex : WORD;
  uclRet   : BYTE;
  ucpValue : BYTE;
END_VAR
wlByteIndex := wpWatchIoNr / 8;
wlBitIndex  := wpWatchIoNr MOD 8;


ucpValue := TCPMain.l_fb_SortjetHMI.SpsToMmi.aucControlSystem[ wlByteIndex ];

uclRet := ucpValue;

CASE wlBitIndex OF

  0: GetBitStatus := uclRet.0;

  1: GetBitStatus := uclRet.1;

  2: GetBitStatus := uclRet.2;

  3: GetBitStatus := uclRet.3;

  4: GetBitStatus := uclRet.4;

  5: GetBitStatus := uclRet.5;

  6: GetBitStatus := uclRet.6;

  7: GetBitStatus := uclRet.7;

END_CASE
END_FUNCTION