(* METADATA
{
	"v3Meta": {
		"objectGuid": "72b3ed85-a5a7-4904-ab18-0650378e5df8"
	}
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// RESET
//-------------------------------------------------------------------------------------------------

IF( blBetriebsartReset )THEN
  CASE steplReset OF
    // RESET ===============================
    STEP_0_E:

      blNachSystemcheckMerker  := FALSE;


      Drehen.bpStarteAbsolutPositionierung := FALSE;
      Drehen.bpStarteDrehBewegung := FALSE;

      BasisStationsParameter.eStatusAuftrag := eKeinStatus;   
   
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf  := FALSE;
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf  := FALSE;
      BasisStationsParameter.bRueckwaertsTransportieren[cWAND_1]                   := FALSE;
      BasisStationsParameter.bStationBelegt[cWAND_1]                               := FALSE;
      BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckMitNachfolger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckAbgeschlossen                                   := FALSE;


      steplReset := STEP_10_E;

    // RESET ===============================
    STEP_10_E:
      (* Anmerkung:
         - Bausteine zurueck setzen.
      *)
      Glastransport.bpReset := TRUE;
      Drehen.bpReset        := TRUE;

      (* Anmerkung:
         - Bausteine welche sich selbst quittieren.
      *)
      Querachse.bpReset         := TRUE;
      Dickenverstellung.bpReset := TRUE;
      Kippen.bpReset            := TRUE;
      Geblaese.bpReset          := TRUE;
      Querfahrt.bpReset         := TRUE;

      steplReset := STEP_20_E;

    // RESET ================================
    STEP_20_E:
      (* Hinweis:
         - Warten bis die Antriebe ihren Reset durchgefuehrt haben
      *)
      IF (  Glastransport.bpDone
           AND Drehen.bpDone )
      THEN
        Glastransport.bpReset := FALSE;
        Drehen.bpReset        := FALSE;
        Querfahrt.bpReset     := FALSE;

        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Reset-Schrittkette zuruecksetzen (Timer abgelaufen)
         - Pruefen welcher Baustein seinen Reset nicht beenden konnte
      *)
      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Glastransport.bpReset := FALSE;
        Drehen.bpReset        := FALSE;
        Geblaese.bpReset      := FALSE;

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

        IF Drehen.bpFehler THEN
          BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
          SpsError( eFehler_Station,
                    BasisStationsParameter.wFehlerNummer,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    BasisStationsparameter.awFehlerInformationen );
        END_IF

        IF Querfahrt.bpFehler THEN
          BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
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

  IF ( steplReset > STEP_0_E )THEN
    Glastransport.bpReset     := FALSE;
    Drehen.bpReset            := FALSE;
    Querachse.bpReset         := FALSE;
    Querfahrt.bpReset         := FALSE;
    Dickenverstellung.bpReset := FALSE;
    Kippen.bpReset            := FALSE;
    Geblaese.bpReset          := FALSE;

    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION