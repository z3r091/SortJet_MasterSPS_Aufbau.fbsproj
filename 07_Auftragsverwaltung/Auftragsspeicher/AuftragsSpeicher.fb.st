(* METADATA
{
	"v3Meta": {
		"objectGuid": "f0eea758-4d67-47c3-84cf-9e26ec72588d"
	}
}
*)
FUNCTION_BLOCK AuftragsSpeicher
VAR_INPUT
 bpReset:BOOL;
 bpNeuerAuftrag:BOOL;
 bpNaechsterAuftrag :BOOL;
 NeuerAuftrag : Auftragsdaten_ST;
END_VAR
VAR_OUTPUT
 bpFehler:BOOL;
 bpAuftragverfuegbar:BOOL:=FALSE;
 AktAuftrag  :Auftragsdaten_ST;
END_VAR
VAR
 MerkerAuftrag :Auftragsdaten_ST;
END_VAR
(* Hinweis:
   - Auftragsdaten- Speicher fuer die " SHUTTLE "
*)
IF bpNeuerAuftrag THEN
 bpNeuerAuftrag:=FALSE;
 MerkerAuftrag := NeuerAuftrag;
 bpAuftragverfuegbar := TRUE;
END_IF

IF bpNaechsterAuftrag AND bpAuftragverfuegbar THEN
 bpNaechsterAuftrag := FALSE;
 AktAuftrag := MerkerAuftrag;
 bpAuftragverfuegbar:=FALSE;
END_IF

IF bpReset THEN
 bpFehler := FALSE;
 bpReset := FALSE;
 bpAuftragverfuegbar:=FALSE;
END_IF
END_FUNCTION_BLOCK