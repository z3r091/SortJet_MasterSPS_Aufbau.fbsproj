(* METADATA
{
	"v3Meta": {
		"objectGuid": "6a30dc93-6cfb-42ec-8e94-53fcaf08507e"
	}
}
*)
FUNCTION RemoveETX : ARRAY [0..3] OF DWORD
VAR_INPUT
  SheetID : ARRAY [0..3] OF DWORD;
END_VAR
VAR
  i, dwIn, dwOut, sh : INT;
  b : BYTE;
  tmp : DWORD;
END_VAR
FOR i := 0 TO 3 DO RemoveETX[i] := DWORD#0; END_FOR;

FOR i := 0 TO 15 DO
  dwIn := i / 4; sh := (i MOD 4) * 8;

  tmp := SHR(SheetID[dwIn], sh);     (* byte runter schieben *)
  tmp := tmp MOD DWORD#256;          (* entspricht AND 16#FF *)
  b := DWORD_TO_BYTE(tmp);

  IF b = BYTE#16#03 THEN b := BYTE#0; END_IF;

  dwOut := i / 4; sh := (i MOD 4) * 8;
  RemoveETX[dwOut] := RemoveETX[dwOut] + SHL(BYTE_TO_DWORD(b), sh);  (* + statt OR *)
END_FOR;
END_FUNCTION