(* METADATA
{
	"v3Meta": {
		"objectGuid": "61da6f1d-6d44-4478-83af-d8c1dc57ab14"
	}
}
*)
METHOD checkAchsID
VAR_INPUT
  wAchsID : REFERENCE TO WORD;
END_VAR
VAR
  cLOG_HANDLE : RTS_IEC_HANDLE := RTS_INVALID_HANDLE;
END_VAR
IF NOT __ISVALIDREF(wAchsID) THEN
  RETURN;
END_IF

IF wAchsID = 65 THEN
  RETURN; // explizit erlaubt
END_IF;

IF wAchsID > 65 THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'Konfigurationsfehler: Konfigurierte AchsID zu groß');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE); // AchsID ist zu groß
  NullRef := TRUE; // Falls die obenstehende Exception nicht auslöst, auf eine NullReferenz zugreifen -> Exception auch in Simulation.
END_IF

IF aUsedAchsIDs[wAchsID] THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'Konfigurationsfehler: AchsID mehrfach vergeben');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE); // AchsID bereits in benutzung!
  NullRef := TRUE; // Falls die obenstehende Exception nicht auslöst, auf eine NullReferenz zugreifen -> Exception auch in Simulation.
END_IF

aUsedAchsIDs[wAchsID] := TRUE;
END_METHOD