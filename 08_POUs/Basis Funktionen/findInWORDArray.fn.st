(* METADATA
{
	"v3Meta": {
		"objectGuid": "27266190-4c13-454c-9114-87648310c4ec"
	}
}
*)
FUNCTION findInWORDArray : BOOL
VAR_INPUT
  awpArray : ARRAY[1..10] OF WORD;
  wpValueToFind : WORD;
END_VAR
VAR
  INDEX : WORD;
END_VAR

findInWORDArray := FALSE;

FOR INDEX := 1 TO 10 DO

  IF awpArray[INDEX] = wpValueToFind THEN
    findInWORDArray := TRUE;
    EXIT;
  END_IF

END_FOR
END_FUNCTION