(* METADATA
{
	"v3Meta": {
		"objectGuid": "f063b21c-ee9e-4ece-bc3c-2deffdcf07f3"
	}
}
*)
FUNCTION_BLOCK Basic_Shuttle_Aktion_FB
VAR_IN_OUT

  (* STRUKT *)
  BasisStationsParameter : StationBasisParameter_ST;

END_VAR
VAR_OUTPUT

  // BOOL
  bprtScheibe : BOOL;

END_VAR
VAR_INPUT

  // BOOL
  bpGeblaeseAktiv        : BOOL;
  bpAutomatikAktiv       : BOOL;
  bpVorAbAuftragAktiv    : BOOL;
  bpZielPositionErreicht : BOOL;

  // WORD
  wWand : WORD;

  // Bausteine
  Glastransport   : REFERENCE TO Shuttle_Glastransport_FB;
  Kippen          : REFERENCE TO Shuttle_Kippen;
  Wandverstellung : REFERENCE TO Dickenverstellung_FB;
  Geblaese        : REFERENCE TO Geblaese_Schuetz_FB;

END_VAR
VAR

  // Steps_TE
  steplAktion : STEPS_TE;

END_VAR
;
END_FUNCTION_BLOCK