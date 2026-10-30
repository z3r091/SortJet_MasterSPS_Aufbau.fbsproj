(* METADATA
{
	"v3Meta": {
		"objectGuid": "d03778ef-6dfb-4ccf-abf1-371dcbbd03f6"
	}
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION RESET *)
(***************************************************************************************************)
tonlMaxWarteAufResetErfolgreich( IN:= BasisStationsParameter.bReset,
                                 PT:= tgMaxWartezeitReset);

IF( blBetriebsartReset )THEN
  CASE steplResetAntrieb OF
(*RESET ===============================*)
    STEP_0_E:
      (* Hinweis:
         - Geblaese stoppen
      *)
      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        Geblaese[wlIndex].bpStart := FALSE;
      END_FOR

      blNachSystemcheckMerker                := FALSE;
      blDatenlichtschrankeUnterbrochenMelden := FALSE;
      
      BasisStationsParameter.bQuittungPositionierungZurueckgesetzt := FALSE;

      toflGeblaeseEnergiesparModus(PT := T#0S);

      BasisStationsParameter.bCheck := FALSE;
		
      Querfahrt.bpShuttleFaecherwagenSuche := FALSE;

      steplResetAntrieb := STEP_10_E;

(*RESET ================================*)
    STEP_10_E:
      (* WICHTIG
         - Reset wird vom Baustein selbst zurueckgesetzt.
      *)
      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        Geblaese[wlIndex].bpReset        := TRUE;
        Wandverstellung[wlIndex].bpReset := TRUE;
        Glastransport[wlIndex].bpReset   := TRUE;
      END_FOR

      Kippen.bpReset            := TRUE;
      Querfahrt.bpReset         := TRUE;
      Zentralschmierung.bpReset := TRUE;

      steplResetAntrieb := STEP_20_E;

(*RESET ================================*)
    STEP_20_E:
      (* Hinweis:
         - Warten bis die Bausteine ihren Reset durchgefuehrt haben
      *)
      blDone := TRUE;

      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        blDone := blDone
                  AND Glastransport[wlIndex].bpDone;
      END_FOR

      IF( ( blDone
        AND Querfahrt.bpDone
        AND Kippen.bpDone ) )
      THEN

        FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
          Geblaese[wlIndex].bpReset := FALSE;
          Wandverstellung[wlIndex].bpReset := FALSE;
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
        END_FOR

        Kippen.bpReset    := FALSE;
        Querfahrt.bpReset := FALSE;

        Zentralschmierung.bpReset := FALSE;

        BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
        SpsError( eFehler_Station, cMELDUNG_STATION_NICHT_ZURUECKGESETZT, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );

        steplResetAntrieb := STEP_900_E;

       (* WICHTIG:
          - Geblaese nur auf Fehlerabfragen 
            => Keine "Abgeschlossen" Meldung, da sich der Reset selbst quittiert 
       *)
       FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
         IF ( Geblaese[wlIndex].bpFehler ) THEN
           Geblaese[wlIndex].bpReset := FALSE;
           BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
         END_IF
         IF ( NOT Glastransport[wlIndex].bpDone OR Glastransport[wlIndex].bpFehler ) THEN
           Glastransport[wlIndex].bpReset := FALSE;
           BasisStationsParameter.wFehlerNummer := Glastransport[wlIndex].wpFehlerNr;
           SpsError( eFehler_Station, BasisStationsParameter.wFehlerNummer, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );
         END_IF
         IF ( NOT Wandverstellung[wlIndex].bpDone OR Wandverstellung[wlIndex].bpFehler ) THEN
           Wandverstellung[wlIndex].bpReset := FALSE;
           BasisStationsParameter.wFehlerNummer := Wandverstellung[wlIndex].wpFehlerNr;
           SpsError( eFehler_Station, BasisStationsParameter.wFehlerNummer, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );
         END_IF
       END_FOR

       (* Hinweis:
          - Fehlerauswertung der Bausteine
       *)
       IF ( NOT Querfahrt.bpDone OR Querfahrt.bpFehler ) THEN
         Querfahrt.bpReset := FALSE;
         BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
         SpsError( eFehler_Station, BasisStationsParameter.wFehlerNummer, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );
       END_IF

       IF ( NOT Kippen.bpDone OR Kippen.bpFehler ) THEN
         Kippen.bpReset := FALSE;
         BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
         SpsError( eFehler_Station, BasisStationsParameter.wFehlerNummer, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );
       END_IF

     END_IF

(*RESET ===============================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bReset := FALSE;

(*RESET ===============================*)
    STEP_1000_E:
      BasisStationsParameter.wFehlerNummer := cMELDUNG_NULL;
      BasisStationsParameter.bFehler := FALSE;
      BasisStationsParameter.bReset := FALSE;

(*RESET ===============================*)
 END_CASE
END_IF

(*Reset wegen Abbruch der Schrittkette
*)
IF( NOT blBetriebsartReset )THEN

  IF( steplResetAntrieb > STEP_0_E ) THEN

    FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
      Geblaese[wlIndex].bpReset := FALSE;
      Glastransport[wlIndex].bpReset := FALSE;
      Wandverstellung[wlIndex].bpReset := FALSE;
    END_FOR

    Querfahrt.bpReset         := FALSE;
    Kippen.bpReset                   := FALSE;

    steplResetAntrieb := STEP_0_E;
  END_IF

END_IF
END_ACTION