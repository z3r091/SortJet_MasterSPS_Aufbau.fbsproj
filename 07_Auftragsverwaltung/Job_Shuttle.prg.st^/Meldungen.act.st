(* METADATA
{
	"v3Meta": {
		"objectGuid": "68e675d5-67ba-4597-82c1-c0511fb282bc"
	}
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION: MELDUNGEN *)
(***************************************************************************************************)
(* WatchIO:
   - Ueberwachung der Verfahrfreigabe der Shuttle
     -> Inputshuttle
     -> Outputshuttle
     -> Transfershuttle
*)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
    WatchIo( NOT abgVerfahrfreigabeShuttle[wlIndex], ioccShuttle1VerfahrfreigabeFehlt + (wlIndex - 101) );
END_FOR;

FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
    WatchIo( NOT abgVerfahrfreigabeShuttle[wlIndex], ioccTransfershuttle1VerfahrfreigabeFehlt + (wlIndex - 151) );
END_FOR;
END_ACTION