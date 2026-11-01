(* METADATA
{
  "v3Meta": {
    "objectGuid": "168dbbd9-344e-42fa-bcd9-fdc0c371e733"
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
tonlMaxWarteZeit(IN:= bpPositionieren,
                  PT:=(ppParameterBaustein.tZeitlicheUeberwachungKippen));


(* Hinweis:
   - Um nicht beim Starten der Anlage in einem Fehler zustehen (KippenAntrieb Fehler ist Zeitgesteuert), 
     wird der Fehler erst nach einigen Sekunden nach dem ersten Durchlaufen dieses Bausteins ausgewertet 
*)
tonlFehlermeldungUnterdrueckenAntriebOK( IN := NOT blErsterZyklus,
                                         PT := T#4s );

(* Timer:
   - Reset- Phoenix Modul
*)
toflReset( IN := bpReset , PT :=  T#3S );
END_ACTION