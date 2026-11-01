(* METADATA
{
  "v3Meta": {
    "objectGuid": "d639c7d7-8a7e-4448-9a6b-70e2e2a58d0a"
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
IF ( NOT ((steplEintransport  = STEP_900_E)
           OR (steplAustransport = STEP_900_E)
           OR (steplCheck        = STEP_900_E)
           OR (steplReset        = STEP_900_E)
           OR  steplReferenz     = STEP_900_E))
THEN

  IF( Glastransport.bpFehler ) THEN
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    BasisStationsParameter.bFehler := TRUE;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    BasisStationsParameter.bFehler := TRUE;
  END_IF

  IF ( Querfahrt.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt ) THEN
    BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
    BasisStationsParameter.bFehler := TRUE;
  END_IF

END_IF

// WatchIO's
WatchIo( NOT Glastransport.Antrieb.bpLS_150F02_230V AND bgEtherCatOK,               wlWatchIONachrichtenNummer + 0 );
WatchIo( NOT Glastransport.Antrieb_Slave.bpLS_150F02_230V AND bgEtherCatOK,         wlWatchIONachrichtenNummer + 1 );
WatchIo( NOT Kippen.Antrieb.bpLS_150F02_230V AND bgEtherCatOK,                      wlWatchIONachrichtenNummer + 2 );
WatchIo( NOT Glastransport.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK,          wlWatchIONachrichtenNummer + 3 );
WatchIo( NOT Glastransport.Antrieb_Slave.bpHaupschalter400VEin AND bgEtherCatOK,    wlWatchIONachrichtenNummer + 4 );
WatchIo( NOT Kippen.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK,                 wlWatchIONachrichtenNummer + 5 );
WatchIo( NOT Kippen.Antrieb.bpIstReferenziert AND NOT blBetriebsartReferenz,        wlWatchIONachrichtenNummer + 6 );
WatchIo( Kippen.bpReferenz AND NOT Kippen.bpDone,                                   wlWatchIONachrichtenNummer + 7 );
WatchIo( NOT Querfahrt.bpInReferenz  AND NOT blBetriebsartReferenz,                 wlWatchIONachrichtenNummer + 8 );
WatchIo( Querfahrt.bpReferenz AND NOT Querfahrt.bpDone,                             wlWatchIONachrichtenNummer + 9 );
END_ACTION