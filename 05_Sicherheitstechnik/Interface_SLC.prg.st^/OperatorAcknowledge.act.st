(* METADATA
{
  "v3Meta": {
    "objectGuid": "178671fb-35b0-4259-a5a5-bd66eca69a26"
  }
}
*)
ACTION OperatorAcknowledge
//-------------------------------------------------------------------------------------------------
// AKTION OPERATOR ACKNOWLEDGE
//-------------------------------------------------------------------------------------------------
// Eingang von SLC
bpOperatorAcknowledgeRequested := EV_ToPLC_bOperatorAckReq OR ( EV_ToPLC_Error_FSoE_Master_1 <> 0 ) OR ( EV_ToPLC_Error_FSoE_Master_2 <> 0 );

// Meldung ausgeben
rtlMeldungQuittierungDurchBedienerErforderlich(CLK := bpOperatorAcknowledgeRequested );
IF ( rtlMeldungQuittierungDurchBedienerErforderlich.Q ) THEN
  wpgFehlerdaten[0] := 0;
  SpsHinweis( eFehler_Safety_Allgemein, 
              cMELDUNG_SAFETY_OPERATOR_ACKNOWLEDGE_REQUESTED, 
              0, 
              AutomatikkreisBestimmen(0),
              wpgFehlerdaten );
END_IF

(* Hinweis:
   - Erforderlich das ein Bediener die Sicherheitstechnik quittiert
     => Module befinden sich im Stopp
*)
rtlResetOA( CLK := ( bpResetOperatorAcknowledge OR bpVisuResetFSoEMaster ) AND bpOperatorAcknowledgeRequested );
toflResetOA( IN := rtlResetOA.Q , PT := T#1S );
EV_ToSLC_bReset_FSoEMaster  := toflResetOA.Q;
bpResetOperatorAcknowledge := FALSE;
END_ACTION