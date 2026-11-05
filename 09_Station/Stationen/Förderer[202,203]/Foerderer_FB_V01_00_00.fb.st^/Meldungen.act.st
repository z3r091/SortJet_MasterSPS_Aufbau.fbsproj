(* METADATA
{
  "v3Meta": {
    "objectGuid": "625d5633-cd1d-4490-8ac9-c51165b48531"
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
                      OR Durchtransport[wlIndex].bpFehler
                      OR Vortransport[wlIndex].bpFehler
                      OR Messkopplung[wlIndex].bpFehler;
END_FOR

IF ( NOT (    blAktionImFehler
           OR (steplCheck             = STEP_900_E)
           OR (steplReferenz          = STEP_900_E )
           OR (steplReset             = STEP_900_E)))
THEN

  IF ( Glastransport.bpFehler ) THEN
    BasisStationsParameter.bFehler   := TRUE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
  END_IF

  IF ( Geblaese.bpFehler ) THEN
    BasisStationsParameter.bFehler   := TRUE;
    BasisStationsParameter.wFehlerNummer := Geblaese.wpFehlerNr;
  END_IF

END_IF

// WatchIO's
WatchIo( NOT Glastransport.Antrieb.bpLS_150F02_230V AND bgEtherCatOK,                                                   wlWatchIONachrichtenNummer + 0 );
WatchIo( NOT Glastransport.Antrieb_Slave.bpLS_150F02_230V AND bgEtherCatOK AND Glastransport.bpOptionSlaveAntrieb,      wlWatchIONachrichtenNummer + 1 );
WatchIo( NOT Glastransport.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK,                                              wlWatchIONachrichtenNummer + 2 );
WatchIo( NOT Glastransport.Antrieb_Slave.bpHaupschalter400VEin AND bgEtherCatOK AND Glastransport.bpOptionSlaveAntrieb, wlWatchIONachrichtenNummer + 3 );
WatchIo( NOT Geblaese.toflMotorschutz.Q AND Geblaese.bpAktivieren,                                                      wlWatchIONachrichtenNummer + 4 );
WatchIo( NOT Kippen.in_bMotorstarter_OK AND Kippen.bpAktivieren,                                                        wlWatchIONachrichtenNummer + 5 );
WatchIo( NOT Kippen.in_bLS400V_OK AND Kippen.bpAktivieren,                                                              wlWatchIONachrichtenNummer + 6 );
WatchIo( NOT Kippen.in_bLSBremse_OK AND Kippen.bpAktivieren,                                                            wlWatchIONachrichtenNummer + 7 );
WatchIo( NOT Hub.in_bMotorstarter_OK AND Hub.bpAktivieren,                                                              wlWatchIONachrichtenNummer + 8 );
WatchIo( NOT Hub.in_bLS400V_OK AND Hub.bpAktivieren,                                                                    wlWatchIONachrichtenNummer + 9 );
WatchIo( NOT Hub.in_bLSBremse_OK AND Hub.bpAktivieren,                                                                  wlWatchIONachrichtenNummer + 10 );
END_ACTION