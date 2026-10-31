(* METADATA
{
  "v3Meta": {
    "objectGuid": "14e1f1f9-a11c-4000-82c5-ba9f94dc3c1b"
  }
}
*)
PROGRAM SlowTask
VAR
	
  // EtherCAT Reset
  bpSlave                    : POINTER TO ETCSlave;
	
  // BOOL
  blECatOK                   : BOOL;
  blRestartEtherCatMMI       : BOOL;
    
  // STEPS
  steplEtherCat_Restart      : Steps_TE;
	
  // TIMER
  tonlWaitInit               : TON;
  tonl_Step                  : TON;
  tonlEtherCat_Start_TimeOut : TON;
  
  // TRIGGER
  rtrigECatOK                : R_TRIG;
END_VAR

StationBasisZuweisungen.M_AufrufeZuweisungen();
EtherCAT_Restart();
END_PROGRAM