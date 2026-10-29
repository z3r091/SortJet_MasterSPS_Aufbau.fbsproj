(* METADATA
{
	"v3Meta": {
		"objectGuid": "568266a3-b56d-4b3c-843a-fa5ab9114a74"
	}
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION RESET *)
(***************************************************************************************************)

IF( blBetriebsartReset )THEN
  CASE steplReset OF
(*RESET ===============================*)
    STEP_0_E:
      (* Hinweis:
         - Aktionen zuruecksetzen
      *)
      blStartePositionWaagerecht := FALSE;
      blStartePositionSenkrecht  := FALSE;
      Kippen.bpStartKippenAuf    := FALSE;
      Kippen.bpStartKippenAb     := FALSE;
	  
      BasisStationsParameter.eStatusAuftrag := eKeinStatus;   
   
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf  := FALSE;
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf  := FALSE;
      BasisStationsParameter.bStationBelegt[cWAND_1]                               := FALSE;
      BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckMitNachfolger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckAbgeschlossen                                   := FALSE;

      steplReset := STEP_10_E;

(*RESET ===============================*)
    STEP_10_E:
      (* Anmerkung:
         - Zuruecksetzen der Unterbausteine die sich in einem Fehlerzustand befinden.

      *)
      Glastransport.bpReset := TRUE;
      Kippen.bpReset        := TRUE;
      Querfahrt.bpReset     := TRUE;

      steplReset := STEP_20_E;

(*RESET ================================*)
    STEP_20_E:
      (* Hinweis:
         - Warten bis die Antriebe ihren Reset durchgefuehrt haben
      *)
      IF (  Kippen.bpDone
        AND Glastransport.bpDone 
        AND Querfahrt.bpDone )
      THEN
        Glastransport.bpReset := FALSE;
        Kippen.bpReset        := FALSE;
        Querfahrt.bpReset        := FALSE;

        steplReset := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung
         - Reset-Schrittkette zuruecksetzen (Timer abgelaufen)
         - Pruefen welcher Baustein seinen Reset nicht beenden konnte
      *)
      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Glastransport.bpReset := FALSE;
        Kippen.bpReset := FALSE;

        BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
        SpsError( eFehler_Station, cMELDUNG_STATION_NICHT_ZURUECKGESETZT, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );

        steplReset := STEP_900_E;

        IF ( NOT Glastransport.bpDone OR Glastransport.bpFehler ) THEN
          BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
          SpsError( eFehler_Station, BasisStationsParameter.wFehlerNummer, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );
        END_IF

        IF ( NOT Kippen.bpDone OR Kippen.bpFehler ) THEN
          BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
          SpsError( eFehler_Station, BasisStationsParameter.wFehlerNummer, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );
        END_IF

        IF ( NOT Querfahrt.bpDone OR Querfahrt.bpFehler ) THEN
          BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
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
      BasisStationsParameter.bFehler       := FALSE;

      BasisStationsParameter.bReset := FALSE;

(*RESET ===============================*)
 END_CASE
ELSE
  IF( steplReset > STEP_0_E )THEN

    Glastransport.bpReset := FALSE;
    Kippen.bpReset        := FALSE;
    Querfahrt.bpReset     := FALSE;

    steplReset := STEP_0_E;
  END_IF
END_IF
END_ACTION