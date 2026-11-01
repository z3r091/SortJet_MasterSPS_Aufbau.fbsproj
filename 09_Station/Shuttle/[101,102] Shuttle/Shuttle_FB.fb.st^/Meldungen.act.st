(* METADATA
{
  "v3Meta": {
    "objectGuid": "cd9bf479-6e19-4116-a663-46de67126c03"
  }
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// AKTION MELDUNGEN
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Diese Fehlerbehandlung sollte nur dann aufgerufen werden wenn in den Schrittketten der
     Fehler nicht abgefangen wurde.
     Fehlerbehandlung:
   - Fremdluefter auf den Antrieben ( Querfahrt )
   - Riemen
   - Geblaese
*)
blFehlerAktiv := FALSE;
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  blFehlerAktiv := blFehlerAktiv OR ( Eintransport[wlIndex].steplAktion          = STEP_900_E )
                   OR ( Austransport[wlIndex].steplAktion          = STEP_900_E )
                   OR ( Durchtransport[wlIndex].steplAktion        = STEP_900_E )
                   OR ( AnsteuerungRessourcen[wlIndex].steplAktion = STEP_900_E );
END_FOR
IF ( NOT ( blFehlerAktiv
           OR ( steplCheck        = STEP_900_E )
           OR ( steplResetAntrieb = STEP_900_E )
           OR ( steplReferenz     = STEP_900_E ) ) )
THEN
  IF ( Querfahrt.bpFehler ) THEN
    BasisStationsParameter.bFehler := Querfahrt.bpFehler;
    BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
  END_IF
  FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
    IF ( Glastransport[wlIndex].bpFehler ) THEN
      BasisStationsParameter.bFehler := Glastransport[wlIndex].bpFehler;
      BasisStationsParameter.wFehlerNummer := Glastransport[wlIndex].wpFehlerNr;
    END_IF
    IF ( Geblaese[wlIndex].bpFehler ) THEN
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
    END_IF
  END_FOR
END_IF

(* Hinweis:
   - Im Handbetrieb einen Fehlermelden
     WICHTIG:
   - Vermeiden das die Meldung doppelt generiert wird wenn von Automatik in Hand gewechselt wird
*)
rtlFehlerAusgeloestImAutomatikbetrieb( CLK :=     blBetriebsartAutomatik
                                       AND BasisStationsParameter.bFehler );

IF ( rtlFehlerAusgeloestImAutomatikbetrieb.Q ) THEN
  blFehlerAusAutomatikBetrieb := TRUE;
ELSIF ( NOT BasisStationsParameter.bFehler ) THEN
  blFehlerAusAutomatikBetrieb := FALSE;
END_IF

rtlFehlerMeldungGenerierenHandbetrieb( CLK :=       BasisStationsParameter.bFehler
                                       AND ( BasisStationsParameter.wFehlerNummer <> 0) );

IF  ( rtlFehlerMeldungGenerierenHandbetrieb.Q
      AND blBetriebsartHand
      AND NOT blFehlerAusAutomatikBetrieb )
THEN
  SpsHinweis( eFehler_Station,
              BasisStationsParameter.wFehlerNummer,
              BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
              AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
              BasisStationsParameter.awFehlerInformationen
            );
END_IF

//-------------------------------------------------------------------------------------------------
// AKTION: MELDUNGEN [WATCH IO]
//-------------------------------------------------------------------------------------------------
// WatchIO:
//   - Datenlichtschranke
blShuttleErreichbar := TRUE;

wlWatchIONachrichtenNummer := BasisStationsParameter.stMKs.wMeldungsNummer;

WatchIo( blShuttleErreichbar AND NOT in_bDatenlichtschrankeShuttleOK                                                                        ,wlWatchIONachrichtenNummer + 0 );
WatchIo( blShuttleErreichbar AND NOT in_bDatenlichtschrankeShuttlebahnOK                                                                    ,wlWatchIONachrichtenNummer + 1 );
WatchIo( blShuttleErreichbar AND NOT in_bNetzteil_24V_OK                                                                                    ,wlWatchIONachrichtenNummer + 2 );
WatchIo( blShuttleErreichbar AND NOT in_bSicherungen24V_OK                                                                                  ,wlWatchIONachrichtenNummer + 3 );
WatchIo( blShuttleErreichbar AND NOT in_bKlimageraet_OK                                                                                     ,wlWatchIONachrichtenNummer + 4 );
WatchIo( blShuttleErreichbar AND NOT in_bSicherungKompressor_OK                                                                             ,wlWatchIONachrichtenNummer + 5 );
WatchIo( blShuttleErreichbar AND NOT in_bSicherungen230V_OK                                                                                 ,wlWatchIONachrichtenNummer + 6 );

WatchIo( blShuttleErreichbar AND NOT in_bLSQuerfahrtBremseOK                                                                                ,wlWatchIONachrichtenNummer + 8 );
WatchIo( blShuttleErreichbar AND NOT Querfahrt.in_bLeistungsschutzFremdluefter                                                              ,wlWatchIONachrichtenNummer + 9 );

WatchIo( blShuttleErreichbar AND NOT Kippen.bpInReferenz                                                                                    ,wlWatchIONachrichtenNummer + 10 );
WatchIo( blShuttleErreichbar AND Kippen.Antrieb.bpMinSchalterBelegt                                                                         ,wlWatchIONachrichtenNummer + 11 );
WatchIo( blShuttleErreichbar AND Kippen.Antrieb.bpMaxSchalterBelegt                                                                         ,wlWatchIONachrichtenNummer + 12 );

FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  WatchIo( blShuttleErreichbar AND NOT Geblaese[wlIndex].toflMotorschutz.Q AND Geblaese[wlIndex].bpAktivieren                             ,wlWatchIONachrichtenNummer + (15 + (wlIndex - cWAND_1)) );
END_FOR

WatchIo( blShuttleErreichbar AND NOT Querfahrt.Antrieb.bpIstReferenziert                                                                    ,wlWatchIONachrichtenNummer + 19 );
WatchIo( blShuttleErreichbar AND Querfahrt.Antrieb.bpMinSchalterBelegt                                                                      ,wlWatchIONachrichtenNummer + 20 );
WatchIo( blShuttleErreichbar AND Querfahrt.Antrieb.bpMaxSchalterBelegt                                                                      ,wlWatchIONachrichtenNummer + 21 );

WatchIo( blShuttleErreichbar AND NOT StatusAnlage.toflDruckluftShuttleOK[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].Q        ,wlWatchIONachrichtenNummer + 24 );

FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  WatchIo( blShuttleErreichbar AND Querfahrt.bpVerfahreShuttle AND NOT Glastransport[wlIndex].bpVerfahrFreigabe,                           wlWatchIONachrichtenNummer + (27 + (wlIndex - cWAND_1)) );
END_FOR
WatchIo( blShuttleErreichbar AND Querfahrt.bpVerfahreShuttle AND bpShuttleAnhalten                                                          ,wlWatchIONachrichtenNummer + 29 );

WatchIo( blShuttleErreichbar AND ( Zentralschmierung.bpFehler OR Zentralschmierung.blFettLeer )                                             ,wlWatchIONachrichtenNummer + 33 );

WatchIo( blShuttleErreichbar AND ( NOT Kippen.toflMotorSicherungOK.Q OR NOT Kippen.toflMotorstarterOK.Q )                                   ,wlWatchIONachrichtenNummer + 36 );
WatchIo( blShuttleErreichbar AND NOT Kippen.in_bLeitungsschutzschalterBremseOK                                                              ,wlWatchIONachrichtenNummer + 37 );
WatchIo( blShuttleErreichbar AND NOT in_bWandverstellungsAntriebsSicherungOK                                                                ,wlWatchIONachrichtenNummer + 38 );
WatchIo( blShuttleErreichbar AND NOT in_bWandverstellungsBremsSicherungOK                                                                   ,wlWatchIONachrichtenNummer + 39 );

//-------------------------------------------------------------------------------------------------
// S T A R T - Hinweismeldung beim Durchschreiten der Datenlichtschranke
//-------------------------------------------------------------------------------------------------
rtlDatenlichtschrankeUnterbrochen( CLK := (NOT(in_bDatenlichtschrankeShuttlebahnOK) OR NOT(in_bDatenlichtschrankeShuttleOK)) );

IF ( rtlDatenlichtschrankeUnterbrochen.Q
     AND NOT blDatenlichtschrankeUnterbrochenMelden )
THEN
  SpsError( eFehler_Station,
            cMELDUNG_STATION_DATENLICHTSCHRANKE_UNTERBROCHEN,
            BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
            AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
            BasisStationsParameter.awFehlerInformationen );

  blDatenlichtschrankeUnterbrochenMelden := TRUE;
END_IF

IF (  NOT in_bDatenlichtschrankeShuttlebahnOK
     AND NOT in_bDatenlichtschrankeShuttleOK )
THEN
  blDatenlichtschrankeUnterbrochenMelden := FALSE;
END_IF

//-------------------------------------------------------------------------------------------------
// AKTION: VERFAHRFREIGABEN
//-------------------------------------------------------------------------------------------------
FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
  rtlGlastransportVerfahrfreigabe[wlIndex](CLK := ( NOT Glastransport[wlIndex].bpVerfahrFreigabe ) );
  IF ( rtlGlastransportVerfahrfreigabe[wlIndex].Q
       AND Querfahrt.bpPositionierungAktiv )
  THEN
    IF ( Glastransport[wlIndex].bpSensorEinlauf ) THEN
      BasisStationsParameter.awFehlerInformationen[1] := wlIndex;
      SpsHinweis( eFehler_Station,
                  cMELDUNG_QUERFAHRT_KANN_NICHT_VERFAHREN_SENSOR_EINLAUF_WAND_BELEGT,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                  BasisStationsParameter.awFehlerInformationen );
    END_IF
    IF ( Glastransport[wlIndex].bpSensorAuslauf ) THEN
      BasisStationsParameter.awFehlerInformationen[1] := wlIndex;
      SpsHinweis( eFehler_Station,
                  cMELDUNG_QUERFAHRT_KANN_NICHT_VERFAHREN_SENSOR_AUSLAUF_WAND_BELEGT,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                  BasisStationsParameter.awFehlerInformationen );
    END_IF
  END_IF
END_FOR
END_ACTION