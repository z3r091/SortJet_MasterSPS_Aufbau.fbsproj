(* METADATA
{
  "v3Meta": {
    "objectGuid": "666a809c-7e52-4abd-9f01-34086fac7ebd"
  }
}
*)
FUNCTION IsInRange : BOOL
VAR_INPUT
  rlValue : REAL;
  rlTargetValue : REAL;
  rlThresshold : REAL;
END_VAR
VAR
END_VAR

IsInRange := ABS(rlValue - rlTargetValue) <= rlThresshold;
END_FUNCTION