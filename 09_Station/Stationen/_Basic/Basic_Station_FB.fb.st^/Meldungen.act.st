(* METADATA
{
  "v3Meta": {
    "objectGuid": "c61cb7e5-08cd-4727-aec6-615f7af7a357"
  }
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// MELDUNGEN
//-------------------------------------------------------------------------------------------------
// Hier werden nur die Basic Meldungen ausgegeben. Der Rest passiert im vererbten Baustein

// WatchIO's
wlWatchIONachrichtenNummer := BasisStationsParameter.stMKs.wMeldungsNummer;
  
// Vermeiden von doppelten Fehlermeldungen beim wechsel von <Automatik> in <Hand>
IF (  blBetriebsartAutomatik
     AND BasisStationsParameter.bFehler )
THEN
  blMerkerFehlerAutomatik := TRUE;
END_IF

// Im Handbetrieb einen Fehlermelden
rtlFehlerMeldungGenerierenHandbetrieb( CLK :=    blBetriebsartHand
                                       AND NOT blMerkerFehlerAutomatik
                                       AND BasisStationsParameter.bFehler
                                       AND ( BasisStationsParameter.wFehlerNummer <> 0) );

IF ( rtlFehlerMeldungGenerierenHandbetrieb.Q ) THEN
  SpsHinweis( eFehler_Station, 
              BasisStationsParameter.wFehlerNummer, 
              BasisStationsParameter.stMKs.stStationsNummern.NummerIntern, 
              AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
              BasisStationsParameter.awFehlerInformationen );
END_IF
END_ACTION