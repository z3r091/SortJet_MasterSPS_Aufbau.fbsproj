(* METADATA
{
	"v3Meta": {
		"objectGuid": "35aa6819-3357-423e-91ac-0c94eb5a5c7a"
	}
}
*)
FUNCTION SetWatchIO : Bool
VAR_INPUT
  in_Word   : WORD;
  in_Number : WORD;
END_VAR
VAR   
  wIndex    : WORD;
END_VAR

FOR wIndex := 0 TO 15 DO
  WatchIo(((in_Word AND (SHL(1, wIndex))) <> 0), (in_Number - 1) + (wIndex + 1));
END_FOR;

//ChangedBits := in_Word XOR old_Word;
//
//IF ChangedBits <> 0 THEN
//
//    FOR i := 0 TO 15 DO
//        IF (ChangedBits AND (SHL(1 , i))) <> 0 THEN
//            WatchIo(((in_Word AND ( SHL(1, i))) <> 0), (in_Number -1) +(i+1) );
//        END_IF;
//    END_FOR;
//  old_Word := in_Word; // alten Wert speichern
//END_IF;
END_FUNCTION