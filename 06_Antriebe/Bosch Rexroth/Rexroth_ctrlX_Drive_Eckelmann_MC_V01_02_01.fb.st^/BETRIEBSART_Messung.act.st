(* METADATA
{
	"v3Meta": {
		"objectGuid": "748a293d-7cb7-4722-9684-4a3f052fb050"
	}
}
*)
ACTION BETRIEBSART_Messung
// Gemeinsame Auswahl; vorhandener Parameter-Re-Entry uebernimmt den Jerk.
rlRuckzeit := RuckFuerBewegung(bStart := asteplSchritt[SCHEIBENMESSUNG] = STEP_325_E,
  bMitZiel := FALSE, lrZiel := 0);

CASE asteplSchritt[SCHEIBENMESSUNG] OF

  STEP_0_E:
    IF NOT bpMotionAktiv THEN // Warten bis die Motion nichts anderes aktiv hat
      lrlMessenPositionSensor1 := lrlMessenPositionSensor2 := 0.0;
      asteplSchritt[SCHEIBENMESSUNG] := STEP_100_E;
    END_IF

  STEP_100_E:
    tonlSoftwareFreigabe( IN := NOT l_mc_Power.Status, PT := cTIME_HARDWARE_FREIGABE );
    IF l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
      asteplSchritt[SCHEIBENMESSUNG] := STEP_200_E;
    ELSIF tonlSoftwareFreigabe.Q THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_200_E:
    tonlHardwareFreigabe( IN := NOT bpReglerBereit, PT := cTIME_HARDWARE_FREIGABE );
    IF bpReglerBereit THEN // Nur weitermachen wenn der Umrichter bereit ist
      asteplSchritt[SCHEIBENMESSUNG] := STEP_300_E;
    ELSIF tonlHardwareFreigabe.Q THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_300_E:
    IF ( blSensoren[eSensorAuswahl_Messung_1] AND NOT blSensoren[eSensorAuswahl_Messung_2] ) OR ( bpDrehrichtungsumkehrMessung AND NOT blSensoren[eSensorAuswahl_Messung_1] AND blSensoren[eSensorAuswahl_Messung_2] ) THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_325_E;
    ELSE
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      bpMessungFehlerhaft := TRUE;
      asteplSchritt[SCHEIBENMESSUNG] := STEP_1000_E;
    END_IF

    // Fehler auswertung
    IF NOT l_mc_Power.Enable OR NOT bpReglerBereit THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_900_E;
      blInternerFehler := TRUE;
      IF NOT l_mc_Power.Enable THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
        Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
      ELSE
        Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
      END_IF
    END_IF
    IF l_mc_MoveVelocity.Error THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_900_E;
    END_IF

  STEP_325_E:
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
    asteplSchritt[SCHEIBENMESSUNG] := STEP_350_E;

  STEP_350_E:

    // Änderungen und Fehler erkennen
    IF ( ( ( rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT ) <> l_mc_MoveVelocity.Velocity )
        OR ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) <> l_mc_MoveVelocity.Acceleration )
        OR ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) <> l_mc_MoveVelocity.Deceleration )
        OR (   rlRuckzeit <> l_mc_MoveVelocity.Jerk ) )
    THEN
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[SCHEIBENMESSUNG] := STEP_325_E;
    ELSIF l_mc_MoveVelocity.Active AND l_mc_MoveVelocity.InVelocity THEN
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
    ELSIF l_mc_MoveVelocity.Error THEN
      wlFehlerVonMotionFunktion := l_mc_MoveVelocity.ErrorID;
      l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[SCHEIBENMESSUNG] := STEP_900_E;
    END_IF

    l_mc_MoveVelocity
    (
      Axis := ppAntriebsInformationen.wAchsID,
    );

    // Sensorik belegt
    IF bFalling[eSensorAuswahl_Messung_1] THEN
      blMesstaster1Gefunden := TRUE;
      lrlMessenPositionSensor1 := l_mc_ReadActualPosition.Position;
    END_IF
    IF bRising[eSensorAuswahl_Messung_2] THEN
      blMesstaster2Gefunden := TRUE;
      lrlMessenPositionSensor2 := l_mc_ReadActualPosition.Position;
    END_IF

    // Messung vollständig abgeschlossen
    IF blMesstaster1Gefunden AND blMesstaster2Gefunden THEN
      IF NOT bpDrehrichtungsumkehrMessung THEN
        lrlMessErgebnis := (lrlMessenPositionSensor1 - lrlMessenPositionSensor2);
        rpMessErgebnis := TO_REAL(lrlMessErgebnis);
      ELSE
        lrlMessErgebnis := (lrlMessenPositionSensor2 - lrlMessenPositionSensor1);
        rpMessErgebnis := TO_REAL(lrlMessErgebnis);
      END_IF
      bpMessungOk := TRUE;
      blStopOhneReset := TRUE;
      asteplSchritt[SCHEIBENMESSUNG] := STEP_1000_E;
    END_IF

    // Fehler auswertung
    IF NOT l_mc_Power.Enable OR NOT bpReglerBereit THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_900_E;
      blInternerFehler := TRUE;
      IF NOT l_mc_Power.Enable THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
        Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
      ELSE
        Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
      END_IF
    END_IF
    IF l_mc_MoveVelocity.Error THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_900_E;
    END_IF

  STEP_500_E:
    IF NOT bpAntrieblaeuft AND l_mc_ReadStatus.StandStill THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_1000_E;
    END_IF

  STEP_900_E:
    l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
    blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );

  STEP_1000_E:
    // Fehler auswertung
    IF NOT l_mc_Power.Status OR NOT bpReglerBereit THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_900_E;
      blInternerFehler := TRUE;
      IF NOT l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
        Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
      ELSE
        Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
      END_IF
    END_IF
    IF l_mc_MoveVelocity.Error THEN
      asteplSchritt[SCHEIBENMESSUNG] := STEP_900_E;
    END_IF

    bpDone := TRUE;

END_CASE
END_ACTION