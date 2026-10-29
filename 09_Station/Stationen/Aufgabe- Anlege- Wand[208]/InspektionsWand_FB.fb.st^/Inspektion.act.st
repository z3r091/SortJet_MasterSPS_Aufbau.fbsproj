(* METADATA
{
	"v3Meta": {
		"objectGuid": "41ee0cf4-7f1d-45db-a652-a22c171dfd5e"
	}
}
*)
ACTION Inspektion
IF ( BasisStationsParameter.bGlaslaengenmessung
  AND blBetriebsartAutomatik ) 
THEN

  CASE steplInspektion OF
  (* Glasinspektion ==================================*)
    STEP_0_E:
      (* Anmerkung:
         - Starten des Inspektionsauftrags 
      *)
      
      ilDimmstufe := 1;
      
      ;
  END_CASE
  
  ELSE
  ;
END_IF
END_ACTION