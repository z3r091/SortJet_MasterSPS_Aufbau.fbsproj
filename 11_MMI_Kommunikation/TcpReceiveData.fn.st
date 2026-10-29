(* METADATA
{
	"v3Meta": {
		"objectGuid": "b74d4ba4-35aa-49dc-9263-31d6cf99974e"
	}
}
*)
FUNCTION TcpReceiveData : __XINT
(*
  Receive data from a TCP socket.
  Return: Number of bytes received or a value < 0 for an error (-1: gracefully closed; -2: error)
*)
VAR_INPUT
  diSocket: RTS_IEC_HANDLE; (* Socket-ID *)
  pbyData: POINTER TO DWORD; (* Address of data buffer *)
  diDataSize: DINT; (* Size of data to receive *)
  diTimeout: DINT; (* Timeout in ms *)
  tcpLastError : POINTER TO LINT;
END_VAR
VAR
END_VAR

TcpReceiveData := 0;

IF SocketIsReadable(diSocket, diTimeout) > 0 THEN
  TcpReceiveData := SysSockRecv(diSocket, pbyData, diDataSize, 0,0); (* Returns 0 if gracefully closed or -1 for an error*)
  IF TcpReceiveData <= 0 THEN
    TcpReceiveData := (*TcpReceiveData*) - 1;
    IF tcpLastError^ = 0 THEN
      tcpLastError^ := TcpReceiveData;
    END_IF
  END_IF
END_IF
END_FUNCTION