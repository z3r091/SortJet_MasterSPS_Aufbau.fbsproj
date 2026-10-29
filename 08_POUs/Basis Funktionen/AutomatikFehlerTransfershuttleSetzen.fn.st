(* METADATA
{
	"v3Meta": {
		"objectGuid": "9a4c379e-af86-4c9e-b628-bbb819ee7aed"
	}
}
*)
FUNCTION AutomatikFehlerTransfershuttleSetzen : BOOL
VAR_INPUT
	eaAutomatikkreise : ARRAY[cERSTER_AUTOMATIKKREIS..cANZAHL_AUTOMATIKKREISE] OF Automatikkreis_EN;
	abpFehler : REFERENCE TO ARRAY[cERSTER_AUTOMATIKKREIS..cLETZTER_AUTOMATIKKREIS] OF BOOL;
  wSpeicherseiteFehler : BYTE;
END_VAR

(*
// TS hat nur einen AK
IF eaAutomatikkreise[1] <> 0 AND eaAutomatikkreise[2] = 0 THEN
    abpFehler[eaAutomatikkreise[1]] := TRUE;
// TS hat 2 AK 
ELSIF eaAutomatikkreise[1] <> 0 AND eaAutomatikkreise[2] <> 0 THEN
  IF wSpeicherseiteFehler = cSPEICHER_EINLAUFSEITE THEN
    abpFehler[eaAutomatikkreise[1]] := TRUE;
  ELSIF wSpeicherseiteFehler = cSPEICHER_AUSLAUFSEITE THEN
    abpFehler[eaAutomatikkreise[2]] := TRUE;
  END_IF
END_IF
*)
AutomatikFehlerTransfershuttleSetzen := TRUE;
END_FUNCTION