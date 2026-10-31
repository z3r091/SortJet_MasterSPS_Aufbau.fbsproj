(* METADATA
{
  "v3Meta": {
    "objectGuid": "a6ec1752-3ec8-4f8b-95bc-dc8d5c4fd619"
  }
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION: RESET *)
(***************************************************************************************************)
AuftragsSpeicher( bpReset := TRUE );

blUebergabeGlas := FALSE;
wpAuftragsTyp := 0;
steplUebergabeGlas := STEP_0_E;
  
BasisStationsParameter.bCheckMitVorgaenger[cWAND_1] := FALSE;
BasisStationsParameter.bCheckMitNachfolger[cWAND_1] := FALSE;
BasisStationsParameter.bFehler                      := FALSE;
BasisStationsParameter.bAuftragAktiv                := FALSE;
BasisStationsParameter.bReset                       := FALSE;
END_ACTION