(* METADATA
{
	"v3Meta": {
		"objectGuid": "b67c01ae-ca41-446f-9a32-c307cde119a9"
	}
}
*)
ACTION SK_Hilfsvariablen
// Nothalt-Knöpfe OP's 
FOR wIndex := cERSTES_TERMINAL TO cLETZTES_TERMINAL DO
  WatchIo( ( NOT GetBitFromWord(EV_ToPLC_Nothalt_Terminals, (wIndex-1)) AND NOT Interface_SLC.bpOperatorAcknowledgeRequested ), ( ioccNotausAnOP1Betaetigt - 1 ) + wIndex );
END_FOR
END_ACTION