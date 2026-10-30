(* METADATA
{
	"v3Meta": {
		"objectGuid": "ee7aef0f-72fa-489b-b1e8-8477729edc64"
	}
}
*)
ACTION SteuerungLuftschranken
IF blNeueLogikLuftschrankenAktiv THEN

(* Hinweis:

  Vorwort:
    Die Luftschranken werden nicht mehr direkt über den Ausgang ein- und ausgeschaltet, sondern
    über eine Merker Variable.
    Diese Änderung war notwendig, da es nicht mehr ein Federrückgestelltes Ventil war, sondern ein
    Impulsventil mit 2 Ausgängen: ein- und ausschalten.

  Funktion:
    Wird eine die Variable eingeschaltet, und das für über 250ms (um Wechsel des Bits die nur ein Zyklus
    stattfinden (aufgrund von z. B. fehlerhafter Code), dann wird ein Trigger geschaltet.


*)
tonLuftschrankeEinlaufEin( IN := blScheibenKontrolleEinlaufseiteEin , PT := t#250ms );
tonLuftschrankeEinlaufAus( IN := NOT blScheibenKontrolleEinlaufseiteEin , PT := t#250ms );
tonLuftschrankeAuslaufEin( IN := blScheibenKontrolleAuslaufseiteEin , PT := t#250ms );
tonLuftschrankeAuslaufAus( IN := NOT blScheibenKontrolleAuslaufseiteEin , PT := t#250ms );

(* Hinweis:

  Funktion:
    Deiser Trigger ist hier zu finden. Der Trigger schaltet, wenn das Merkerbit lange genug
    aktiv ist zum einschalten der Luftschranke. Schaltet es, folgt eine Ausschaltverzögerung.

*)
rtlLuftschrankeEinlaufEin( CLK := tonLuftschrankeEinlaufEin.Q );
rtlLuftschrankeEinlaufAus( CLK := tonLuftschrankeEinlaufAus.Q );
rtlLuftschrankeAuslaufEin( CLK := tonLuftschrankeAuslaufEin.Q );
rtlLuftschrankeAuslaufAus( CLK := tonLuftschrankeAuslaufAus.Q );

(* Hinweis:

  Funktion:
    Diese Ausschaltverzögerung dient dazu, den Ausgang lang genug zu beschreiben. Ein Trigger
    wäre nur ein Zyklus auf TRUE, was nicht ausreichen wird, um das Ventil zu schalten, da die
    Buslaufzeit viel zu lange ist

*)
tofLuftschrankeEinlaufEin( IN := rtlLuftschrankeEinlaufEin.Q , PT := t#500ms );
tofLuftschrankeEinlaufAus( IN := rtlLuftschrankeEinlaufAus.Q , PT := t#500ms );
tofLuftschrankeAuslaufEin( IN := rtlLuftschrankeAuslaufEin.Q , PT := t#500ms );
tofLuftschrankeAuslaufAus( IN := rtlLuftschrankeAuslaufAus.Q , PT := t#500ms );

(* Hinweis:

  Funktion:
    Die Ausschaltverzögerung wird letztlich auf den passenden Ausgang korrekt geschrieben und somit
    auch auf das Ventil. Wir haben also insgesamt Eine Verzögerung von min. 250ms zum starten der
    Luftschranke wenn das Merkerbit geschrieben wurde.

*)
out_bScheibenKontrolleEinlaufSeiteEinschalten := tofLuftschrankeEinlaufEin.Q;
out_bScheibenKontrolleAuslaufSeiteEinschalten := tofLuftschrankeAuslaufEin.Q;

ELSE

  out_bScheibenKontrolleEinlaufSeiteEinschalten := blScheibenKontrolleEinlaufseiteEin;
  out_bScheibenKontrolleAuslaufSeiteEinschalten := blScheibenKontrolleAuslaufseiteEin;

END_IF
END_ACTION