(* METADATA
{
  "v3Meta": {
    "objectGuid": "f777e7d2-b541-4986-a805-f532b855ffdc"
  }
}
*)
ACTION Reset
(***************************************************************************************************)
(* BAUSTEIN: RESET *)
(***************************************************************************************************)
IF bpReset THEN

  CASE steplReset OF

(* RESET ============================================================================ *)
    STEP_0_E:

      (* Hinweis:
          - Zu Beginn die Grundsätzlichsten Dinge zurücksetzen
      *)
      IF blStarteSchmierung AND ( steplSchmierung = STEP_900_E ) THEN

        out_bSteuerSignal := FALSE;
        wlIndex := 0;

        FOR wlIndex := cSCHMIERKREIS_1 TO cSCHMIERKREIS_2 DO
          ailAktiverHub[wlIndex]  := 0;
          ablStarteKreis[wlIndex] := FALSE; 
          ablHubAktiv[wlIndex]    := FALSE;
          atoflPause[wlIndex]( IN := FALSE );
        END_FOR

        tonlWartezeitFuerSchmierHub( IN := FALSE );
        tonSchmierkreisAnsteuerung(IN:= FALSE);
        wlIndex := 0;

        blSchmierhubOk            := FALSE;
        blSchmierhubOkBaldLeer    := FALSE;
        blKeineOderLeereKartusche := FALSE;
        blGeraeteFehler           := FALSE;

        steplSchmierung := STEP_0_E;
        blStarteSchmierung := FALSE;

      END_IF

      IF tonlSchmierungNichtBetriebsbereit.Q OR bpFehler THEN

        wSps2MmiErrorNumber           := 100;
        wSps2MmiErrorShuttleNumber    := stStationsNummern.NummerSPS;
        wSps2MmiErrorShuttleSchritt   := STEP_0_E;
        wSps2MmiErrorShuttlePosition4 := 0;
        wSps2MmiErrorShuttlePosition5 := 0;
        wSps2MmiErrorShuttlePosition6 := 0;
        wSps2MmiErrorShuttlePosition7 := 0;
        wSps2MmiErrorShuttlePosition8 := 0;
        wSps2MmiErrorShuttlePosition9 := 0;
        MsgToMmi( auftragsnr_w := SB0_SPS_ErrorMSG );

        steplReset := STEP_100_E;
      ELSE
        steplReset := STEP_1000_E;
      END_IF

(* RESET ============================================================================ *)
    STEP_100_E:
      (* Hinweis:
          - Das Steuersignal so lange setzen wie notwendig, 
            um einen Reset durchzuführen
      *)
      tonlSteuerSignal_Reset_Starten( IN := TRUE , PT := tResetStarten );

      out_bSteuerSignal := TRUE;

      IF tonlSteuerSignal_Reset_Starten.Q THEN

        out_bSteuerSignal := FALSE;

        tonlSteuerSignal_Reset_Starten( IN := FALSE );

        steplReset := STEP_1000_E;

      END_IF

(* RESET ============================================================================ *)
    STEP_1000_E:
      bpFehler := FALSE;
      bpInternerFehler := FALSE;
      out_bSteuerSignal := FALSE;

      (* Hinweis:
          - Meldung Fett leer quittieren. Ist die Kartusche weiter leer, meldet die Pumpe es beim naechsten Hub erneut
      *)
      blFettLeer := FALSE;

      steplReset := STEP_0_E;

      bpReset := FALSE;

  END_CASE

ELSE

  IF ( steplReset > STEP_0_E ) THEN
    tonlSteuerSignal_Reset_Starten( IN := FALSE );
    out_bSteuerSignal := FALSE;
    steplReset := STEP_0_E;
  END_IF

END_IF
END_ACTION