(* METADATA
{
	"v3Meta": {
		"objectGuid": "13f78e6e-ca3a-4dd4-bc80-ae0752972bf6"
	}
}
*)
ACTION StarteTouchprobeFunktion
// Über CoE an den Umrichter die Messtaster / Touchprobe Funktionen aktivieren, sobald dieser im Bus erreichbar ist
uilSchreibeUeberCoeTouchProbe := 13107;
l_fb_CoeTouchProbeSchreiben
  (
    i_by_EcID      := 1000+l_ts_MKAxisConfig.uiDeviceAddress,
    i_w_ObjectNum  := 16#60B8,
    i_by_SubIndex  := 0,
    i_w_DataTyp    := 6,
    i_p_Var        := ADR(uilSchreibeUeberCoeTouchProbe),
    i_w_BufSize    := SIZEOF(uilSchreibeUeberCoeTouchProbe),
  );
IF NOT uiTouchProbeStatus.0 AND NOT l_fb_CoeTouchProbeSchreiben.i_b_Execute AND NOT blTouchprobeScheibenAktiv THEN
  l_fb_CoeTouchProbeSchreiben( i_b_Execute := TRUE );
  blTouchprobeScheibenAktiv := TRUE;
END_IF

// Wenn die Touchprobe nicht rechtzeitig aktiv wird, CoE-Schreibbaustein zurücksetzen und neu starten
tonlTouchprobeNeustart( IN := blTouchprobeScheibenAktiv AND NOT uiTouchProbeStatus.0, PT := cTIME_TOUCHPROBE_NEUSTART );
IF tonlTouchprobeNeustart.Q THEN
  l_fb_CoeTouchProbeSchreiben( i_b_Execute := FALSE, i_b_Reset := TRUE );
  blTouchprobeScheibenAktiv := FALSE;
  tonlTouchprobeNeustart( IN := FALSE );
END_IF
END_ACTION