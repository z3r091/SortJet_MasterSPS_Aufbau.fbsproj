(* METADATA
{
	"v3Meta": {
		"objectGuid": "09fd4fa8-a37f-4c73-a399-1240fdc7917f"
	}
}
*)
FUNCTION_BLOCK AnlegeAbnahmeWand_Glastransport_FB EXTENDS Basic_Glastransport_FB
VAR_INPUT
	
  // BOOLEAN
  bpAnforderungHandfunktion      : BOOL;  
  bpScheibeQuittiert             : BOOL;
  bpScheibeFreigegeben           : BOOL;
  
END_VAR
VAR

  // TRIGGER
  ftlScheibeZurueckFahren     : F_TRIG;

END_VAR

VAR_OUTPUT

  // BOOLEAN
  bpAnforderungMessergebnis  : BOOL; (* STATUS: Riemen wartet auf das Scann- Ergebnis aus dem Uebergeordneteten Baustein *)
 
  
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