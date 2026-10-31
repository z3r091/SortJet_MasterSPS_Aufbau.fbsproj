(* METADATA
{
  "v3Meta": {
    "objectGuid": "807f3243-bd0e-4699-ab72-cd6f3f1341d1"
  }
}
*)
ACTION A_Geblaese
(***************************************************************************************************)
(* STEUERUNG GEBLAESE *)
(***************************************************************************************************)
rtlAutomatikActiv(CLK := BasisStationsParameter.bAutomatik);

IF rtlAutomatikActiv.Q THEN
  blNachSystemcheckMerker := FALSE;
END_IF

IF ( blBetriebsartAutomatik
  OR blBetriebartCheck
  OR blNachSystemcheckMerker )
THEN

  (* Energiesparmodus:
     - Gebläse bei längerer Inaktivität ausschalten 
  *)
  toflGeblaeseEnergiesparModus( IN := ( BasisStationsParameter.bAuftragAktiv OR rtlAutomatikActiv.Q),
                                PT := tgZeitAutoabschaltungEnergiesparModus );

  IF (  toflGeblaeseEnergiesparModus.Q
    AND BasisStationsParameter.bFreigabe )
  THEN
    FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
      Geblaese[wlIndex].bpStart := TRUE;
    END_FOR

  ELSE
    FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
      Geblaese[wlIndex].bpStart := FALSE;
    END_FOR

    blNachSystemcheckMerker := FALSE;

  END_IF


END_IF

(* Hinweis:
   - Geblaese aktiv
*)
blDone := TRUE;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blDone := blDone AND Geblaese[wlIndex].bpDone;
END_FOR
blGeblaeseAktiv  := blDone;
END_ACTION