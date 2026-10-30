(* METADATA
{
	"v3Meta": {
		"objectGuid": "5621efb7-cd40-4c15-9d03-482a92cbc1a2"
	}
}
*)
ACTION FUNKTION_Absolut_setzen
IF bpAbsolutSetzen THEN

  CASE asteplSchritt[ABSOLUT_SETZEN] OF

    STEP_0_E:  
      bpAbsolutSetzenDone := FALSE;
      SignalSteuerWort.0 := TRUE; // Referenz ablöschen
      IF NOT bpIstReferenziert THEN
        SignalSteuerWort.0 := FALSE; // Referenz ablöschen
        asteplSchritt[ABSOLUT_SETZEN] := STEP_10_E;        
      END_IF  

    STEP_10_E:
      SignalSteuerWort.14 := TRUE; //Referenz setzen
      IF bpIstReferenziert THEN
        SignalSteuerWort.14 := FALSE; 
        asteplSchritt[ABSOLUT_SETZEN] := STEP_1000_E;        
      END_IF

    STEP_900_E:
      ;

    STEP_1000_E:
      bpAbsolutSetzenDone := TRUE;  

  END_CASE


ELSE
  bpAbsolutSetzenDone := FALSE;
  SignalSteuerWort.0  := FALSE;
  SignalSteuerWort.14 := FALSE;
  asteplSchritt[ABSOLUT_SETZEN] := STEP_0_E;

END_IF
END_ACTION