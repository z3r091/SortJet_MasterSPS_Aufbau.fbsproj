(* METADATA
{
  "v3Meta": {
    "objectGuid": "2275e5b1-b203-4bf0-b30f-688441afb91b"
  }
}
*)
METHOD M_AuftragFreigabe : BOOL
VAR_INPUT
  bpAuftragAktiv   : BOOL; // Station bearbeitet einen Auftrag mit hydraulischen Bewegungen
  bpAuftragStarten : BOOL; // Station moechte einen neuen Auftrag mit hydraulischen Bewegungen starten
END_VAR

(* Hinweis:
   - Jede zugeordnete Faecherwagenstation ruft die Methode zyklisch vor dem Aufruf der Hydraulikstation auf
   - Die Leistung des Aggregats reicht nur fuer eine begrenzte Anzahl gleichzeitiger Auftraege
     (MK wMaximaleAnzahlAktiverAuftraege, 0 = unbegrenzt)
   - Rueckgabe TRUE: Auftrag laeuft bereits oder darf starten; die Station startet ihn im naechsten Zyklus
     und meldet ihn ab dann als aktiv
   - Gezaehlt wird gegen die aktiven Auftraege des letzten Zyklus plus die in diesem Zyklus neu
     freigegebenen, damit zwei Stationen im selben Zyklus nicht beide freigegeben werden
*)
IF ( bpAuftragAktiv ) THEN
  wlAktiveAuftraegeZyklus := wlAktiveAuftraegeZyklus + 1;
  M_AuftragFreigabe       := TRUE;

ELSIF ( bpAuftragStarten ) THEN

  IF    NOT __ISVALIDREF(refMK)
     OR_ELSE ( refMK.wMaximaleAnzahlAktiverAuftraege = 0 )
     OR_ELSE ( ( wlAktiveAuftraege + wlNeueAuftraegeZyklus ) < refMK.wMaximaleAnzahlAktiverAuftraege )
  THEN
    wlNeueAuftraegeZyklus   := wlNeueAuftraegeZyklus + 1;
    wlAktiveAuftraegeZyklus := wlAktiveAuftraegeZyklus + 1;
    M_AuftragFreigabe       := TRUE;
  ELSE
    M_AuftragFreigabe       := FALSE;
  END_IF

ELSE
  M_AuftragFreigabe := FALSE;
END_IF
END_METHOD