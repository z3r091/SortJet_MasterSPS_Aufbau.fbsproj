(* METADATA
{
  "v3Meta": {
    "objectGuid": "b7be4780-1c3e-4371-bb2a-cc9122a11be5"
  }
}
*)
FUNCTION PruefungWertImIntervall : BOOL
VAR_INPUT

  // WORD
  wpWert         : WORD;
  wpIntervallMin : WORD;
  wpIntervallMax : WORD;

END_VAR
VAR
END_VAR
//-------------------------------------------------------------------------------------------------
// LOGIK
//-------------------------------------------------------------------------------------------------
IF (  wpWert >= wpIntervallMin
     AND wpWert <= wpIntervallMax )
THEN
  PruefungWertImIntervall := TRUE;
ELSE
  PruefungWertImIntervall := FALSE;
END_IF
END_FUNCTION