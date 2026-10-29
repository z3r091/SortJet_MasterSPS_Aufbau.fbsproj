(* METADATA
{
	"v3Meta": {
		"objectGuid": "b642c49f-6ffa-4fce-b10f-dd7fb5dad387"
	}
}
*)
METHOD checkMeldungsnummer
VAR_INPUT
  Basis : REFERENCE TO StationBasisParameter_ST;
END_VAR

// wMeldungsnummer prüfen - nicht 0 und nicht doppelt vergeben
IF Basis.stMKs.wMeldungsnummer = 0 THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'wMeldungsnummer darf nicht 0 sein');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
  NullRef := TRUE;
END_IF
IF aUsedMeldungsnummern[Basis.stMKs.wMeldungsnummer] THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'wMeldungsnummer mehrfach konfiguriert');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
  NulLRef := TRUE;
END_IF
aUsedMeldungsnummern[Basis.stMKs.wMeldungsnummer] := TRUE;
END_METHOD