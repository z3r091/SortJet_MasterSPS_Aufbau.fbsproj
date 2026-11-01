(* METADATA
{
  "v3Meta": {
    "objectGuid": "d32c6aa1-5147-4825-8c12-9ee37c3754f5"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* S T A R T - Fehlerauswertung Antriebe und WatchIO Meldungen *)
(***************************************************************************************************)

(*Antrieb
*)
IF( NOT bpFehler
    AND Antrieb.bpFehler )
THEN
  wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
  bpFehler := TRUE;
END_IF


(***************************************************************************************************)
(* E N D E - Fehlerauswertung Antriebe und WatchIO Meldungen *)
(***************************************************************************************************)
END_ACTION