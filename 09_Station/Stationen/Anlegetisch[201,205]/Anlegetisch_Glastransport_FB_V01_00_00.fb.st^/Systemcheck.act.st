(* METADATA
{
	"v3Meta": {
		"objectGuid": "1c54546b-5e3e-44fa-a046-ea313eb309ce"
	}
}
*)
ACTION Systemcheck
//-------------------------------------------------------------------------------------------------
// AKTION: SYSTEMCHECK
//-------------------------------------------------------------------------------------------------

CASE ( steplCheck ) OF
  // SYSTEM CHECK=========================
  STEP_100_E:
    // Pruefen ob es sich um einen SystemCheck mit einer Vorganger- Nachfolge- Station handelt oder ob der
    //   default SystemCheck abgehandelt werden soll.
    IF ( NOT ( bpCheckMitVorgaenger
               OR bpCheckMitNachfolger) )
    THEN
      steplCheck := STEP_4000_E;
    ELSE
      steplCheck := STEP_300_E;
    END_IF

  STEP_4000_E:
    (* Hinweis:
       - Pruefen ob die Station belegt ist
    *)
    bpStationBelegt :=  toflAuslaufsensor.Q;
    steplCheck := STEP_1000_E;

END_CASE

// Aufruf Basic_Station Aktion
SUPER^.SystemCheck();
END_ACTION