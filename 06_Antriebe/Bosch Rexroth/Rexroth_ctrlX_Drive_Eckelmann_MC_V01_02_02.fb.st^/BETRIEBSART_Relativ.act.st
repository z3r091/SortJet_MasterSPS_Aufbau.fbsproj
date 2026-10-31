(* METADATA
{
  "v3Meta": {
    "objectGuid": "7d6d986c-3860-4a6a-9626-b52f70d8fccd"
  }
}
*)
ACTION BETRIEBSART_Relativ
// Gemeinsame Auswahl; vorhandener Parameter-Re-Entry uebernimmt den Jerk.
rlRuckzeit := RuckFuerBewegung(bStart := asteplSchritt[RELATIV] = STEP_400_E,
  bMitZiel := TRUE, lrZiel := TO_LREAL(rlZielPosition));

CASE asteplSchritt[RELATIV] OF

  STEP_0_E:
    IF NOT bpMotionAktiv THEN // Warten bis die Motion nichts anderes aktiv hat
      asteplSchritt[RELATIV] := STEP_100_E;
    END_IF

  STEP_100_E:
    tonlSoftwareFreigabe( IN := NOT l_mc_Power.Status, PT := cTIME_HARDWARE_FREIGABE );
    IF l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
      asteplSchritt[RELATIV] := STEP_200_E;
    ELSIF tonlSoftwareFreigabe.Q THEN
      asteplSchritt[RELATIV] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_200_E:
    tonlHardwareFreigabe( IN := NOT bpReglerBereit, PT := cTIME_HARDWARE_FREIGABE );
    IF bpReglerBereit THEN // Nur weitermachen wenn der Umrichter bereit ist
      asteplSchritt[RELATIV] := STEP_300_E;//300
    ELSIF tonlHardwareFreigabe.Q THEN
      asteplSchritt[RELATIV] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_300_E:
    IF bpIstReferenziert THEN // Nur weitermachen wenn der Umrichter in Referenz meldet
      asteplSchritt[RELATIV] := STEP_350_E;
    ELSE
      asteplSchritt[RELATIV] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeinReferenzpunktBeiPosAbs;
    END_IF

  STEP_350_E:
    // Für Relativ wird schlicht eine Absolut-Positionierung genutzt
    rlZielposition := rpIstPosition + rpZielposition;

    // Zielposition kleiner/größer Min/max Pos
    IF blSoftwareLimitAktiv AND ( rlZielPosition < rpMinPosition ) THEN
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cMotionMinimumSoftwareEndschalterAusgeloest;
      asteplSchritt[RELATIV] := STEP_900_E;
    ELSIF blSoftwareLimitAktiv AND ( rlZielPosition > rpMaxPosition ) THEN
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cMotionMaximumSoftwareEndschalterAusgeloest;
      asteplSchritt[RELATIV] := STEP_900_E;
    ELSE
      asteplSchritt[RELATIV] := STEP_400_E;
    END_IF

  STEP_400_E:

    l_mc_MoveAbsolute
    (
      Axis := ppAntriebsInformationen.wAchsID,
      Position := rlZielposition,
      Velocity := rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT,
      Acceleration := rlBeschleunigung * cFAKTOR_RAMPEN,
      Deceleration := rlVerzoegerung * cFAKTOR_RAMPEN,
      Jerk := rlRuckzeit,
      Direction := MC_Direction.MD_SHORTEST_WAY_E,
      BufferMode := MC_BufferMode.BM_ABORTING_E,
      Execute := TRUE
    );

    asteplSchritt[RELATIV] := STEP_500_E;

  STEP_500_E:
    IF ( ( ( rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT ) <> l_mc_MoveAbsolute.Velocity )
        OR ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) <> l_mc_MoveAbsolute.Acceleration )
        OR ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) <> l_mc_MoveAbsolute.Deceleration )
        OR (   rlRuckzeit <> l_mc_MoveAbsolute.Jerk ) )
    THEN
      l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RELATIV] := STEP_400_E;
    ELSIF l_mc_MoveAbsolute.Done THEN
      l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RELATIV] := STEP_1000_E;
    ELSIF l_mc_MoveAbsolute.Error THEN
      wlFehlerVonMotionFunktion := l_mc_MoveAbsolute.ErrorID;
      l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RELATIV] := STEP_900_E;
    END_IF

    l_mc_MoveAbsolute
    (
      Axis := ppAntriebsInformationen.wAchsID
    );

    // Fehler auswertung
    IF NOT l_mc_Power.Status OR NOT bpReglerBereit THEN
      asteplSchritt[RELATIV] := STEP_900_E;
      blInternerFehler := TRUE;
      IF NOT l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
        Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
      ELSE
        Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
      END_IF
    END_IF

  STEP_900_E:
    l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
    blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );

  STEP_1000_E:
    bpDone := TRUE;

END_CASE
END_ACTION