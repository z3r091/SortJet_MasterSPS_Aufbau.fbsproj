(* METADATA
{
  "v3Meta": {
    "objectGuid": "7b92aebb-a3f2-4eb0-b504-974c397a8547"
  }
}
*)
ACTION BETRIEBSART_Reset
CASE asteplSchritt[RESET] OF

  STEP_0_E:
    wlAktiveBetriebsart := RESET;
    ResetStepsUndMcAktionen();
    asteplSchritt[RESET] := STEP_100_E;

  STEP_100_E:
    // Reset nur ausführen WENN Idle und kein Fehler
    // oder Antriebsfehler und dieser Löschbar
    // oder Fehler und kein Fehler vom Antrieb (MC-Error)
    IF ( NOT bpMotionAktiv AND NOT blFehlerAktiv )
      OR ( i_ui_Cia402_StatusWord.3 AND Diagnose.bDeleteable )
      OR ( blFehlerAktiv AND NOT i_ui_Cia402_StatusWord.3 )
      OR ( l_mc_ReadStatus.ErrorStop )
    THEN
      bpFehler                           := FALSE;
      blInternerFehler                   := FALSE;
      wlError                            := 0;
      Diagnose.wFehlerNr                 := 0;
      Antriebsfehler.wlBausteinFehlerNr  := 0;
      tonlFehlermeldungAusgeben(IN := FALSE);
      // l_mc_Power
      // (
      //   Axis   := ppAntriebsInformationen.wAchsID,
      //   Enable := FALSE
      // );
      IF i_ui_Cia402_StatusWord.3 OR l_mc_ReadStatus.ErrorStop THEN
        asteplSchritt[RESET] := STEP_200_E;
      ELSIF NOT blFehlerAktiv THEN
        asteplSchritt[RESET] := STEP_1000_E;
      END_IF
    ELSIF ( i_ui_Cia402_StatusWord.3 AND NOT Diagnose.bDeleteable ) THEN
      bpFehler                           := FALSE;
      blInternerFehler                   := FALSE;
      wlError                            := 0;
      Diagnose.wFehlerNr                 := 0;
      Antriebsfehler.wlBausteinFehlerNr  := 0;
      tonlFehlermeldungAusgeben(IN := FALSE);
      asteplSchritt[RESET] := STEP_1000_E;
    END_IF

  STEP_200_E:
    IF l_mc_ReadStatus.Errorstop THEN
      l_mc_Reset(
        Axis := ppAntriebsInformationen.wAchsID,
        Execute := TRUE
      );
      asteplSchritt[RESET] := STEP_250_E;
    ELSE
      IF i_ui_Cia402_StatusWord.3 THEN
        asteplSchritt[RESET] := STEP_275_E;
      ELSE
        blInternerFehler := FALSE;
        Antriebsfehler.wlBausteinFehlerNr := 0;
        asteplSchritt[RESET] := STEP_1000_E;
      END_IF
    END_IF

  STEP_250_E:
    l_mc_Reset(
      Axis := ppAntriebsInformationen.wAchsID
    );
    IF l_mc_Reset.Done THEN
      l_mc_Reset(
        Axis := ppAntriebsInformationen.wAchsID,
        Execute := FALSE
      );
      IF i_ui_Cia402_StatusWord.3 THEN
        tonlWarteAufReset( IN := FALSE );
        asteplSchritt[RESET] := STEP_260_E;
      ELSE
        blInternerFehler := FALSE;
        Antriebsfehler.wlBausteinFehlerNr := 0;
        asteplSchritt[RESET] := STEP_1000_E;
      END_IF
    END_IF

  STEP_260_E:
    // Dem Antrieb Zeit geben, den Fehler nach MC_Reset selbst zu loeschen
    tonlWarteAufReset( IN := TRUE, PT := T#1S );
    IF tonlWarteAufReset.Q THEN
      tonlWarteAufReset( IN := FALSE );
      asteplSchritt[RESET] := STEP_275_E;
    END_IF

    //
    // RESET VIA CoE Write
    //
  STEP_275_E:
    l_fb_CoeSchreiben( i_by_EcID := 1000+l_ts_MKAxisConfig.uiDeviceAddress, i_b_Execute := FALSE, i_b_Reset := TRUE );
    IF NOT l_fb_CoeSchreiben.o_b_Busy THEN
      asteplSchritt[RESET] := STEP_300_E;
    END_IF

  STEP_300_E:
    uilSchreibeUeberCoe := 3;
    l_fb_CoeSchreiben
    (
      i_by_EcID      := 1000+l_ts_MKAxisConfig.uiDeviceAddress,
      i_w_ObjectNum  := 16#2B87,
      i_by_SubIndex  := 2,
      i_w_DataTyp    := 6,
      i_p_Var        := ADR(uilSchreibeUeberCoe),
      i_w_BufSize    := SIZEOF(uilSchreibeUeberCoe)
    );
    l_fb_CoeSchreiben( i_b_Execute := TRUE );
    asteplSchritt[RESET] := STEP_325_E;

  STEP_325_E:
    l_fb_CoeSchreiben();
    IF l_fb_CoeSchreiben.o_b_Busy THEN
      asteplSchritt[RESET] := STEP_350_E;
    END_IF

  STEP_350_E:
    l_fb_CoeSchreiben();
    IF NOT l_fb_CoeSchreiben.o_b_Busy THEN
      asteplSchritt[RESET] := STEP_400_E;
    END_IF

  STEP_400_E:
    l_fb_CoeSchreiben( i_by_EcID := 1000+l_ts_MKAxisConfig.uiDeviceAddress, i_b_Execute := FALSE, i_b_Reset := TRUE );
    IF NOT l_fb_CoeSchreiben.o_b_Busy THEN
      asteplSchritt[RESET] := STEP_450_E;
    END_IF

  STEP_450_E:
    uilSchreibeUeberCoe := 0;
    l_fb_CoeSchreiben
    (
      i_by_EcID      := 1000+l_ts_MKAxisConfig.uiDeviceAddress,
      i_w_ObjectNum  := 16#2B87,
      i_by_SubIndex  := 2,
      i_w_DataTyp    := 6,
      i_p_Var        := ADR(uilSchreibeUeberCoe),
      i_w_BufSize    := SIZEOF(uilSchreibeUeberCoe)
    );
    l_fb_CoeSchreiben( i_b_Execute := TRUE );
    asteplSchritt[RESET] := STEP_475_E;

  STEP_475_E:
    l_fb_CoeSchreiben();
    IF l_fb_CoeSchreiben.o_b_Busy THEN
      asteplSchritt[RESET] := STEP_500_E;
    END_IF

  STEP_500_E:
    l_fb_CoeSchreiben();
    IF NOT l_fb_CoeSchreiben.o_b_Busy THEN
      blInternerFehler := FALSE;
      Antriebsfehler.wlBausteinFehlerNr := 0;
      asteplSchritt[RESET] := STEP_1000_E;
    END_IF

  STEP_1000_E:
    wlAktiveBetriebsart := KEINE_FUNKTION;
    bpDone := NOT bpFehler OR NOT Diagnose.bDeleteable;

END_CASE
END_ACTION