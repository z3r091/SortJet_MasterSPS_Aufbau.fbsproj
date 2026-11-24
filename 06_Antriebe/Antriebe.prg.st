(* METADATA
{
	"v3Meta": {
		"objectGuid": "130e50b5-3a19-47f5-9b2d-e0706d73a38e"
	}
}
*)
PROGRAM Antriebe
VAR
  i : INT := 0;
END_VAR

// Aufruf:
//    - Antrieb
IF NOT Main.blErsterZyklus THEN
  FOR i := 0 TO 64 DO
    // Visu "Antriebe_Verfahren": uebernommener Override gilt nur fuer die gewaehlte Achse
    IF ( AntriebeVerfahren.bpOverrideWirksam AND ( INT_TO_WORD( i ) = wgAuswahlAchsID ) ) THEN
      pgAntriebe[i]( rpOverride := AntriebeVerfahren.rpOverrideVisu );
    ELSE
      pgAntriebe[i]( rpOverride := rgMaschinenGeschwindigkeitsOverride );
    END_IF
  END_FOR
  pgAntriebe[65]();
END_IF

IF M_SB0_MMI_DRIVEOVERRIDE THEN

  IF IsBetweenWORD(tMmi2SpsInfo.wMmi2SpsOverrideValue, 0, 100) THEN
    rgMaschinenGeschwindigkeitsOverride := TO_REAL(tMmi2SpsInfo.wMmi2SpsOverrideValue);
  END_IF

  M_SB0_MMI_DRIVEOVERRIDE := FALSE;

END_IF
END_PROGRAM