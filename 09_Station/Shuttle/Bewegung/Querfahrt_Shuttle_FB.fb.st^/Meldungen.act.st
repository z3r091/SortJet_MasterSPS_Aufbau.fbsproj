(* METADATA
{
  "v3Meta": {
    "objectGuid": "416a7260-1d66-4ec1-8a4b-b556c53adb20"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION MELDUNGEN*)
(***************************************************************************************************)
IF( Antrieb.bpFehler
  AND NOT (
       STEP_Mov_Shuttle_W           = STEP_900_E
    OR schrittlReset                = STEP_900_E
    OR steplReferenz                = STEP_900_E ) )
THEN
  wpFehlerNr := cMELDUNG_ANTRIEB_QUERFAHRT;
  bpFehler := TRUE;
END_IF
END_ACTION