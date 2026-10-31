(* METADATA
{
  "v3Meta": {
    "objectGuid": "5e7f3be3-98a2-4beb-b625-b580500a4088"
  }
}
*)
ACTION BETRIEBSART_Handplus
// Gemeinsame Auswahl; vorhandener Parameter-Re-Entry uebernimmt den Jerk.
rlRuckzeit := RuckFuerBewegung(bStart := asteplSchritt[HANDPLUS] = STEP_300_E,
  bMitZiel := blSoftwareLimitAktiv, lrZiel := TO_LREAL(rpMaxPosition));

CASE asteplSchritt[HANDPLUS] OF

  STEP_0_E:
    IF NOT bpMotionAktiv THEN // Warten bis die Motion nichts anderes aktiv hat
      asteplSchritt[HANDPLUS] := STEP_100_E;
    END_IF

  STEP_100_E:
    tonlSoftwareFreigabe( IN := NOT l_mc_Power.Status, PT := cTIME_HARDWARE_FREIGABE );
    IF l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
      asteplSchritt[HANDPLUS] := STEP_200_E;
    ELSIF tonlSoftwareFreigabe.Q THEN
      asteplSchritt[HANDPLUS] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_200_E:
    tonlHardwareFreigabe( IN := NOT bpReglerBereit, PT := cTIME_HARDWARE_FREIGABE );
    IF bpReglerBereit THEN // Nur weitermachen wenn der Umrichter bereit ist
      asteplSchritt[HANDPLUS] := STEP_300_E;
    ELSIF tonlHardwareFreigabe.Q THEN
      asteplSchritt[HANDPLUS] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_300_E:
    IF blSoftwareLimitAktiv AND ( rpIstPosition >= rpMaxPosition ) THEN
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      blStopOhneReset := TRUE;
      asteplSchritt[HANDPLUS] := STEP_1000_E;
    ELSE
      l_mc_MoveVelocity
      (
        Axis := ppAntriebsInformationen.wAchsID,
        Velocity := rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT,
        Acceleration := rlBeschleunigung * cFAKTOR_RAMPEN,
        Deceleration := rlVerzoegerung * cFAKTOR_RAMPEN,
        Jerk := rlRuckzeit,
        BufferMode := MC_BufferMode.BM_ABORTING_E,
        Direction := MC_Direction.MD_POSITIV_E,
        Execute := TRUE
      );
      asteplSchritt[HANDPLUS] := STEP_400_E;
    END_IF

  STEP_400_E:
    IF ( ( ( rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT ) <> l_mc_MoveVelocity.Velocity )
        OR ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) <> l_mc_MoveVelocity.Acceleration )
        OR ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) <> l_mc_MoveVelocity.Deceleration )
        OR (   rlRuckzeit <> l_mc_MoveVelocity.Jerk ) )
    THEN
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[HANDPLUS] := STEP_300_E;
    ELSIF l_mc_MoveVelocity.Active AND l_mc_MoveVelocity.InVelocity THEN
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[HANDPLUS] := STEP_1000_E;
    ELSIF l_mc_MoveVelocity.Error THEN
      wlFehlerVonMotionFunktion := l_mc_MoveVelocity.ErrorID;
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[HANDPLUS] := STEP_900_E;
    END_IF

    l_mc_MoveVelocity
    (
      Axis := ppAntriebsInformationen.wAchsID,
    );

    // Fehler auswertung
    IF NOT l_mc_Power.Status OR NOT bpReglerBereit THEN
      asteplSchritt[HANDPLUS] := STEP_900_E;
      blInternerFehler := TRUE;
      IF NOT l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
        Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
      ELSE
        Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
      END_IF
    END_IF
    IF l_mc_MoveVelocity.Error THEN
      asteplSchritt[HANDPLUS] := STEP_900_E;
    END_IF

    IF     blSoftwareLimitAktiv
      AND ( rlVerzoegerung > 0 )
      AND ( rpStillstandsPosition >= rpMaxPosition )
    THEN
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      blStopOhneReset := TRUE;
      blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );
      asteplSchritt[HANDPLUS] := STEP_1000_E;
    END_IF

  STEP_900_E:
    l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
    blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );

  STEP_1000_E:
    // Fehler auswertung
    IF NOT l_mc_Power.Status OR NOT bpReglerBereit THEN
      asteplSchritt[HANDPLUS] := STEP_900_E;
      blInternerFehler := TRUE;
      IF NOT l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
        Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
      ELSE
        Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
      END_IF
    END_IF
    IF l_mc_MoveVelocity.Error THEN
      asteplSchritt[HANDPLUS] := STEP_900_E;
    END_IF

    // Parameter geändert ?
    IF ( ( ( rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT ) <> l_mc_MoveVelocity.Velocity )
        OR ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) <> l_mc_MoveVelocity.Acceleration )
        OR ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) <> l_mc_MoveVelocity.Deceleration )
        OR (   rlRuckzeit <> l_mc_MoveVelocity.Jerk ) )
    THEN
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[HANDPLUS] := STEP_300_E;
    END_IF

    IF     blSoftwareLimitAktiv
      AND ( rlVerzoegerung > 0 )
      AND ( rpStillstandsPosition >= rpMaxPosition )
    THEN
      l_mc_MoveVelocity(Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE);
      blStopOhneReset := TRUE;
      blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );
    END_IF

END_CASE
END_ACTION