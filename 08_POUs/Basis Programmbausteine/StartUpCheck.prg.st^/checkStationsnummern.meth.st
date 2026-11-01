(* METADATA
{
  "v3Meta": {
    "objectGuid": "577e9539-3133-4f06-80f9-5ab9a23fcb59"
  }
}
*)
METHOD checkStationsnummern
VAR_INPUT
  Basis : REFERENCE TO StationBasisParameter_ST;
END_VAR

// stStationsNummern prüfen - keine 0 keine doppelt vergeben
IF Basis.stMKs.stStationsNummern.NummerIntern = 0 THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'StationsNummer Intern darf nicht 0 sein');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
  NullRef := TRUE;
END_IF
IF aUsedStationNrIntern[Basis.stMKs.stStationsNummern.NummerIntern] THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'StationsNummer Intern doppelt vergeben');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
  NullRef := TRUE;
END_IF
aUsedStationNrIntern[Basis.stMKs.stStationsNummern.NummerIntern] := TRUE;

IF Basis.stMKs.stStationsNummern.NummerSPS = 0 THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'StationsNummer SPS darf nicht 0 sein');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
  NullRef := TRUE;
END_IF
IF aUsedStationNrSPS[Basis.stMKs.stStationsNummern.NummerSPS] THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'StationsNummer SPS doppelt vergeben');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
  NullRef := TRUE;
END_IF
aUsedStationNrSPS[Basis.stMKs.stStationsNummern.NummerSPS] := TRUE;

// INFO: Extern kann nicht geprüft werden, da undefinierter Nummernkreis!
END_METHOD