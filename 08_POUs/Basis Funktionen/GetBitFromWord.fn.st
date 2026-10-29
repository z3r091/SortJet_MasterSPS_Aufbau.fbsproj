(* METADATA
{
	"v3Meta": {
		"objectGuid": "4ac38ee7-2639-4587-9c58-5882c3701cd8"
	}
}
*)
FUNCTION GetBitFromWord : Bool
VAR_INPUT    
    Value : WORD;   // Das Wort, aus dem du die Bits auslesen willst
    Index : Word;    // Welches Bit (0..15)
END_VAR
VAR
END_VAR

GetBitFromWord := (Value AND SHL(1, Index)) <> 0;
END_FUNCTION