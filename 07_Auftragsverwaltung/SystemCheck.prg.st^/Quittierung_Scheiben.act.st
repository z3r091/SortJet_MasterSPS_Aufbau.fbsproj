(* METADATA
{
  "v3Meta": {
    "objectGuid": "2a70e2fa-dcda-4b8f-820f-05f7864c9862"
  }
}
*)
ACTION Quittierung_Scheiben
//-------------------------------------------------------------------------------------------------
// QUITTIEREN DER SCHEIBEN IM SYSTEMCHECK [VERBUND]
//-------------------------------------------------------------------------------------------------


FOR wlIndexQuitt := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  IF ( abpCheck[wlIndexQuitt] ) THEN

    IF ( starrStationBasisParameter[cSTATION_207].OutGlasTransport[cWAND_1].bQuittScheibe ) AND StationInAutomatikkreis(starrStationBasisParameter[cSTATION_207].stMKs.eaAutomatikkreis, wlIndexQuitt) THEN

      wSps2MmiZielStation     := cSTATION_207;
      wSps2MmiQuellStation    := cSTATION_206;
      wSps2MmiZielWand        := cWAND_1;
      wSps2MmiQuellWand       := cWAND_1;
      dwSps2MmiWartezeit      := 0;
      wSPS2MMIAuftragstyp     := 0;
      dwSPS2MMIGenutzteSauger := 0;
  
      MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
          
    END_IF
    
    IF ( starrStationBasisParameter[cSTATION_206].OutGlasTransport[cWAND_1].bQuittScheibe ) AND StationInAutomatikkreis(starrStationBasisParameter[cSTATION_207].stMKs.eaAutomatikkreis, wlIndexQuitt) THEN

      wSps2MmiZielStation     := cSTATION_206;
      wSps2MmiQuellStation    := cSTATION_205;
      wSps2MmiZielWand        := cWAND_1;
      wSps2MmiQuellWand       := cWAND_1;
      dwSps2MmiWartezeit      := 0;
      wSPS2MMIAuftragstyp     := 0;
      dwSPS2MMIGenutzteSauger := 0;
  
      MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
          
    END_IF

    IF ( starrStationBasisParameter[cSTATION_205].OutGlasTransport[cWAND_1].bQuittScheibe ) AND StationInAutomatikkreis(starrStationBasisParameter[cSTATION_205].stMKs.eaAutomatikkreis, wlIndexQuitt) THEN

      wSps2MmiZielStation     := cSTATION_205;
      wSps2MmiQuellStation    := cSTATION_204;
      wSps2MmiZielWand        := cWAND_1;
      wSps2MmiQuellWand       := cWAND_1;
      dwSps2MmiWartezeit      := 0;
      wSPS2MMIAuftragstyp     := 0;
      dwSPS2MMIGenutzteSauger := 0;
  
      MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
          
    END_IF

    IF ( starrStationBasisParameter[cSTATION_202].OutGlasTransport[cWAND_1].bQuittScheibe ) AND StationInAutomatikkreis(starrStationBasisParameter[cSTATION_202].stMKs.eaAutomatikkreis, wlIndexQuitt) THEN

      wSps2MmiZielStation     := cSTATION_202;
      wSps2MmiQuellStation    := cSTATION_201;
      wSps2MmiZielWand        := cWAND_1;
      wSps2MmiQuellWand       := cWAND_1;
      dwSps2MmiWartezeit      := 0;
      wSPS2MMIAuftragstyp     := 0;
      dwSPS2MMIGenutzteSauger := 0;
  
      MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
          
    END_IF


  END_IF

END_FOR
END_ACTION