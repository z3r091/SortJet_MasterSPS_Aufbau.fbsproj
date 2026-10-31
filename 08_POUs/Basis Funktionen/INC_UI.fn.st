(* METADATA
{
  "v3Meta": {
    "objectGuid": "e071f047-ba29-40c0-bdd3-dce3563eb13b"
  }
}
*)
FUNCTION INC_UI : UINT
VAR_INPUT
	pui : REFERENCE TO UINT;
END_VAR
VAR
END_VAR

IF pui < 65536
THEN
  pui := pui + 1;
END_IF
END_FUNCTION