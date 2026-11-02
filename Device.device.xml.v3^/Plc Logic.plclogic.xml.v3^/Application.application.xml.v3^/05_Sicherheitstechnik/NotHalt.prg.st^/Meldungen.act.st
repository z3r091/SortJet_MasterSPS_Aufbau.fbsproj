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
END_ACTION