(* METADATA
{
	"v3Meta": {
		"objectGuid": "6ac5d840-4a0e-4401-831b-759903fc413b"
	}
}
*)
ACTION StartCheck
//-------------------------------------------------------------------------------------------------
// AKTION: SYSTEM CHECK STARTEN
//-------------------------------------------------------------------------------------------------
IF ( M_SB0_MMI_SortierungCheckInputQueue ) THEN
  M_SB0_MMI_SortierungCheckInputQueue := FALSE;


  FOR wIndexCheck := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

    IF ( tMmi2SpsInfo.wCheckArea = wIndexCheck ) THEN
      SendShuttlePosition();
      IF ( bgSystemCheck[wIndexCheck] ) THEN
        SystemCheck.abpCheck[wIndexCheck] := TRUE;
      ELSE
        wSps2MmiCheckArea :=tMmi2SpsInfo.wCheckArea;
        wSps2MmiCheckSuccessful := 1;
        MsgToMmi(auftragsnr_w := SB0_SPS_SYSTEMCHECKFINISHED );
      END_IF

    END_IF

  END_FOR

END_IF
END_ACTION