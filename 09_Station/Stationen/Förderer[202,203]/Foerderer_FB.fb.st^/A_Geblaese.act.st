(* METADATA
{
  "v3Meta": {
    "objectGuid": "5978a36a-9375-4d46-b7b2-10dc4e26b7df"
  }
}
*)
ACTION A_Geblaese
(***************************************************************************************************)
(* AKTION GEBLAESE *)
(***************************************************************************************************)
rtlAutomatikActiv(CLK := blBetriebsartAutomatik );

IF rtlAutomatikActiv.Q THEN
  blNachSystemcheckMerker := FALSE;
END_IF

IF ( blBetriebsartAutomatik OR blBetriebartCheck OR blNachSystemcheckMerker ) THEN

  (* Energiesparmodus:
     - Gebläse bei laengerer Inaktivität ausschalten 
  *)
  toflGeblaeseEnergiesparModus( IN := (    BasisStationsParameter.bAuftragAktiv
                                        OR rtlAutomatikActiv.Q) ,
                                PT := tgZeitAutoabschaltungEnergiesparModus );

  IF (  toflGeblaeseEnergiesparModus.Q
       AND BasisStationsParameter.bFreigabe )
  THEN
    Geblaese.bpStart := TRUE;

  ELSE
    Geblaese.bpStart := FALSE;

    blNachSystemcheckMerker := FALSE;

  END_IF

END_IF

blGeblaeseAktiv  := Geblaese.bpDone;
END_ACTION