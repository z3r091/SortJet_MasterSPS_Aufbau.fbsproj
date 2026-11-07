(* METADATA
{
	"v3Meta": {
		"objectGuid": "8ac789ad-b8f8-4460-adb8-3fa1c010b792"
	}
}
*)
FUNCTION WatchIoControl : BOOL
VAR_INPUT
  tpTimeOut      : TIME;
  wpControlIndex : WORD;
  bpStatus       : BOOL;
END_VAR
VAR
  blResult    : BOOL;
  tlLaufzeit  : TIME;
END_VAR

blResult := FALSE;

IF NOT bgDeaktiviereWatchIOs THEN
  aicgIoControl[ wpControlIndex ].tTimeOut := tpTimeOut;
  IF bpStatus THEN
    IF( aicgIoControl[ wpControlIndex ].tWatchStart > T#0ms )THEN

      tlLaufzeit := TIME() - aicgIoControl[ wpControlIndex ].tWatchStart;

      IF( tlLaufzeit >= aicgIoControl[ wpControlIndex ].tTimeOut )THEN
        SetIoControl( wpControlIndex );
        blResult := TRUE;
      END_IF

    ELSE
      // Überwachung starten
      aicgIoControl[ wpControlIndex ].tWatchStart := TIME();
    END_IF
  ELSE
    ResetIoControl( wpControlIndex := wpControlIndex );
  END_IF

END_IF

WatchIoControl := blResult;
END_FUNCTION