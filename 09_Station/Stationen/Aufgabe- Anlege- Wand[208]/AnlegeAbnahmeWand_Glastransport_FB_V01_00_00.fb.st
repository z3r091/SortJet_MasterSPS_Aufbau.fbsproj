(* METADATA
{
  "v3Meta": {
    "objectGuid": "09fd4fa8-a37f-4c73-a399-1240fdc7917f"
  }
}
*)
FUNCTION_BLOCK AnlegeAbnahmeWand_Glastransport_FB_V01_00_00 EXTENDS Basic_Glastransport_FB_V01_00_00
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