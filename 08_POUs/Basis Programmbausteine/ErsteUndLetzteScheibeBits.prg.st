(* METADATA
{
  "v3Meta": {
    "objectGuid": "2dfa9b46-65fe-42f1-b72f-b251bddaa00a"
  }
}
*)
PROGRAM ErsteUndLetzteScheibeBits
VAR_INPUT

  (* WORD *)
   wpErsteUndLetzteScheibe : WORD;

END_VAR
VAR_OUTPUT

  (* WORD *)
  wpLetzteScheibe,
  wpErsteScheibe   : WORD;

END_VAR
VAR

  (* WORD *)
  wlMerkerErsteUndLetzteScheibe  : WORD;

END_VAR
VAR CONSTANT

  (* WORD *)
  cBIT_MASKE_LETZTE_SCHEIBE  : WORD := 2#0000000011111111;

END_VAR

(***************************************************************************************************)
(* BAUSTEIN: LOGIK  *)
(***************************************************************************************************)

(* Hinweis:
   - Erste Scheibe
*)
wlMerkerErsteUndLetzteScheibe := wpErsteUndLetzteScheibe;
wpLetzteScheibe := wlMerkerErsteUndLetzteScheibe AND cBIT_MASKE_LETZTE_SCHEIBE;

(* Hinweis:
   - Letzte Scheibe
*)
wlMerkerErsteUndLetzteScheibe := wpErsteUndLetzteScheibe;
wpErsteScheibe := SHR(wlMerkerErsteUndLetzteScheibe, 8);
END_PROGRAM