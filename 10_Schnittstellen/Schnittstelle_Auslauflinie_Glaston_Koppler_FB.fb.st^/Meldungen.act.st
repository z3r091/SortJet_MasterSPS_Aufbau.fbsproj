(* METADATA
{
  "v3Meta": {
    "objectGuid": "59ebec6e-09ff-479e-aaff-9c16800184a4"
  }
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// MELDUNGEN
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Fehlermeldung ausgeben
     => Kommunikations- Probleme
*)
rtlFehlermeldungGenerierenKommunikation( CLK := blFehlermeldungGenerierenKommunikation );

IF ( rtlFehlermeldungGenerierenKommunikation.Q ) THEN

  IF ( NOT bpFehlerMeldungDeaktiviert ) THEN
    SpsError( eFehler_Schnittstelle,
              cMELDUNG_SCHNITTSTELLE_KOMUNIKATION_TIMEOUT,
              BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
              AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
              wpgFehlerdaten );
  END_IF

END_IF


(* Hinweis:
   - Fehlermeldung ausgeben
     => Gespiegelte Auftragsdaten sind nicht gleich
*)
rtlFehlermeldungGenerierenAuftragsdaten( CLK := blFehlermeldungGenerierenAuftragsdaten );

IF ( rtlFehlermeldungGenerierenAuftragsdaten.Q ) THEN

  bpAuftragsdatenVorhanden := FALSE;
  blFehlermeldungGenerierenAuftragsdaten := FALSE;

  IF ( NOT bpFehlerMeldungDeaktiviert ) THEN
    SpsError( eFehler_Schnittstelle,
              cMELDUNG_SCHNITTSTELLE_DATEN_NICHT_AEQUIVALENT,
              BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
              AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
              wpgFehlerdaten );
  END_IF

  BasisStationsParameter.bFehler := TRUE;

END_IF


// WatchIO Meldung generieren
IF NOT bpFehlerMeldungDeaktiviert THEN
  wlWatchIONachrichtenNummer := BasisStationsParameter.stMKs.wMeldungsNummer;

  WatchIo( blFehlermeldungGenerierenKommunikation ,wlWatchIONachrichtenNummer + 0 );
  WatchIo( blFehlermeldungGenerierenAuftragsdaten ,wlWatchIONachrichtenNummer + 1 );
  
END_IF
END_ACTION