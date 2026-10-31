(* METADATA
{
  "v3Meta": {
    "objectGuid": "23a2b991-aabc-47b9-b0d1-d7664e8b8309"
  }
}
*)
ACTION Defaults
blRuckProfilInitialisiert := FALSE;
blRuckBremsphase := FALSE;
blRuckKurzfahrt := FALSE;
bpFehler := FALSE;
bpDone := FALSE; // Kein altes Done waehrend Busausfall melden
blFehlerAktiv := FALSE;
blInternerFehler := FALSE;
bpMotionAktiv := FALSE;
bpReglerBereit := FALSE;
bpAntrieblaeuft := FALSE;
bpAntriebFreigegeben := FALSE;
bpKonstantfahrtAktiv := FALSE;
bpBeschleunigungAktiv := FALSE;
bpVerzoegerungAktiv := FALSE;
bpBewegungsrichtungPositiv := FALSE;
bpBewegungsrichtungNegativ := FALSE;
bpAchseSychron := FALSE;
bpMessungOk := FALSE;
bpMessungFehlerhaft := FALSE;
bpRestwegMaterialGefunden := FALSE;
blAchseStoppen := FALSE;
blAchseStoppenAktiv := FALSE;
blFreigabeEntziehenPowerAus := FALSE;
blReferenzLoeschen := FALSE;
blReferenzSetzen := FALSE;
blBremseLoesen := FALSE;
wlAusgaengeUmrichter := WORD#0;
tonlMaxZeitStatusUngueltig( IN := FALSE ); // Statusueberwachung nach Busrueckkehr neu starten
eBewegungsrichtung := TE_Move_Direction.MD_STANDSTILL_E;

IF __ISVALIDREF(ppAntriebsInformationen) AND_THEN ( ppAntriebsInformationen.wAchsID <> 65 ) THEN
  l_fb_CoeLesen( i_b_Execute := FALSE );
  l_fb_CoeSchreiben( i_b_Execute := FALSE );
  l_fb_CoeTouchProbeSchreiben( i_b_Execute := FALSE );
  l_mc_GearIn( Master := ppAntriebsInformationen.wAchsID, Slave := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_Reset( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_Home( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_Stop( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_Power( Axis := ppAntriebsInformationen.wAchsID, Enable := FALSE );
END_IF
END_ACTION