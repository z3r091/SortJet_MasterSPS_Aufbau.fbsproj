(* METADATA
{
	"v3Meta": {
		"objectGuid": "d65baa10-5143-49f5-b44e-477f273ce654"
	}
}
*)
ACTION EtherCAT_Restart
// EtherCAT über das MMI neu starten
IF M_SB0_MMI_RESET_ETHERCAT THEN
  M_SB0_MMI_RESET_ETHERCAT := FALSE;	
  blRestartEtherCatMMI := TRUE;
END_IF

bpSlave := EtherCAT_Master.FirstSlave;
blECatOK := TRUE;
WHILE(bpSlave <> 0)
DO
	blECatOK := blECatOK 
            AND (    bpSlave^.wState = 8
                  OR bpSlave^.IsConfigAsOptional  );
  bpSlave := bpSlave^.NextInstance;
  
END_WHILE

bgEtherCatOK := blECatOK AND NOT EtherCAT_Master.xNeedsRestart AND NOT EtherCAT_Master.xRestart;

// Watch IO ausgeben
WatchIo(NOT bgEtherCatOK, ioccEtherCatNotRunning);	

// Timer
tonlWaitInit(IN :=bgEtherCatOK OR bgInbetriebnahmeBit, PT:=T#5S);


IF  EtherCAT_Master.xConfigFinished
AND ( EtherCAT_Master.xNeedsRestart
	OR blRestartEtherCatMMI )
AND steplEtherCat_Restart = STEP_0_E
THEN
  blRestartEtherCatMMI := FALSE;
  steplEtherCat_Restart := STEP_10_E;
END_IF

CASE steplEtherCat_Restart OF
	STEP_10_E:
		IF EtherCAT_Master.xConfigFinished THEN
			tonl_Step(IN:=FALSE);
			steplEtherCat_Restart := STEP_100_E;
		END_IF

	STEP_50_E:
		tonl_Step(IN:=TRUE,PT:=T#5S);
		IF tonl_Step.Q THEN
         EtherCAT_Master.xStopBus := FALSE;
			steplEtherCat_Restart := STEP_100_E;
		END_IF

	STEP_100_E:
		IF NOT EtherCAT_Master.xStopBus THEN			 
      	EtherCAT_Master.xRestart := TRUE;
			tonl_Step(IN:=FALSE);
			tonlEtherCat_Start_TimeOut(IN:=FALSE);
			steplEtherCat_Restart := STEP_150_E;
		END_IF

	STEP_150_E:
		tonl_Step(IN:=TRUE,PT:=T#5S);
		IF tonl_Step.Q THEN
			EtherCAT_Master.xRestart := FALSE;
			steplEtherCat_Restart := STEP_500_E;
		END_IF

	STEP_500_E:
		tonlEtherCat_Start_TimeOut( IN:=TRUE,PT:=T#180S );
		IF tonlWaitInit.Q THEN
			steplEtherCat_Restart := STEP_550_E;
		ELSIF tonlEtherCat_Start_TimeOut.Q THEN
			steplEtherCat_Restart := STEP_10_E;
		END_IF

	STEP_550_E:
	   tonlEtherCat_Start_TimeOut( IN:=FALSE );
		steplEtherCat_Restart := STEP_0_E;

END_CASE
END_ACTION