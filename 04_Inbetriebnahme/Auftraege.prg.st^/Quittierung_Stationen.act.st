(* METADATA
{
	"v3Meta": {
		"objectGuid": "99e0c60d-64d8-410d-9193-8cedcd4dd773"
	}
}
*)
ACTION Quittierung_Stationen
(***************************************************************************************************)
(* AKTION: QUITTIEREN VON SCHEIBEN *)
(***************************************************************************************************)

(* ---------------------------------------------------------------------------------------
//  QUITTIERUNG 
//         
//  Hinweis:
// - Glas Empfaenger quittiert die Scheiben 
// ---------------------------------------------------------------------------------------*)

IF ( bgNachrichtQuitturungGenerieren ) THEN

  bgNachrichtQuitturungGenerieren := FALSE;

  wSps2MmiZielStation  := wgGlasEmpfaenger;
  wSps2MmiQuellStation := wgGlasSender;
  wSps2MmiZielWand     := wgTransferWandGlasEmpfaenger;
  wSps2MmiQuellWand    := wgTransferWandGlasSenser;
  dwSps2MmiWartezeit   := 0;
  wSPS2MMIAuftragstyp  := wgQuittungAuftragstyp;

  MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );

END_IF
END_ACTION