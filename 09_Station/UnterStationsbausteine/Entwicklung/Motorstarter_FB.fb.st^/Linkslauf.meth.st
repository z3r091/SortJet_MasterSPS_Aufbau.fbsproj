(* METADATA
{
	"v3Meta": {
		"objectGuid": "901ae501-1a81-4a6e-8340-32118915e16c"
	}
}
*)
METHOD Linkslauf : BOOL
VAR_INPUT
END_VAR

VAR
	tonlMaxWarteZeit : TON;
	
END_VAR
Linkslauf := FALSE;

tonlMaxWarteZeit( IN := TRUE, PT:= T#4000MS );
IF ( tonlMaxWarteZeit.Q ) THEN
   bpFehler := TRUE;
   wpFehlerNr := cMELDUNG_MOTORSTARTER_FEHLER_LINKSLAUF_OK;
   out_bLinkslauf := FALSE;
END_IF

out_bLinkslauf := bpSensorNotNockeLinkslauf;

IF NOT bpSensorNotNockeLinkslauf THEN
  Linkslauf := TRUE;
END_IF
END_METHOD