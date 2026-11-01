(* METADATA
{
  "v3Meta": {
    "objectGuid": "776e2b82-2de4-416c-bff2-678a8194ecb8"
  }
}
*)
ACTION Kipparme
//-------------------------------------------------------------------------------------------------
// AKTION KIPPARME
//-------------------------------------------------------------------------------------------------
rtlKipparmeAnschlaegeAuf(CLK := in_bTasterKipparmeAuf);
rtlKipparmeAnschlaegeAb(CLK := in_bTasterKipparmeAb);

// Anschläge ein/aus fahren
IF rtlKipparmeAnschlaegeAuf.Q
   AND NOT in_bSensorKipparmeAnschlaegeOben
THEN
  out_bKipparmeAnschlaegeAb  := FALSE;
  out_bKipparmeAnschlaegeAuf := TRUE;
END_IF

IF rtlKipparmeAnschlaegeAb.Q
   AND NOT in_bSensorKipparmeNichtUnten
THEN
  out_bKipparmeAnschlaegeAb  := TRUE;
  out_bKipparmeAnschlaegeAuf := FALSE;
END_IF

// Kipparme auf fahren
IF in_bTasterKipparmeAuf
   AND in_bSensorKipparmeAnschlaegeOben
   AND in_bSensorKipparmeNichtOben
   AND NOT in_bTasterKipparmeAb
THEN
  out_bKipparmeAuf := TRUE;
  out_bKipparmeAb  := FALSE;
ELSE
  out_bKipparmeAuf := FALSE;
END_IF

// Kipparme ab fahren
IF in_bTasterKipparmeAb
   AND in_bSensorKipparmeNichtUnten
   AND NOT in_bTasterKipparmeAuf
THEN
  out_bKipparmeAuf := FALSE;
  out_bKipparmeAb  := TRUE;
ELSE
  out_bKipparmeAb := FALSE;
END_IF
END_ACTION