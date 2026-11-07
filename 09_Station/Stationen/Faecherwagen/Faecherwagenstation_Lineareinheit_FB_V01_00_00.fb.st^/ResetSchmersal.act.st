(* METADATA
{
	"v3Meta": {
		"objectGuid": "56bdc92e-7ac4-4069-b99f-c9d8017d4381"
	}
}
*)
ACTION ResetSchmersal
tplResetSchmersal(IN := blAckRequested OR Nothalt.in_bTasterNothaltQuittieren, PT:= T#500MS, Q => blResetSchmersal, ET => );
END_ACTION