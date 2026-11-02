(* METADATA
{
  "v3Meta": {
    "objectGuid": "ae71e8ec-8646-40ea-a1dc-1a79bd3158a7"
  }
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// AKTION MELDUNGEN
//-------------------------------------------------------------------------------------------------
// OperatorAcknowledge
WatchIo( bpOperatorAcknowledgeRequested , ioccSLC_Safety_Operator_Acknowledge_Requested);

// Einer der FSoE Master meldet einen Fehler
WatchIo( (EV_ToPLC_Error_FSoE_Master_1 <> 0) OR (EV_ToPLC_Error_FSoE_Master_2 <> 0), ioccSLC_Error_FSoE_Master );  


IF bpEDMFehlerAktiv THEN
  // EDM Error
  SetWatchIO(EV_ToPLC_EDM_1, ioccSLC_EDM_Error01 );
  SetWatchIO(EV_ToPLC_EDM_2, ioccSLC_EDM_Error17 );
  SetWatchIO(EV_ToPLC_EDM_3, ioccSLC_EDM_Error33 );
  SetWatchIO(EV_ToPLC_EDM_4, ioccSLC_EDM_Error49 );
END_IF

// Es steht ein EDM Fehler an
bpEDMFehlerAktiv :=    ( EV_ToPLC_EDM_1 <> 0 ) 
                       OR ( EV_ToPLC_EDM_2 <> 0 ) 
                       OR ( EV_ToPLC_EDM_3 <> 0 ) 
                       OR ( EV_ToPLC_EDM_4 <> 0 );
                    
WatchIo(bpEDMFehlerAktiv, ioccSLC_EDM_FehlerAktiv);

// SLC Error Equivalent 
SetWatchIO(EV_ToPLC_Error_Equivalent, ioccSLC_Error_Equivalent_1 );
END_ACTION