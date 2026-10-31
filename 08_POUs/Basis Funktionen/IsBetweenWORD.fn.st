(* METADATA
{
  "v3Meta": {
    "objectGuid": "640e1550-054d-48b5-a8dc-d9ce3f68325e"
  }
}
*)
FUNCTION IsBetweenWORD : BOOL
VAR_INPUT
 lwValue   : WORD;
 lwBorder1 : WORD;
 lwBorder2 : WORD;
END_VAR
VAR
END_VAR

IsBetweenWORD := FALSE;

IF lwBorder1 < lwBorder2 THEN
  IsBetweenWORD := lwBorder1 <= lwValue
                AND lwValue <= lwBorder2;
ELSE
  IsBetweenWORD := lwBorder2 <= lwValue
                AND lwValue <= lwBorder1;
END_IF
END_FUNCTION