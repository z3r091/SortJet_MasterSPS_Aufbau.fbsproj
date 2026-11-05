(* METADATA
{
  "v3Meta": {
    "objectGuid": "a1f16c92-caf1-4fb2-b3e1-8749538944e0"
  }
}
*)
METHOD M_Anfordern
VAR_INPUT
  bpHydraulikEin      : BOOL; // Station fordert eine hydraulische Bewegung an
  bpUmlaufventilPause : BOOL; // Station nimmt das Umlaufventil zwischen zwei Bewegungen kurz zurueck
END_VAR

(* Hinweis:
   - Jede zugeordnete Faecherwagenstation ruft die Methode zyklisch vor dem Aufruf der Hydraulikstation auf
   - Anforderungen aller Stationen werden ODER-verknuepft
*)
blAnforderungHydraulik         := blAnforderungHydraulik OR bpHydraulikEin;
blAnforderungUmlaufventilPause := blAnforderungUmlaufventilPause OR bpUmlaufventilPause;
END_METHOD