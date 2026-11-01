(* METADATA
{
  "v3Meta": {
    "objectGuid": "c3a65185-b6f7-4978-83ae-2e8140594d8c"
  }
}
*)
FUNCTION TcpSendData : __XINT
//  Send data via TCP socket.
//  Return: Number of bytes sent or a value < 0 for an error (-1: gracefully closed; -2: error)
VAR_INPUT
  diSocket: RTS_IEC_HANDLE; // Socket-ID
  pbyData: POINTER TO DWORD; // Address of data buffer
  diDataSize: DINT; // Size of data to send
  tcpLastError : POINTER TO LINT;
END_VAR
VAR
  iecResult : RTS_IEC_RESULT;
END_VAR

TcpSendData := SysSockSend(diSocket, pbyData, diDataSize, SOCKET_MSG_DONTWAIT, ADR(iecResult));
IF iecResult = CmpErrors.Errors.ERR_SOCK_WOULDBLOCK THEN
  TcpSendData := 0;
ELSE
  IF TcpSendData < 0 AND TcpSendData <> -6 AND TcpSendData <> -1 THEN
    TcpSendData := (*TcpSendData*) - 1;

    IF tcpLastError^ = 0 THEN
      tcpLastError^ := TcpSendData;
    END_IF
  END_IF
END_IF
END_FUNCTION