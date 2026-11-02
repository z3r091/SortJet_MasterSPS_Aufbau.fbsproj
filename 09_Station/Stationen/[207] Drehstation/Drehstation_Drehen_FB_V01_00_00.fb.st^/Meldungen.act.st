(* METADATA
{
  "v3Meta": {
    "objectGuid": "f7c39367-f432-4fac-b614-257c6e4e2d42"
  }
}
*)
ACTION Meldungen
IF( NOT bpFehler
    AND Antrieb.bpFehler )
THEN
  wpFehlerNr := cMELDUNG_ANTRIEB_DREHEN;
  bpFehler := TRUE;
END_IF
END_ACTION