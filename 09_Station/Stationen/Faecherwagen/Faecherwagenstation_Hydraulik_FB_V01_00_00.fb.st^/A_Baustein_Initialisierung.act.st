(* METADATA
{
	"v3Meta": {
		"objectGuid": "5fa0690d-d940-4cf9-b75e-26a8152730da"
	}
}
*)
ACTION A_Baustein_Initialisierung
//-------------------------------------------------------------------------------------------------
// BAUSTEIN INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
BasisStationsParameter.awFehlerInformationen[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;

// Anschlag laut MK, beide Endlagen werden abgefragt
Anschlag.bpAktivieren                  := BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag;
Anschlag.bpAbfrageAusgefahrenVorhanden := TRUE;
Anschlag.bpAbfrageEingefahrenVorhanden := TRUE;

// Option AGV: Anschlag zusaetzlich vor/zurueck, beide Endlagen werden abgefragt
AnschlagHorizontal.bpAktivieren :=     BasisStationsParameter.stMKs.stStationsAufbau.bAnschlag
                                   AND BasisStationsParameter.stMKs.stStationsAufbau.bAGV;
AnschlagHorizontal.bpAbfrageAusgefahrenVorhanden := TRUE;
AnschlagHorizontal.bpAbfrageEingefahrenVorhanden := TRUE;

// Zugeordnete Hydraulikstation laut MK (0 = keine)
IF     ( BasisStationsParameter.stMKs.stStationsAufbau.wHydraulikstation >= cERSTE_HYDRAULIKSTATIONS_NR )
   AND ( BasisStationsParameter.stMKs.stStationsAufbau.wHydraulikstation <= cLETZTE_HYDRAULIKSTATIONS_NR )
THEN
  refHydraulikstation REF= aHydraulikstation[BasisStationsParameter.stMKs.stStationsAufbau.wHydraulikstation];
END_IF
END_ACTION