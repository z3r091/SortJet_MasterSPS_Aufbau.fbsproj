(* METADATA
{
  "v3Meta": {
    "objectGuid": "a87131f4-5e77-4d9f-8573-9f205355a0c5"
  }
}
*)
{attribute 'excludefrombuild'}
ACTION A_Changelog
(* !!! VERSIONSÄNDERUNGEN WERDEN HIER DETAILLIERT DOKUMENTIERT !!!

- 2026-04-15 - V01_00_00:
  - Übernahme des Bausteins; Erste Version die Freigegeben wird/wurde
  
- 2026-04-15 - V01_01_00: Daniel Vogelsang
  -  Aktion Messung
     - In Step 30 wird überwacht, ob der Einlaufsensor nach einem bestimmten weg frei wird. Der Auslaufsensor wird Glastyp abhängig ebenfalls überwacht, ob dieser True wird.
     - In Step 50 wird, wenn das Ergebnis 0 ist, wird der Fehler "Fehler Glasmessung" ausgegeben. Zuvor ist die SPS in den Step hängen geblieben

- 2026-11-02 - V01_01_01: Tobias Brekerbohm, Claude
  - Übernahme in den Master; Version im Bausteinnamen

*)
END_ACTION