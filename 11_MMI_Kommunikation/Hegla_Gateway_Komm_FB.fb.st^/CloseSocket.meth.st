(* METADATA
{
  "v3Meta": {
    "objectGuid": "9f82718f-b1e3-4bef-8f71-7bc3b9baf787"
  }
}
*)
METHOD CloseSocket : BOOL
//  Closes a socket and sets it invalid.
//  Return: Success of operation
VAR_INPUT
  hSocket: POINTER TO RTS_IEC_HANDLE; // Address of Socket-ID  
END_VAR
VAR
  uiResult : UDINT;
END_VAR
CloseSocket := FALSE;
IF ( hSocket <> 0 ) AND ( hSocket^ <> RTS_INVALID_HANDLE )
THEN
  uiResult:= SysSockClose(hSocket^);
  IF uiResult = CmpErrors.Errors.ERR_OK 
  THEN
    CloseSocket:= TRUE;
  ELSE
    CloseSocket:= FALSE;
  END_IF
  hSocket^:= RTS_INVALID_HANDLE;
END_IF
END_METHOD