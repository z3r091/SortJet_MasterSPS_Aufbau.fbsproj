(* METADATA
{
	"v3Meta": {
		"objectGuid": "4f81610e-119d-462b-b6ef-1c5c06c97f10"
	}
}
*)
METHOD checkAutomatikkreiseMK
VAR_INPUT
END_VAR
VAR
  x : WORD;
END_VAR
FOR x := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  IF apgMKAutomatikkreise[x].epAutomatikkreis_Transfershuttle = 0 THEN
    CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000040, x, 'apgMKAutomatikkreise: Automatikkreis nicht definiert');
    SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
    NullRef := TRUE;
  END_IF
END_FOR
END_METHOD