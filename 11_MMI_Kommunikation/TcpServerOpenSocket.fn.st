(* METADATA
{
	"v3Meta": {
		"objectGuid": "36dfe783-e7c1-434c-babf-2b0976501267"
	}
}
*)
FUNCTION TcpServerOpenSocket : RTS_IEC_HANDLE
//  Opens a TCP server socket.
//  Return: Socket-ID
VAR_INPUT
  uiPort: UINT; // Port number
  diMaxConnections: DINT; // Max possible client connections of the server
END_VAR
VAR
  hSocket: RTS_IEC_HANDLE;
  pResult: RTS_IEC_RESULT;
  uiResult: UDINT;
  uiCloseResult: UDINT;
  sa: SOCKADDRESS;
  dwValue: DWORD := 1;
END_VAR


hSocket := SysSockCreate(SOCKET_AF_INET, SOCKET_STREAM, SOCKET_IPPROTO_TCP, ADR(pResult));

IF hSocket <> RTS_INVALID_HANDLE THEN
  SysSockSetOption(hSocket, SOCKET_SOL, SOCKET_SO_REUSEADDR, ADR(dwValue), SIZEOF(dwValue));
  sa.sin_family     := SOCKET_AF_INET;
  sa.sin_addr.ulAddr := SOCKET_INADDR_ANY;
  sa.sin_port       := SysSockHtons(uiPort);
  uiResult       := SysSockBind(hSocket, ADR(sa), SIZEOF(sa));

  IF uiResult <> CmpErrors.Errors.ERR_OK THEN
    uiCloseResult := SysSockClose(hSocket);
    hSocket := RTS_INVALID_HANDLE;
  ELSE
    uiResult := SysSockListen(hSocket, diMaxConnections);
    IF uiResult <> CmpErrors.Errors.ERR_OK THEN
      uiCloseResult := SysSockClose(hSocket);
      hSocket := RTS_INVALID_HANDLE;
    END_IF
  END_IF
END_IF
TcpServerOpenSocket := hSocket;
END_FUNCTION