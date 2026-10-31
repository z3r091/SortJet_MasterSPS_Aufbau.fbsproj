(* METADATA
{
  "v3Meta": {
    "objectGuid": "881fd6d0-6f9c-47f2-85a3-13545b9b9be3"
  }
}
*)
//Returns true if the adress is not zero
FUNCTION F_ASSIGNED : BOOL
VAR_INPUT
	i_udi_Adr : __UXINT;
END_VAR
F_ASSIGNED := i_udi_Adr <> 0;
END_FUNCTION