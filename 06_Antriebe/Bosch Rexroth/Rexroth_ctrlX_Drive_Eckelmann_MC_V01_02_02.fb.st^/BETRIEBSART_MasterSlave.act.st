(* METADATA
{
  "v3Meta": {
    "objectGuid": "6d2aa95c-c8c9-48d0-a651-a62b0cc396bc"
  }
}
*)
ACTION BETRIEBSART_MasterSlave
// Gemeinsame Auswahl; vorhandener Parameter-Re-Entry uebernimmt den Jerk.
rlRuckzeit := RuckFuerBewegung(bStart := asteplSchritt[wlSchrittkette] = STEP_400_E,
                                bMitZiel := FALSE, lrZiel := 0);

CASE asteplSchritt[wlSchrittkette] OF

  STEP_0_E:
    IF NOT bpMotionAktiv THEN // Warten bis die Motion nichts anderes aktiv hat
      asteplSchritt[wlSchrittkette] := STEP_100_E;
    END_IF

  STEP_100_E:
    tonlSoftwareFreigabe( IN := NOT l_mc_Power.Status, PT := cTIME_HARDWARE_FREIGABE );
    IF l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
      asteplSchritt[wlSchrittkette] := STEP_200_E;
    ELSIF tonlSoftwareFreigabe.Q THEN
      asteplSchritt[wlSchrittkette] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_200_E:
    tonlHardwareFreigabe( IN := NOT bpReglerBereit, PT := cTIME_HARDWARE_FREIGABE );
    IF bpReglerBereit THEN // Nur weitermachen wenn der Umrichter bereit ist
      asteplSchritt[wlSchrittkette] := STEP_300_E;
    ELSIF tonlHardwareFreigabe.Q THEN
      asteplSchritt[wlSchrittkette] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_300_E:
    IF bpIstReferenziert THEN // Nur weitermachen wenn der Umrichter in Referenz meldet
      asteplSchritt[wlSchrittkette] := STEP_400_E;
    ELSE
      asteplSchritt[wlSchrittkette] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeinReferenzpunktBeiPosAbs;
    END_IF

  STEP_400_E:
    IF ( NOT IsBetweenWORD(wpMaster, 0, 64) ) OR ( wpMaster = ppAntriebsInformationen.wAchsID ) THEN
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cBetriebsartNichtUnterstuetzt;
      asteplSchritt[wlSchrittkette] := STEP_900_E;
    ELSE
      l_mc_GearIn
        (
          Slave := ppAntriebsInformationen.wAchsID,
          Master := wpMaster,
          Acceleration := rlBeschleunigung * cFAKTOR_RAMPEN,
          Deceleration := rlVerzoegerung * cFAKTOR_RAMPEN,
          Jerk := rlRuckzeit,
          RatioNumerator := 1,
          RatioDenominator := SEL( ( wlAktiveBetriebsart = INVERTIERTER_SYNC_AUF_MASTER ), 1, -1), // SEL: WENN  ( wlAktiveBetriebsart = INVERTIERTER_SYNC_AUF_MASTER ) = FALSE dann 1 ansonsten -1
          BufferMode := MC_BufferMode.BM_ABORTING_E,
          Execute := TRUE
        );

      asteplSchritt[wlSchrittkette] := STEP_1000_E;
    END_IF

  STEP_900_E:
    l_mc_GearIn( Slave := ppAntriebsInformationen.wAchsID, Master := wpMaster, Execute := FALSE );
    blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );

  STEP_1000_E:
    IF ( ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) <> l_mc_GearIn.Acceleration )
         OR ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) <> l_mc_GearIn.Deceleration )
         OR (   rlRuckzeit <> l_mc_GearIn.Jerk ) )
    THEN
      l_mc_GearIn( Slave := ppAntriebsInformationen.wAchsID, Master := wpMaster, Execute := FALSE );
      asteplSchritt[wlSchrittkette] := STEP_400_E;
    END_IF

    l_mc_GearIn
      (
        Slave := ppAntriebsInformationen.wAchsID,
        Master := wpMaster,
      );
    // Done direkt aus dem aktuellen InGear bilden (bpAchseSychron ist der Wert aus dem Vorzyklus)
    bpDone := l_mc_GearIn.InGear;

    // Fehler auswertung
    IF NOT l_mc_Power.Status OR NOT bpReglerBereit THEN
      bpDone := FALSE;
      asteplSchritt[wlSchrittkette] := STEP_900_E;
      blInternerFehler := TRUE;
      IF NOT l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
        Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
      ELSE
        Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
      END_IF
    END_IF
    IF l_mc_GearIn.Error THEN
      bpDone := FALSE;
      wlFehlerVonMotionFunktion := l_mc_GearIn.ErrorID;
      l_mc_GearIn( Slave := ppAntriebsInformationen.wAchsID, Master := wpMaster, Execute := FALSE );
      asteplSchritt[wlSchrittkette] := STEP_900_E;
    END_IF

END_CASE
END_ACTION