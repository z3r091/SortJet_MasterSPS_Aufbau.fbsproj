(* METADATA
{
	"v3Meta": {
		"objectGuid": "8440d4b2-0d12-462a-874f-5dd80fe8d64c"
	}
}
*)
FUNCTION Safety_Ausloesen : WORD
VAR_INPUT
END_VAR
VAR
  // WORD
  wTemp  : WORD;
  wIndex : WORD;
END_VAR

// Bit Kodiert setzen welcher Sicherheitskreis freigegeben werden soll
wTemp := 2#0000000000000000;
Safety_Ausloesen := 2#0000000000000000;
FOR wIndex := 1 TO cANZAHL_SICHERHEITSKREISE DO
 IF Sicherheitskreis[wIndex].bpFreigabeSafetyAusloesen THEN
   wTemp := 2#0000000000000001;
   wTemp := SHL(wTemp,wIndex -1);
 END_IF
Safety_Ausloesen := wTemp OR Safety_Ausloesen;
END_FOR
END_FUNCTION