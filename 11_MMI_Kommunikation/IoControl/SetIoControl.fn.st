(* METADATA
{
  "v3Meta": {
    "objectGuid": "cdf47146-760f-48c9-a8df-c674983d5b70"
  }
}
*)
FUNCTION SetIoControl : BOOL
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


ucValue := TCPMain.l_fb_SortjetHMI.SpsToMmi.aucControlSystem[ wlByteIndex ];

ucValue := SetBitStatus( ucValue, wlBitIndex, TRUE );

TCPMain.l_fb_SortjetHMI.SpsToMmi.aucControlSystem[ wlByteIndex ] := ucValue;

SetIoControl := TRUE;
END_FUNCTION