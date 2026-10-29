(* METADATA
{
	"v3Meta": {
		"objectGuid": "7ae6aadb-d504-4a64-ae44-49a559d1f9ad"
	}
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Motorstarter_FB
VAR_INPUT
	bpReset                    : BOOL;
	bpMotorstarterOK           : BOOL;  
	bpSensorNotNockeLinkslauf  : BOOL;
	bpSensorNotNockeRechtslauf : BOOL;
END_VAR
VAR_OUTPUT
  bpFehler   : BOOL;
  bpdone     : BOOL;
  
  wpFehlerNr : Fehlerkonstanten_EN;
  
  // IO's
  out_bLinkslauf   : BOOL;
  out_bRechtslauf  : BOOL;
  out_Reset        : BOOL;
  out_BremseLoesen : BOOL;
  
END_VAR
VAR
  // BOOLEAN 
  blErsterZyklus : BOOL := TRUE;
  
  // TIMER
  tonlFehlermeldungUnterdrueckenAntriebOK : TON;
	
END_VAR

(* Hinweis:
   - Um nicht beim Starten der Anlage in einem Fehler zustehen (HubAntrieb Fehler ist Zeitgesteuert), 
     wird der Fehler erst nach einigen Sekunden nach dem ersten Durchlaufen dieses Bausteins ausgewertet 
*)
tonlFehlermeldungUnterdrueckenAntriebOK( IN := NOT blErsterZyklus,
                                         PT := T#4s );

IF bpReset THEN
  bpdone := Reset();
ELSIF bpFehler THEN
  out_bLinkslauf  := FALSE;	
  out_bRechtslauf := FALSE;	  
ELSE
  bpdone := FALSE;
END_IF

// Bremse lösen
out_BremseLoesen := out_bLinkslauf OR out_bRechtslauf;
END_FUNCTION_BLOCK