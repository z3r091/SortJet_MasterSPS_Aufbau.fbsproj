(* METADATA
{
	"v3Meta": {
		"objectGuid": "e8a694c3-4b92-4b4d-9e51-92b9da22543a"
	}
}
*)
METHOD PutMsg : BOOL
VAR_INPUT
  smpSpsMessage : SpsMessage;
  bpTrig        : BOOL;
END_VAR
VAR
  smlSpsMessage : SpsMessage;
END_VAR

// Nachricht in den Kommunikationspuffer zum MMI eintragen bzw. in die Queue,
//    falls der Kommunikationspuffer belegt ist.

IF( o_b_WatchdogOk <> TRUE )THEN
  RETURN;
END_IF;

// Compilerfehler beim direkten verwenden der Inputvariable bei BLKMOV und MessageIn !?
// Wenn notwenig Drehen, wird in der Funktion GetSpsWord Entscheiden
smlSpsMessage.wAuftrag := HMI_GetWORD(ADR(smpSpsMessage.wAuftrag));
smlSpsMessage.wLaenge  := HMI_GetWORD(ADR(smpSpsMessage.wLaenge));
smlSpsMessage.awDaten  := smpSpsMessage.awDaten; // Die Daten werden in MSGToMMi Aufbereitet


IF( HMI_GetWORD( ADR(MmiToSps.smbMessageBlock.wQuitCnt)) = SpsToMmi.smbMessageBlock.wCnt1 )THEN
  // noch etwas in der Queue ?
  IF( smqSpsMessageQueue.iInzeig <> smqSpsMessageQueue.iOutzeig )THEN
    SpsToMmi.smbMessageBlock.wCnt1 := INT_TO_WORD( WORD_TO_INT( SpsToMmi.smbMessageBlock.wCnt1 ) + 1 );

    // Nachricht 1
    SpsToMmi.smbMessageBlock.wAnzAuftraege := 1;
    Memcopy( ADR( SpsToMmi.smbMessageBlock.asmSpsMessage[0] ), ADR( smqSpsMessageQueue.asmSpsMessage[ smqSpsMessageQueue.iOutzeig ] ), SIZEOF( smlSpsMessage ) );
    smqSpsMessageQueue.iOutzeig := ( smqSpsMessageQueue.iOutzeig + 1 ) MOD 25;

    // Nachricht 2
    IF( smqSpsMessageQueue.iInzeig <> smqSpsMessageQueue.iOutzeig )THEN
      SpsToMmi.smbMessageBlock.wAnzAuftraege := 2;
      Memcopy( ADR( SpsToMmi.smbMessageBlock.asmSpsMessage[1] ), ADR( smqSpsMessageQueue.asmSpsMessage[ smqSpsMessageQueue.iOutzeig ] ), SIZEOF( smlSpsMessage ) );
      smqSpsMessageQueue.iOutzeig := ( smqSpsMessageQueue.iOutzeig + 1 ) MOD 25;
    END_IF;

    // Nachricht 3
    IF( smqSpsMessageQueue.iInzeig <> smqSpsMessageQueue.iOutzeig )THEN
      SpsToMmi.smbMessageBlock.wAnzAuftraege := 3;
      Memcopy( ADR( SpsToMmi.smbMessageBlock.asmSpsMessage[2] ), ADR( smqSpsMessageQueue.asmSpsMessage[ smqSpsMessageQueue.iOutzeig ] ), SIZEOF( smlSpsMessage ) );
      smqSpsMessageQueue.iOutzeig := ( smqSpsMessageQueue.iOutzeig + 1 ) MOD 25;
    END_IF;

    // Nachricht 4
    IF( smqSpsMessageQueue.iInzeig <> smqSpsMessageQueue.iOutzeig )THEN
      SpsToMmi.smbMessageBlock.wAnzAuftraege := 4;
      Memcopy( ADR( SpsToMmi.smbMessageBlock.asmSpsMessage[3] ), ADR( smqSpsMessageQueue.asmSpsMessage[ smqSpsMessageQueue.iOutzeig ] ), SIZEOF( smlSpsMessage ) );
      smqSpsMessageQueue.iOutzeig := ( smqSpsMessageQueue.iOutzeig + 1 ) MOD 25;
    END_IF;

    // Nachricht 5
    IF( smqSpsMessageQueue.iInzeig <> smqSpsMessageQueue.iOutzeig )THEN
      SpsToMmi.smbMessageBlock.wAnzAuftraege := 5;
      Memcopy( ADR( SpsToMmi.smbMessageBlock.asmSpsMessage[4] ), ADR( smqSpsMessageQueue.asmSpsMessage[ smqSpsMessageQueue.iOutzeig ] ), SIZEOF( smlSpsMessage ) );
      smqSpsMessageQueue.iOutzeig := ( smqSpsMessageQueue.iOutzeig + 1 ) MOD 25;
    END_IF;

    SpsToMmi.smbMessageBlock.wCnt2                  := SpsToMmi.smbMessageBlock.wCnt1;
    SpsToMmi.smbMessageBlock.dwCrc32Checksumme      := Crc32( ADR(SpsToMmi.smbMessageBlock ), SIZEOF( SpsToMmi.smbMessageBlock ) - cSizeOfWord );

    IF( NOT bpTrig )THEN
      InMsg( psmSpsMessage:=smlSpsMessage );
    END_IF
  ELSE
    IF( NOT bpTrig )THEN
      InMsg( psmSpsMessage:=smlSpsMessage );
    END_IF;
  END_IF;
ELSE
  IF( NOT bpTrig )THEN
    InMsg( psmSpsMessage:=smlSpsMessage );
  END_IF;
END_IF;
END_METHOD