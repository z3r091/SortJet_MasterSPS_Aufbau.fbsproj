(* METADATA
{
	"v3Meta": {
		"objectGuid": "d72a9e43-2104-4490-bd51-13d6e7b9c79c"
	}
}
*)
FUNCTION_BLOCK Taktberechnung_FB
VAR_INPUT
  Signal             : BOOL;
END_VAR
VAR_OUTPUT
  Herz               : REAL;
END_VAR
VAR

  SignalSteigend     : R_TRIG;
  SignalFallend      : F_TRIG;

  tonZeitmessungOn   : TON;
  tonZeitmessungOff  : TON;

  tlOn               : TIME;
  tlOff              : TIME;
  tlHerz             : TIME;

END_VAR
SignalSteigend( CLK := Signal);
SignalFallend( CLK := Signal);

IF SignalSteigend.Q THEN
  tlOff := tonZeitmessungOff.ET;
END_IF

IF SignalFallend.Q THEN
  tlOn := tonZeitmessungOn.ET;
END_IF

tonZeitmessungOn( IN := Signal, PT := t#2s );
tonZeitmessungOff( IN := NOT Signal, PT := t#2s );

tlHerz := tlOff + tlOn;
IF tlHerz = T#0MS THEN
  tlHerz := T#1MS;
END_IF

IF NOT tonZeitmessungOff.Q AND NOT tonZeitmessungOn.Q THEN
  Herz := ( 1 / (TIME_TO_REAL(tlHerz) / 1000 ) );
ELSE
  Herz := 0.0;
END_IF
END_FUNCTION_BLOCK