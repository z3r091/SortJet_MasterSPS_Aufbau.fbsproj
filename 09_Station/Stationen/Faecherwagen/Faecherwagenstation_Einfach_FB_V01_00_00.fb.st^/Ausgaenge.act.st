(* METADATA
{
	"v3Meta": {
		"objectGuid": "e830b8db-ea27-4185-a784-9d3baca3fb6c"
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

// Grundstellung: Arretierung offen, Rolltor unten (Faecherwagen darf in der Station stehen)
bpBoxInHomePosition :=     blArretierungOffen
                       AND (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bRolltor
                             OR bpRolltorUnten );

// Beladeposition: Faecherwagen vorhanden und arretiert, Rolltor oben
bpStatusStationInBeladePosition :=     in_bFaecherwagenVorhanden
                                   AND blArretierungGeschlossen
                                   AND (    NOT BasisStationsParameter.stMKs.stStationsAufbau.bRolltor
                                         OR ( NOT in_bNichtRolltorGeoeffnet AND NOT bpRolltorUnten ) );

// Schnittstelle zum Shuttle
bpOutBereitZumEintransport := bpStatusStationInBeladePosition;
bpOutBereitZumAustransport := bpStatusStationInBeladePosition;

// Station in einer undefinierten Position
blStationsposUndefiniert :=     NOT bpBoxInHomePosition
                            AND NOT bpStatusStationInBeladePosition
                            AND NOT bpAuftragAktiv;
END_ACTION