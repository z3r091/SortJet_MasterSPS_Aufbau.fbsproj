(* METADATA
{
  "v3Meta": {
    "objectGuid": "22b8b65b-6376-41dd-ab5a-bf0c9c2eeadd"
  }
}
*)
METHOD checkDurchgaenge
VAR_INPUT
END_VAR
VAR
  x : WORD;
END_VAR

FOR x := cERSTER_DURCHGANG TO cANZAHL_DURCHGANGE DO
  IF apgMKDurchgang[x].eDurchgang = 0 THEN
    CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000060, x, 'apgMKDurchgang: Durchgang nicht definiert');
    SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
    NullRef := TRUE;
  END_IF
END_FOR
END_METHOD