(* METADATA
{
	"v3Meta": {
		"objectGuid": "2fba16dc-56bd-4c56-9768-dbe33d4a7ec0"
	}
}
*)
FUNCTION_BLOCK AuftragsSpeicherStationen
VAR_INPUT

  (* BOOLEAN *)
  bpReset            : BOOL;
  bpNeuerAuftrag     : BOOL;
  bpNaechsterAuftrag : BOOL;

  (* STRUCT *)
  NeuerAuftrag : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpFehler             : BOOL;
  bpAuftragverfuegbar : BOOL := FALSE;

  (* STRUCT *)
  AktAuftrag : Auftragsdaten_ST;

END_VAR
VAR

  (* STRUCT *)
  MerkerAuftrag :Auftragsdaten_ST;

END_VAR
(* Hinweis:
   - Auftragsdaten- Speicher fuer die " STATIONEN "
*)
IF ( bpNeuerAuftrag ) THEN
  bpNeuerAuftrag:=FALSE;
  MerkerAuftrag := NeuerAuftrag;
  bpAuftragverfuegbar := TRUE;
END_IF

IF ( bpNaechsterAuftrag AND bpAuftragverfuegbar ) THEN
  bpNaechsterAuftrag := FALSE;
  AktAuftrag := MerkerAuftrag;
  bpAuftragverfuegbar:=FALSE;
END_IF

IF ( bpReset ) THEN
  bpFehler := FALSE;
  bpReset := FALSE;
  bpAuftragverfuegbar:=FALSE;
END_IF
END_FUNCTION_BLOCK