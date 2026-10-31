(* METADATA
{
	"v3Meta": {
		"objectGuid": "256917a2-e0b1-4142-bfa2-dbde064a02d5"
	}
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION RESET *)
(***************************************************************************************************)

IF( blBetriebsartReset )THEN
  CASE steplReset OF
(*RESET ==========================*)
    STEP_0_E:
      out_bAmpelSignalGruenScheibeAnlegen    := FALSE;
      out_bAmpelSignalRot                    := FALSE;
      out_bSignalTasterScheibeQuittieren     := FALSE;
      out_bGeblaese1Ein                      := FALSE;
      out_bGeblaese2Ein                      := FALSE;
      out_bDrosselklappeOeffnen              := FALSE;

      blMerkerDrosselklappeAuf    := FALSE;

      Glastransport.bpAnforderungHandfunktion := FALSE;

      BasisStationsParameter.eStatusAuftrag := eKeinStatus;   
   
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberEinlauf  := FALSE;
      BasisStationsParameter.OutGlasTransport[cWAND_1].bScheibeFaehrtUeberAuslauf  := FALSE;
      BasisStationsParameter.bStationBelegt[cWAND_1]                               := FALSE;
      BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckMitNachfolger[cWAND_1]                          := FALSE;
      BasisStationsParameter.bCheckAbgeschlossen                                   := FALSE;

      steplReset := STEP_10_E;

(*RESET ==========================*)
    STEP_10_E:
      (* Hinweis:
         - Zurecksetzen der Bausteine
         Wichtig
         - Hubrahmen / Anschlag setzen ihren reset selbst zurueck
      *)
      Glastransport.bpReset := TRUE;
      Messachse.bpReset     := TRUE;
      Hubrahmen.bpReset     := TRUE;

      (* WICHTIG:
         - Reset setzt sich selbststaendig zurueck
      *)
      Anschlag.bpReset      := TRUE;

      steplReset := STEP_20_E;

(*RESET ==========================*)
    STEP_20_E:
      (* Hinweis:
         - Pruefen ob alle Antriebe zurueckgesetzt worden sind
      *)
      IF (  Glastransport.bpDone
        AND Messachse.bpDone
        AND Hubrahmen.bpDone )
      THEN
        Glastransport.bpReset := FALSE;
        Hubrahmen.bpReset     := FALSE;
        Messachse.bpReset     := FALSE;

        steplReset := STEP_1000_E;
      END_IF

      (* Fehlverhalten:
        - Ausertung welcher Baustein einen Fehlermeldet
          => Pneumatik Bauteile brauchen nicht ueberwacht zu werden
      *)
      IF ( tonlMaxWarteAufResetErfolgreich.Q ) THEN
        Glastransport.bpReset := FALSE;
        Hubrahmen.bpReset     := FALSE;
        Messachse.bpReset     := FALSE;

        BasisStationsParameter.wFehlerNummer := cMELDUNG_STATION_NICHT_ZURUECKGESETZT;
        SpsError( eFehler_Station, cMELDUNG_STATION_NICHT_ZURUECKGESETZT, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );

        IF ( NOT Glastransport.bpDone OR Glastransport.bpFehler ) THEN
          BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
          SpsError( eFehler_Station, BasisStationsParameter.wFehlerNummer, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );
        END_IF

        IF ( NOT Messachse.bpDone OR Messachse.bpFehler ) THEN
          BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
          SpsError( eFehler_Station, BasisStationsParameter.wFehlerNummer, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );
        END_IF

        IF ( NOT Hubrahmen.bpDone OR Hubrahmen.bpFehler ) THEN
          BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
          SpsError( eFehler_Station, BasisStationsParameter.wFehlerNummer, BasisStationsParameter.stMKs.stStationsNummern.NummerSPS, AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS), BasisStationsparameter.awFehlerInformationen );
        END_IF

        steplReset := STEP_900_E;
      END_IF

(*RESET ==========================*)
    STEP_900_E:
      (* Fehlerbehandlung
      *)
      BasisStationsParameter.bFehler := TRUE;
      BasisStationsParameter.bReset := FALSE;

(*RESET ==========================*)
    STEP_1000_E:
      BasisStationsParameter.bFehler := FALSE;
      BasisStationsParameter.wFehlerNummer := cMELDUNG_NULL;

      BasisStationsParameter.bReset := FALSE;

(*RESET ==========================*)
  END_CASE
END_IF

IF ( NOT blBetriebsartReset ) THEN

  IF ( steplReset > STEP_0_E ) THEN

    Glastransport.bpReset := FALSE;
    Hubrahmen.bpReset     := FALSE;
    Anschlag.bpReset      := FALSE;
    Messachse.bpReset     := FALSE;

    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION