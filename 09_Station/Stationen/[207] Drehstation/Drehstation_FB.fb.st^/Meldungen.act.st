(* METADATA
{
  "v3Meta": {
    "objectGuid": "d62e85bb-590f-44b8-a585-b547e5f408eb"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION MELDUNGEN *)
(***************************************************************************************************)
// Master aufrufen
SUPER^.Meldungen();

// Fehlerbehandlung
(* Hinweis:
   - Diese Fehlerbehandlung sollte nur dann aufgerufen werden wenn in den Schrittketten der
     Fehler nicht abgefangen wurde.
*)
IF ( NOT ((steplEintransport       = STEP_900_E)
  OR (steplAustransport            = STEP_900_E)
  OR (steplPositionierungQuerfahrt = STEP_900_E)
  OR (steplCheck                   = STEP_900_E)
  OR (steplReset                   = STEP_900_E)
  OR  steplReferenz                = STEP_900_E))
THEN

  IF( Glastransport.bpFehler ) THEN
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    BasisStationsParameter.bFehler := TRUE;
  END_IF

  IF ( Drehen.bpFehler ) THEN
    BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
    BasisStationsParameter.bFehler := TRUE;
  END_IF

  IF ( Geblaese.bpFehler ) THEN
    Geblaese.bpStart := FALSE;
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
    BasisStationsParameter.bFehler := TRUE;
  END_IF
  
  IF ( Querfahrt.bpFehler ) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_QUERFAHRT;
  END_IF

END_IF

// WatchIO's
WatchIo( NOT Glastransport.Antrieb.bpLS_150F02_230V,                                                                                                      wlWatchIONachrichtenNummer + 0 );
WatchIo( NOT Drehen.Antrieb.bpLS_150F02_230V,                                                                                                             wlWatchIONachrichtenNummer + 1 );
WatchIo( NOT Glastransport.Antrieb_Slave.bpLS_150F02_230V AND BasisStationsParameter.stMKs.stStationsAufbau.bGlastransportSlaveVorhanden,                       wlWatchIONachrichtenNummer + 2 );
WatchIo( NOT in_bMotorstarter_Geblaese_OK,                                                                                                                wlWatchIONachrichtenNummer + 3 );

//Querfahrt
WatchIo( NOT Querfahrt.Antrieb.bpLS_150F02_230V AND BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt,                                             wlWatchIONachrichtenNummer + 4 );
WatchIo( ( Querfahrt.Antrieb.bpMinSchalterBelegt OR Querfahrt.Antrieb.bpMaxSchalterBelegt ) AND BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt, wlWatchIONachrichtenNummer + 5 );
                            
WatchIo( NOT Querfahrt.bpInReferenz AND NOT blBetriebsartReferenz AND BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt,                           wlWatchIONachrichtenNummer + 6 );
WatchIo( Querfahrt.bpReferenz AND NOT Querfahrt.bpDone AND BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt,                                      wlWatchIONachrichtenNummer + 7 );

// Drehen
WatchIo( Drehen.Antrieb.bpMinSchalterBelegt OR Drehen.Antrieb.bpMaxSchalterBelegt,                                                                        wlWatchIONachrichtenNummer + 8 );
WatchIo( NOT Drehen.bpInReferenz AND NOT blBetriebsartReferenz,                                                                                           wlWatchIONachrichtenNummer + 9 );
WatchIo( Drehen.bpReferenz AND NOT Drehen.bpDone,                                                                                                         wlWatchIONachrichtenNummer + 10 );
END_ACTION