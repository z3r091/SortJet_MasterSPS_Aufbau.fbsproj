(* METADATA
{
  "v3Meta": {
    "objectGuid": "776e2b82-2de4-416c-bff2-678a8194ecb8"
  }
}
*)
ACTION Kipparme
(***************************************************************************************************)
(* AKTION KIPPARME *)
(***************************************************************************************************)
rtlKipparmeAnschlaegeAuf(CLK := in_bTasterKipparmeAuf);
rtlKipparmeAnschlaegeAb(CLK := in_bTasterKipparmeAb);

(* Anschläge ein/aus fahren *)
IF rtlKipparmeAnschlaegeAuf.Q
  AND NOT in_bSensorKipparmeAnschlaegeOben
THEN
  outbKipparmeAnschlaegeAb  := FALSE;
  outbKipparmeAnschlaegeAuf := TRUE;
END_IF

IF rtlKipparmeAnschlaegeAb.Q
  AND NOT in_bSensorKipparmeNichtUnten
THEN
  outbKipparmeAnschlaegeAb  := TRUE;
  outbKipparmeAnschlaegeAuf := FALSE;
END_IF

(* Kipparme auf fahren *)
IF in_bTasterKipparmeAuf
  AND in_bSensorKipparmeAnschlaegeOben
  AND in_bSensorKipparmeNichtOben
  AND NOT in_bTasterKipparmeAb
THEN
  outbKipparmeAuf := TRUE;
  outbKipparmeAb  := FALSE;
ELSE
  outbKipparmeAuf := FALSE;
END_IF

(* Kipparme ab fahren *)
IF in_bTasterKipparmeAb
  AND in_bSensorKipparmeNichtUnten
  AND NOT in_bTasterKipparmeAuf
THEN
  outbKipparmeAuf := FALSE;
  outbKipparmeAb  := TRUE;
ELSE
  outbKipparmeAb := FALSE;
END_IF
END_ACTION