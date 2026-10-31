(* METADATA
{
  "v3Meta": {
    "objectGuid": "88c040f8-409a-4941-b3a2-808eaede908e"
  }
}
*)
ACTION BETRIEBSART_Referenz
CASE asteplSchritt[REFERENZ] OF

  STEP_0_E:
    IF NOT bpMotionAktiv THEN // Warten bis die Motion nichts anderes aktiv hat
      asteplSchritt[REFERENZ] := STEP_100_E;
    END_IF


  STEP_100_E:

    tonlSoftwareFreigabe( IN := NOT l_mc_Power.Status, PT := cTIME_HARDWARE_FREIGABE );
    IF l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
      blReferenzLoeschen := TRUE; // Referenz ablöschen
      IF NOT bpIstReferenziert THEN
        blReferenzLoeschen := FALSE;
        asteplSchritt[REFERENZ] := STEP_200_E;
      END_IF
    ELSIF tonlSoftwareFreigabe.Q THEN
      asteplSchritt[REFERENZ] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_200_E:
    tonlHardwareFreigabe( IN := NOT bpReglerBereit , PT := cTIME_HARDWARE_FREIGABE );
    IF bpReglerBereit THEN // Nur weitermachen wenn der Umrichter bereit ist
      asteplSchritt[REFERENZ] := STEP_300_E;
    ELSIF tonlHardwareFreigabe.Q THEN
      asteplSchritt[REFERENZ] := STEP_900_E;
      blInternerFehler := TRUE;
      Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
    END_IF

  STEP_300_E:
    // Referenzfahrt ausführen
    l_mc_Home
    (
      Axis := ppAntriebsInformationen.wAchsID,
      Position := 0, //Extra Offset adde to the value of VON_NC.MK,
      Execute := TRUE
    );
    IF l_mc_Home.Done AND bpIstReferenziert AND NOT bpAntrieblaeuft THEN
      l_mc_Home
      (
        Axis := ppAntriebsInformationen.wAchsID,
        Execute := FALSE
      );
      asteplSchritt[REFERENZ] := STEP_1000_E;
    END_IF
    IF l_mc_Home.Error THEN
      wlFehlerVonMotionFunktion := l_mc_Home.ErrorID;
      asteplSchritt[REFERENZ] := STEP_900_E;
    END_IF

    // Fehler auswertung
    IF NOT l_mc_Power.Status OR NOT bpReglerBereit THEN
      asteplSchritt[REFERENZ] := STEP_900_E;
      blInternerFehler := TRUE;
      IF NOT l_mc_Power.Status THEN // Nur weitermachen wenn die Software-Freigabe gesetzt ist
        Antriebsfehler.wlBausteinFehlerNr := cKeineSoftwareReglerFreigabeBeiPositionierung;
      ELSE
        Antriebsfehler.wlBausteinFehlerNr := cKeineHardwareReglerFreigabeBeiPositionierung;
      END_IF
    END_IF

  STEP_900_E:
    l_mc_Home( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
    blAchseStoppen := bpReglerBereit AND NOT l_mc_ReadStatus.Errorstop AND ( bpAntrieblaeuft OR bpAchseSychron );

  STEP_1000_E:
    bpDone := bpIstReferenziert;

END_CASE
END_ACTION