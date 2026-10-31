(* METADATA
{
  "v3Meta": {
    "objectGuid": "b3622f19-1aaf-4182-891a-040c2736cdb4"
  }
}
*)
METHOD checkAutomatikkreis
VAR_INPUT
  Basis : REFERENCE TO StationBasisParameter_ST;
END_VAR
VAR
  x : WORD;
  bAutomatikkreisGefunden : BOOL;
  eaAutomatikkreis : ARRAY [cERSTER_AUTOMATIKKREIS..cANZAHL_AUTOMATIKKREISE] OF BOOL;
END_VAR

// eaAutomatikkreis prüfen - mindestens ein AK muss gesetzt sein und nur vorhandene Automatikkreise dürfen gesetzt sein

bAutomatikkreisGefunden := FALSE;

FOR x := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
  IF Basis.stMKs.eaAutomatikkreis[x] <> 0 THEN
    bAutomatikkreisGefunden := TRUE;
  END_IF
END_FOR
IF NOT bAutomatikkreisGefunden THEN
  CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, 0, 'Kein Automatikkreis konfiguriert');
  SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
  NullRef := TRUE;
END_IF

FOR x := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
  IF Basis.stMKs.eaAutomatikkreis[x] <> 0 THEN
    IF ( Basis.stMKs.eaAutomatikkreis[x] < cERSTER_AUTOMATIKKREIS ) OR ( Basis.stMKs.eaAutomatikkreis[x] > cLETZTER_AUTOMATIKKREIS ) THEN
      CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000010, Basis.stMKs.eaAutomatikkreis[x], 'Automatikkreis existiert nicht');
      SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
      NullRef := TRUE;
    END_IF
  END_IF
END_FOR
END_METHOD