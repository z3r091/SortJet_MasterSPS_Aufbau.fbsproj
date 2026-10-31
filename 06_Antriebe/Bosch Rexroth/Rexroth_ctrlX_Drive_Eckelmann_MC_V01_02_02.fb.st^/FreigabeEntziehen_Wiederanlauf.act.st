(* METADATA
{
  "v3Meta": {
    "objectGuid": "91260ed7-d0f3-4853-b1f2-4ccb222d9ae8"
  }
}
*)
ACTION FreigabeEntziehen_Wiederanlauf
IF ( NOT blFreigabeEntziehenAktiv ) AND blFreigabeEntziehenAktivVorzyklus THEN
  // Reset-Freigabe erst nach aktivem Stop aufheben, sonst koennte rtlStop die Schrittkette unerwuenscht resetten.
  IF NOT blAchseStoppen AND NOT blAchseStoppenAktiv THEN
    blStopOhneReset := FALSE;
  END_IF

  // Wiederanlauf nach Pause:
  // Schritte ohne erneutes Execute := TRUE auf den jeweiligen Startschritt zuruecksetzen.
  CASE wlAktiveBetriebsart OF
    HANDPLUS:
      IF ( asteplSchritt[HANDPLUS] = STEP_400_E ) OR ( asteplSchritt[HANDPLUS] = STEP_1000_E ) THEN
        asteplSchritt[HANDPLUS] := STEP_300_E;
      END_IF

    HANDMINUS:
      IF ( asteplSchritt[HANDMINUS] = STEP_400_E ) OR ( asteplSchritt[HANDMINUS] = STEP_1000_E ) THEN
        asteplSchritt[HANDMINUS] := STEP_300_E;
      END_IF

    ABSOLUT:
      IF asteplSchritt[ABSOLUT] = STEP_500_E THEN
        asteplSchritt[ABSOLUT] := STEP_450_E;
      END_IF

    RELATIV:
      IF asteplSchritt[RELATIV] = STEP_500_E THEN
        asteplSchritt[RELATIV] := STEP_400_E;
      END_IF

    SCHEIBENMESSUNG:
      IF ( asteplSchritt[SCHEIBENMESSUNG] = STEP_350_E ) OR ( asteplSchritt[SCHEIBENMESSUNG] = STEP_500_E ) THEN
        asteplSchritt[SCHEIBENMESSUNG] := STEP_325_E;
      END_IF

    RESTWEG:
      IF asteplSchritt[RESTWEG] = STEP_450_E THEN
        asteplSchritt[RESTWEG] := STEP_400_E;
      ELSIF asteplSchritt[RESTWEG] = STEP_550_E THEN
        asteplSchritt[RESTWEG] := STEP_525_E;
      END_IF

    SYNC_AUF_MASTER:
      IF asteplSchritt[SYNC_AUF_MASTER] = STEP_1000_E THEN
        asteplSchritt[SYNC_AUF_MASTER] := STEP_400_E;
      END_IF

    INVERTIERTER_SYNC_AUF_MASTER:
      IF asteplSchritt[INVERTIERTER_SYNC_AUF_MASTER] = STEP_1000_E THEN
        asteplSchritt[INVERTIERTER_SYNC_AUF_MASTER] := STEP_400_E;
      END_IF

    RESET:
      IF asteplSchritt[RESET] = STEP_250_E THEN
        asteplSchritt[RESET] := STEP_200_E;
      ELSIF ( asteplSchritt[RESET] = STEP_325_E ) OR ( asteplSchritt[RESET] = STEP_350_E ) OR ( asteplSchritt[RESET] = STEP_400_E ) THEN
        asteplSchritt[RESET] := STEP_300_E;
      ELSIF ( asteplSchritt[RESET] = STEP_475_E ) OR ( asteplSchritt[RESET] = STEP_500_E ) THEN
        asteplSchritt[RESET] := STEP_450_E;
      END_IF
  END_CASE
END_IF

IF blFreigabeEntziehenAktiv THEN
  blStopOhneReset := TRUE;
  bpDone := FALSE;

  // Aktive MC-/CoE-Aktionen auch bei pausierter Betriebsartlogik sicher beenden
  l_fb_CoeLesen( i_b_Execute := FALSE );
  l_fb_CoeSchreiben( i_b_Execute := FALSE );
  l_mc_GearIn( Master := ppAntriebsInformationen.wAchsID, Slave := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_Reset( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_Home( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_MoveVelocity( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );
  l_mc_MoveAbsolute( Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE );

  // Warte-/Fehlertimer der eingefrorenen Schrittkette zuruecksetzen, damit die Haltezeit nicht als Timeout zaehlt
  tonlSoftwareFreigabe( IN := FALSE );
  tonlHardwareFreigabe( IN := FALSE );

  // Fahrtest nicht nur ueber bpAntrieblaeuft (Weg/Zyklus > 0.1 mm, 100 ms Entprellung -> langsame Fahrt / Anlauf wird als Stillstand gewertet),
  // sondern zusaetzlich ueber den MC-Status: Achse nicht im Stillstand (aber nicht Disabled/ungueltig) => MC_Stop, Power erst danach weg
  IF ( bpAntrieblaeuft OR bpAchseSychron OR l_mc_ReadStatus.Stopping OR blAchseStoppenAktiv
       OR ( l_mc_ReadStatus.Valid AND NOT l_mc_ReadStatus.StandStill AND NOT l_mc_ReadStatus.Disabled ) )
     AND NOT l_mc_ReadStatus.ErrorStop THEN
    blAchseStoppen := TRUE;
    blFreigabeEntziehenPowerAus := FALSE;
  ELSE
    blAchseStoppen := FALSE;
    blFreigabeEntziehenPowerAus := TRUE;
  END_IF
ELSE
  blFreigabeEntziehenPowerAus := FALSE;
END_IF
END_ACTION