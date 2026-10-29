(* METADATA
{
	"v3Meta": {
		"objectGuid": "dbe974c3-5aa4-42b4-add7-2c28280dcaca"
	}
}
*)
ACTION Meldungen
(* HINWEIS:
   - Instanzerkennung
     => Erleichterung der Zuweisung der WatchIO- Meldungen [es gibt 8 Instanzen = (0..7)]
        - 0 erste Instanz
        - 1 zweite Instanz
        - etc. 
*)
wlIoccMeldungsNummer := BasisStationsParameter.stMKs.wMeldungsNummer;

wlioccFWStationGegenhalterUnterwagenNichtFixiert := wlIoccMeldungsNummer + 0;
wlioccFWStationGegenhalterUnterwagenNichtFrei    := wlIoccMeldungsNummer + 1;
wlioccFWStationRolltorNichtOben                  := wlIoccMeldungsNummer + 2;
wlioccFWStationRolltorNichtUnten                 := wlIoccMeldungsNummer + 3;
wlioccFWStationGreiferNichtGeoeffnet             := wlIoccMeldungsNummer + 4;
wlioccFWStationGreiferNichtGeschlossen           := wlIoccMeldungsNummer + 5;
wlioccFWStationLineareinheitNichtVorne           := wlIoccMeldungsNummer + 6;
wlioccFWStationLineareinheitNichtHinten          := wlIoccMeldungsNummer + 7;
wlioccFWStationEntriegelungNichtGeoeffnet        := wlIoccMeldungsNummer + 8;
wlioccFWStationEntriegelungNichtGeschlossen      := wlIoccMeldungsNummer + 9;
wlioccFWStationAusrichtPositionNichtOK           := wlIoccMeldungsNummer + 10;
wlioccStationsposUndefiniert                     := wlIoccMeldungsNummer + 11;
wlioccFWagenStationSIKreisausgeloest             := wlIoccMeldungsNummer + 12;
wlioccRolltorBlockiertdurchFWNichtinPos          := wlIoccMeldungsNummer + 18;

WatchIoControl(T#30S, wlioccFWStationGegenhalterUnterwagenNichtFixiert, ( out_bGegenhalterAusfahren AND NOT in_bGegenhalterZu ) );
WatchIoControl(T#30S, wlioccFWStationGegenhalterUnterwagenNichtFrei, ( out_bGegenhalterEinfahren AND NOT in_bGegenhalterOffen ) );
WatchIoControl(T#30S, wlioccFWStationGreiferNichtGeoeffnet, ( out_bGreiferAusfahren AND NOT ( in_bGreifer1Offen AND in_bGreifer2Offen ) ) );
WatchIoControl(T#30S, wlioccFWStationGreiferNichtGeschlossen, ( out_bGreiferEinfahren AND NOT  ( in_bGreifer1Zu AND in_bGreifer2Zu ) ) );
WatchIoControl(T#30S, wlioccFWStationLineareinheitNichtVorne, ( out_bLinearEinheitVor AND NOT (  in_bLinearEinheit1Vorne AND in_bLinearEinheit2Vorne  ) ) );
WatchIoControl(T#30S, wlioccFWStationLineareinheitNichtHinten, ( out_bLinearEinheitZurueck AND NOT ( ( in_bLinearEinheit1Hinten AND in_bLinearEinheit2Hinten ) OR ( in_bLineareinheit1Umgreifposition AND in_bLineareinheit2Umgreifposition  ) ) ) );
WatchIoControl(T#30S, wlioccFWStationEntriegelungNichtGeoeffnet, ( out_bEntriegelungAusfahren AND NOT in_bEntriegelungOffen ) );
WatchIoControl(T#30S, wlioccFWStationEntriegelungNichtGeschlossen, ( out_bEntriegelungEinfahren AND NOT in_bEntriegelungGeschlossen ) );
WatchIoControl(T#100S, wlioccFWStationAusrichtPositionNichtOK, BasisStationsParameter.bEintransport[cWAND_1] AND NOT bpStatusStationInBeladePosition );
WatchIoControl(T#0S, wlioccStationsposUndefiniert, blStationsposUndefiniert );
WatchIoControl(T#0S, wlioccFWagenStationSIKreisausgeloest, ( NOT bpLichtschranke_OK AND NOT blRolltorUnten ) OR ( NOT bpLichtschranke_OK AND BasisStationsParameter.bAustransport[cWAND_1] ) );
WatchIoControl(T#0S, wlioccRolltorBlockiertdurchFWNichtinPos, ( steplAusschleusen = STEP_143_E ) );

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bRolltor ) THEN
 WatchIoControl(T#15S, wlioccFWStationRolltorNichtOben,     (out_bRolltorAuf AND NOT in_bNichtRolltorGeoeffnet));
 WatchIoControl(T#15S, wlioccFWStationRolltorNichtUnten,    (out_bRolltorAb AND blRolltorUnten));
END_IF

wlioccFWagenStationHomeposLineareinheitNichtHinten     := wlIoccMeldungsNummer + 13;
wlioccFWagenStationHomeposGreiferNichtGeoeffnet        := wlIoccMeldungsNummer + 14;
wlioccFWagenStationHomeposRolltorNichtUnten            := wlIoccMeldungsNummer + 15;
wlioccFWagenStationHomeposEntriegelungNichtGeschlossen := wlIoccMeldungsNummer + 16;
wlioccFWagenStationHomeposGegenhalterNichtGeoeffnet    := wlIoccMeldungsNummer + 17;

blErr1 := blErr2 := blErr3 := blErr4 := blErr5 := FALSE;

IF blStationsposUndefiniert THEN

  IF NOT blLinearEinheitSH AND NOT blLinearEinheitHinten THEN
    blErr1 := TRUE;

  ELSIF NOT blLinearEinheitSH AND NOT blGreiferOffen THEN
    blErr2 := TRUE;

  ELSIF NOT blRolltorUnten THEN
    blErr3 := TRUE;

  ELSIF NOT blLinearEinheitSH AND NOT in_bEntriegelungGeschlossen THEN
    blErr4 := TRUE;

  ELSIF NOT blLinearEinheitSH AND NOT in_bGegenhalterOffen THEN
    blErr5 := TRUE;

  END_IF

END_IF

WatchIO(blErr1, wlioccFWagenStationHomeposLineareinheitNichtHinten);
WatchIO(blErr2, wlioccFWagenStationHomeposGreiferNichtGeoeffnet);
WatchIO(blErr3, wlioccFWagenStationHomeposRolltorNichtUnten);
WatchIO(blErr4, wlioccFWagenStationHomeposEntriegelungNichtGeschlossen);
WatchIO(blErr5, wlioccFWagenStationHomeposGegenhalterNichtGeoeffnet);
END_ACTION