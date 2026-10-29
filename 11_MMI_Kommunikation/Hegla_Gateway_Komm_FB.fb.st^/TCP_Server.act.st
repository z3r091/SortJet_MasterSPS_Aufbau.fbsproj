(* METADATA
{
	"v3Meta": {
		"objectGuid": "305dcaac-e980-4088-8579-24e649819553"
	}
}
*)
ACTION TCP_Server
IF bInit THEN

  IF ( hSocket <> RTS_INVALID_HANDLE ) THEN
    IF ( Client.hSocket <> RTS_INVALID_HANDLE ) THEN
      CloseSocket( ADR(Client.hSocket) );
      Client.stIPAddress := '';
    END_IF

    CloseSocket( ADR(hSocket) );
  END_IF

  bgTcpConnected := FALSE;
  tonlOpenForClient(IN := FALSE);
  bInit := FALSE;
ELSE
  tonlOpenForClient(IN := TRUE,PT := T#5000MS);

(*Server Socket öffnen*)
  IF  hSocket = RTS_INVALID_HANDLE
  AND tonlOpenForClient.Q
  THEN
    hSocket := TcpServerOpenSocket(4444, 1);
  ELSIF tonlOpenForClient.Q THEN
  (*Auf Client verbindung warten*)
  IF Client.hSocket = RTS_INVALID_HANDLE
  THEN
    bgTcpConnected := FALSE;
    Client := TcpServerWaitForConnect(hSocket, 0);
  ELSE
    bgTcpConnected := TRUE;
  END_IF;

  END_IF
END_IF


blVerbindungReset :=
    (NOT o_b_WatchdogOk) AND
    (wZyklenOff > 30) AND
    (Client.hSocket <> RTS_INVALID_HANDLE) AND
    (NOT tnlVerbindungReset.Q);

tnlVerbindungReset(IN := blVerbindungReset, PT := WORD_TO_TIME(wlVerbindungReset));
rtlVerbindungReset(CLK := tnlVerbindungReset.Q);

IF (rtlVerbindungReset.Q) THEN
(* SendMsg.berror := FALSE;*)
  CloseSocket(ADR(Client.hSocket));
  Client.stIPAddress := '';
END_IF;

ReadMsg();
END_ACTION