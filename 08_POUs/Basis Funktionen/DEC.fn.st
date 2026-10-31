(* METADATA
{
  "v3Meta": {
    "objectGuid": "e4081493-5d9a-4e63-8c4b-cba513ba3d02"
  }
}
*)
{attribute 'excludefrombuild'}
FUNCTION DEC : INT
VAR_INPUT
  iWert    : INT;
  iMinuend : INT;
END_VAR




(* Hinweis:
   - Funktion zum reduzieren der Eingangsvariablen X um 1. 
*)
DEC := iWert - iMinuend;
END_FUNCTION