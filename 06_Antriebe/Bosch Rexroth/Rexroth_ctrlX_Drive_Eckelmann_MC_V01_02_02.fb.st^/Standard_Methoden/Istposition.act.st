(* METADATA
{
  "v3Meta": {
    "objectGuid": "5dddbe07-35c7-4b08-936f-494c3e7dbe41"
  }
}
*)
ACTION Istposition
l_mc_ReadActualPosition
(
  Axis := ppAntriebsInformationen.wAchsID,
  Enable := NOT l_mc_ReadActualPosition.Error
);
IF l_mc_ReadActualPosition.Valid THEN
  rpIstPosition := TO_REAL(l_mc_ReadActualPosition.Position);
END_IF
END_ACTION