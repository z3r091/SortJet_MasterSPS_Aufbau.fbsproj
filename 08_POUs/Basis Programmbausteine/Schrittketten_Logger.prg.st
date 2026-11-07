(* METADATA
{
	"v3Meta": {
		"objectGuid": "cb3b1eb5-1dc3-4d16-abd2-ade96f8e42d9"
	}
}
*)
PROGRAM Schrittketten_Logger
VAR

  // WORD
  i              : WORD;
  j              : WORD;
  wiSchrittkette : ARRAY[0..7] OF WORD;
  wlSchrittkette : ARRAY[0..7,0..31] OF WORD;

  // STRING
  sBezeichnung   : ARRAY[0..7] OF STRING;


END_VAR
sBezeichnung[0]   := ' - ';
wiSchrittkette[0] := 0;     

sBezeichnung[1]   := ' - ';
wiSchrittkette[1] := 0;    

sBezeichnung[2]   :=  ' - ';
wiSchrittkette[2] :=  0;       

sBezeichnung[3]   :=  ' - ';
wiSchrittkette[3] :=  0;    

sBezeichnung[4]   := ' - ';
wiSchrittkette[4] := 0;

sBezeichnung[5]   := ' - ';
wiSchrittkette[5] := 0;    

sBezeichnung[6]   := ' - ';
wiSchrittkette[6] := 0;

sBezeichnung[7]   := ' - ';
wiSchrittkette[7] := 0;

FOR i := 0 TO 7 DO

  IF(wiSchrittkette[i] <> wlSchrittkette[i,31])THEN;

    FOR j := 0 TO 30 DO
      wlSchrittkette[i,j] := wlSchrittkette[i,j+1];
    END_FOR

    wlSchrittkette[i,31] := wiSchrittkette[i];
  END_IF

END_FOR
END_PROGRAM