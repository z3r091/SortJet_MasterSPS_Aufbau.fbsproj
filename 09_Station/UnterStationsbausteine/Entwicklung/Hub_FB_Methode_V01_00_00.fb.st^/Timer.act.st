(* METADATA
{
	"v3Meta": {
		"objectGuid": "98ac83fd-f1bc-46a3-bfd6-12fae1391740"
	}
}
*)
ACTION Timer
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: TIMER, TRIGGER, ETC.
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Ueberwachung
*)
tonlMaxWarteZeit( IN:=( bpStartHubAb OR bpStartHubAuf ),
                  PT:=(WORD_TO_TIME(ppParameterBaustein.wMaximaleWartezeitHub ) ) );


tonlMaximaleWartezeitAufReset( IN := bpReset, PT := T#10S );
 
(* Hinweis:
   - Um nicht beim Starten der Anlage in einem Fehler zustehen (HubAntrieb Fehler ist Zeitgesteuert),
     wird der Fehler erst nach einigen Sekunden nach dem ersten Durchlaufen dieses Bausteins ausgewertet
*)
tonlFehlermeldungUnterdrueckenAntriebOK( IN := NOT blErsterZyklus,
                                         PT := T#4s );
END_ACTION