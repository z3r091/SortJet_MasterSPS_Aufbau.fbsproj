(* METADATA
{
	"v3Meta": {
		"objectGuid": "d62e85bb-590f-44b8-a585-b547e5f408eb"
	}
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// AKTION MELDUNGEN
//-------------------------------------------------------------------------------------------------
// Master aufrufen
SUPER^.Meldungen();

// Fehlerbehandlung
(* Hinweis:
   - Diese Fehlerbehandlung sollte nur dann aufgerufen werden wenn in den Schrittketten der
     Fehler nicht abgefangen wurde.
*)
blAktionImFehler := FALSE;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blAktionImFehler :=    blAktionImFehler
                      OR Eintransport[wlIndex].bpFehler
                      OR Austransport[wlIndex].bpFehler
                      OR Vortransport[wlIndex].bpFehler;
END_FOR

IF ( NOT (    blAktionImFehler
           OR (steplPositionierungQuerfahrt = STEP_900_E)
           OR (steplCheck                   = STEP_900_E)
           OR (steplReset                   = STEP_900_E)
           OR  steplReferenz                = STEP_900_E))
THEN

  IF( Glastransport.bpFehler ) THEN
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    BasisStationsParameter.bFehler := TRUE;
  END_IF

  IF ( Drehen.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bDrehen ) THEN
    BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
    BasisStationsParameter.bFehler := TRUE;
  END_IF

  IF ( Geblaese.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bGeblase[cWAND_1] ) THEN
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
    BasisStationsParameter.bFehler := TRUE;
  END_IF

  IF ( Querfahrt.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt ) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_QUERFAHRT;
  END_IF

END_IF

// WatchIO's (nur fuer vorhandene Komponenten laut Ausbaustufe)
WatchIo( NOT Glastransport.Antrieb.bpLS_150F02_230V,                                      wlWatchIONachrichtenNummer + 0 );

IF ( BasisStationsParameter.stMKs.stStationsAufbau.bGlastransportSlaveVorhanden ) THEN
  WatchIo( NOT Glastransport.Antrieb_Slave.bpLS_150F02_230V,                              wlWatchIONachrichtenNummer + 2 );
END_IF

// Geblaese
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bGeblase[cWAND_1] ) THEN
  WatchIo( NOT in_bMotorstarter_Geblaese_OK,                                              wlWatchIONachrichtenNummer + 3 );
END_IF

// Querfahrt
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt ) THEN
  WatchIo( NOT Querfahrt.Antrieb.bpLS_150F02_230V,                                        wlWatchIONachrichtenNummer + 4 );
  WatchIo( Querfahrt.Antrieb.bpMinSchalterBelegt OR Querfahrt.Antrieb.bpMaxSchalterBelegt, wlWatchIONachrichtenNummer + 5 );
  WatchIo( NOT Querfahrt.bpInReferenz AND NOT blBetriebsartReferenz,                      wlWatchIONachrichtenNummer + 6 );
  WatchIo( Querfahrt.bpReferenz AND NOT Querfahrt.bpDone,                                 wlWatchIONachrichtenNummer + 7 );
END_IF

// Drehen
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bDrehen ) THEN
  WatchIo( NOT Drehen.Antrieb.bpLS_150F02_230V,                                           wlWatchIONachrichtenNummer + 1 );
  WatchIo( Drehen.Antrieb.bpMinSchalterBelegt OR Drehen.Antrieb.bpMaxSchalterBelegt,      wlWatchIONachrichtenNummer + 8 );
  WatchIo( NOT Drehen.bpInReferenz AND NOT blBetriebsartReferenz,                         wlWatchIONachrichtenNummer + 9 );
  WatchIo( Drehen.bpReferenz AND NOT Drehen.bpDone,                                       wlWatchIONachrichtenNummer + 10 );

  // Durchfassperre 208: nur melden, wenn gedreht werden soll und die Sperre laenger als 10 s offen ist
  WatchIoControl( T#10S, wlWatchIONachrichtenNummer + 11, ( Drehen.bpDrehvorgangAktiv OR Drehen.bpReferenz ) AND NOT EV_ToPLC_b207_geschlossen );
END_IF
END_ACTION