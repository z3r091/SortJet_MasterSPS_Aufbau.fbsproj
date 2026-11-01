(* METADATA
{
  "v3Meta": {
    "objectGuid": "339b2ef9-3f23-482c-98f4-06c495d9a955"
  }
}
*)
FUNCTION AutomatikAktiv : BOOL
VAR_INPUT
  wpMmiNummer : WORD;
END_VAR
VAR
  wlIndex : WORD;
  Basis   : REFERENCE TO StationBasisParameter_ST;
END_VAR

// Hinweis:
// - Prueft ob einer der Automatikkreise der Station (Shuttle, TS, Station, Faecherwagen, Fremdanlage) aktiv ist
// - Die Basis wird ueber getBasis bestimmt
// - Unbekannte Nummer oder nicht zugewiesene MK => FALSE
// - Ein nicht belegter Automatikkreis (0) beendet die Pruefung
AutomatikAktiv := FALSE;

Basis REF= getBasis( wpMmiNummer );

IF NOT __ISVALIDREF( Basis ) THEN
  RETURN;
END_IF

IF NOT __ISVALIDREF( Basis.stMKs ) THEN
  RETURN;
END_IF

FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO

  IF Basis.stMKs.eaAutomatikkreis[wlIndex] = 0 THEN
    RETURN;
  END_IF

  IF M_Automatik_Aktiv[Basis.stMKs.eaAutomatikkreis[wlIndex]] THEN
    AutomatikAktiv := TRUE;
    RETURN;
  END_IF

END_FOR
END_FUNCTION