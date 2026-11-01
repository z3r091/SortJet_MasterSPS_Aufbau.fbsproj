(* METADATA
{
  "v3Meta": {
    "objectGuid": "57b43017-bb28-437d-982e-b60f799a1ca9"
  }
}
*)
FUNCTION ResetIoControl : BOOL
VAR_INPUT
  wpControlIndex : WORD;
END_VAR
VAR
  wlByteIndex : WORD;
  wlBitIndex  : WORD;
  ucValue     : BYTE;
END_VAR

wlByteIndex := wpControlIndex / 8;
wlBitIndex  := wpControlIndex MOD 8;


(* Überwachung deaktivieren *)
aicgIoControl[ wpControlIndex ].tWatchStart := T#0ms;

(* Meldungsbit zurücksetzen *)
ucValue := TCPMain.l_fb_SortjetHMI.SpsToMmi.aucControlSystem[ wlByteIndex ];
ucValue := SetBitStatus( ucValue, wlBitIndex, FALSE );
TCPMain.l_fb_SortjetHMI.SpsToMmi.aucControlSystem[ wlByteIndex ] := ucValue;
END_FUNCTION