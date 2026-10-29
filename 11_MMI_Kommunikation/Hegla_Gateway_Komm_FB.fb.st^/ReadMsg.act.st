(* METADATA
{
	"v3Meta": {
		"objectGuid": "f24bca42-101c-4726-904f-63b36c6b8d1a"
	}
}
*)
ACTION ReadMsg
(*Receive Data*)

IF ( bgTcpConnected AND (Client.hSocket <> RTS_INVALID_HANDLE) ) THEN

  //Reset the variables to receive a new MSG
  IF      l_b_ReadMsg_NewMsg
  AND NOT l_b_ReadMsg_Failure
  THEN
    pbCunrrent := ADR( bBuffer_Read[0] );
    l_b_ReadMsg_NewMsg := FALSE;
    l_b_ReadMsg_Body := FALSE;
  END_IF

  //Read the Header Out of the Buffer to get the type of MSG and it's designated length.
  IF  NOT l_b_ReadMsg_NewMsg
  AND NOT l_b_ReadMsg_Body
  AND NOT l_b_ReadMsg_Failure
  THEN
    diLenght  := DWORD_TO_DINT(ADR( bBuffer_Read[0] ) + SIZEOF( mhHeader ) - pbCunrrent);

    diReceived := TcpReceiveData( Client.hSocket, pbCunrrent, diLenght, 0, ADR(tcpLastError) );

    IF ( diReceived >= 0 ) THEN (*Daten empfangen*)
      pbCunrrent := pbCunrrent + LINT_TO_DWORD(diReceived);
    ELSE
      CloseSocket( ADR( Client.hSocket ) );
    END_IF

    diRemaining := DWORD_TO_DINT(ADR( bBuffer_Read[0] ) + SIZEOF( mhHeader) - pbCunrrent);

    IF ( diRemaining = 0 )
    THEN
      (*Header Komplett, next step read the body*)
      mhHeader.wType   := HMI_GetWORD( ADR( bBuffer_Read[0] ) );
      mhHeader.wLenght := HMI_GetWORD( ADR( bBuffer_Read[2] ) );
      IF ( mhHeader.wLenght <= SIZEOF( bBuffer_Read ) - SIZEOF( mhHeader ) ) THEN
        l_b_ReadMsg_Body := TRUE;
      ELSE
        CloseSocket( ADR( Client.hSocket ) );
      END_IF
    ELSIF (diRemaining < 0)
    THEN
      (*Fehler in der Datenverabeitung*)
      CloseSocket( ADR( Client.hSocket ) );
    END_IF
  END_IF

  //After we now how big the body is, we can read it.
  IF      l_b_ReadMsg_Body
  AND NOT l_b_ReadMsg_Failure
  THEN
    diLenght := DWORD_TO_DINT(ADR( bBuffer_Read[SIZEOF(mhHeader)] ) + mhHeader.wLenght - pbCunrrent);

    diReceived := TcpReceiveData( Client.hSocket, pbCunrrent, diLenght, 0, ADR(tcpLastError) );

    IF ( diReceived >= 0 ) THEN (*Daten empfangen*)
      pbCunrrent := pbCunrrent + LINT_TO_DWORD(diReceived);
    ELSE;
      CloseSocket( ADR( Client.hSocket ) );
    END_IF

    diRemaining := DWORD_TO_DINT(ADR( bBuffer_Read[SIZEOF( mhHeader )] ) + mhHeader.wLenght - pbCunrrent);

    IF (diRemaining = 0 ) THEN
      (*Daten Komplett*)
      IF M_ReadMsg_InterpretMsg()
      THEN
        l_b_ReadMsg_NewMsg := TRUE;
      ELSE
        l_b_ReadMsg_NewMsg := TRUE; //Unbekannte Nachricht verwerfen und weiter.
      END_IF;
    ELSIF ( diRemaining < 0 ) THEN
      CloseSocket( ADR( Client.hSocket ) );
    END_IF
  END_IF

ELSE
  //Try to read a new msg, when the connection resets.
  l_b_ReadMsg_NewMsg := TRUE;
  l_b_ReadMsg_Failure := FALSE;
END_IF
END_ACTION