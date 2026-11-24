(* METADATA
{
	"v3Meta": {
		"objectGuid": "7ec0b8f4-68b3-4f9f-ad7e-7075fb5f6975"
	}
}
*)
ACTION Reset
//==================================================================================================
// AKTION RESET
//==================================================================================================
IF ( blBetriebsartReset ) THEN

  CASE steplReset OF
    //=== RESET ===========================================================================================
    STEP_0_E:
      BasisStationsParameter.eStatusAuftrag                                       := eKeinStatus;
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf := FALSE;
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf := FALSE;
      BasisStationsParameter.bStationBelegt[cWAND_1]                              := FALSE;
      BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]                         := FALSE;
      BasisStationsParameter.bCheckMitNachfolger[cWAND_1]                         := FALSE;
      BasisStationsParameter.bCheckAbgeschlossen                                  := FALSE;

      blNachSystemcheckMerker  := FALSE;
      blHubrahmenPositionieren := FALSE;

      steplReset := STEP_10_E;

    //=== RESET ===========================================================================================
    STEP_10_E:
      (* Hinweis:
         - Zuruecksetzen der Unterbausteine die sich in einem Fehlerzustand befinden.
      *)
      Glastransport_X.bpReset := TRUE;
      Glastransport_Y.bpReset := TRUE;

      (* Hinweis:
         - Bausteine welche sich selbst zurueck setzen
      *)
      Hubrahmen.bpReset := TRUE;

      steplReset := STEP_20_E;

    //=== RESET ===========================================================================================
    STEP_20_E:
      (* Hinweis:
         - Warten bis die Antriebe ihren Reset durchgefuehrt haben
      *)
      IF (    Glastransport_X.bpDone
           AND Glastransport_Y.bpDone )
      THEN
        Glastransport_X.bpReset := FALSE;
        Glastransport_Y.bpReset := FALSE;

        steplReset := STEP_1000_E;
      END_IF

      // Fehlerbehandlung
      // - Reset-Schrittkette zuruecksetzen (Timer abgelaufen)
      // - Pruefen welcher Baustein seinen Reset nicht beenden konnte
      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Glastransport_X.bpReset := FALSE;
        Glastransport_Y.bpReset := FALSE;

        BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
        SpsError( eFehler_Station,
                  cMELDUNG_STATION_NICHT_ZURUECKGESETZT,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsParameter.awFehlerInformationen );

        IF ( NOT Glastransport_X.bpDone OR Glastransport_X.bpFehler ) THEN
          // Nummer des Bausteins nur uebernehmen, wenn er selbst schon einen Fehler meldet
          IF ( Glastransport_X.wpFehlerNr <> cMELDUNG_NULL ) THEN
            BasisStationsParameter.wFehlerNummer := Glastransport_X.wpFehlerNr;
            SpsError( eFehler_Station,
                      BasisStationsParameter.wFehlerNummer,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
          END_IF
        END_IF

        IF ( NOT Glastransport_Y.bpDone OR Glastransport_Y.bpFehler ) THEN
          // Nummer des Bausteins nur uebernehmen, wenn er selbst schon einen Fehler meldet
          IF ( Glastransport_Y.wpFehlerNr <> cMELDUNG_NULL ) THEN
            BasisStationsParameter.wFehlerNummer := Glastransport_Y.wpFehlerNr;
            SpsError( eFehler_Station,
                      BasisStationsParameter.wFehlerNummer,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsParameter.awFehlerInformationen );
          END_IF
        END_IF

        steplReset := STEP_900_E;
      END_IF

    //=== RESET ===========================================================================================
    STEP_900_E:
      // Fehlerbehandlung
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bReset  := FALSE;

    //=== RESET ===========================================================================================
    STEP_1000_E:
      BasisStationsParameter.wFehlerNummer := cMELDUNG_NULL;
      BasisStationsParameter.bFehler       := FALSE;
      BasisStationsParameter.bReset        := FALSE;

  //=== RESET ===========================================================================================
  END_CASE
ELSE

  IF ( steplReset > STEP_0_E ) THEN
    Glastransport_X.bpReset := FALSE;
    Glastransport_Y.bpReset := FALSE;
    Hubrahmen.bpReset       := FALSE;

    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION