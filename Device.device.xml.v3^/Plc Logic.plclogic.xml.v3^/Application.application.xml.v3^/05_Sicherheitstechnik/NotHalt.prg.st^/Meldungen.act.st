(* METADATA
{
	"v3Meta": {
		"objectGuid": "7aa08060-ae3e-4314-8b15-8d626e58c29d"
	}
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// MELDUNGEN
//-------------------------------------------------------------------------------------------------
wMeldungsnummer := ioccNotaus1Betaetigt;

WatchIo( NOT bpNotHaltOK, ioccNotausBetaetigt );

WatchIo( NOT EV_ToPLC_bNothalt_CAB2_OK AND NOT Interface_SLC.bpOperatorAcknowledgeRequested,                        wMeldungsnummer + 0 );
WatchIo( NOT EV_ToPLC_bNothalt_Station201_Vorderseite_OK AND NOT Interface_SLC.bpOperatorAcknowledgeRequested,      wMeldungsnummer + 1 );
WatchIo( NOT EV_ToPLC_bNothalt_Station201_Rueckseite_OK AND NOT Interface_SLC.bpOperatorAcknowledgeRequested,       wMeldungsnummer + 2 );
// Nothalt 203 Bedienseite = Nothalt OP 2, Meldung ueber die Terminals
WatchIo( NOT EV_ToPLC_bNothalt_Station205_Vorderseite_OK AND NOT Interface_SLC.bpOperatorAcknowledgeRequested,      wMeldungsnummer + 4 );
WatchIo( NOT EV_ToPLC_bNothalt_Station301_OK AND NOT Interface_SLC.bpOperatorAcknowledgeRequested,                   wMeldungsnummer + 5 );
WatchIo( NOT EV_ToPLC_bNothalt_Station302_OK AND NOT Interface_SLC.bpOperatorAcknowledgeRequested,                   wMeldungsnummer + 6 );
WatchIo( NOT EV_ToPLC_bNothalt_Station303_OK AND NOT Interface_SLC.bpOperatorAcknowledgeRequested,                   wMeldungsnummer + 7 );
WatchIo( NOT EV_ToPLC_bNothalt_Station304_OK AND NOT Interface_SLC.bpOperatorAcknowledgeRequested,                   wMeldungsnummer + 8 );
WatchIo( NOT EV_ToPLC_bNothalt_Station305_OK AND NOT Interface_SLC.bpOperatorAcknowledgeRequested,                   wMeldungsnummer + 9 );
END_ACTION