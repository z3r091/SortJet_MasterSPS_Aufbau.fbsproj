(* METADATA
{
	"v3Meta": {
		"objectGuid": "4fa4033e-e747-4aeb-929e-769f6a25d112"
	}
}
*)
ACTION ResetStepsUndMcAktionen
blRuckProfilInitialisiert := FALSE;
blRuckBremsphase := FALSE;
blRuckKurzfahrt := FALSE;
l_fb_CoeLesen( i_b_Execute := FALSE );
l_fb_CoeSchreiben( i_b_Execute := FALSE );
l_mc_GearIn( Master := ppAntriebsInformationen.wAchsID, Slave := ppAntriebsInformationen.wAchsID, Execute := FALSE ); // geht das?
l_mc_Reset( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
l_mc_Home( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
tonlSoftwareFreigabe( IN := FALSE );
tonlHardwareFreigabe( IN := FALSE );
asteplSchritt[HANDPLUS] := STEP_0_E;
asteplSchritt[HANDMINUS] := STEP_0_E;
asteplSchritt[RELATIV] := STEP_0_E;
asteplSchritt[ABSOLUT] := STEP_0_E;
asteplSchritt[REFERENZ] := STEP_0_E;
asteplSchritt[RESET] := STEP_0_E;
asteplSchritt[BREMSE_LOESEN] := STEP_0_E;
asteplSchritt[FAHRE_RESTWEG_ABSOLUT] := STEP_0_E;
asteplSchritt[INVERTIERTER_SYNC_AUF_MASTER] := STEP_0_E;
asteplSchritt[SYNC_AUF_MASTER] := STEP_0_E;
asteplSchritt[SCHEIBENMESSUNG] := STEP_0_E;
asteplSchritt[RESTWEG] := STEP_0_E;
bpRestwegMaterialGefunden := FALSE;
lrlMessErgebnis := rpMessErgebnis := 0;
bpMessungOk := FALSE;
bpMessungFehlerhaft := FALSE;
blHelfer_RestwegMesung_Objekt_Gefunden := FALSE;
blStopOhneReset := FALSE;
blMesstaster1Gefunden := FALSE;
blMesstaster2Gefunden := FALSE;
bpDone := FALSE;
SignalSteuerWort.0 := FALSE;
SignalSteuerWort.15 := FALSE;
END_ACTION