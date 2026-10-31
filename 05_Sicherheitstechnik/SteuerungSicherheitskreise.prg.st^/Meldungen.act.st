(* METADATA
{
  "v3Meta": {
    "objectGuid": "2a36bedb-9a13-4baa-bd5c-8b4f9f84641b"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* WatchIO Meldungen *)
(***************************************************************************************************)
// Status der Sicherheiskreis 
wlMeldungsnummer := ( ioccSiKreis1 -1 );
FOR wlIndex := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO
  WatchIo( NOT Sicherheitskreis[wlIndex].bpSicherheitskreisGeschlossen, ( wlMeldungsnummer + wlIndex ) );  
END_FOR

// Status der Tueren 
wlMeldungsnummer := ( ioccTuer1NichtGeschlossen -1 );
FOR wlIndex := cERSTE_TUER TO cLETZTE_TUER DO
  WatchIo( aTuer[wlIndex].bpStatusTuerNichtGeschlossen, ( wlMeldungsnummer + wlIndex ) );  
END_FOR

// Status der Durchgänge 
 wlMeldungsnummer := ( ioccDurchgang1NichtGeschlossen -1 );
 FOR wlIndex := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
   WatchIo( aDurchgang[wlIndex].bpStatusDurchgangNichtGeschlossen, ( wlMeldungsnummer + wlIndex ) );  
 END_FOR

// Durchgang blockiert 
 wlMeldungsnummer := ( ioccDurchgang1Blockiert -1 );
 FOR wlIndex := cERSTER_DURCHGANG TO cLETZTER_DURCHGANG DO
   WatchIoControl(T#3S,  ( wlMeldungsnummer + wlIndex ),( aDurchgang[wlIndex].bpAnforderungZumDurchgangOffnenGestellt AND NOT aDurchgang[wlIndex].bpFreigabeZumOeffnenDurchgang AND NOT aDurchgang[wlIndex].bpAbschrankung_Geschlossen ));
 END_FOR
END_ACTION