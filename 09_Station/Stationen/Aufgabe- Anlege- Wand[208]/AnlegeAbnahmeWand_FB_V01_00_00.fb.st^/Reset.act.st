(* METADATA
{
  "v3Meta": {
    "objectGuid": "e4a949e4-8b96-4ace-be1e-f642c2d35408"
  }
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// AKTION RESET
//-------------------------------------------------------------------------------------------------

IF( blBetriebsartReset )THEN
  CASE steplReset OF
    // RESET ===============================
    STEP_0_E:
      Geblaese.bpReset              := TRUE;
      out_bSignalScheibeAbnehmen    := FALSE;
      out_bAmpelSignalGruen         := FALSE;
      out_bSignalScheibeAufgegeben  := FALSE;
      out_bSignalScheibeFehlmessung := FALSE;

      blMerkerFehlerAutomatik       := FALSE;
      blNachSystemcheckMerker       := FALSE;

      Kippen.bpPositionieren        := FALSE;
      Messachse.bpPositionierung    := FALSE;

      Glastransport.bpEintransport             := FALSE;
      Glastransport.bpEintransportRueckwaertig := FALSE;    
      Glastransport.bpAustransport             := FALSE;
      Glastransport.bpAustransportRueckwaertig := FALSE;    

      BasisStationsParameter.eStatusAuftrag := eKeinStatus;
      
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf  := FALSE;
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf  := FALSE;
      BasisStationsParameter.bStationBelegt[cWAND_1]                               := FALSE;
      BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckMitNachfolger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckAbgeschlossen                                   := FALSE;

      steplReset := STEP_10_E;

    // RESET ===============================
    STEP_10_E:
      (* Hinweis:
         - Zuruecksetzen der Unterbausteine die sich in einem Fehlerzustand befinden.
      *)
      Glastransport.bpReset := TRUE;
      Messachse.bpReset     := TRUE;
      Kippen.bpReset        := TRUE;

      (* Hinweis:
         - Bausteine welche sich selbst zurueck setzen
      *)
      Dickenverstellung.bpReset := TRUE;

      steplReset := STEP_20_E;

    // RESET ===============================
    STEP_20_E:
      (* Hinweis:
         - Warten bis die Antriebe ihren Reset durchgefuehrt haben
      *)
      IF (  Glastransport.bpDone
           AND ( Kippen.bpDone OR NOT Kippen.bpReset )
           AND ( Messachse.bpDone OR NOT Messachse.bpReset ))
      THEN
        Glastransport.bpReset := FALSE;
        Messachse.bpReset     := FALSE;
        Kippen.bpReset        := FALSE;
        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Reset-Schrittkette zuruecksetzen (Timer abgelaufen)
         - Pruefen welcher Baustein seinen Reset nicht beenden konnte
      *)
      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Glastransport.bpReset := FALSE;
        Messachse.bpReset     := FALSE;
        Kippen.bpReset        := FALSE;

        BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
        SpsError( eFehler_Station,
                  cMELDUNG_STATION_NICHT_ZURUECKGESETZT,
                  BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                  BasisStationsparameter.awFehlerInformationen );

        IF Glastransport.bpFehler THEN
          BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
          SpsError( eFehler_Station,
                    BasisStationsParameter.wFehlerNummer,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    BasisStationsparameter.awFehlerInformationen );
        END_IF

        IF Messachse.bpFehler THEN
          BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
          SpsError( eFehler_Station,
                    BasisStationsParameter.wFehlerNummer,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    BasisStationsparameter.awFehlerInformationen );
        END_IF

        IF Kippen.bpFehler THEN
          BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
          SpsError( eFehler_Station,
                    BasisStationsParameter.wFehlerNummer,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    BasisStationsparameter.awFehlerInformationen );
        END_IF

        steplReset := STEP_900_E;

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
  IF( steplReset > STEP_0_E )THEN

    Glastransport.bpReset := FALSE;
    Messachse.bpReset     := FALSE;
    Kippen.bpReset        := FALSE;
    Dickenverstellung.bpReset := FALSE;

    steplReset := STEP_0_E;
  END_IF
END_IF
END_ACTION