(* METADATA
{
  "v3Meta": {
    "objectGuid": "d594440a-245c-4d8b-b035-4039646a8e1d"
  }
}
*)
ACTION Meldungen
//==================================================================================================
// AKTION MELDUNGEN
//==================================================================================================
// Master aufrufen
SUPER^.Meldungen();

// Fehlerbehandlung
// Hinweis:
// - Diese Fehlerbehandlung sollte nur dann aufgerufen werden wenn in den Schrittketten der
//   Fehler nicht abgefangen wurde.
IF ( NOT (   ( steplEintransport  = STEP_900_E )
          OR ( steplAustransport  = STEP_900_E )
          OR ( steplVortransport  = STEP_900_E )
          OR ( steplCheck         = STEP_900_E )
          OR ( steplReset         = STEP_900_E ) ) )
THEN
  IF ( Glastransport_X.bpFehler ) THEN
    BasisStationsParameter.bFehler       := TRUE;
    BasisStationsParameter.wFehlerNummer := Glastransport_X.wpFehlerNr;
  END_IF

  IF ( Glastransport_Y.bpFehler ) THEN
    BasisStationsParameter.bFehler       := TRUE;
    BasisStationsParameter.wFehlerNummer := Glastransport_Y.wpFehlerNr;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    BasisStationsParameter.bFehler       := TRUE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
  END_IF
END_IF

// WatchIO's
WatchIo( NOT Glastransport_X.Antrieb.bpLS_150F02_230V AND bgEtherCatOK,      wlWatchIONachrichtenNummer + 0 );
WatchIo( NOT Glastransport_X.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK, wlWatchIONachrichtenNummer + 1 );
WatchIo( NOT Glastransport_Y.Antrieb.bpLS_150F02_230V AND bgEtherCatOK,      wlWatchIONachrichtenNummer + 2 );
WatchIo( NOT Glastransport_Y.Antrieb.bpHaupschalter400VEin AND bgEtherCatOK, wlWatchIONachrichtenNummer + 3 );
END_ACTION