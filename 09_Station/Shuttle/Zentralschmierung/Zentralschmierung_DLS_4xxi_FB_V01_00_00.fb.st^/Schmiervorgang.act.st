(* METADATA
{
	"v3Meta": {
		"objectGuid": "f6d6f829-3991-4365-9dae-cc900dba6270"
	}
}
*)
ACTION Schmiervorgang
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: SCHMIERVORGANG
//-------------------------------------------------------------------------------------------------

//Komplette überarbeitung
rtlStarteSchmierung( CLK := ablStarteKreis[cSCHMIERKREIS_1] OR ablStarteKreis[cSCHMIERKREIS_2] OR bpStartSchmierungHand );
IF rtlStarteHandschmierung.Q THEN
  ablStarteKreis[cSCHMIERKREIS_1] := ablStarteKreis[cSCHMIERKREIS_2] := TRUE;
END_IF

IF rtlStarteSchmierung.Q THEN


  blStarteSchmierung := TRUE;

  wSps2MmiErrorNumber           := 110;
  wSps2MmiErrorShuttleNumber    := stStationsNummern.NummerIntern;
  wSps2MmiErrorShuttleSchritt   := STEP_999_E;
  wSps2MmiErrorShuttlePosition4 := 0;
  wSps2MmiErrorShuttlePosition5 := 0;
  wSps2MmiErrorShuttlePosition6 := 0;
  wSps2MmiErrorShuttlePosition7 := 0;
  wSps2MmiErrorShuttlePosition8 := 0;
  wSps2MmiErrorShuttlePosition9 := 0;
  MsgToMmi( auftragsnr_w := SB0_SPS_ErrorMSG );

END_IF

(* Hinweis:
   - Die Schmierung darf nicht unterbrochen werden - sollte der SK oder Notaus auslösen,
     wird alles nur "pausiert" es darf nichts zurückgesetzt oder von vorn begonnen werden
*)
IF bpFreigabe THEN

  IF blStarteSchmierung THEN

    CASE steplSchmierung OF

      // ZENTRALSCHMIERUNG ============================================================================
      STEP_0_E:
        (* Hinweis:
           - Wurde die Schrittkette neu gestartet oder lief sie schon?
              In Schritt 0 darf die Schrittkette nur neu gestartet sein!
           - Die Schmierung muss mindestens 3 Sekunden ein High Signal auf
              dem Status senden, damit diese Betriebsbereit ist (Wie bei der Neuen)
        *)
        IF tonlSchmierungBetriebsbereit.Q AND (( ailAktiverHub[cSCHMIERKREIS_1] = 0 ) OR (ailAktiverHub[cSCHMIERKREIS_2] = 0)) THEN

          wSps2MmiErrorNumber           := 120;
          wSps2MmiErrorShuttleNumber    := stStationsNummern.NummerIntern;
          wSps2MmiErrorShuttleSchritt   := STEP_0_E;
          wSps2MmiErrorShuttlePosition4 := 0;
          wSps2MmiErrorShuttlePosition5 := 0;
          wSps2MmiErrorShuttlePosition6 := 0;
          wSps2MmiErrorShuttlePosition7 := 0;
          wSps2MmiErrorShuttlePosition8 := 0;
          wSps2MmiErrorShuttlePosition9 := 0;
          MsgToMmi( auftragsnr_w := SB0_SPS_ErrorMSG );
          ablHubAktiv[cSCHMIERKREIS_1] := FALSE;
          ablHubAktiv[cSCHMIERKREIS_2] := FALSE;

          steplSchmierung := STEP_50_E;
        ELSE
          steplSchmierung := STEP_900_E;
        END_IF

      // ZENTRALSCHMIERUNG ============================================================================
      STEP_50_E:
        (* Hinweis:
           - STEP_50_E ist für die Auswahl der Schmierkreise ((1 OR 2) OR (1 AND 2))
        *)
        FOR wlIndex := cSCHMIERKREIS_1 TO cSCHMIERKREIS_2 DO
          IF ablStarteKreis[wlIndex] AND NOT atoflPause[wlIndex].Q  THEN
            tAnsteuern:=tAnsteuernKreise[wlIndex];
            ablHubAktiv[wlIndex] := TRUE;
            steplSchmierung := STEP_100_E;
          ELSE
            ablHubAktiv[wlIndex] := FALSE;
          END_IF

        END_FOR

        // Beide Schmierkreise später implementieren wenn Schmierkreis 1 und 2  einzeln laufen

        IF ablHubAktiv[cSCHMIERKREIS_1] AND ablHubAktiv[cSCHMIERKREIS_2]  THEN
          tAnsteuern:=tAnsteuernKreise[cSCHMIERKREIS_1_2];
          steplSchmierung := STEP_100_E;
        END_IF

      // ZENTRALSCHMIERUNG ============================================================================
      STEP_100_E:
        (* Hinweis:
           - Das Steuersignal so lange setzen wie notwendig,
              um einen Hub an der Zentralschmierung durchzuführen
        *)


        tonSchmierkreisAnsteuerung(IN:= TRUE ,PT:=tAnsteuern);
        out_bSteuerSignal:= TRUE;
        IF tonSchmierkreisAnsteuerung.Q THEN
          out_bSteuerSignal := FALSE;
          tonSchmierkreisAnsteuerung(IN:= FALSE);
          FOR wlIndex := cSCHMIERKREIS_1 TO cSCHMIERKREIS_2 DO
            IF ablHubAktiv[wlIndex] THEN
              ailAktiverHub[wlIndex] := ailAktiverHub[wlIndex] + 1;
            END_IF
          END_FOR

          steplSchmierung := STEP_200_E;

        END_IF

      // ZENTRALSCHMIERUNG ============================================================================
      STEP_200_E:
        (* Hinweis:
           - Wenn der Schmiermotor gestartet ist, dann fällt das
              Status Signal ab. Dies wird überprüft und entspr.
              ausgewertet
           - Sollte das Signal nach Dauer eines Hubs (lt. Bedienungsanleitung > 10 Sekunden)
              nicht abgefallen sein, ist die Schmierung nicht gestartet
        *)
        tonlWartezeitFuerSchmierHub( IN := TRUE , PT := tDauerEinHub );

        IF blSchmierhubOk THEN
          blSchmierhubOk := FALSE;
          steplSchmierung := STEP_300_E;
        END_IF
        IF blSchmierhubOkBaldLeer THEN
          blSchmierhubOkBaldLeer := FALSE;
          wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
          SpsHinweis( eFehler_Station,
                      cMELDUNG_ZENTRALSCHMIERUNG_FETT_BALD_LEER,
                      stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(stStationsNummern.NummerSPS),
                      wpgFehlerdaten );

          steplSchmierung := STEP_300_E;
        END_IF

        IF tonlWartezeitFuerSchmierHub.Q THEN
          tonlWartezeitFuerSchmierHub( IN := FALSE );
          wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
          SpsError( eFehler_Station,
                    cMELDUNG_ZENTRALSCHMIERUNG_GERAETEFEHLER,
                    stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(stStationsNummern.NummerSPS),
                    wpgFehlerdaten );

          wSps2MmiErrorNumber           := 110;
          wSps2MmiErrorShuttleNumber    := stStationsNummern.NummerIntern;
          wSps2MmiErrorShuttleSchritt   := STEP_200_E;
          wSps2MmiErrorShuttlePosition4 := 0;
          wSps2MmiErrorShuttlePosition5 := 0;
          wSps2MmiErrorShuttlePosition6 := 0;
          wSps2MmiErrorShuttlePosition7 := 0;
          wSps2MmiErrorShuttlePosition8 := 0;
          wSps2MmiErrorShuttlePosition9 := 0;
          MsgToMmi( auftragsnr_w := SB0_SPS_ErrorMSG );

          steplSchmierung := STEP_900_E;
        END_IF

      // ZENTRALSCHMIERUNG ============================================================================
      STEP_300_E:
        (* Hinweis:
           - Mach Dauer eines Hubs (lt. Bedienungsanleitung > 22 Sekunden( 10 Sekunden bei der neuen Pumpe) können wir fortfahren
        *)
        tonlWartezeitFuerSchmierHub( IN := TRUE , PT := tDauerEinHub );

        IF tonlWartezeitFuerSchmierHub.Q THEN
          tonlWartezeitFuerSchmierHub( IN := FALSE );
          steplSchmierung := STEP_400_E;
        END_IF

      // ZENTRALSCHMIERUNG ============================================================================
      STEP_400_E:
        (* Hinweis:
           - Der Schmiervorgang ist beendet, das Status Signal sollte wieder als High-Pegel anliegen
           - Anderenfalls wird möglicherweise eine Störung anliegen
        *)
        IF in_bStatus THEN
          steplSchmierung := STEP_450_E;
        ELSE
          wSps2MmiErrorNumber           := 110;
          wSps2MmiErrorShuttleNumber    := stStationsNummern.NummerIntern;
          wSps2MmiErrorShuttleSchritt   := STEP_400_E;
          wSps2MmiErrorShuttlePosition4 := 0;
          wSps2MmiErrorShuttlePosition5 := 0;
          wSps2MmiErrorShuttlePosition6 := 0;
          wSps2MmiErrorShuttlePosition7 := 0;
          wSps2MmiErrorShuttlePosition8 := 0;
          wSps2MmiErrorShuttlePosition9 := 0;
          MsgToMmi( auftragsnr_w := SB0_SPS_ErrorMSG );
          steplSchmierung := STEP_900_E;
        END_IF

      // ZENTRALSCHMIERUNG ============================================================================
      STEP_450_E:
        //  Es wird überprüft ob Schmierkreis 1 oder 2 die geforderten Hübe ausgeführt hat,
        //  sodass ein der Schmierkreis bei dem nächsten Zyklus abgeschaltet wird.
        FOR wlIndex := cSCHMIERKREIS_1 TO cSCHMIERKREIS_2 DO
          IF ailAktiverHub[wlIndex] = ppParameterBaustein.aiAnzahlHuebe[wlIndex] THEN
            ablHubAktiv[wlIndex]    := FALSE;
            ablStarteKreis[wlIndex] := FALSE;
            ailAktiverHub[wlIndex]  :=0;
          END_IF
        END_FOR

        steplSchmierung := STEP_500_E;


      // ZENTRALSCHMIERUNG ============================================================================
      STEP_500_E:
        (* Hinweis:
           - Folgende Situationen gibt es nun:
           - STEP_500_E Anzahl der Hübe ist ODER ist nicht erreicht und die Zahl der max. Hübe bis zur Pause IST erreicht
           - STEP_530_E Anzahl der Hübe ist erreicht und der Schmiervorgang ist beendet
           - STEP_560_E Anzahl der Hübe ist NICHT erreicht und die Zahl der max. Hübe bis zur Pause ist NICHT erreicht
        *)

        FOR wlIndex := cSCHMIERKREIS_1 TO cSCHMIERKREIS_2 DO
          IF ( ( ailAktiverHub[wlIndex] MOD iAnzahlHuebeBisGrossePause ) = 0 ) AND ablHubAktiv[wlIndex] THEN
            (* Hinweis:
               - die Anzahl der Hübe bis zur langen Pause sind erreicht weshalb diese Pause zwingend durchgeführt werden muss,
                  bevor die Schmierung nochmal gestartet werden kann
            *)
            ablHubAktiv[wlIndex]     := FALSE;
            ablPauseStarten[wlIndex] := TRUE;
          END_IF
        END_FOR

        steplSchmierung := STEP_530_E;


      // ZENTRALSCHMIERUNG ============================================================================
      STEP_530_E:
        ablPauseStarten[cSCHMIERKREIS_1] := FALSE ;
        ablPauseStarten[cSCHMIERKREIS_2] := FALSE ;
        IF ( NOT ablHubAktiv[cSCHMIERKREIS_1] ) AND ( NOT ablHubAktiv[cSCHMIERKREIS_2] ) AND NOT atoflPause[cSCHMIERKREIS_1].Q AND NOT atoflPause[cSCHMIERKREIS_2].Q THEN

          (* Hinweis:
             - Alle geforderten Hübe wurden durchgeführt und es ist keine Pause notwendig
          *)
          steplSchmierung := STEP_1000_E;
        ELSE
          steplSchmierung := STEP_560_E;
        END_IF

      // ZENTRALSCHMIERUNG ============================================================================
      Step_560_E:
        IF ( ( ailAktiverHub[cSCHMIERKREIS_1] MOD iAnzahlHuebeBisGrossePause ) <> 0 ) OR ( ( ailAktiverHub[cSCHMIERKREIS_2] MOD iAnzahlHuebeBisGrossePause ) <> 0 ) OR
           atoflPause[cSCHMIERKREIS_1].Q OR atoflPause[cSCHMIERKREIS_2].Q THEN

          (* Hinweis:
             - Es sind noch Hübe durchzuführen und die Pause wurde noch nicht erreicht
          *)
          steplSchmierung := STEP_50_E;
        ELSE
          (* Hinweis:
             - Unerwartete Situation, hier sollte man eigentlich nie hinkommen!
          *)
          wSps2MmiErrorNumber           := 110;
          wSps2MmiErrorShuttleNumber    := stStationsNummern.NummerIntern;
          wSps2MmiErrorShuttleSchritt   := STEP_560_E;
          wSps2MmiErrorShuttlePosition4 := 0;
          wSps2MmiErrorShuttlePosition5 := 0;
          wSps2MmiErrorShuttlePosition6 := 0;
          wSps2MmiErrorShuttlePosition7 := 0;
          wSps2MmiErrorShuttlePosition8 := 0;
          wSps2MmiErrorShuttlePosition9 := 0;
          MsgToMmi( auftragsnr_w := SB0_SPS_ErrorMSG );
          steplSchmierung := STEP_900_E;

        END_IF


      // ZENTRALSCHMIERUNG ============================================================================
      STEP_900_E:
        tonlWartezeitFuerSchmierHub( IN := FALSE );

        bpInternerFehler := TRUE;

      // ZENTRALSCHMIERUNG ============================================================================
      STEP_1000_E:
        tonlWartezeitFuerSchmierHub( IN := FALSE );
        tonSchmierkreisAnsteuerung(IN:= FALSE);

        wSps2MmiErrorNumber           := 130;
        wSps2MmiErrorShuttleNumber    := stStationsNummern.NummerIntern;
        wSps2MmiErrorShuttleSchritt   := STEP_1000_E;
        wSps2MmiErrorShuttlePosition4 := 0;
        wSps2MmiErrorShuttlePosition5 := 0;
        wSps2MmiErrorShuttlePosition6 := 0;
        wSps2MmiErrorShuttlePosition7 := 0;
        wSps2MmiErrorShuttlePosition8 := 0;
        wSps2MmiErrorShuttlePosition9 := 0;
        MsgToMmi( auftragsnr_w := SB0_SPS_ErrorMSG );
        steplSchmierung := STEP_1001_E;
        ablHubAktiv[cSCHMIERKREIS_1] := FALSE;
        ablHubAktiv[cSCHMIERKREIS_2] := FALSE;
        blStarteSchmierung           := FALSE;

    // ZENTRALSCHMIERUNG ============================================================================
    END_CASE

  ELSE

    IF ( steplSchmierung > STEP_0_E ) THEN

      out_bSteuerSignal := FALSE;

      ailAktiverHub[cSCHMIERKREIS_1] := 0;
      ailAktiverHub[cSCHMIERKREIS_2] := 0;

      steplSchmierung := STEP_0_E;

      tonlWartezeitFuerSchmierHub( IN := FALSE );
      tonSchmierkreisAnsteuerung(IN:= FALSE);

    END_IF

  END_IF

END_IF
END_ACTION