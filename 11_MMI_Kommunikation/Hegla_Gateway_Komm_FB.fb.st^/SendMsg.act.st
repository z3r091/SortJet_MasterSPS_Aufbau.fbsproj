(* METADATA
{
  "v3Meta": {
    "objectGuid": "1d0ebe0f-be57-4ced-a649-54fad2d51936"
  }
}
*)
ACTION SendMsg
(*--------------------------Datenabgleich wird bei jeder veränderung ausgeführt--------------------------*)
IF ( bgTcpConnected AND (Client.hSocket <> RTS_INVALID_HANDLE)) THEN

  IF ( MemComp( ADR( SpsToTcp.wWatchdog ), ADR( SpsToMmiMem.wWatchdog ), SIZEOF( SpsToMmiMem.wWatchdog ) ) <> 0 ) THEN
    MemCopy( ADR( SpsToTcp.wWatchdog ), ADR( SpsToMmiMem.wWatchdog ), SIZEOF( SpsToMmiMem.wWatchdog ) );
    bSendWatchDog := TRUE;
  END_IF

  IF ( MemComp( ADR( SpsToTcp.smbMessageBlock ), ADR( SpsToMmiMem.smbMessageBlock ), SIZEOF( SpsToMmiMem.smbMessageBlock ) ) <> 0 ) THEN
    MemCopy( ADR( SpsToTcp.smbMessageBlock ), ADR( SpsToMmiMem.smbMessageBlock ), SIZEOF( SpsToMmiMem.smbMessageBlock ) );
    bSendMsgBlock := TRUE;
  END_IF

  tnSendIoSystem(IN := TRUE,PT := tSendIoSystem);
  IF ( MemComp( ADR( SpsToTcp.ioSystem ), ADR( SpsToMmiMem.ioSystem ), SIZEOF( SpsToMmiMem.ioSystem ) ) <> 0 )
     AND(tnSendIoSystem.Q)
  THEN
    MemCopy( ADR( SpsToTcp.ioSystem ), ADR( SpsToMmiMem.ioSystem ), SIZEOF( SpsToMmiMem.ioSystem ) );
    bSendIoSystem := TRUE;
    tnSendIoSystem(IN := FALSE);
  END_IF

  IF ( MemComp( ADR( SpsToTcp.aucControlSystem ), ADR( SpsToMmiMem.aucControlSystem ), SIZEOF( SpsToMmiMem.aucControlSystem ) ) <> 0 ) THEN
    MemCopy( ADR( SpsToTcp.aucControlSystem ), ADR( SpsToMmiMem.aucControlSystem), SIZEOF( SpsToMmiMem.aucControlSystem ) );
    bSendControlSystem := TRUE;
  END_IF

  IF ( MemComp( ADR( SpsToTcp.aAntrieb ), ADR( SpsToMmiMem.aAntrieb ), SIZEOF( SpsToMmiMem.aAntrieb ) ) <> 0 ) THEN
    MemCopy( ADR( SpsToTcp.aAntrieb ), ADR( SpsToMmiMem.aAntrieb), SIZEOF( SpsToMmiMem.aAntrieb ) );
    bSendDrives := TRUE;
  END_IF
END_IF

IF ( NOT bgTcpConnected ) THEN
  SpsToTcp.wWatchdog := 0;
  SpsToMmi.wWatchdog := 0;
  SpsToMmiMem.wWatchdog := 0;
  MmiToSps.wWatchdog := 0;
  MmiToSpsMem.wWatchdog := 0;
  bTimeOff := FALSE;
  wZyklenOff := 0;
END_IF

(*--------------------------Watchdog versenden-------------------------------------------------------*)
IF bSendWatchDog AND (Client.hSocket <> RTS_INVALID_HANDLE) THEN

  HMI_PutWORD( ADR( mhMsgHeader.wType ), cMsg_Watchdog );
  HMI_PutWORD( ADR( mhMsgHeader.wLenght ), SIZEOF( SpsToTcp.wWatchdog ) );
  HMI_PutWORD( ADR( bBuffer_Send[0] ),SpsToTcp.wWatchdog );

  (* Header Versenden *)
  diSent := TcpSendData( Client.hSocket, ADR( mhMsgHeader ), SIZEOF( mhMsgHeader), ADR(tcpLastError) );
  IF diSent = SIZEOF( mhMsgHeader ) THEN
    (* Daten Versenden *)
    diSent := TcpSendData( Client.hSocket, ADR( bBuffer_Send[0] ), SIZEOF( SpsToTcp.wWatchdog), ADR(tcpLastError) ) ;
    IF diSent = SIZEOF( SpsToTcp.wWatchdog ) THEN
      bSendWatchDog := FALSE;
    ELSIF diSent <> 0 THEN
      IF tcpTrace = 0 THEN
        tcpTrace := 2;
      END_IF
      CloseSocket( ADR( Client.hSocket ) );
    END_IF
  ELSIF diSent <> 0 THEN
    IF tcpTrace = 0 THEN
      tcpTrace := 1;
    END_IF
    CloseSocket( ADR( Client.hSocket ) );
  END_IF
END_IF

(*--------------------------MsgBlock versenden-------------------------------------------------------*)
IF ( bSendMsgBlock AND (Client.hSocket <> RTS_INVALID_HANDLE) ) THEN
  wSendMsgBlock := wSendMsgBlock+1;

  (*Daten umkopieren und für die Oberfläche vorbereiten*)
  (*Es kann nicht der gesammte Msg Block 1:1 umkopiert werden weil es bei der Ekelmann Steuerung
    nachdem 3 Word und vor dem letzen DWORD des MsgBlock 2 Buffer Bytes gibt*)

  HMI_PutWORD( ADR( mhMsgHeader.wType ), cMsg_MsgBlock );
  HMI_PutWORD( ADR( mhMsgHeader.wLenght ), 332 );(*Original Byte Größe verwenden bei Sizeof() werden BufferBytes mitberechnet*)

  HMI_PutWORD( ADR( bBuffer_Send[0] ),SpsToTcp.smbMessageBlock.wQuitCnt );
  HMI_PutWORD( ADR( bBuffer_Send[2] ),SpsToTcp.smbMessageBlock.wCnt1 );
  HMI_PutWORD( ADR( bBuffer_Send[4] ),SpsToTcp.smbMessageBlock.wAnzAuftraege );

  MemCopy( ADR( bBuffer_Send[6] ),ADR( SpsToTcp.smbMessageBlock.asmSpsMessage ),SIZEOF( SpsToTcp.smbMessageBlock.asmSpsMessage ) );

  pbCurPos_Send := ADR( bBuffer_Send[6])+ SIZEOF( SpsToTcp.smbMessageBlock.asmSpsMessage );
  HMI_PutWORD( pbCurPos_Send, SpsToTcp.smbMessageBlock.wCnt2 );

  dwCrcTemp :=  Crc32( ADR( bBuffer_Send[0] ), SIZEOF( SpsToTcp.smbMessageBlock ) - cSizeOfWord );

  pbCurPos_Send := pbCurPos_Send +2 ;
  HMI_PutDWORD( pbCurPos_Send,dwCrcTemp );

  (*Header versenden*)
  diSent := TcpSendData( Client.hSocket, ADR( mhMsgHeader ), SIZEOF( mhMsgHeader ), ADR(tcpLastError)  );
  IF diSent = SIZEOF( mhMsgHeader ) THEN
    diSent := TcpSendData( Client.hSocket, ADR( bBuffer_Send[0] ), 332, ADR(tcpLastError)  );
    IF diSent = 332 THEN
      bSendMsgBlock := FALSE;
    ELSIF diSent <> 0 THEN
      IF tcpTrace = 0 THEN tcpTrace := 4; END_IF
      CloseSocket( ADR( Client.hSocket ) );
    END_IF
  ELSIF diSent <> 0 THEN
    IF tcpTrace = 0 THEN tcpTrace := 3; END_IF
    CloseSocket( ADR( Client.hSocket ) );
  END_IF
END_IF

(*-------------------------- ConrolSystem versenden-------------------------------------------------------*)
IF ( bSendControlSystem AND (Client.hSocket <> RTS_INVALID_HANDLE) ) THEN
  wSendControlSystem := wSendControlSystem+1;

  HMI_PutWORD( ADR( mhMsgHeader.wType ), cMsg_ControlSystem );
  HMI_PutWORD( ADR( mhMsgHeader.wLenght ), SIZEOF( SpsToTcp.aucControlSystem ) );

  MemCopy( ADR( bBuffer_Send[0] ), ADR( SpsToTcp.aucControlSystem ), SIZEOF( SpsToTcp.aucControlSystem ) );

  diSent := TcpSendData( Client.hSocket, ADR( mhMsgHeader ), SIZEOF( mhMsgHeader ), ADR(tcpLastError)  );
  (*Header Versenden*)
  IF diSent = SIZEOF( mhMsgHeader ) THEN
    (*Daten versenden*)
    diSent := TcpSendData( Client.hSocket, ADR( bBuffer_Send[0] ), SIZEOF( SpsToTcp.aucControlSystem ), ADR(tcpLastError)  );
    IF diSent = SIZEOF( SpsToTcp.aucControlSystem ) THEN
      bSendControlSystem := FALSE;
    ELSIF diSent <> 0 THEN
      IF tcpTrace = 0 THEN tcpTrace := 6; END_IF
      CloseSocket( ADR( Client.hSocket ) );
    END_IF
  ELSIF diSent <> 0 THEN
    IF tcpTrace = 0 THEN tcpTrace := 5; END_IF
    CloseSocket( ADR( Client.hSocket ) );
  END_IF
END_IF

(*-------------------------- IO's versenden-------------------------------------------------------*)

IF ( bSendIoSystem AND (Client.hSocket <> RTS_INVALID_HANDLE) ) THEN
  wSendIoSystem := wSendIoSystem+1;

  HMI_PutWORD( ADR( mhMsgHeader.wType ), cMsg_IOSystem );
  HMI_PutWORD( ADR( mhMsgHeader.wLenght ), SIZEOF( SpsToTcp.ioSystem ) );

  MemCopy( ADR( bBuffer_Send[0] ), ADR( SpsToTcp.ioSystem ), SIZEOF( SpsToTcp.ioSystem ) );

  (*Header versenden*)
  diSent := TcpSendData( Client.hSocket, ADR( mhMsgHeader ), SIZEOF( mhMsgHeader ), ADR(tcpLastError) );
  IF diSent = SIZEOF( mhMsgHeader ) THEN
    (*Daten Versenden*)
    diSent := TcpSendData( Client.hSocket, ADR( bBuffer_Send[0] ), SIZEOF( SpsToTcp.ioSystem ), ADR(tcpLastError) );
    IF diSent = SIZEOF( SpsToTcp.ioSystem ) THEN
      bSendIoSystem := FALSE;
    ELSIF diSent <> 0 THEN
      IF tcpTrace = 0 THEN tcpTrace := 66; END_IF
      CloseSocket( ADR( Client.hSocket ) );
    END_IF
  ELSIF diSent <> 0 THEN
    IF tcpTrace = 0 THEN tcpTrace := 55; END_IF
    CloseSocket(ADR(Client.hSocket));
  END_IF
END_IF


IF ( FALSE AND  bSendDrives AND (Client.hSocket <> RTS_INVALID_HANDLE) ) THEN

  HMI_PutWORD( ADR( mhMsgHeader.wType ), cMsg_Drives );
  HMI_PutWORD( ADR( mhMsgHeader.wLenght ), SIZEOF( SpsToTcp.aAntrieb ) );

  pbCurPos_Send := ADR( bBuffer_Send[0] );

  FOR i := 0 TO 18 BY 1 DO

    FOR j := 0 TO 8 BY 1 DO

      HMI_PutWORD( pbCurPos_Send,SpsToTcp.aAntrieb[i].awPAE[j] );
      pbCurPos_Send := pbCurPos_Send +2;
      HMI_PutWORD( pbCurPos_Send,SpsToTcp.aAntrieb[i].awPAA[j] );
      pbCurPos_Send := pbCurPos_Send +2;
    END_FOR;

  END_FOR;

  (*Header Versenden*)
  diSent := TcpSendData( Client.hSocket, ADR( mhMsgHeader ), SIZEOF( mhMsgHeader ), ADR(tcpLastError) );
  IF diSent = SIZEOF( mhMsgHeader ) THEN
    (*Daten Versenden*)
    diSent := TcpSendData( Client.hSocket, ADR( bBuffer_Send[0] ), SIZEOF( SpsToTcp.aAntrieb ), ADR(tcpLastError) );
    IF diSent = SIZEOF( SpsToTcp.aAntrieb ) THEN
      bSendDrives := FALSE;
    ELSIF diSent <> 0 THEN
      CloseSocket(ADR(Client.hSocket));
    END_IF
  ELSIF diSent <> 0 THEN
    CloseSocket(ADR(Client.hSocket));
  END_IF
END_IF
END_ACTION