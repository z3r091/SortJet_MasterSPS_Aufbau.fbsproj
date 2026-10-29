(* METADATA
{
	"v3Meta": {
		"objectGuid": "069a39b7-4f5e-4945-ad9c-15d536732ac7"
	}
}
*)
ACTION Status
l_mc_ReadStatus
(
  Axis := ppAntriebsInformationen.wAchsID,
  Enable := NOT l_mc_ReadStatus.Error
);
END_ACTION