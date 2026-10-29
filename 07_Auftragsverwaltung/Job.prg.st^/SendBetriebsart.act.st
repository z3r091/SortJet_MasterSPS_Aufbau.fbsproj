(* METADATA
{
	"v3Meta": {
		"objectGuid": "f30ecbf4-dfb4-425a-a000-c82fc611506a"
	}
}
*)
ACTION SendBetriebsart
(***************************************************************************************************)
(* BETRIEBSART SENDEN  *)
(***************************************************************************************************)
(* Hinweis:
   - Meldung bei Anfrage  
*)
IF ( M_Send_MaschineStatus ) THEN
  blSendJobStatus := TRUE;
  M_Send_MaschineStatus := FALSE;
END_IF

(* Hinweis:
   - Status an MMI schicken 
*)
IF( blSendJobStatus )THEN
  MsgToMmi( auftragsnr_w := SB0_SPS_SETBETRIEBSART );
  blSendJobStatus := FALSE;
END_IF
END_ACTION