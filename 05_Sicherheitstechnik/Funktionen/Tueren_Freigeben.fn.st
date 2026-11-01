(* METADATA
{
  "v3Meta": {
    "objectGuid": "3e444047-0bbc-4115-8663-bc85922a54df"
  }
}
*)
FUNCTION Tueren_Freigeben : WORD
VAR_INPUT
END_VAR
VAR
  // WORD
  wTemp  : WORD;
  wIndex : WORD;
END_VAR

// Bit Kodiert setzen welche Tür geöffnet werden soll
wTemp := 2#0000000000000000;
Tueren_Freigeben := 2#0000000000000000;
FOR wIndex := 1 TO cLETZTE_TUER DO
  IF aTuer[wIndex].out_bTuerZuhaltungDeaktivieren THEN
    wTemp := 2#0000000000000001;
    wTemp := SHL(wTemp,wIndex -1);
  END_IF
  Tueren_Freigeben := wTemp OR Tueren_Freigeben;
END_FOR
END_FUNCTION