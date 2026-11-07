(* METADATA
{
	"v3Meta": {
		"objectGuid": "4435c994-edd9-4a41-a226-0a7a5a038c4d"
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
     => +0  Hubrahmen nicht oben               => +1  Hubrahmen nicht unten
     => +2  Faecherwagen nicht vorne           => +3  Faecherwagen nicht hinten
     => +4  Zentrierung nicht geschlossen      => +5  Zentrierung nicht offen
     => +6  Anschlag nicht oben                => +7  Anschlag nicht unten
     => +8  Rolltor nicht oben                 => +9  Rolltor nicht unten
     => +10 Muting-Sensoren nicht gleich       => +11 Faecherwagen nicht in Ausrichtposition
     => +12 Station in undefinierter Position  => +13 Abrollsicherung Rolltor ausgeloest
     => +14 Anschlag nicht vorne (AGV)         => +15 Anschlag nicht hinten (AGV)
     => +17 Sicherheitskreis der Station ausgeloest
*)
wlIoccMeldungsNummer := BasisStationsParameter.stMKs.wMeldungsNummer;

// Hydraulik-Komponenten (nicht im AGV-Betrieb)
IF NOT BasisStationsParameter.stMKs.stStationsAufbau.bAGV THEN
  WatchIoControl( T#10S, wlIoccMeldungsNummer + 0, ( out_bHubrahmenHeben AND NOT in_bHubrahmenOben ) OR blLadepositionOhneOben );
  WatchIoControl( T#10S, wlIoccMeldungsNummer + 1, out_bHubrahmenSenken AND NOT in_bHubrahmenUnten );
  WatchIoControl( T#10S, wlIoccMeldungsNummer + 2, out_bFaecherwagenVor AND NOT in_bFaecherwagenVorne );
  WatchIoControl( T#10S, wlIoccMeldungsNummer + 3, out_bFaecherwagenZurueck AND NOT in_bFaecherwagenHinten );
  WatchIoControl( T#10S, wlIoccMeldungsNummer + 4, out_bZentrierungSchliessen AND NOT in_bZentrierungGeschlossen );
  WatchIoControl( T#10S, wlIoccMeldungsNummer + 5, out_bZentrierungOeffnen AND NOT in_bZentrierungOffen );
END_IF

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag ) THEN
  WatchIoControl( T#5S, wlIoccMeldungsNummer + 6, out_bAnschlagAuf AND NOT in_bAnschlagOben );
  WatchIoControl( T#5S, wlIoccMeldungsNummer + 7, out_bAnschlagAb AND NOT in_bAnschlagUnten );

  IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAGV ) THEN
    WatchIoControl( T#5S, wlIoccMeldungsNummer + 14, out_bAnschlagVor AND NOT in_bAnschlagVorne );
    WatchIoControl( T#5S, wlIoccMeldungsNummer + 15, out_bAnschlagZurueck AND NOT in_bAnschlagHinten );
  END_IF
END_IF

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bRolltor ) THEN
  WatchIoControl( T#15S, wlIoccMeldungsNummer + 8, out_bRolltorAuf AND in_bNichtRolltorGeoeffnet );
  WatchIoControl( T#15S, wlIoccMeldungsNummer + 9, out_bRolltorAb AND NOT bpRolltorUnten );
  WatchIo( NOT in_bAbrollsicherungOK, wlIoccMeldungsNummer + 13 );
END_IF

// Nur ein Muting-Sensor belegt: Faecherwagen steht schief oder Sensor defekt
tonlMutingSensorFehler( IN := in_bMutingSensorLinks XOR in_bMutingSensorRechts, PT := T#1S );
WatchIo( tonlMutingSensorFehler.Q, wlIoccMeldungsNummer + 10 );

WatchIoControl( T#100S, wlIoccMeldungsNummer + 11, BasisStationsParameter.bEintransport[cWAND_1] AND NOT bpStatusStationInBeladePosition );
WatchIoControl( T#0S, wlIoccMeldungsNummer + 12, blStationsposUndefiniert );
WatchIoControl( T#5S, wlIoccMeldungsNummer + 17, NOT in_bSicherheitsrelaisOK );
END_ACTION