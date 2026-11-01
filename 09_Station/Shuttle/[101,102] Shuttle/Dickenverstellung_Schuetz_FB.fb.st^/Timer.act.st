(* METADATA
{
  "v3Meta": {
    "objectGuid": "74339379-23b8-4010-bb8a-908a4d53c2ee"
  }
}
*)
ACTION Timer
(***************************************************************************************************)
(* BAUSTEIN: TIMER, TRIGGER, ETC. *)
(***************************************************************************************************)
(* Hinweis:
   - Ueberwachung 
*)
tonlMaxWarteZeit(IN:=( (   bpVerstellungSchliessen AND out_bVerstellungSchliessen)
                       OR (bpVerstellungOeffnen AND out_bVerstellungOeffnen)),
                  PT:= T#10S);


(* Hinweis:
   - Um nicht beim Starten der Anlage in einem Fehler zustehen (HubAntrieb Fehler ist Zeitgesteuert), 
     wird der Fehler erst nach einigen Sekunden nach dem ersten Durchlaufen dieses Bausteins ausgewertet 
*)
tonlFehlermeldungUnterdrueckenAntriebOK( IN := NOT blErsterZyklus,
                                         PT := T#4s );
END_ACTION