(* METADATA
{
	"v3Meta": {
		"objectGuid": "3a67f1d5-b91a-47a8-b2e1-739a6fa2b35e"
	}
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// AKTION RESET
//-------------------------------------------------------------------------------------------------

IF( blBetriebsartReset )THEN
  CASE steplReset OF
    // RESET ============================
    STEP_0_E:

      BasisStationsParameter.eStatusAuftrag := eKeinStatus;

      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf  := FALSE;
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf  := FALSE;
      BasisStationsParameter.bStationBelegt[cWAND_1]                               := FALSE;
      BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckMitNachfolger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckAbgeschlossen                                   := FALSE;

      blNachSystemcheckMerker := FALSE;

      steplReset := STEP_10_E;

    // RESET ============================
    STEP_10_E:
      (* Hinweis:
         - Zuruecksetzen der Unterbausteine die sich in einem Fehlerzustand befinden.
      *)
      Glastransport.bpReset   := TRUE;
      Kippen.bpReset          := TRUE;
      Hub.bpReset             := TRUE;
      Querfahrt.bpReset       := TRUE;

      (* Hinweis:
         - Bausteine welche sich selbst zurueck setzen
      *)
      Geblaese.bpReset        := TRUE;
      Roellchenleiste.bpReset := TRUE;
      Wandverstellung.bpReset := TRUE;

      steplReset := STEP_20_E;

    // RESET ============================
    STEP_20_E:
      (* Hinweis:
         - Warten bis die Antriebe ihren Reset durchgefuehrt haben
      *)
      IF ( Glastransport.bpDone
           AND Kippen.bpDone
           AND Hub.bpDone
           AND Querfahrt.bpDone)
      THEN
        Glastransport.bpReset   := FALSE;
        Kippen.bpReset          := FALSE;
        Geblaese.bpReset        := FALSE;
        Hub.bpReset             := FALSE;
        Querfahrt.bpReset       := FALSE;

        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Reset-Schrittkette zuruecksetzen (Timer abgelaufen)
         - Pruefen welcher Baustein seinen Reset nicht beenden konnte
      *)
      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Glastransport.bpReset   := FALSE;
        Kippen.bpReset          := FALSE;
        Geblaese.bpReset        := FALSE;
        Hub.bpReset             := FALSE;
        Querfahrt.bpReset       := FALSE;

        steplReset := STEP_900_E;

        BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
        SpsError( eFehler_Station,
                  cMELDUNG_STATION_NICHT_ZURUECKGESETZT,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsparameter.awFehlerInformationen );

        IF ( NOT Glastransport.bpDone OR Glastransport.bpFehler ) THEN
          // Nummer des Bausteins nur uebernehmen, wenn er selbst schon einen Fehler meldet
          IF ( Glastransport.wpFehlerNr <> cMELDUNG_NULL ) THEN
            BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
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

        IF ( NOT Geblaese.bpDone OR Geblaese.bpFehler ) THEN
          // Nummer des Bausteins nur uebernehmen, wenn er selbst schon einen Fehler meldet
          IF ( Geblaese.wpFehlerNr <> cMELDUNG_NULL ) THEN
            BasisStationsParameter.wFehlerNummer := Geblaese.wpFehlerNr;
            SpsError( eFehler_Station,
                      BasisStationsParameter.wFehlerNummer,
                      BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                      BasisStationsparameter.awFehlerInformationen );
          END_IF
        END_IF

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

      END_IF

    // RESET ============================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bReset := FALSE;

    // RESET ============================
    STEP_1000_E:
      BasisStationsParameter.wFehlerNummer := cMELDUNG_NULL;
      BasisStationsParameter.bFehler := FALSE;

      BasisStationsParameter.bReset := FALSE;

  // RESET ============================
  END_CASE
ELSE

  IF( steplReset > STEP_0_E )THEN
    Glastransport.bpReset   := FALSE;
    Kippen.bpReset          := FALSE;
    Hub.bpReset             := FALSE;
    Geblaese.bpReset        := FALSE;
    Roellchenleiste.bpReset := FALSE;
    Wandverstellung.bpReset := FALSE;
    Querfahrt.bpReset       := FALSE;

    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION