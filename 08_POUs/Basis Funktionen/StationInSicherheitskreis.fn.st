(* METADATA
{
  "v3Meta": {
    "objectGuid": "28064981-b681-426a-a86e-e794fcbf1911"
  }
}
*)
FUNCTION StationInSicherheitskreis : BOOL
VAR_INPUT
  awpArray : ARRAY[0..cANZAHL_SICHERHEITSKREISE] OF Sicherheitskreis_EN;
  wpValueToFind : WORD;
END_VAR
VAR
  INDEX : WORD;
END_VAR

StationInSicherheitskreis := FALSE;

FOR INDEX := 0 TO cANZAHL_SICHERHEITSKREISE DO
	
  IF awpArray[INDEX] = wpValueToFind THEN
	  StationInSicherheitskreis := TRUE;
    RETURN;
  END_IF

END_FOR
END_FUNCTION