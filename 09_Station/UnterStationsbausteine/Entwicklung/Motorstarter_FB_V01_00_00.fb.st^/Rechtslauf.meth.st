(* METADATA
{
	"v3Meta": {
		"objectGuid": "9a97d710-cc7f-4070-b236-0ffc8d0344e1"
	}
}
*)
METHOD Rechtslauf : BOOL
VAR_INPUT
END_VAR

VAR
  tonlMaxWarteZeit : TON;

END_VAR
Rechtslauf := FALSE;

tonlMaxWarteZeit( IN := TRUE, PT:= T#4000MS );
IF ( tonlMaxWarteZeit.Q )THEN
  bpFehler := TRUE;
  wpFehlerNr := cMELDUNG_MOTORSTARTER_FEHLER_RECHTSLAUF_OK;
  out_bRechtslauf := FALSE;
END_IF

out_bRechtslauf := bpSensorNotNockeRechtslauf;

IF NOT bpSensorNotNockeRechtslauf THEN
  Rechtslauf := TRUE;
END_IF
END_METHOD