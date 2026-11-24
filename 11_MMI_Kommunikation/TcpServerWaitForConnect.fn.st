(* METADATA
{
	"v3Meta": {
		"objectGuid": "244699a7-7b28-4ca6-ad52-b215d0417df3"
	}
}
*)
FUNCTION TcpServerWaitForConnect : TCP_CLIENT_ACCEPT
//  Wait for a client to connect.
//  Return: Socket and IP-Address of connected client
VAR_INPUT
  hSocket: RTS_IEC_HANDLE; // Socket-ID
  diTimeout: DINT; // Timeout in ms
END_VAR
VAR
  pResult: RTS_IEC_RESULT;
  sa: SOCKADDRESS;
  ia: INADDR;
  diSize: DINT;
END_VAR

TcpServerWaitForConnect.hSocket := RTS_INVALID_HANDLE;
TcpServerWaitForConnect.stIPAddress := '';

IF SocketIsReadable(hSocket, diTimeout) > 0 THEN
  diSize := SIZEOF(sa);
  TcpServerWaitForConnect.hSocket := SysSockAccept(hSocket, ADR(sa), ADR(diSize),ADR(pResult));
  IF TcpServerWaitForConnect.hSocket <> RTS_INVALID_HANDLE THEN
    ia.ulAddr := sa.sin_addr.ulAddr;
    SysSockInetNtoa(ADR(ia), TcpServerWaitForConnect.stIPAddress, SIZEOF(TcpServerWaitForConnect.stIPAddress));
  END_IF
END_IF
END_FUNCTION