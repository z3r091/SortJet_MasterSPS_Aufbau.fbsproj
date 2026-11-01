(* METADATA
{
  "v3Meta": {
    "objectGuid": "e8c31880-687e-415f-8f59-833ae6fe9ace"
  }
}
*)
ACTION Check_MMI_Verbindung
//-------------------------------------------------------------------------------------------------
// MMI VERBINDUNG
//-------------------------------------------------------------------------------------------------
ftlMmiOk(CLK := TCPMain.l_fb_SortjetHMI.o_b_WatchdogOk);

IF ( ftlMmiOk.Q ) THEN
  M_SB0_MMI_SortierungAutomatik_Stop := TRUE;
  tMmi2SpsInfo.wAutomatikStopArea := cSTOPP_ALLE_AUTOMATIKKREIS;
END_IF

IF ( ftlMmiOk.Q ) THEN
  blMerkerMmiNichtOk := TRUE;
  timelMmiNichtOk := TIME();
  lrlMmiNichtOk := TIME_TO_LREAL(TIME());
END_IF

tonlMmiOk(IN:=TCPMain.l_fb_SortjetHMI.o_b_WatchdogOk,pt:=T#2S);
rtlMmiOk(CLK:=tonlMmiOk.Q);
IF ( rtlMmiOk.Q ) THEN
  blSendJobStatus := TRUE;
  MsgToMmi( auftragsnr_w := SB0_SPS_PUFFERSTATUS );
END_IF

IF ( NOT TCPMain.l_fb_SortjetHMI.o_b_WatchdogOk ) THEN
  lrlAktuelleZeit := TIME_TO_LREAL(TIME());
  wlMinutenMmiNichtOk := DWORD_TO_WORD(LREAL_TO_DWORD((lrlAktuelleZeit - lrlMmiNichtOk)) / 60000);
  wlSekundenMmiNichtOk := (LREAL_TO_WORD((lrlAktuelleZeit - lrlMmiNichtOk)) MOD 60000) / 1000;
  wlMilliSekundenMmiNichtOk := LREAL_TO_WORD((lrlAktuelleZeit - lrlMmiNichtOk)) MOD 1000;
END_IF

IF ( TCPMain.l_fb_SortjetHMI.o_b_WatchdogOk
     AND blMerkerMmiNichtOk )
THEN
  blMerkerMmiNichtOk := FALSE;
  blMerkerNachrichtabsetzen := TRUE;
  blSendJobStatus := TRUE;
  SendBetriebsart();
END_IF

tonlNachrichtAbsetzen(IN := blMerkerNachrichtabsetzen, PT := t#2s);

IF ( tonlNachrichtAbsetzen.Q ) THEN
  blMerkerNachrichtabsetzen := FALSE;
  wpgFehlerdaten[0] := wlMinutenMmiNichtOk;
  wpgFehlerdaten[1] := wlSekundenMmiNichtOk;
  wpgFehlerdaten[2] := wlMilliSekundenMmiNichtOk;
  SpsHinweis( eFehler_Mmi, 
              cMELDUNG_MMI_VERBINDUNGS_TIME_OUT, 
              0, 
              AutomatikkreisBestimmen(0), 
              wpgFehlerdaten );
END_IF
END_ACTION