(* METADATA
{
  "v3Meta": {
    "objectGuid": "2ee0d1a4-84c9-4083-9399-00f06b07a933"
  }
}
*)
ACTION BETRIEBSART_Restweg_Mit_Messung
// Gemeinsame Auswahl; vorhandener Parameter-Re-Entry uebernimmt den Jerk.
rlRuckzeit := RuckFuerBewegung(bStart := (asteplSchritt[RESTWEG] = STEP_400_E)
    OR (asteplSchritt[RESTWEG] = STEP_525_E),
  bMitZiel := asteplSchritt[RESTWEG] >= STEP_500_E,
  lrZiel := TO_LREAL(rlZielPosition));

CASE asteplSchritt[RESTWEG] OF

  STEP_0_E:
    IF NOT bpMotionAktiv THEN // Warten bis die Motion nichts anderes aktiv hat
      asteplSchritt[RESTWEG] := STEP_100_E;
    END_IF

  STEP_100_E:
    tonlSoftwareFreigabe( IN := NOT l_mc_Power.Status, PT := cTIME_HARDWARE_FREIGABE );
    IF l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
      asteplSchritt[RESTWEG] := STEP_200_E;
    ELSIF tonlSoftwareFreigabe.Q THEN
      asteplSchritt[RESTWEG] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_200_E:
    tonlHardwareFreigabe( IN := NOT bpReglerBereit, PT := cTIME_HARDWARE_FREIGABE );
    IF bpReglerBereit THEN // Nur weitermachen wenn der Umrichter bereit ist
      asteplSchritt[RESTWEG] := STEP_300_E;
    ELSIF tonlHardwareFreigabe.Q THEN
      asteplSchritt[RESTWEG] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_300_E:
    IF bpIstReferenziert THEN // Nur weitermachen wenn der Umrichter in Referenz meldet
      asteplSchritt[RESTWEG] := STEP_400_E;
    ELSE
      asteplSchritt[RESTWEG] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeinReferenzpunktBeiPosAbs;
    END_IF

  STEP_400_E:
    // Drehrichtung für Suchfahrt bestimmen
    IF wpRestwegMode.0 THEN
      l_mc_MoveVelocity.Direction :=  MC_Direction.MD_POSITIV_E;
    ELSE
      l_mc_MoveVelocity.Direction :=  MC_Direction.MD_NEGATIV_E;
    END_IF

    IF wpRestwegMode.0 AND blSoftwareLimitAktiv AND ( rpIstPosition >= rpMaxPosition ) THEN
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cMotionMaximumSoftwareEndschalterAusgeloest;
      blStopOhneReset := TRUE;
      asteplSchritt[RESTWEG] := STEP_900_E;
    ELSIF ( NOT wpRestwegMode.0 ) AND blSoftwareLimitAktiv AND ( rpIstPosition <= rpMinPosition ) THEN
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cMotionMinimumSoftwareEndschalterAusgeloest;
      blStopOhneReset := TRUE;
      asteplSchritt[RESTWEG] := STEP_900_E;
    ELSE
      l_mc_MoveVelocity
      (
        Axis := ppAntriebsInformationen.wAchsID,
        Velocity := rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT,
        Acceleration := rlBeschleunigung * cFAKTOR_RAMPEN,
        Deceleration := rlVerzoegerung * cFAKTOR_RAMPEN,
        Jerk := rlRuckzeit,
        BufferMode := MC_BufferMode.BM_ABORTING_E,
        Execute := TRUE
      );
      asteplSchritt[RESTWEG] := STEP_450_E;
    END_IF

    // Sensorik prüfen für Flanken und Messung
    BETRIEBSART_Restweg_X_Flankenerkennung();

  STEP_450_E:
    // Fahrparameter geändert
    IF ( ( ( rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT ) <> l_mc_MoveVelocity.Velocity )
        OR ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) <> l_mc_MoveVelocity.Acceleration )
        OR ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) <> l_mc_MoveVelocity.Deceleration )
        OR (   rlRuckzeit <> l_mc_MoveVelocity.Jerk ) )
    THEN
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RESTWEG] := STEP_400_E;
    ELSIF l_mc_MoveVelocity.Error THEN
      wlFehlerVonMotionFunktion := l_mc_MoveVelocity.ErrorID;
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RESTWEG] := STEP_900_E;
    END_IF

    l_mc_MoveVelocity
    (
      Axis := ppAntriebsInformationen.wAchsID,
    );

    IF ( rlVerzoegerung > 0 ) THEN
      IF    wpRestwegMode.0
        AND blSoftwareLimitAktiv
        AND ( rpStillstandsPosition >= rpMaxPosition )
      THEN
        blInternerFehler := TRUE;
        Antriebsfehler.wlBausteinFehlerNr := cMotionMaximumSoftwareEndschalterAusgeloest;
        l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
        blStopOhneReset := TRUE;
        blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );
        asteplSchritt[RESTWEG] := STEP_900_E;
      ELSIF ( NOT wpRestwegMode.0 )
        AND blSoftwareLimitAktiv
        AND ( rpStillstandsPosition <= rpMinPosition )
      THEN
        blInternerFehler := TRUE;
        Antriebsfehler.wlBausteinFehlerNr := cMotionMinimumSoftwareEndschalterAusgeloest;
        l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
        blStopOhneReset := TRUE;
        blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );
        asteplSchritt[RESTWEG] := STEP_900_E;
      ELSE
        // Sensorik prüfen für Flanken und Messung
        BETRIEBSART_Restweg_X_Flankenerkennung();
      END_IF
    ELSE
      // Sensorik prüfen für Flanken und Messung
      BETRIEBSART_Restweg_X_Flankenerkennung();
    END_IF

  STEP_500_E:
    bpRestwegMaterialGefunden := TRUE;
    rlZielPosition := TO_REAL(lrlRestwegMesstasterGefunden) + rpZielPosition;

    // Sensorik weiterhin für die Messung auswerten
    BETRIEBSART_Restweg_X_Flankenerkennung();

    // Zielposition kleiner/größer Min/max Pos
    IF blSoftwareLimitAktiv AND ( rlZielPosition < rpMinPosition ) THEN
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cMotionMinimumSoftwareEndschalterAusgeloest;
      asteplSchritt[RESTWEG] := STEP_900_E;
    ELSIF blSoftwareLimitAktiv AND ( rlZielPosition > rpMaxPosition ) THEN
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cMotionMaximumSoftwareEndschalterAusgeloest;
      asteplSchritt[RESTWEG] := STEP_900_E;
    ELSE
      asteplSchritt[RESTWEG] := STEP_525_E;
    END_IF

  STEP_525_E:
    l_mc_MoveAbsolute
    (
      Axis := ppAntriebsInformationen.wAchsID,
      Position := rlZielPosition,
      Velocity := rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT,
      Acceleration := rlBeschleunigung * cFAKTOR_RAMPEN,
      Deceleration := rlVerzoegerung * cFAKTOR_RAMPEN,
      Jerk := rlRuckzeit,
      Direction := MC_Direction.MD_SHORTEST_WAY_E,
      BufferMode := MC_BufferMode.BM_ABORTING_E,
      Execute := TRUE
    );

    // Sensorik weiterhin für die Messung auswerten
    BETRIEBSART_Restweg_X_Flankenerkennung();

    asteplSchritt[RESTWEG] := STEP_550_E;

  STEP_550_E:
    IF ( ( ( rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT ) <> l_mc_MoveAbsolute.Velocity )
        OR ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) <> l_mc_MoveAbsolute.Acceleration )
        OR ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) <> l_mc_MoveAbsolute.Deceleration )
        OR (   rlRuckzeit <> l_mc_MoveAbsolute.Jerk ) )
    THEN
      l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RESTWEG] := STEP_500_E;
    ELSIF l_mc_MoveAbsolute.Done AND NOT bpAntrieblaeuft THEN
      l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RESTWEG] := STEP_1000_E;
    ELSIF l_mc_MoveAbsolute.Error THEN
      wlFehlerVonMotionFunktion := l_mc_MoveAbsolute.ErrorID;
      l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[RESTWEG] := STEP_900_E;
    END_IF

    l_mc_MoveAbsolute
    (
      Axis := ppAntriebsInformationen.wAchsID
    );

    // Während der gesamten Absolutfahrt die zweite Flanke erfassen
    BETRIEBSART_Restweg_X_Flankenerkennung();

    // Fehler auswertung
    IF NOT l_mc_Power.Status OR NOT bpReglerBereit THEN
      asteplSchritt[RESTWEG] := STEP_900_E;
      blInternerFehler := TRUE;
      IF NOT l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
        Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
      ELSE
        Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
      END_IF
    END_IF

  STEP_900_E:
    l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
    l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
    blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );

  STEP_1000_E:
    bpDone := TRUE;

END_CASE
END_ACTION