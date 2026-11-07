(* METADATA
{
	"v3Meta": {
		"objectGuid": "1e7d8eb1-23f2-478f-a0da-97a7b6d734ce"
	}
}
*)
METHOD checkSicherheitskreiseMK
VAR_INPUT
END_VAR
VAR
  x : WORD;
END_VAR

FOR x := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO
  IF apgMKSicherheiskreis[x].eSicherheitskreis = 0 THEN
    CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000050, x, 'apgMKSicherheiskreis: Sicherheitskreis nicht definiert');
    SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
    NullRef := TRUE;
  END_IF
END_FOR
END_METHOD