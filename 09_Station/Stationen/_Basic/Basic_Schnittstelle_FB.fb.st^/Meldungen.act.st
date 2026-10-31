(* METADATA
{
  "v3Meta": {
    "objectGuid": "44589f73-366e-43f4-b889-8e113549444f"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION: MELDUNGEN *)
(***************************************************************************************************)
// Meldungsnummer übergeben
wlWatchIONachrichtenNummer := BasisStationsParameter.stMKs.wMeldungsNummer;
  
WatchIoControl(T#30S ,wlWatchIONachrichtenNummer + 2  ,( blSenderBereit AND blSenderGlasBereit AND NOT blBereitZumEintransport));
END_ACTION