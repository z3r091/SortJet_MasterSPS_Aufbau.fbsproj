(* METADATA
{
	"v3Meta": {
		"objectGuid": "ae6b70f1-f8b0-4b66-95d6-dde84fa25bbc"
	}
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION MELDUNGEN *)
(***************************************************************************************************)
// Master aufrufen
SUPER^.Meldungen();

WatchIo( in_b24VNetzteilLEDs_OK AND  BasisStationsParameter.stMKs.stStationsAufbau.bInspektionsStation,                             wlWatchIONachrichtenNummer + 8 );
WatchIo( in_b24VSammelsicherungLEDs_OK AND BasisStationsParameter.stMKs.stStationsAufbau.bInspektionsStation,                       wlWatchIONachrichtenNummer + 9 );
END_ACTION