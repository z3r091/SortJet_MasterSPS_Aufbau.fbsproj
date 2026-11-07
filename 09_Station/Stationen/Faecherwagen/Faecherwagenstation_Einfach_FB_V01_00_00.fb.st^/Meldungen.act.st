(* METADATA
{
	"v3Meta": {
		"objectGuid": "fba03458-e479-4719-a271-db9b94fbd01a"
	}
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// MELDUNGEN
//-------------------------------------------------------------------------------------------------
// Allgemeine Meldungen der Station (Fehler im Handbetrieb)
SUPER^.Meldungen();

(* Hinweis:
   - WatchIO-Meldungen ab der Meldungsnummer der Station (MK wMeldungsNummer)
     => +4  Arretierung nicht geschlossen
     => +5  Arretierung nicht geoeffnet
     => +8  Rolltor nicht oben
     => +9  Rolltor nicht unten
     => +10 Faecherwagen nicht in Ausrichtposition
     => +12 Station in undefinierter Position
     => +13 Abrollsicherung am Rolltor ausgeloest
*)
wlIoccMeldungsNummer := BasisStationsParameter.stMKs.wMeldungsNummer;

WatchIoControl( T#10S, wlIoccMeldungsNummer + 4, out_bArretierungAusfahren AND NOT blArretierungGeschlossen );
WatchIoControl( T#10S, wlIoccMeldungsNummer + 5, out_bArretierungEinfahren AND NOT blArretierungOffen );
WatchIoControl( T#100S, wlIoccMeldungsNummer + 10, BasisStationsParameter.bEintransport[cWAND_1] AND NOT bpStatusStationInBeladePosition );
WatchIoControl( T#0S, wlIoccMeldungsNummer + 12, blStationsposUndefiniert );

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bRolltor ) THEN
  WatchIoControl( T#15S, wlIoccMeldungsNummer + 8, out_bRolltorAuf AND in_bNichtRolltorGeoeffnet );
  WatchIoControl( T#15S, wlIoccMeldungsNummer + 9, out_bRolltorAb AND NOT bpRolltorUnten );
  WatchIo( NOT in_bAbrollsicherungOK, wlIoccMeldungsNummer + 13 );
END_IF
END_ACTION