(* METADATA
{
  "v3Meta": {
    "objectGuid": "85d3af47-a90f-4682-b915-71df36769443"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* AKTION: MELDUNGEN  *)
(***************************************************************************************************)
// Master aufrufen
SUPER^.Meldungen();

(* Hinweis:
   - Diese Fehlerbehandlung sollte nur dann aufgerufen werden wenn in den Schrittketten der
     Fehler nicht abgefangen wurde.
*)
IF ( NOT ((steplEintransport  = STEP_900_E)
           OR (steplAustransport       = STEP_900_E)
           OR (steplAnlegen            = STEP_900_E)
           OR (steplGlaslaengenmessung = STEP_900_E)
           OR (steplCheck              = STEP_900_E)
           OR (steplReset              = STEP_900_E)
           OR  steplReferenz           = STEP_900_E))
THEN

  IF( Glastransport.bpFehler ) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
  END_IF

  IF ( Messachse.bpFehler ) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
  END_IF

END_IF

// WatchIO's
WatchIo( NOT Glastransport.Antrieb.bpLS_150F02_230V,                                      wlWatchIONachrichtenNummer + 0 );
WatchIo( NOT Glastransport.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK,                wlWatchIONachrichtenNummer + 1 );
WatchIo( NotHalt.bpNotHaltOK AND NOT in_bMotorschutzGeblaese_Ok,                          wlWatchIONachrichtenNummer + 2 );
WatchIo( NOT toflDruckluftOK.Q,                                                           wlWatchIONachrichtenNummer + 3 );

// Messache
WatchIo( NOT Messachse.Antrieb.bpLS_150F02_230V,                                          wlWatchIONachrichtenNummer + 4 );
WatchIo( NOT Glastransport.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK,                wlWatchIONachrichtenNummer + 5 );
WatchIo( NOT Messachse.bpInReferenz  AND NOT blBetriebsartReferenz,                       wlWatchIONachrichtenNummer + 6 );
WatchIo( Messachse.Antrieb.bpMaxSchalterBelegt OR Messachse.Antrieb.bpMinSchalterBelegt,  wlWatchIONachrichtenNummer + 7 );
WatchIo( Messachse.bpReferenz AND NOT Messachse.bpDone,                                   wlWatchIONachrichtenNummer + 8 );

// Kippen
WatchIo( NOT in_bMotorschutzHydraulik,                                                    wlWatchIONachrichtenNummer + 9 );
WatchIo( out_bSchaltleisteAusgeloest,                                                     wlWatchIONachrichtenNummer + 10 );

// Kipparme
WatchIo( NOT in_bMotorschutschalterKipparme,                                              wlWatchIONachrichtenNummer + 11 );
END_ACTION