(* METADATA
{
  "v3Meta": {
    "objectGuid": "75e5d8ce-551d-4a97-9aee-dcc367cf028c"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION MELDUNGEN *)
(***************************************************************************************************)
IF( NOT bpFehler
    AND Antrieb.bpFehler )
THEN
  wpFehlerNr := cMELDUNG_ANTRIEB_KIPPEN;
  bpFehler := TRUE;
END_IF
END_ACTION