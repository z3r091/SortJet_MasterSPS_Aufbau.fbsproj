(* METADATA
{
	"v3Meta": {
		"objectGuid": "2cb6dbe6-422b-425c-a0a1-ce9f3946c716"
	}
}
*)
ACTION SystemCheck
//-------------------------------------------------------------------------------------------------
// AKTION: SYSTEM-CHECK
//-------------------------------------------------------------------------------------------------
IF ( blBetriebartCheck ) THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpCheck := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF


  CASE steplCheck OF
    // SYSTEM CHECK =========================
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

        IF ( NOT (  BasisStationsParameter.bCheckMitNachfolger[cWAND_1] OR BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]) ) THEN

          IF ( Glastransport.bpSensorEinlauf
               OR Glastransport.bpSensorEinlaufVorAb
               OR Glastransport.bpSensorAuslaufVorAb
               OR Glastransport.bpSensorauslauf )
          THEN
            BasisStationsParameter.bStationBelegt[cWAND_1] := TRUE;
          END_IF

          rSps2MmiMessungScheibenlaenge   := -1;
          wSps2MmiMessungStationNummer    := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
          wSps2MmiMessungSlotNummer       := 1;
          iSps2MmiMessungScheibenanzahl   := BOOL_TO_INT(BasisStationsParameter.bStationBelegt[cWAND_1]);

          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

          steplCheck := STEP_800_E;

        ELSE
          BasisStationsParameter.wFehlerNummer := cMELDUNG_SYSTEMCHECK_KANN_NICHT_DURCHGEFUEHRT_WERDEN;
          steplCheck := STEP_900_E;

        END_IF

      END_IF

    // SYSTEM CHECK =========================
    STEP_10_E:
      (* Hinweis:
         - Wenn die Geblaese gestartet sind kann mit dem SystemCheck begonnen werden.
      *)
      IF ( blGeblaeseAktiv  ) THEN
        steplCheck := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
      *)
      IF ( Geblaese.bpFehler ) THEN
        BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
        steplCheck:=STEP_900_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES SYSTEM CHECKS
      //
      //  Hinweis:
      //  - Restweg-Positionierung
      // ---------------------------------------------------------------------------------------

      Glastransport.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];
      Glastransport.bpCheckMitVorgaenger := BasisStationsParameter.bCheckMitVorgaenger[cWAND_1];
      Glastransport.pAuftrag             := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpCheck              := TRUE;

      steplCheck:=STEP_110_E;

    // SYSTEM CHECK =========================
    STEP_110_E:
      (* Hinweis:
         - Pruefen ob die Station belegt ist
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1] := Glastransport.bpStationBelegt;

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpCheck := FALSE;
        steplCheck:=STEP_800_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_800_E:
      // ---------------------------------------------------------------------------------------
      //  AUSWERTEN DES BELADUNGSSTATUS MIT DEN MMI DATEN
      //
      //  Hinweis:
      // - Nachricht an den Bediener senden wenn die Daten nicht passen
      // ---------------------------------------------------------------------------------------

      steplCheck := STEP_1000_E;

      IF ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben = 0 ) AND BasisStationsParameter.bStationBelegt[cWAND_1] THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten );

        IF NOT StationHatShuttleNachbar( BasisStationsParameter ) THEN
          BasisStationsParameter.wFehlerNummer         := cMELDUNG_SYSTEMCHECK_SCHEIBE_GEFUNDEN;
          BasisStationsParameter.awFehlerInformationen := wpgFehlerdaten;
          steplCheck                                   := STEP_900_E;
        END_IF
      END_IF

      IF ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben <> 0 ) AND NOT BasisStationsParameter.bStationBelegt[cWAND_1] THEN
        wpgFehlerdaten[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station,
                    cMELDUNG_SYSTEMCHECK_KEINE_SCHEIBE_GEFUNDEN,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten );

        IF NOT StationHatShuttleNachbar( BasisStationsParameter ) THEN
          BasisStationsParameter.wFehlerNummer         := cMELDUNG_SYSTEMCHECK_KEINE_SCHEIBE_GEFUNDEN;
          BasisStationsParameter.awFehlerInformationen := wpgFehlerdaten;
          steplCheck                                   := STEP_900_E;
        END_IF
      END_IF

    // SYSTEM CHECK=========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;
      blNachSystemcheckMerker := FALSE;

    // SYSTEM CHECK=========================
    STEP_1000_E:
      // Auftrag für erneuten Automatikbetrieb setzen
      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Belegt;
      ELSE
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Kein_Auftrag;
      END_IF

      BasisStationsParameter.bCheckAbgeschlossen  := TRUE;
      blNachSystemcheckMerker := TRUE;

  // SYSTEM CHECK=========================
  END_CASE

ELSE

  IF (steplCheck > STEP_0_E) THEN

    BasisStationsParameter.bCheckMitNachfolger[cWAND_1] := FALSE;
    BasisStationsParameter.bCheckMitVorgaenger[cWAND_1] := FALSE;
    BasisStationsParameter.bCheckAbgeschlossen          := FALSE;

    Glastransport.bpCheck := FALSE;


    blNachSystemcheckMerker := FALSE;
    steplCheck := STEP_0_E;
  END_IF

END_IF
END_ACTION