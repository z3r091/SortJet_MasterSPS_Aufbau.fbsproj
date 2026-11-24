(* METADATA
{
	"v3Meta": {
		"objectGuid": "0ddae00d-dcbd-4119-b665-fd6cf401e753"
	}
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// MELDUNGEN
//-------------------------------------------------------------------------------------------------
(* Fehlerbehandlung:
   - Glastransport
*)
IF( Querfahrt.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt
    AND NOT BasisStationsParameter.bFehler )
THEN
  BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
  BasisStationsParameter.bFehler := TRUE;
END_IF

IF( Glastransport.bpFehler
    AND NOT BasisStationsParameter.bFehler )
THEN
  BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
  BasisStationsParameter.bFehler := TRUE;
END_IF



//-------------------------------------------------------------------------------------------------
// WTACHIO - MELDUNGEN
//-------------------------------------------------------------------------------------------------

wlWatchIONachrichtenNummer := BasisStationsParameter.stMKs.wMeldungsNummer;


// Querfahrt
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt ) THEN
  WatchIo( NOT in_bLeitungsschutz_Querfahrt_OK,                                                     wlWatchIONachrichtenNummer + 0 );
  WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 3, ( Querfahrt.Antrieb.bpFreigabe AND NOT Querfahrt.Antrieb.bpReglerBereit ) );
  WatchIo( Querfahrt.Antrieb.bpMinSchalterBelegt OR Querfahrt.Antrieb.bpMaxSchalterBelegt,          wlWatchIONachrichtenNummer + 17 );
  WatchIo( NOT Querfahrt.Antrieb.bpIstReferenziert,                                                 wlWatchIONachrichtenNummer + 18 );
END_IF

// Druckluft
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bDruckluft ) THEN
  WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 1, ( NOT in_bDruckluftWartungseinheitOK ) );
END_IF

// Glastransport: Scheibenabfragen (Luft, nicht bei Ultraschallsensoren)
IF NOT BasisStationsParameter.stMKs.stStationsOptionen.stTransfershuttle.bTransferShuttleMitUltraschallSensoren THEN
  WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 4, ( Glastransport.out_bScheibenKontrolleEinlaufSeiteEinschalten AND NOT Glastransport.blDruckluftEinlaufSeiteOK ) );
  WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 5, ( Glastransport.out_bScheibenKontrolleAuslaufSeiteEinschalten AND NOT Glastransport.blDruckluftAuslaufSeiteOK ) );
  WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 6, ( NOT Glastransport.out_bScheibenKontrolleEinlaufSeiteAuf AND NOT Glastransport.bpSensorScheibenKontrolleEinlaufSeiteUnten ) );
  WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 7, ( Glastransport.out_bScheibenKontrolleEinlaufSeiteAuf AND NOT Glastransport.bpSensorScheibenKontrolleEinlaufSeiteOben ) );
  WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 8, ( NOT Glastransport.out_bScheibenKontrolleAuslaufSeiteAuf AND NOT Glastransport.bpSensorScheibenKontrolleAuslaufSeiteUnten ) );
  WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 9, ( Glastransport.out_bScheibenKontrolleAuslaufSeiteAuf AND NOT Glastransport.bpSensorScheibenKontrolleAuslaufSeiteOben ) );
END_IF

// Glastransport: Hub und Abfragen
WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 10, ( Glastransport.out_bShuttleAnheben AND NOT Glastransport.blSensorGlastransportOben ) );
WatchIoControl( T#5S, wlWatchIONachrichtenNummer + 11, ( NOT Glastransport.out_bShuttleAnheben AND NOT Glastransport.blSensorGlastransportUnten ) );
WatchIo( Glastransport.blMeldungAuslaufAbfrageBelegt,                                               wlWatchIONachrichtenNummer + 19 );
WatchIo( Glastransport.blMeldungEinlaufAbfrageBelegt,                                               wlWatchIONachrichtenNummer + 20 );

// Zentralschmierung
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bDLSSchmiersystem ) THEN
  WatchIo( Zentralschmierung.bpFehler OR Zentralschmierung.blFettLeer,                              wlWatchIONachrichtenNummer + 12 );
END_IF

WatchIo( blHinweisGenerierenSKAusgeloest,                                                           wlWatchIONachrichtenNummer + 23 );
END_ACTION