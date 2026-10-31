(* METADATA
{
  "v3Meta": {
    "objectGuid": "47a21df2-edbb-49b0-932f-ef927933ed32"
  }
}
*)
FUNCTION INCI : INT
VAR_INPUT
  X : INT;
  N : INT;
END_VAR



(* Hinweis:
   - Funktion zum erhoehen der Eingangsvariablen X um 1. Sobald X den Wert N erreicht hat startet der Wert wieder bei 0.
*)
IF ( X >= N - 1 ) THEN
	INCI := 0;
ELSE
	INCI := X + 1;
END_IF;
END_FUNCTION