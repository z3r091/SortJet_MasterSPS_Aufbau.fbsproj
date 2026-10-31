(* METADATA
{
  "v3Meta": {
    "objectGuid": "1787c9d8-e07d-471d-967c-af403122e309"
  }
}
*)
METHOD checkStationsTyp
VAR_INPUT
  Basis : REFERENCE TO StationBasisParameter_ST;
END_VAR

// eStationsTyp prüfen - nicht 0
IF Basis.stMKs.eStationsTyp = 0 THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'eStationsTyp darf nicht 0 sein');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
  NullRef := TRUE;
END_IF
END_METHOD