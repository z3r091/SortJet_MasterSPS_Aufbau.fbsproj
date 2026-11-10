(* METADATA
{
	"v3Meta": {
		"objectGuid": "dcded4cc-d766-4c84-a212-2fe6cc93f6db"
	}
}
*)
FUNCTION checkSafetyCircuitsConfigured : BOOL
VAR_INPUT
  StationData : REFERENCE TO StationBasisParameter_ST;
END_VAR
VAR
  wIndexMK : WORD := 0;
END_VAR

// It will checked if a safety circuit is configured

checkSafetyCircuitsConfigured := FALSE;

IF NOT __ISVALIDREF(StationData.stMKs) OR_ELSE StationData.stMKs.bDeaktivieren THEN
  RETURN;
END_IF

FOR wIndexMK := 0 TO cANZAHL_SICHERHEITSKREISE DO
  IF ( StationData.stMKs.eaSicherheitskreis[wIndexMK] <> eSicherheitskreis_Undefiniert ) THEN
    checkSafetyCircuitsConfigured := TRUE;
    EXIT;
  END_IF
END_FOR
END_FUNCTION