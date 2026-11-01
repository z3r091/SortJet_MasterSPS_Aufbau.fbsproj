(* METADATA
{
  "v3Meta": {
    "objectGuid": "9bbc4f4b-7c56-4bbd-9f87-a841e4609bac"
  }
}
*)
FUNCTION WatchIo : BOOL
VAR_INPUT
  bpStatus : BOOL;
  wpControlIndex : WORD;
END_VAR
VAR
  wlByteIndex : WORD;
  wlBitIndex  : WORD;
  ucValue     : BYTE;
END_VAR
IF NOT bgDeaktiviereWatchIOs THEN
  IF bpStatus <> GetBitStatus(wpControlIndex) THEN
    wlByteIndex := wpControlIndex / 8;
    wlBitIndex  := wpControlIndex MOD 8;
    (* Meldungsbit zurücksetzen *)
    ucValue := TCPMain.l_fb_SortjetHMI.SpsToMmi.aucControlSystem[ wlByteIndex ];
    IF bpStatus THEN
      ucValue := SetBitStatus( ucValue, wlBitIndex, TRUE );
    ELSE
      aicgIoControl[ wpControlIndex ].tWatchStart := T#0MS;
      ucValue := SetBitStatus( ucValue, wlBitIndex, FALSE );
    END_IF
    TCPMain.l_fb_SortjetHMI.SpsToMmi.aucControlSystem[ wlByteIndex ] := ucValue;
  END_IF
END_IF
END_FUNCTION