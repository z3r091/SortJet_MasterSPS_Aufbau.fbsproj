(* METADATA
{
	"v3Meta": {
		"objectGuid": "e658493f-ee55-49d1-b74f-ae85f8ce4fd2"
	}
}
*)
METHOD PRIVATE ScheibenID : ARRAY [0..3] OF DWORD
VAR_INPUT
  wFremdanlage  : WORD;
  adwScheibenID : ARRAY [0..3] OF DWORD;
END_VAR

// Hinweis:
// - Scheiben-ID aus dem MMI uebernehmen, ETX nur entfernen wenn per MK aktiviert (stFremdanlage.bRemoveETX)
IF ( starrFremdanlageAuslaufStationBasisParameter[wFremdanlage].stMKs.stFremdanlage.bRemoveETX ) THEN
  ScheibenID := RemoveETX( adwScheibenID );
ELSE
  ScheibenID := adwScheibenID;
END_IF
END_METHOD