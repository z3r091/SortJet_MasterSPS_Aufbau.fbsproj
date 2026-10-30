(* METADATA
{
	"v3Meta": {
		"objectGuid": "293c075f-e4eb-4596-80bf-f2217638693b"
	}
}
*)
FUNCTION_BLOCK Anlegetisch_Glastransport_FB EXTENDS Basic_Glastransport_FB
VAR_INPUT
	
  // BOOLEAN
  bpAnforderungHandfunktion      : BOOL;  
  bpScheibeQuittiert             : BOOL;
  bpScheibeFreigegeben           : BOOL;
  
END_VAR
VAR

  // TRIGGER
  ftlScheibeZurueckFahren     : F_TRIG;
  ftlScheibeVorFahren         : F_TRIG;

END_VAR

VAR_OUTPUT

  // BOOLEAN
  bpAnforderungMessergebnis  : BOOL; (* STATUS: Riemen wartet auf das Scann- Ergebnis aus dem Uebergeordneteten Baustein *)
    
END_VAR 

VAR
  // BOOL
  
END_VAR
(* Hinweis:
   - Master aufrufen
*)
SUPER^();

(***************************************************************************************************)
(*  AUFRUFE *)
(***************************************************************************************************)
// Die fehlenden Aktionen werden im Master aufgerufen
Laengenmessung();
END_FUNCTION_BLOCK