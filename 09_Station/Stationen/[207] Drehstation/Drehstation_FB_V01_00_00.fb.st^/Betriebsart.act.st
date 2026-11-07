(* METADATA
{
	"v3Meta": {
		"objectGuid": "69bac668-a540-4793-a5fb-efb456c8596b"
	}
}
*)
ACTION Betriebsart
//-------------------------------------------------------------------------------------------------
// S T A R T - Betriebsart festlegen
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

//-------------------------------------------------------------------------------------------------
// E N D E - Betriebsart festlegen
//-------------------------------------------------------------------------------------------------
END_ACTION