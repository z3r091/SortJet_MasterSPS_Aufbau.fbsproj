(* METADATA
{
  "v3Meta": {
    "objectGuid": "ed448837-b746-4b1a-b2e7-236797e04e0f"
  }
}
*)
PROGRAM CheckReset
VAR
  wlIndexAutomatikkreis,
  wlIndexStation : WORD;
END_VAR

FOR wlIndexAutomatikkreis := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  agbResetAktiv[wlIndexAutomatikkreis] := FALSE;

  FOR wlIndexStation := cERSTE_STATION TO cLETZTE_STATION DO
    IF starrStationBasisParameter[wlIndexStation].bReset AND_THEN StationInAutomatikkreis(starrStationBasisParameter[wlIndexStation].stMKs.eaAutomatikkreis, wlIndexAutomatikkreis) THEN
      agbResetAktiv[wlIndexAutomatikkreis] := TRUE;
      EXIT;
    END_IF
  END_FOR

  // Schleife des AK eine Iteration weiter 
  IF agbResetAktiv[wlIndexAutomatikkreis] THEN
    CONTINUE; 
  END_IF

  FOR wlIndexStation := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
    IF starrShuttleBasisParameter[wlIndexStation].bReset AND_THEN StationInAutomatikkreis(starrShuttleBasisParameter[wlIndexStation].stMKs.eaAutomatikkreis, wlIndexAutomatikkreis) THEN
      agbResetAktiv[wlIndexAutomatikkreis] := TRUE;
      EXIT;
    END_IF
  END_FOR

  // Schleife des AK eine Iteration weiter 
  IF agbResetAktiv[wlIndexAutomatikkreis] THEN
    CONTINUE; 
  END_IF

  FOR wlIndexStation := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
    IF starrTransferShuttleBasisParameter[wlIndexStation].bReset AND_THEN StationInAutomatikkreis(starrTransferShuttleBasisParameter[wlIndexStation].stMKs.eaAutomatikkreis, wlIndexAutomatikkreis) THEN
      agbResetAktiv[wlIndexAutomatikkreis] := TRUE;
      EXIT;
    END_IF
  END_FOR

  // Schleife des AK eine Iteration weiter 
  IF agbResetAktiv[wlIndexAutomatikkreis] THEN
    CONTINUE; 
  END_IF

  FOR wlIndexStation := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
    IF starrFaecherwagenBasisParameter[wlIndexStation].bReset AND_THEN StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndexStation].stMKs.eaAutomatikkreis, wlIndexAutomatikkreis) THEN
      agbResetAktiv[wlIndexAutomatikkreis] := TRUE;
      EXIT;
    END_IF
  END_FOR

  // Schleife des AK eine Iteration weiter 
  IF agbResetAktiv[wlIndexAutomatikkreis] THEN
    CONTINUE; 
  END_IF

  FOR wlIndexStation := cERSTE_FREMDANLAGE_EINLAUF TO cLETZTE_FREMDANLAGE_EINLAUF DO
    IF starrFremdanlageEinlaufStationBasisParameter[wlIndexStation].bReset AND_THEN StationInAutomatikkreis(starrFremdanlageEinlaufStationBasisParameter[wlIndexStation].stMKs.eaAutomatikkreis, wlIndexAutomatikkreis) THEN
      agbResetAktiv[wlIndexAutomatikkreis] := TRUE;
      EXIT;
    END_IF
  END_FOR

  // Schleife des AK eine Iteration weiter 
  IF agbResetAktiv[wlIndexAutomatikkreis] THEN
    CONTINUE; 
  END_IF

  FOR wlIndexStation := cERSTE_FREMDANLAGE_AUSLAUF TO cLETZTE_FREMDANLAGE_AUSLAUF DO
    IF starrFremdanlageAuslaufStationBasisParameter[wlIndexStation].bReset AND_THEN StationInAutomatikkreis(starrFremdanlageAuslaufStationBasisParameter[wlIndexStation].stMKs.eaAutomatikkreis, wlIndexAutomatikkreis) THEN
      agbResetAktiv[wlIndexAutomatikkreis] := TRUE;
      EXIT;
    END_IF
  END_FOR

END_FOR
END_PROGRAM