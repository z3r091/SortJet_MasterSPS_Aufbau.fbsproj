(* METADATA
{
	"v3Meta": {
		"objectGuid": "f0428ac3-de7d-45c5-b9f6-87f92d4b12a8"
	}
}
*)
ACTION StopVerwaltung
// Gemeinsames Anhalten fuer alle Betriebsarten.
IF blAchseStoppen THEN
  // 1. Jerk bei Stop-Beginn festlegen und bis Stop-Ende beibehalten.
  IF NOT blAchseStoppenAktiv THEN
    rlRuckStop := rlRuckVerzoegerung;

    // Positive Beschleunigung muss zuerst abgebaut werden.
    // Deshalb hier mindestens den Beschleunigungs- und bisherigen Auftrags-Jerk verwenden.
    IF bpBeschleunigungAktiv OR NOT l_mc_ReadStatus.Valid THEN
      rlRuckStop := MAX(rlRuckStop, rlRuckBeschleunigung);
      // Bei geaenderten Eingaben auch die Werte des laufenden Auftrags beachten.
      CASE wlAktiveBetriebsart OF
        ABSOLUT, RELATIV:
          rlRuckStop := MAX(rlRuckStop, TO_REAL(l_mc_MoveAbsolute.Jerk));
        HANDPLUS, HANDMINUS, SCHEIBENMESSUNG:
          rlRuckStop := MAX(rlRuckStop, TO_REAL(l_mc_MoveVelocity.Jerk));
        RESTWEG:
          rlRuckStop := MAX(rlRuckStop,
                             TO_REAL(l_mc_MoveVelocity.Jerk), TO_REAL(l_mc_MoveAbsolute.Jerk));
        SYNC_AUF_MASTER, INVERTIERTER_SYNC_AUF_MASTER:
          rlRuckStop := MAX(rlRuckStop, TO_REAL(l_mc_GearIn.Jerk));
      END_CASE
    END_IF
  END_IF

  // 2. Bei geaenderten Stop-Parametern eine neue Execute-Flanke vorbereiten.
  IF (l_mc_Stop.Jerk <> rlRuckStop)
     OR (l_mc_Stop.Deceleration <> TO_LREAL(rlVerzoegerung * cFAKTOR_RAMPEN)) THEN
    l_mc_Stop(Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE);
  END_IF

  // 3. Stop mit dem festgehaltenen Jerk ausfuehren.
  l_mc_Stop(
             Axis            := ppAntriebsInformationen.wAchsID,
             Deceleration    := TO_LREAL(rlVerzoegerung * cFAKTOR_RAMPEN),
             Jerk            := rlRuckStop,
             StopSpecification := MC_StopSpecification.STOP_SPEC_ALL_AXIS_MOTION_E,
             Execute         := TRUE
           );
  blAchseStoppenAktiv := TRUE;

ELSE
  // kein Stop angefordert → Stop-FB zurücksetzen
  l_mc_Stop(Axis := ppAntriebsInformationen.wAchsID, Execute := FALSE);
  blAchseStoppenAktiv := FALSE;
END_IF;
END_ACTION