(* METADATA
{
  "v3Meta": {
    "objectGuid": "4a5dc8cc-233c-4d19-b434-5bbaf5270e22"
  }
}
*)
ACTION WatchDog
  ilDiff := WORD_TO_INT( MmiToSps.wWatchdog ) - WORD_TO_INT( SpsToMmi.wWatchdog );
  tlTimeDiff := TIME() - tlTimeOut;

  IF (tlTimeDiff > T#5s) THEN
    bTimeOff := TRUE;
    wZyklenOff := wZyklenOff + 1;
    IF ( ilDiff <> 1 ) THEN
      wlWatchdogOk := wlWatchdogOk + 1;
    END_IF
  END_IF

  IF ( ilDiff <> 1 ) THEN

    IF ( tlTimeDiff > T#5s ) THEN
      (* Kommunikationstimeout erreicht *)
      IF (wZyklenOff>30)
      THEN
        o_b_WatchdogOk := FALSE;
      END_IF
  END_IF

  ELSE

    IF ( NOT o_b_WatchdogOk ) THEN
      dwlCrc32Value        := Crc32(ADR( MmiToSps.smbMessageBlock ), SIZEOF( MmiToSps.smbMessageBlock ) - cSizeOfDWord );
      dwAuftragsChecksumme_WatchDog := HMI_GetDWORD(ADR(MmiToSps.smbMessageBlock.dwCrc32Checksumme));
      IF ( ( dwlCrc32Value = dwAuftragsChecksumme_WatchDog ) AND
          ( MmiToSps.smbMessageBlock.wCnt1 = HMI_GetWORD(ADR(SpsToMmi.smbMessageBlock.wQuitCnt))) AND
          ( MmiToSps.smbMessageBlock.wCnt2 = HMI_GetWORD(ADR(SpsToMmi.smbMessageBlock.wQuitCnt))) AND
          ( MmiToSps.smbMessageBlock.wQuitCnt = HMI_GetWORD(ADR(SpsToMmi.smbMessageBlock.wCnt1))) AND
          ( MmiToSps.smbMessageBlock.wQuitCnt = HMI_GetWORD(ADR(SpsToMmi.smbMessageBlock.wCnt2)))
        ) THEN
      o_b_WatchdogOk := TRUE;
      wZyklenOff     := 0;
      bTimeOff       := FALSE;
      END_IF
  END_IF

  tlTimeOut := TIME();

  END_IF
  IF ( NOT o_b_WatchdogOk ) THEN
    SpsToMmi.smbMessageBlock.wCnt1    := SpsToMmi.smbMessageBlock.wCnt2;
    SpsToMmi.smbMessageBlock.wQuitCnt := HMI_GetWORD(ADR(MmiToSps.smbMessageBlock.wCnt2));

    SpsToMmi.smbMessageBlock.dwCrc32Checksumme := Crc32( ADR( SpsToMmi.smbMessageBlock ), SIZEOF( SpsToMmi.smbMessageBlock ) - cSizeOfDWord );

  END_IF
  SpsToMmi.wWatchdog := MmiToSps.wWatchdog;
END_ACTION