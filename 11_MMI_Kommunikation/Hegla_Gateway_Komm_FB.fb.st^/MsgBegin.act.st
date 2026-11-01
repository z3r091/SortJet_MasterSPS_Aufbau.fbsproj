(* METADATA
{
  "v3Meta": {
    "objectGuid": "bd949edd-780c-4971-83d6-b01a2ef6b548"
  }
}
*)
ACTION MsgBegin
(* Watchdog-Value auf die Struktur übernehmen *)
Memcopy( ADR( MmiToSps ), ADR( MmiToSpsMem ), cSizeOfWord );

(* MessageBlock vom MMI überprüfen *)
IF( Memcomp( ADR( MmiToSps.smbMessageBlock ), ADR( MmiToSpsMem.smbMessageBlock ), SIZEOF( MmiToSps.smbMessageBlock ) ) <> 0 )THEN
  (* Prüfen ob der neue Messageblock vom MMI gültig ist *)
  dwlChecksumme0 := Crc32( ADR(MmiToSpsMem.smbMessageBlock), SIZEOF( MmiToSps.smbMessageBlock ) - cSizeOfDWord );
  
  (*dwlChecksumme1 :=  MmiToSpsMem.smbMessageBlock.dwCrc32Checksumme;*)
  dwlChecksumme1 := HMI_GetDWORD( ADR( MmiToSpsMem.smbMessageBlock.dwCrc32Checksumme));

  IF( dwlChecksumme0 = dwlChecksumme1 )THEN
    (* neuen MessageBlock vom MMI überbenehmen *)
    Memcopy( ADR( MmiToSps.smbMessageBlock ), ADR( MmiToSpsMem.smbMessageBlock ), SIZEOF( MmiToSps.smbMessageBlock ));
  END_IF;
END_IF;

Watchdog();
IF( o_b_WatchdogOk )THEN
  GetMessage();
END_IF;
END_ACTION