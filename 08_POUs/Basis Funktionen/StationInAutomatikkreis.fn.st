(* METADATA
{
  "v3Meta": {
    "objectGuid": "a9180b59-ead2-48cb-98e6-a6809a238554"
  }
}
*)
FUNCTION StationInAutomatikkreis : BOOL
VAR_INPUT
  awpArray : ARRAY[cERSTER_AUTOMATIKKREIS..cANZAHL_AUTOMATIKKREISE] OF Automatikkreis_EN;
  wpValueToFind : WORD;
END_VAR
VAR
  INDEX : WORD;
END_VAR

StationInAutomatikkreis := FALSE;

FOR INDEX := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
	
  IF awpArray[INDEX] = wpValueToFind THEN
	  StationInAutomatikkreis := TRUE;
    RETURN;
  END_IF

END_FOR
END_FUNCTION