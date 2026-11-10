(* METADATA
{
	"v3Meta": {
		"objectGuid": "a5602391-f145-45a7-88a7-cf2977d4c874"
	}
}
*)
FUNCTION checkSafetyCircuits : BOOL
VAR_INPUT
  StationData  : REFERENCE TO StationBasisParameter_ST;
  SaftyCircuit : WORD;
END_VAR
VAR
  wIndexMK : WORD := 0;
END_VAR
// It will checked if the safety circuit configured for this station

checkSafetyCircuits := FALSE;
  
FOR wIndexMK := 0 TO cANZAHL_SICHERHEITSKREISE DO
  IF ( SaftyCircuit = StationData.stMKs.eaSicherheitskreis[wIndexMK] ) THEN
    checkSafetyCircuits := TRUE;
    EXIT;
  END_IF
END_FOR
END_FUNCTION