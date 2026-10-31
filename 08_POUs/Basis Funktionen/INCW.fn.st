(* METADATA
{
  "v3Meta": {
    "objectGuid": "c3800ee6-fccf-491b-bd53-b6c1155883a9"
  }
}
*)
FUNCTION INCW : WORD
VAR_INPUT
  X : WORD;
  N : WORD;
END_VAR



(* Hinweis:
   - Funktion zum erhoehen der Eingangsvariablen X um 1. Sobald X den Wert N erreicht hat startet der Wert wieder bei 0.
*)
IF ( X >= N - 1 ) THEN
  INCW := 0;
ELSE
  INCW := X + 1;
END_IF;
END_FUNCTION