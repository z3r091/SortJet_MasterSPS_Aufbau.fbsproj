(* METADATA
{
	"v3Meta": {
		"objectGuid": "b05be44e-048d-42d4-abc7-77aa943f133f"
	}
}
*)
METHOD M_CloseSocket : UDINT
VAR_INPUT
END_VAR


CloseSocket(ADR(Client.hSocket));

CloseSocket(ADR(hSocket));
END_METHOD