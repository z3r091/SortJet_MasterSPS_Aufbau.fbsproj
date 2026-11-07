(* METADATA
{
	"v3Meta": {
		"objectGuid": "679129d7-748c-405f-80fb-fdc1b01c2175"
	}
}
*)
ACTION Betriebsart
//-------------------------------------------------------------------------------------------------
// BETRIEBSART
//-------------------------------------------------------------------------------------------------

wlBetriebsart.0 := BasisStationsParameter.bReset;
wlBetriebsart.1 := BasisStationsParameter.bCheck;
wlBetriebsart.2 := BasisStationsParameter.bAutomatik;
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
    //  Nicht unterstützte Betriebsart
    BasisStationsParameter.wFehlerNummer := cMELDUNG_UNGUELTIGE_BETRIEBSART;
    BasisStationsParameter.bFehler := TRUE;

END_CASE
END_ACTION