(* METADATA
{
	"v3Meta": {
		"objectGuid": "a208902d-2df6-4041-b9d3-eb345b2f3a75"
	}
}
*)
FUNCTION_BLOCK Kipptisch_Restezufuehrung_Glastransport_FB EXTENDS Kipptisch_Glastransport_FB
VAR_INPUT
	
  // BOOLEAN

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