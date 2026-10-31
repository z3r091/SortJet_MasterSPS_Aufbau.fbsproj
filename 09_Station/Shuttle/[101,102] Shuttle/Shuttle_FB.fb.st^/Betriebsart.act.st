(* METADATA
{
  "v3Meta": {
    "objectGuid": "5bd671a0-be3e-4a4f-b353-e4682bef1efb"
  }
}
*)
ACTION Betriebsart
(***************************************************************************************************)
(* AKTION BETRIEBSART *)
(***************************************************************************************************)
wlBetriebsart.0 := BasisStationsParameter.bReset;
wlBetriebsart.1 := BasisStationsParameter.bCheck;
wlBetriebsart.2 := BasisStationsParameter.bAutomatik ;
wlBetriebsart.3 := BasisStationsParameter.bReferenz;

blBetriebsartHand      := FALSE;
blBetriebsartReset     := FALSE;
blBetriebartCheck      := FALSE;
blBetriebsartAutomatik := FALSE;
blBetriebsartReferenz  := FALSE;

CASE wlBetriebsart OF

  cStationHandbetrieb:
    blBetriebsartHand := TRUE;

  cStationReset:
    blBetriebsartReset := TRUE;

  cStationCheck:
    blBetriebartCheck := TRUE;

  cStationAutomatik:
    blBetriebsartAutomatik := TRUE;

  cStationReferenz:
    blBetriebsartReferenz := TRUE;

  ELSE

    (*
      Nicht unterstützte Betriebsart 
    *)
    BasisStationsParameter.wFehlerNummer := cMELDUNG_UNGUELTIGE_BETRIEBSART;
    BasisStationsParameter.bFehler := TRUE;

END_CASE
END_ACTION