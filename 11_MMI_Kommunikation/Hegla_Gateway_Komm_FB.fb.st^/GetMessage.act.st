(* METADATA
{
  "v3Meta": {
    "objectGuid": "c15a1bbd-8694-42ea-9195-cf52aa2de87e"
  }
}
*)
ACTION GetMessage
  IF ( ilAuftraegeAnz = 0 ) THEN
  (* CRC32-Summe für die Aufträge prüfen. *)
  dwAuftragsChecksumme := Crc32( ADR( MmiToSps.smbMessageBlock ), SIZEOF( MmiToSps.smbMessageBlock ) - cSizeOfDWord );
  IF ( HMI_GetDWORD( ADR(MmiToSps.smbMessageBlock.dwCrc32Checksumme)) = dwAuftragsChecksumme ) THEN
    (* Nachrichten aus dem Speicher übernehmen und Quitieren *)
    IF ( ( HMI_GetWORD(ADR(MmiToSps.smbMessageBlock.wCnt2)) <> SpsToMmi.smbMessageBlock.wQuitCnt ) AND
        ( HMI_GetWORD(ADR(MmiToSps.smbMessageBlock.wCnt1)) =  HMI_GetWORD(ADR( MmiToSps.smbMessageBlock.wCnt2 ) ))
      ) THEN
    MemCopy( ADR( asmSpsMessage ), ADR( MmiToSps.smbMessageBlock.asmSpsMessage ), SIZEOF( asmSpsMessage ) );
    ilAuftraegeAnz := WORD_TO_INT(HMI_GetWORD( ADR(MmiToSps.smbMessageBlock.wAnzAuftraege)) );
    IF ilAuftraegeAnz > 5 THEN
      ilAuftraegeAnz := 5; // Schutz vor Array-Überlauf (asmSpsMessage[0..4])
    END_IF
    ilAuftragIndex := 0;
    SpsToMmi.smbMessageBlock.wQuitCnt := HMI_GetWORD(ADR( MmiToSps.smbMessageBlock.wCnt2));
    END_IF;
  END_IF;
  END_IF;

  (* 1 Nachricht pro Zyklus verarbeiten *)
  IF ( ilAuftraegeAnz > 0 ) THEN
    MemCopy( ADR( smlSpsMessage ), ADR( asmSpsMessage[ ilAuftragIndex ] ), SIZEOF( smlSpsMessage ) );
    ilAuftragIndex := ilAuftragIndex + 1;
    (*NEU-->*)
    smlSpsMessage.wAuftrag := HMI_GetWORD(ADR(smlSpsMessage.wAuftrag));
    smlSpsMessage.wLaenge := HMI_GetWORD(ADR(smlSpsMessage.wLaenge));
    (*<--NEU*)
    IF ( MsgInterpret(smlSpsMessage) = FALSE ) THEN
      // smlErrorMsg.wAuftrag   := 32767;
      // smlErrorMsg.wLaenge    := 4;
      // HMI_PutWORD(ADR(smlErrorMsg.awDaten[0]), 3);
      // HMI_PutWORD(ADR(smlErrorMsg.awDaten[1]), smlSpsMessage.wAuftrag);
      // PutMsg( smpSpsMessage := smlErrorMsg, bpTrig := FALSE );

    END_IF
  END_IF;
  IF ( ilAuftragIndex >= ilAuftraegeAnz ) THEN
    ilAuftraegeAnz := 0;
    ilAuftragIndex := 0;
  END_IF;
END_ACTION