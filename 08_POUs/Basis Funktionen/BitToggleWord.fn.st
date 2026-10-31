(* METADATA
{
  "v3Meta": {
    "objectGuid": "aa0bc2f8-efb2-48a1-91f1-3637f8b86daf"
  }
}
*)
FUNCTION BitToggleWord : WORD
VAR_INPUT

  (* WORD *)
	IN : WORD;

  (* INT *)
	POS : INT;

END_VAR
(***************************************************************************************************)
(* BAUSTEIN: LOGIK  *)
(***************************************************************************************************)

(* Hinweis:
   - Diese Funktion setzt in einem WORD ein BIT an einer Position
   => Oscat-Lib 
*)
BitToggleWord := SHL(WORD#1, POS) XOR IN;
END_FUNCTION