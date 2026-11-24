(* METADATA
{
	"v3Meta": {
		"objectGuid": "8dc432ad-fadb-4851-919a-23df82dc8299"
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
tonlMaxWarteZeit(IN:=( (bpStartHubAb AND out_bHubAbSetzen)
                       OR (bpStartHubAuf AND out_bHubAufSetzen)),
                  PT:=MAXIMALE_WARTEZEIT_HUB );


(* Hinweis:
   - Um nicht beim Starten der Anlage in einem Fehler zustehen (HubAntrieb Fehler ist Zeitgesteuert),
     wird der Fehler erst nach einigen Sekunden nach dem ersten Durchlaufen dieses Bausteins ausgewertet
*)
tonlFehlermeldungUnterdrueckenAntriebOK( IN := NOT blErsterZyklus,
                                         PT := T#4s );
END_ACTION