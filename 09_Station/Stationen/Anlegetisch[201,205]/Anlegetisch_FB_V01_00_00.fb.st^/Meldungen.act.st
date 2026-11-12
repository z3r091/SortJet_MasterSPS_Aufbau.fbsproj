(* METADATA
{
	"v3Meta": {
		"objectGuid": "85d3af47-a90f-4682-b915-71df36769443"
	}
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// AKTION: MELDUNGEN
//-------------------------------------------------------------------------------------------------
// Master aufrufen
SUPER^.Meldungen();

(* Hinweis:
   - Diese Fehlerbehandlung sollte nur dann aufgerufen werden wenn in den Schrittketten der
     Fehler nicht abgefangen wurde.
*)
blAktionImFehler := FALSE;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blAktionImFehler :=    blAktionImFehler
                      OR Eintransport[wlIndex].bpFehler
                      OR Austransport[wlIndex].bpFehler;
END_FOR

IF ( NOT (blAktionImFehler
           OR  Anlegen.bpFehler
           OR (steplEintransportSchneidlinie = STEP_900_E)
           OR  Glaslaengenmessung.bpFehler
           OR  Glashoehenmessung.bpFehler
           OR (steplCheck              = STEP_900_E)
           OR (steplReset              = STEP_900_E)
           OR  steplReferenz           = STEP_900_E))
THEN

  IF( Glastransport.bpFehler ) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
  END_IF

  IF ( Messachse.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
  END_IF

  IF ( Hubrahmen.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
  END_IF

END_IF

// WatchIO's (nur fuer vorhandene Komponenten laut Ausbaustufe)
WatchIo( NOT Glastransport.Antrieb.bpLS_150F02_230V,                                      wlWatchIONachrichtenNummer + 0 );
WatchIo( NOT Glastransport.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK,                wlWatchIONachrichtenNummer + 1 );

// Geblaese
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bGeblase[cWAND_1] ) THEN
  WatchIo( NotHalt.bpNotHaltOK AND NOT in_bMotorschutzGeblaese_Ok,                        wlWatchIONachrichtenNummer + 2 );
END_IF

// Druckluft
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bDruckluft ) THEN
  WatchIo( NOT toflDruckluftOK.Q,                                                         wlWatchIONachrichtenNummer + 3 );
END_IF

// Messachse
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bMessachse ) THEN
  WatchIo( NOT Messachse.Antrieb.bpLS_150F02_230V,                                        wlWatchIONachrichtenNummer + 4 );
  WatchIo( NOT Messachse.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK,                  wlWatchIONachrichtenNummer + 5 );
  WatchIo( NOT Messachse.bpInReferenz AND NOT blBetriebsartReferenz,                      wlWatchIONachrichtenNummer + 6 );
  WatchIo( Messachse.Antrieb.bpMaxSchalterBelegt OR Messachse.Antrieb.bpMinSchalterBelegt, wlWatchIONachrichtenNummer + 7 );
  WatchIo( Messachse.bpReferenz AND NOT Messachse.bpDone,                                 wlWatchIONachrichtenNummer + 8 );
END_IF

// Kippen (Kipptisch)
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] ) THEN
  WatchIo( NOT in_bMotorschutzHydraulik,                                                  wlWatchIONachrichtenNummer + 9 );
  WatchIo( out_bSchaltleisteAusgeloest,                                                   wlWatchIONachrichtenNummer + 10 );
END_IF

// Kipparme
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bKipparme ) THEN
  WatchIo( NOT in_bMotorschutschalterKipparme,                                            wlWatchIONachrichtenNummer + 11 );
END_IF
END_ACTION