(* METADATA
{
	"v3Meta": {
		"objectGuid": "6cb1873b-bee2-479c-9eb9-fe72382f7d3a"
	}
}
*)
ACTION Systemcheck
//-------------------------------------------------------------------------------------------------
// AKTION SYTEMCHECK
//-------------------------------------------------------------------------------------------------
IF( blBetriebartCheck )THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpReferenz := FALSE;
    Glastransport.bpCheck    := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF

  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    Kippen.bpLangsamKippen  := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF


  CASE ( steplCheck ) OF
    // SYSTEM CHECK =========================
    STEP_0_E:
      (* Hinweis:
         - Riemen aufkoppeln [Master- Slave Betrieb]
      *)
      BasisStationsParameter.bCheckAbgeschlossen := FALSE;
      BasisStationsParameter.bStationBelegt[cWAND_1]  := FALSE;

      (* Hinweis:
         - Sollte es sich z.B. um eine Station handeln die in einen anderen SK transportiert
           kann die <<Freigabe>> [Hardware-] entzogen sein wenn dieser geoeffnet ist.
      *)
      IF ( BasisStationsParameter.bFreigabe ) THEN
        steplCheck := STEP_10_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_10_E:
      (* Hinweis:
         - Referenzieren der Antriebe ( Position auf 0 (NULL) setzen )
         - Setzen der Master-Slave- Kopplung Riemen / Rollen
      *)
      Glastransport.bpReferenz := TRUE;

      IF (  Glastransport.bpDone ) THEN
        Glastransport.bpReferenz := FALSE;

        steplCheck := STEP_20_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_20_E:
      (* Hinweis:
         - Starten des SystemCheck
         - Pruefen des Kipp-Status
      *)
      CASE Kippen.epKippStatus OF

        eKippen_Position_0Grad:
          IF ( NOT blOption_Eintransport_Aufgekippt ) THEN
            Glastransport.bpCheckMitVorgaenger := BasisStationsParameter.bCheckMitVorgaenger[cWAND_1];
          ELSE
            Glastransport.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];
          END_IF


        eKippen_Position_90Grad:
          IF ( blOption_Eintransport_Aufgekippt ) THEN
            Glastransport.bpCheckMitVorgaenger := BasisStationsParameter.bCheckMitVorgaenger[cWAND_1];
          ELSE
            Glastransport.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];
          END_IF


        eKippen_Fehler:
          Glastransport.bpCheckMitVorgaenger := FALSE;
          Glastransport.bpCheckMitNachfolger := FALSE;

      END_CASE

      Glastransport.pAuftrag          := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpCheck           := TRUE;

      steplCheck := STEP_30_E;

    // SYSTEM CHECK =========================
    STEP_30_E:

      (* Hinweis:
         - Pruefen ob die Station belegt ist
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1] := Glastransport.bpStationBelegt;

      IF ( Glastransport.bprtScheibe ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben + 1;
      END_IF

      IF ( ftlGlastransportCheckMitNachfolger.Q ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben - 1;
      END_IF

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpCheck := FALSE;
        steplCheck := STEP_40_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_40_E:
      // ---------------------------------------------------------------------------------------
      //  BELADUNGSSTATUS PRUEFEN
      //
      //  Hinweis:
      //  - Belegt: Station auf die Uebergabe- Position kippen
      //  - Leer  : Station auf die Uebernahme- Position kippen
      //  WICHTIG
      //  - Es kann sein das der RKT nicht in die Austransport-Position kippen darf.
      //    [Bsp. RKT befindet sich hinter einem Shuttle] Darum hier nochmal das
      //    Bit "Letzte Scheibe" abfragen.
      // ---------------------------------------------------------------------------------------

      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        steplCheck := STEP_100_E;
      ELSE
        steplCheck := STEP_300_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  UEBERGABEPOSITION KIPPEN
      //
      //  Hinweis:
      // - Station belegt
      // ---------------------------------------------------------------------------------------

      IF ( blOption_Austransport_Aufgekippt ) THEN
        Kippen.epZielPosition := eKippen_Position_90Grad;
        Kippen.bpPositionieren := TRUE;
        Kippen.bpLangsamKippen  := TRUE;

      ELSE
        Kippen.epZielPosition := eKippen_Position_0Grad;
        Kippen.bpPositionieren := TRUE;
        Kippen.bpLangsamKippen  := FALSE;

      END_IF

      steplCheck := STEP_110_E;

    // SYSTEM CHECK =========================
    STEP_110_E:
      IF ( Kippen.bpDone ) THEN
        Kippen.bpPositionieren := FALSE;
        Kippen.bpLangsamKippen  := FALSE;

        steplCheck := STEP_800_E;
      END_IF

    // SYSTEM CHECK =========================
    STEP_300_E:
      // ---------------------------------------------------------------------------------------
      //  UEBERNAHMEPOSITION KIPPEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( blOption_Eintransport_Aufgekippt ) THEN

        IF ( Kippen.epKippStatus = eKippen_Position_90Grad ) THEN
          steplCheck := STEP_800_E;
        ELSE
          Kippen.epZielPosition := eKippen_Position_90Grad;
          Kippen.bpPositionieren := TRUE;
          Kippen.bpLangsamKippen  := TRUE;

          steplCheck := STEP_310_E;
        END_IF

      ELSE

        IF (  Kippen.epKippStatus = eKippen_Position_0Grad ) THEN
          steplCheck := STEP_800_E;
        ELSE
          Kippen.epZielPosition := eKippen_Position_0Grad;
          Kippen.bpPositionieren := TRUE;
          Kippen.bpLangsamKippen  := FALSE;

          steplCheck := STEP_310_E;
        END_IF

      END_IF

    // SYSTEM CHECK =========================
    STEP_310_E:
      IF ( Kippen.bpDone  ) THEN
        Kippen.bpPositionieren := FALSE;
        Kippen.bpLangsamKippen  := FALSE;
        steplCheck := STEP_800_E;
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

    // SYSTEM CHECK =========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // SYSTEM CHECK =========================
    STEP_1000_E:
      // Auftrag für erneuten Automatikbetrieb setzen
      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Belegt;
      ELSE
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Kein_Auftrag;
      END_IF

      BasisStationsParameter.bCheckAbgeschlossen := TRUE;

  // SYSTEM CHECK =========================
  END_CASE

ELSE

  IF (steplCheck > STEP_0_E ) THEN

    Kippen.bpPositionieren := FALSE;
    Kippen.bpLangsamKippen  := FALSE;

    BasisStationsParameter.bCheckMitVorgaenger[cWAND_1]   := FALSE;
    BasisStationsParameter.bCheckMitNachfolger[cWAND_1]   := FALSE;

    Glastransport.bpReferenz := FALSE;
    Glastransport.bpCheck    := FALSE;


    BasisStationsParameter.bCheckAbgeschlossen := FALSE;

    steplCheck := STEP_0_E;
  END_IF

END_IF
END_ACTION