(* METADATA
{
  "v3Meta": {
    "objectGuid": "81d76c12-755d-4317-8441-3237ae760654"
  }
}
*)
ACTION SystemCheck
//==================================================================================================
// AKTION SYSTEM-CHECK
//==================================================================================================
IF ( blBetriebartCheck ) THEN

  // Ausnahmesituation
  IF ( GlastransportAus.bpFehler ) THEN
    GlastransportAus.bpCheck := FALSE;
    BasisStationsParameter.wFehlerNummer := GlastransportAus.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF

  IF ( Hubrahmen.bpFehler ) THEN
    blHubrahmenPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Hubrahmen.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF


  CASE steplCheck OF
    //=== SYSTEM CHECK ====================================================================================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      BasisStationsParameter.bCheckAbgeschlossen     := FALSE;
      BasisStationsParameter.bStationBelegt[cWAND_1] := FALSE;

      (* Hinweis:
         - Sollte es sich z.B. um eine Station handeln die in einen anderen SK transportiert
           kann die <<Freigabe>> [Hardware-] entzogen sein wenn dieser geoeffnet ist.
      *)
      IF ( BasisStationsParameter.bFreigabe ) THEN
        steplCheck := STEP_10_E;
      ELSE
        IF ( NOT ( BasisStationsParameter.bCheckMitNachfolger[cWAND_1] OR BasisStationsParameter.bCheckMitVorgaenger[cWAND_1] ) ) THEN
          BasisStationsParameter.bStationBelegt[cWAND_1] := (    Glastransport_X.bpSensorEinlauf
                                                              OR Glastransport_X.bpSensorEinlaufVorAb
                                                              OR Glastransport_X.bpSensorAuslaufVorAb
                                                              OR Glastransport_X.bpSensorAuslauf
                                                              OR Glastransport_Y.bpSensorEinlauf
                                                              OR Glastransport_Y.bpSensorEinlaufVorAb
                                                              OR Glastransport_Y.bpSensorAuslaufVorAb
                                                              OR Glastransport_Y.bpSensorAuslauf );

          rSps2MmiMessungScheibenlaenge := -1;
          wSps2MmiMessungStationNummer  := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
          wSps2MmiMessungSlotNummer     := 1;
          iSps2MmiMessungScheibenanzahl := BOOL_TO_INT(BasisStationsParameter.bStationBelegt[cWAND_1]);
          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

          steplCheck := STEP_800_E;
        ELSE
          BasisStationsParameter.wFehlerNummer := cMELDUNG_SYSTEMCHECK_KANN_NICHT_DURCHGEFUEHRT_WERDEN;
          steplCheck := STEP_900_E;
        END_IF
      END_IF

    //=== SYSTEM CHECK ====================================================================================
    STEP_10_E:
      (* Hinweis:
         - Hubrahmen auf die Austransport-Achse stellen, dort liegt eine Scheibe in Grundstellung
      *)
      elHubrahmenZielAchse     := elAchseAustransport;
      blHubrahmenPositionieren := TRUE;

      steplCheck := STEP_20_E;

    //=== SYSTEM CHECK ====================================================================================
    STEP_20_E:
      IF ( blHubrahmenInPosition ) THEN
        blHubrahmenPositionieren := FALSE;

        steplCheck := STEP_100_E;
      END_IF

    //=== SYSTEM CHECK ====================================================================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES SYSTEM CHECKS
      //
      //  Hinweis:
      //  - Restweg-Positionierung auf der Austransport-Achse
      // ---------------------------------------------------------------------------------------
      GlastransportAus.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];
      GlastransportAus.bpCheckMitVorgaenger := BasisStationsParameter.bCheckMitVorgaenger[cWAND_1];
      GlastransportAus.pAuftrag             := BasisStationsParameter.pAuftrag[cWAND_1];
      GlastransportAus.bpCheck              := TRUE;

      steplCheck := STEP_110_E;

    //=== SYSTEM CHECK ====================================================================================
    STEP_110_E:
      (* Hinweis:
         - Pruefen ob die Station belegt ist
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1] := GlastransportAus.bpStationBelegt;

      IF ( GlastransportAus.bpDone ) THEN
        GlastransportAus.bpCheck := FALSE;

        steplCheck := STEP_800_E;
      END_IF

    //=== SYSTEM CHECK ====================================================================================
    STEP_800_E:
      // ---------------------------------------------------------------------------------------
      //  AUSWERTEN DES BELADUNGSSTATUS MIT DEN MMI DATEN
      //
      //  Hinweis:
      //  - Nachricht an den Bediener senden wenn die Daten nicht passen
      // ---------------------------------------------------------------------------------------
      IF (    ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben = 0 )
           AND BasisStationsParameter.bStationBelegt[cWAND_1] )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten );
      END_IF

      IF (    ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben <> 0 )
           AND NOT BasisStationsParameter.bStationBelegt[cWAND_1] )
      THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_KEINE_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten );
      END_IF

      steplCheck := STEP_1000_E;

    //=== SYSTEM CHECK ====================================================================================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      blNachSystemcheckMerker := FALSE;

    //=== SYSTEM CHECK ====================================================================================
    STEP_1000_E:
      // Auftrag fuer erneuten Automatikbetrieb setzen
      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Belegt;
      ELSE
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Kein_Auftrag;
      END_IF

      BasisStationsParameter.bCheckAbgeschlossen := TRUE;
      blNachSystemcheckMerker := TRUE;

  //=== SYSTEM CHECK ====================================================================================
  END_CASE
ELSE

  IF ( steplCheck > STEP_0_E ) THEN
    BasisStationsParameter.bCheckMitNachfolger[cWAND_1] := FALSE;
    BasisStationsParameter.bCheckMitVorgaenger[cWAND_1] := FALSE;
    BasisStationsParameter.bCheckAbgeschlossen          := FALSE;

    Glastransport_X.bpCheck  := FALSE;
    Glastransport_Y.bpCheck  := FALSE;
    blHubrahmenPositionieren := FALSE;

    GlastransportAus.bpCheck := FALSE;
    blNachSystemcheckMerker := FALSE;
    steplCheck := STEP_0_E;
  END_IF

END_IF
END_ACTION