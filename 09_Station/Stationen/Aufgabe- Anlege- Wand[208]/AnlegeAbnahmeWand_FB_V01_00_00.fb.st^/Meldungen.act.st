(* METADATA
{
  "v3Meta": {
    "objectGuid": "a27d903c-d2dd-4649-afcb-d5829cf94f4f"
  }
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// AKTION MELDUNGEN
//-------------------------------------------------------------------------------------------------
// Master aufrufen
SUPER^.Meldungen();

(* Hinweis:
   - Diese Fehlerbehandlung sollte nur dann aufgerufen werden wenn in den Schrittketten der
     Fehler nicht abgefangen wurde.
     Fehlerbehandlung:
   - Glastransport
*)
blAktionImFehler := FALSE;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blAktionImFehler :=    blAktionImFehler
                      OR Eintransport[wlIndex].bpFehler
                      OR Austransport[wlIndex].bpFehler;
END_FOR

IF ( NOT (Anlegen.bpFehler
           OR  Glaslaengenmessung.bpFehler
           OR  Glashoehenmessung.bpFehler
           OR  Abnehmen.bpFehler
           OR  blAktionImFehler
           OR (steplCheck        = STEP_900_E)
           OR (steplReset        = STEP_900_E)
           OR  steplReferenz     = STEP_900_E))
THEN

  IF ( Glastransport.bpFehler ) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
  END_IF

  IF ( Messachse.bpFehler )THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
  END_IF

  IF ( Kippen.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1]) THEN
    BasisStationsParameter.bFehler := TRUE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
  END_IF

END_IF


// WatchIO's// WatchIO's
WatchIo( NOT Glastransport.Antrieb.bpLS_150F02_230V AND bgEtherCatOK,                                                               wlWatchIONachrichtenNummer + 0 );
WatchIo( NOT Glastransport.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK,                                                          wlWatchIONachrichtenNummer + 1 );
WatchIo( NOT in_bMotorschutzGeblaese_Ok AND BasisStationsParameter.stMKs.stStationsAufbau.bGeblase[cWAND_1],                        wlWatchIONachrichtenNummer + 2 );
                                                                                                                                    
// Messache                                                                                                                         
WatchIo( NOT Messachse.Antrieb.bpLS_150F02_230V AND bgEtherCatOK AND BasisStationsParameter.stMKs.stStationsAufbau.bMessachse,      wlWatchIONachrichtenNummer + 3 );
WatchIo( NOT Messachse.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK AND BasisStationsParameter.stMKs.stStationsAufbau.bMessachse, wlWatchIONachrichtenNummer + 4 );
WatchIo( NOT Messachse.bpInReferenz AND NOT blBetriebsartReferenz,                                                                  wlWatchIONachrichtenNummer + 5 );
WatchIo( Messachse.Antrieb.bpMinSchalterBelegt OR Messachse.Antrieb.bpMaxSchalterBelegt,                                            wlWatchIONachrichtenNummer + 6 );
WatchIo( Messachse.bpReferenz AND NOT Messachse.bpDone,                                                                             wlWatchIONachrichtenNummer + 7 );
END_ACTION