(* METADATA
{
	"v3Meta": {
		"objectGuid": "4af98741-4e9d-4c0b-ae92-ac6a6c18f571"
	}
}
*)
ACTION BETRIEBSART_Absolut
// Gemeinsame Auswahl; vorhandener Parameter-Re-Entry uebernimmt den Jerk.
rlRuckzeit := RuckFuerBewegung(bStart := asteplSchritt[ABSOLUT] = STEP_450_E,
                                bMitZiel := TRUE, lrZiel := TO_LREAL(rlZielPosition));

CASE asteplSchritt[ABSOLUT] OF

  STEP_0_E:
    IF NOT bpMotionAktiv THEN // Warten bis die Motion nichts anderes aktiv hat
      asteplSchritt[ABSOLUT] := STEP_100_E;
    END_IF

  STEP_100_E:
    tonlSoftwareFreigabe( IN := NOT l_mc_Power.Status, PT := cTIME_HARDWARE_FREIGABE );
    IF l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
      asteplSchritt[ABSOLUT] := STEP_200_E;
    ELSIF tonlSoftwareFreigabe.Q THEN
      asteplSchritt[ABSOLUT] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_200_E:
    tonlHardwareFreigabe( IN := NOT bpReglerBereit, PT := cTIME_HARDWARE_FREIGABE );
    IF bpReglerBereit THEN // Nur weitermachen wenn der Umrichter bereit ist
      asteplSchritt[ABSOLUT] := STEP_300_E;
    ELSIF tonlHardwareFreigabe.Q THEN
      asteplSchritt[ABSOLUT] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_300_E:
    IF bpIstReferenziert THEN // Nur weitermachen wenn der Umrichter in Referenz meldet
      asteplSchritt[ABSOLUT] := STEP_400_E;
    ELSE
      asteplSchritt[ABSOLUT] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeinReferenzpunktBeiPosAbs;
    END_IF

  STEP_400_E:
    // Zielposition überprüfen
    IF blSoftwareLimitAktiv AND ( rpZielposition < rpMinPosition ) THEN
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cMotionMinimumSoftwareEndschalterAusgeloest;
      asteplSchritt[ABSOLUT] := STEP_900_E;
    ELSIF blSoftwareLimitAktiv AND ( rpZielposition > rpMaxPosition ) THEN
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cMotionMaximumSoftwareEndschalterAusgeloest;
      asteplSchritt[ABSOLUT] := STEP_900_E;
    ELSE
      rlZielPosition := rpZielposition;
      asteplSchritt[ABSOLUT] := STEP_450_E;
    END_IF

  STEP_450_E:
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

    asteplSchritt[ABSOLUT] := STEP_500_E;

  STEP_500_E:
    IF ( ( ( rlGeschwindigkeit * cFAKTOR_GESCHWINDIGKEIT ) <> l_mc_MoveAbsolute.Velocity )
         OR ( ( rlBeschleunigung * cFAKTOR_RAMPEN ) <> l_mc_MoveAbsolute.Acceleration )
         OR ( ( rlVerzoegerung * cFAKTOR_RAMPEN ) <> l_mc_MoveAbsolute.Deceleration )
         OR (   rlRuckzeit <> l_mc_MoveAbsolute.Jerk ) )
    THEN
      l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[ABSOLUT] := STEP_400_E;
    ELSIF l_mc_MoveAbsolute.Done AND NOT bpAntrieblaeuft THEN
      l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[ABSOLUT] := STEP_1000_E;
    ELSIF l_mc_MoveAbsolute.Error THEN
      wlFehlerVonMotionFunktion := l_mc_MoveAbsolute.ErrorID;
      l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
      asteplSchritt[ABSOLUT] := STEP_900_E;
    END_IF

    l_mc_MoveAbsolute
      (
        Axis := ppAntriebsInformationen.wAchsID
      );

    // Fehler auswertung
    IF NOT l_mc_Power.Status OR NOT bpReglerBereit THEN
      asteplSchritt[ABSOLUT] := STEP_900_E;
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