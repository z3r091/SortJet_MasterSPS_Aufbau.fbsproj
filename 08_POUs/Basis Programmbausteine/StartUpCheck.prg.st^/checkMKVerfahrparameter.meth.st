(* METADATA
{
  "v3Meta": {
    "objectGuid": "c7964ec2-357c-46cb-95df-ee4bc270f3f8"
  }
}
*)
METHOD checkMKVerfahrparameter
VAR_INPUT
END_VAR
VAR
  x : WORD;
END_VAR

FOR x := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
    IF ( apgShuttleVerfahrparameter[x].eParkposition = 0 ) THEN
        CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000020, 0, 'apgShuttleVerfahrparameter steht auf Default');
        SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
        NullRef := TRUE;
    END_IF
END_FOR
FOR x := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
    IF ( apgTransfershuttleVerfahrparameter[x].eParkposition = 0 ) THEN
        CmpLog.LogAdd2(cLOG_HANDLE, 16#00010000, 16#00000001, 16#00000021, 0, 'apgTransfershuttleVerfahrparameter steht auf Default');
        SysExceptGenerateException(RtsExceptions.RTSEXCPT_NONCONTINUABLE);
        NullRef := TRUE;
    END_IF
END_FOR
END_METHOD