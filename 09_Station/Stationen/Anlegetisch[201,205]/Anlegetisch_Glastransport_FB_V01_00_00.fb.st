(* METADATA
{
	"v3Meta": {
		"objectGuid": "293c075f-e4eb-4596-80bf-f2217638693b"
	}
}
*)
FUNCTION_BLOCK Anlegetisch_Glastransport_FB_V01_00_00 EXTENDS Basic_Glastransport_FB_V01_00_00
VAR

  // TRIGGER
  ftlScheibeVorFahren         : F_TRIG;

END_VAR

VAR
// BOOL
  
END_VAR
(* Hinweis:
   - Master aufrufen
*)
SUPER^();

//-------------------------------------------------------------------------------------------------
// AUFRUFE
//-------------------------------------------------------------------------------------------------
// Die Aktionen werden im Master aufgerufen (auch die Laengenmessung)
;
END_FUNCTION_BLOCK