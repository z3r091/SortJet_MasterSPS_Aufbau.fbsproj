(* METADATA
{
	"v3Meta": {
		"objectGuid": "605f94de-cd86-43d0-95cd-83c44bc0f8dc"
	}
}
*)
FUNCTION IsBetweenLReal : BOOL
VAR_INPUT
 lriValue   : LREAL;
 lriBorder1 : LREAL;
 lriBorder2 : LREAL;
END_VAR
VAR
END_VAR

IsBetweenLReal := FALSE;

IF lriBorder1 < lriBorder2 THEN
  IsBetweenLReal := lriBorder1 <= lriValue
                AND lriValue <= lriBorder2;
ELSE
  IsBetweenLReal := lriBorder2 <= lriValue
                AND lriValue <= lriBorder1;
END_IF
END_FUNCTION