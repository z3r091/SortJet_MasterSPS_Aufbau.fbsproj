(* METADATA
{
  "v3Meta": {
    "objectGuid": "0cffa44a-96d6-4cd8-9f3c-3120d05aae22"
  }
}
*)
FUNCTION SocketIsReadable : UDINT
//  Function to detect if data for reading is available on socket.
//  Return: Availability of data
VAR_INPUT
  hSocket: RTS_IEC_HANDLE; // Socket-ID
  diTimeout : DINT; // Timeout in ms
END_VAR
VAR
  fdRead: SysSocket.SOCKET_FD_SET;
  tvTimeout: SysSocket.SOCKET_TIMEVAL;
  diSysSockSelect_Return : UDINT;
  diReadySockets : DINT;
END_VAR

tvTimeout.tv_sec := diTimeout / 1000;
tvTimeout.tv_usec := (diTimeout MOD 1000) * 1000;
fdRead.fd_count := 1;
fdRead.fd_array[0] := hSocket;

diReadySockets := 0;
diSysSockSelect_Return := SysSockSelect(UDINT_TO_DINT(fdRead.fd_count), ADR(fdRead), 0, 0, ADR(tvTimeout), ADR(diReadySockets));
IF diSysSockSelect_Return = CmpErrors.Errors.ERR_OK THEN
  IF diReadySockets > 0 THEN
    SocketIsReadable := 1;
  ELSE
    SocketIsReadable := 0;
  END_IF
ELSE
  SocketIsReadable := 0;
END_IF
END_FUNCTION