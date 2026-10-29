(* METADATA
{
	"v3Meta": {
		"objectGuid": "b9f6b86d-7a91-4709-a115-3d1bc5da6f67"
	}
}
*)
METHOD M_ReadMsg_InterpretMsg : BOOL
VAR_INPUT
END_VAR

M_ReadMsg_InterpretMsg := FALSE;
CASE mhHeader.wType OF

  cMsg_Watchdog:
     (*Watchdog Nachricht empfangen*)
     MmiToSpsMem.wWatchdog := HMI_GetWORD( ADR( bBuffer_Read[4] ) );
     M_ReadMsg_InterpretMsg         := TRUE;

  cMsg_MsgBlock:
     (*Messageblock Nachricht empfangen*)
     (*EXC88 keine Buffer Words mehr!*)
     MemCopy( ADR( MmiToSpsMem.smbMessageBlock.wQuitCnt ),ADR( bBuffer_Read[4] ),cSizeOfWord *3 );

     MemCopy( ADR( MmiToSpsMem.smbMessageBlock.asmSpsMessage[0].wAuftrag ),
                ADR( bBuffer_Read[10] ), SIZEOF( MmiToSpsMem.smbMessageBlock.asmSpsMessage ) ) ;

     (*Pointer setzen*)
     pbCurPos_Read := ADR( bBuffer_Read[10] ) + SIZEOF( MmiToSpsMem.smbMessageBlock.asmSpsMessage );
     MemCopy( ADR( MmiToSpsMem.smbMessageBlock.wCnt2 ), pbCurPos_Read, cSizeOfWord );

     pbCurPos_Read := pbCurPos_Read + 2; (*Pointer um 2 Bytes erhöhen*)
     MemCopy( ADR( MmiToSpsMem.smbMessageBlock.dwCrc32Checksumme ), pbCurPos_Read, cSizeOfDWord );

     M_ReadMsg_InterpretMsg := TRUE;
END_CASE
END_METHOD