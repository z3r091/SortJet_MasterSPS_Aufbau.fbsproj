(* METADATA
{
  "v3Meta": {
    "objectGuid": "cda4a395-9b7d-4fad-8723-3f1586f2af42"
  }
}
*)
ACTION A_Geblaese
(***************************************************************************************************)
(* STEUERUNG GEBLAESE *)
(***************************************************************************************************)
(* Energiesparrmodus:
   -  Geblaese bei laengerer Inaktivitaet ausschalten 
*)
rtlAutomatikActiv(CLK := blBetriebsartAutomatik );

IF rtlAutomatikActiv.Q THEN
  blNachSystemcheckMerker := FALSE;
END_IF

IF ( blBetriebsartAutomatik OR blBetriebartCheck OR blNachSystemcheckMerker ) THEN

  (* Energiesparmodus:
     - Gebläse bei längerer Inaktivität ausschalten 
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

(* Hinweis:
   - Geblaese aktiv
     => Interne Variable ob das Geblaese angelaufen ist
*)
blGeblaeseAktiv := Geblaese.bpDone;
END_ACTION