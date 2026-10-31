(* METADATA
{
  "v3Meta": {
    "objectGuid": "4fd29558-d6eb-46af-8028-798423b786a8"
  }
}
*)
FUNCTION PruefungWertImIntervallAutomatikkreise : BOOL
VAR_INPUT

  (* WORD *)
  wpWert         : ARRAY[cERSTER_AUTOMATIKKREIS..cANZAHL_AUTOMATIKKREISE] OF Automatikkreis_EN;
  wpIntervallMin : WORD;
  wpIntervallMax : WORD;

END_VAR
VAR
  wlIndex : WORD;
END_VAR
(***************************************************************************************************)
(* LOGIK  *)
(***************************************************************************************************)
PruefungWertImIntervallAutomatikkreise := FALSE;

FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO

  IF wpWert[wlIndex] = 0 THEN
    RETURN;
  END_IF

  IF (  wpWert[wlIndex] >= wpIntervallMin
    AND wpWert[wlIndex] <= wpIntervallMax )
  THEN
    PruefungWertImIntervallAutomatikkreise := TRUE;
  ELSE
    PruefungWertImIntervallAutomatikkreise := FALSE;
    RETURN;
  END_IF

END_FOR
END_FUNCTION