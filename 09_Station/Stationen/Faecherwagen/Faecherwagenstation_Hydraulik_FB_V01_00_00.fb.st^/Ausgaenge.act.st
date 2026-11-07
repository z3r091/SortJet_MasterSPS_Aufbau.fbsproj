(* METADATA
{
	"v3Meta": {
		"objectGuid": "54f6a092-43cb-4827-ad13-4a0f8db4d373"
	}
}
*)
ACTION Ausgaenge
//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------

// Auftrag aktiv
bpAuftragAktiv := (    blBetriebartCheck
                    OR BasisStationsParameter.bEintransport[cWAND_1]
                    OR BasisStationsParameter.bAustransport[cWAND_1] );

IF NOT BasisStationsParameter.stMKs.stStationsAufbau.bAGV THEN

  // Grundstellung: Hubrahmen unten, hinten, Zentrierung offen, Anschlag unten
  bpBoxInHomePosition :=     in_bHubrahmenUnten
                         AND in_bFaecherwagenHinten
                         AND in_bZentrierungOffen
                         AND blAnschlagUntenOderOhne;

  // Beladeposition: Hubrahmen oben, vorne, zentriert, Faecherwagen erkannt, Anschlag unten, Rolltor oben
  bpStatusStationInBeladePosition :=     in_bHubrahmenOben
                                     AND in_bFaecherwagenVorne
                                     AND in_bZentrierungGeschlossen
                                     AND in_bMutingSensorLinks
                                     AND blAnschlagUntenOderOhne
                                     AND (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bRolltor
                                           OR ( NOT in_bNichtRolltorGeoeffnet AND NOT bpRolltorUnten ) );

  // Station in einer undefinierten Position
  blStationsposUndefiniert :=     NOT bpBoxInHomePosition
                              AND NOT bpStatusStationInBeladePosition
                              AND NOT bpAuftragAktiv
                              AND NOT blPositionskorrekturAktiv;

ELSE

  // Option AGV: keine Mechanik, die in Grundstellung fahren muss
  bpBoxInHomePosition := TRUE;

  // Beladeposition: Faecherwagen auf der Station, RFID gelesen (Option bRFID), Anschlag unten, Rolltor oben
  bpStatusStationInBeladePosition :=     blFaecherwagenErkannt
                                     AND ( in_bRFID_DataValid OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bRFID )
                                     AND blAnschlagUntenOderOhne
                                     AND (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bRolltor
                                           OR ( NOT in_bNichtRolltorGeoeffnet AND NOT bpRolltorUnten ) );

  // Station in einer undefinierten Position: Rolltor weder oben noch unten
  blStationsposUndefiniert :=     NOT bpAuftragAktiv
                              AND BasisStationsParameter.stMKs.stStationsAufbau.bRolltor
                              AND in_bNichtRolltorGeoeffnet
                              AND NOT bpRolltorUnten;

END_IF

// Schnittstelle zum Shuttle
bpOutBereitZumEintransport := bpStatusStationInBeladePosition;
bpOutBereitZumAustransport := bpStatusStationInBeladePosition;
END_ACTION