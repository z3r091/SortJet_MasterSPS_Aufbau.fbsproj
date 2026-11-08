(* METADATA
{
	"v3Meta": {
		"objectGuid": "d03778ef-6dfb-4ccf-abf1-371dcbbd03f6"
	}
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// AKTION RESET
//-------------------------------------------------------------------------------------------------
tonlMaxWarteAufResetErfolgreich( IN:= BasisStationsParameter.bReset,
                                 PT:= tgMaxWartezeitReset);

IF( blBetriebsartReset )THEN
  CASE steplResetAntrieb OF
    // RESET ===============================
    STEP_0_E:
      (* Hinweis:
         - Geblaese stoppen
      *)

      blNachSystemcheckMerker                := FALSE;
      blDatenlichtschrankeUnterbrochenMelden := FALSE;
      
      BasisStationsParameter.bQuittungPositionierungZurueckgesetzt := FALSE;

      BasisStationsParameter.bCheck := FALSE;

      Querfahrt.bpShuttleFaecherwagenSuche := FALSE;

      steplResetAntrieb := STEP_10_E;

    // RESET ================================
    STEP_10_E:
      (* Wichtig:
         - Reset wird vom Baustein selbst zurueckgesetzt.
      *)
      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        Geblaese[wlIndex].bpReset        := TRUE;
        Wandverstellung[wlIndex].bpReset := TRUE;
        Glastransport[wlIndex].bpReset   := TRUE;
        Greifer[wlIndex].bpReset         := BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex];
      END_FOR

      Kippen.bpReset            := TRUE;
      Querfahrt.bpReset         := TRUE;
      Zentralschmierung.bpReset := TRUE;

      steplResetAntrieb := STEP_20_E;

    // RESET ================================
    STEP_20_E:
      (* Hinweis:
         - Warten bis die Bausteine ihren Reset durchgefuehrt haben
      *)
      blDone := TRUE;

      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        blDone := blDone
                  AND Glastransport[wlIndex].bpDone
                  AND ( Greifer[wlIndex].bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex] );
      END_FOR

      IF( ( blDone
            AND Querfahrt.bpDone
            AND Kippen.bpDone ) )
      THEN

        FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
          Geblaese[wlIndex].bpReset := FALSE;
          Wandverstellung[wlIndex].bpReset := FALSE;
          Greifer[wlIndex].bpReset := FALSE;
          Glastransport[wlIndex].bpReset := FALSE;
        END_FOR

        Kippen.bpReset    := FALSE;
        Querfahrt.bpReset := FALSE;

        steplResetAntrieb := STEP_1000_E;
      END_IF


      (* Fehlerbehandlung:
         - Timer abgelaufen
           => Bausteinrest zuruecksetzen
      *)
      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN

        FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
          Geblaese[wlIndex].bpReset := FALSE;
          Wandverstellung[wlIndex].bpReset := FALSE;
          Glastransport[wlIndex].bpReset := FALSE;
          Greifer[wlIndex].bpReset := FALSE;
        END_FOR

        Kippen.bpReset    := FALSE;
        Querfahrt.bpReset := FALSE;

        Zentralschmierung.bpReset := FALSE;

        BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
        SpsError( eFehler_Station,
                  cMELDUNG_STATION_NICHT_ZURUECKGESETZT,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsparameter.awFehlerInformationen );

        steplResetAntrieb := STEP_900_E;

        (* Wichtig:
           - Geblaese nur auf Fehlerabfragen
             => Keine "Abgeschlossen" Meldung, da sich der Reset selbst quittiert
        *)
        FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
          IF ( Geblaese[wlIndex].bpFehler ) THEN
            BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
          END_IF
          IF ( NOT Glastransport[wlIndex].bpDone OR Glastransport[wlIndex].bpFehler ) THEN
            // Nummer des Bausteins nur uebernehmen, wenn er selbst schon einen Fehler meldet
            IF ( Glastransport[wlIndex].wpFehlerNr <> cMELDUNG_NULL ) THEN
              BasisStationsParameter.wFehlerNummer := Glastransport[wlIndex].wpFehlerNr;
              SpsError( eFehler_Station,
                        BasisStationsParameter.wFehlerNummer,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                        BasisStationsparameter.awFehlerInformationen );
            END_IF
          END_IF
          IF ( NOT Wandverstellung[wlIndex].bpDone OR Wandverstellung[wlIndex].bpFehler ) THEN
            // Nummer des Bausteins nur uebernehmen, wenn er selbst schon einen Fehler meldet
            IF ( Wandverstellung[wlIndex].wpFehlerNr <> cMELDUNG_NULL ) THEN
              BasisStationsParameter.wFehlerNummer := Wandverstellung[wlIndex].wpFehlerNr;
              SpsError( eFehler_Station,
                        BasisStationsParameter.wFehlerNummer,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                        BasisStationsparameter.awFehlerInformationen );
            END_IF
          END_IF
          IF (     BasisStationsParameter.stMKs.stStationsAufbau.bGreifer[wlIndex]
               AND ( NOT Greifer[wlIndex].bpDone OR Greifer[wlIndex].bpFehler ) )
          THEN
            // Nummer des Bausteins nur uebernehmen, wenn er selbst schon einen Fehler meldet
            IF ( Greifer[wlIndex].wpFehlerNr <> cMELDUNG_NULL ) THEN
              BasisStationsParameter.wFehlerNummer := Greifer[wlIndex].wpFehlerNr;
              SpsError( eFehler_Station,
                        BasisStationsParameter.wFehlerNummer,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                        BasisStationsparameter.awFehlerInformationen );
            END_IF
          END_IF
        END_FOR

        (* Hinweis:
           - Fehlerauswertung der Bausteine
        *)
        IF ( NOT Querfahrt.bpDone OR Querfahrt.bpFehler ) THEN
          // Nummer des Bausteins nur uebernehmen, wenn er selbst schon einen Fehler meldet
          IF ( Querfahrt.wpFehlerNr <> cMELDUNG_NULL ) THEN
            BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
            SpsError( eFehler_Station,
                      BasisStationsParameter.wFehlerNummer,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsparameter.awFehlerInformationen );
          END_IF
        END_IF

        IF ( NOT Kippen.bpDone OR Kippen.bpFehler ) THEN
          // Nummer des Bausteins nur uebernehmen, wenn er selbst schon einen Fehler meldet
          IF ( Kippen.wpFehlerNr <> cMELDUNG_NULL ) THEN
            BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
            SpsError( eFehler_Station,
                      BasisStationsParameter.wFehlerNummer,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsparameter.awFehlerInformationen );
          END_IF
        END_IF

      END_IF

    // RESET ===============================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bReset := FALSE;

    // RESET ===============================
    STEP_1000_E:
      BasisStationsParameter.wFehlerNummer := cMELDUNG_NULL;
      BasisStationsParameter.bFehler := FALSE;
      BasisStationsParameter.bReset := FALSE;

  // RESET ===============================
  END_CASE
ELSE
  // Reset wegen Abbruch der Schrittkette
  IF( steplResetAntrieb > STEP_0_E ) THEN

    FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
      Geblaese[wlIndex].bpReset := FALSE;
      Glastransport[wlIndex].bpReset := FALSE;
      Wandverstellung[wlIndex].bpReset := FALSE;
      Greifer[wlIndex].bpReset := FALSE;
    END_FOR

    Querfahrt.bpReset         := FALSE;
    Kippen.bpReset                   := FALSE;

    Zentralschmierung.bpReset := FALSE;
    tonlMaxWarteAufResetErfolgreich( IN := FALSE );
    steplResetAntrieb := STEP_0_E;
  END_IF
END_IF
END_ACTION