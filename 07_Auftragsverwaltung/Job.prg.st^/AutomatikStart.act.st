(* METADATA
{
	"v3Meta": {
		"objectGuid": "773750ca-eb9f-400c-96e8-2e45a60e5e21"
	}
}
*)
ACTION AutomatikStart
(***************************************************************************************************)
(* AUTOMATIK START *)
(***************************************************************************************************)
IF ( M_SB0_MMI_SORTIERUNGAUTOMATIKSTART ) THEN
  M_SB0_MMI_SORTIERUNGAUTOMATIKSTART:=FALSE;

  M_Automatik_Aktiv[tMmi2SpsInfo.wAutomatikStartTransportLineNr]            := TRUE;

END_IF
END_ACTION