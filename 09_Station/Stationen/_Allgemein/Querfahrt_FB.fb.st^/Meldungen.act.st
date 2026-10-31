(* METADATA
{
  "v3Meta": {
    "objectGuid": "b536b448-1333-4d2d-8a24-085f2ca78b2d"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* MELDUNGEN *)
(***************************************************************************************************)
IF(  Antrieb.bpFehler
  AND NOT (  steplPositionieren = STEP_900_E
    OR steplReferenz = STEP_900_E
    OR steplReset    = STEP_900_E )
  )
THEN
  wpFehlerNR := cMELDUNG_ANTRIEB_QUERFAHRT;
  bpFehler := TRUE;
END_IF
END_ACTION