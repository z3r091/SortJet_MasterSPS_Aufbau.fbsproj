(* METADATA
{
  "v3Meta": {
    "objectGuid": "10c1b2d6-77ce-44d1-9dc1-390f3ff85d9b"
  }
}
*)
FUNCTION AutomatikFehlerSetzen : BOOL
VAR_INPUT
  eaAutomatikkreise : ARRAY[cERSTER_AUTOMATIKKREIS..cANZAHL_AUTOMATIKKREISE] OF Automatikkreis_EN;
  abpFehler : REFERENCE TO ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;
END_VAR
VAR
  wlIndex: WORD;
END_VAR

FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO

  IF eaAutomatikkreise[wlIndex] <> 0 THEN
    abpFehler[eaAutomatikkreise[wlIndex]] := TRUE;
  END_IF 

END_FOR

AutomatikFehlerSetzen := TRUE;
END_FUNCTION