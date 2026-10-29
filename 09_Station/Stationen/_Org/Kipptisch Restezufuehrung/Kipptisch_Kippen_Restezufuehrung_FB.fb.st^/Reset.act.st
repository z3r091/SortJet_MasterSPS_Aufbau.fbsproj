(* METADATA
{
	"v3Meta": {
		"objectGuid": "ce8d184f-02a1-4903-a300-44f7eb4fc4f7"
	}
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION RESET *)
(***************************************************************************************************)
// Aufruf Basic_Station Aktion
SUPER^.Reset();

IF ( bpReset (*AND ( steplReset = STEP_0_E )*) ) THEN
  Antriebseinheit.bpReset := TRUE;
END_IF
END_ACTION