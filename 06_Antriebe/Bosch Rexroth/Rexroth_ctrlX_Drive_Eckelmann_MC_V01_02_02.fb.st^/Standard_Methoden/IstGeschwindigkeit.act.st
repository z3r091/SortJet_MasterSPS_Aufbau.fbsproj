(* METADATA
{
  "v3Meta": {
    "objectGuid": "43c32770-3f44-41e7-93e4-b3eb6054e1ca"
  }
}
*)
ACTION IstGeschwindigkeit
l_mc_ReadActualVelocity
(
  Axis := ppAntriebsInformationen.wAchsID,
  Enable := NOT l_mc_ReadActualVelocity.Error
);
IF l_mc_ReadActualVelocity.Valid THEN
  IF l_ts_MKAxisConfig.dwAxisFlags.0 THEN // Rotative Achsen anders berechnen
    rpIstGeschwindigkeit := TO_REAL(l_mc_ReadActualVelocity.Velocity) * 360 / 60;
  ELSE
    rpIstGeschwindigkeit := TO_REAL(l_mc_ReadActualVelocity.Velocity) / 60;
  END_IF
END_IF
END_ACTION