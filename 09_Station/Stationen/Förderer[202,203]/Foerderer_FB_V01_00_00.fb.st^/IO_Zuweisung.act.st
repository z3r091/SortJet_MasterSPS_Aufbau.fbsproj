(* METADATA
{
	"v3Meta": {
		"objectGuid": "79442fd1-2af5-4812-8933-45597606a265"
	}
}
*)
ACTION IO_Zuweisung
//-------------------------------------------------------------------------------------------------
// IO ZUWEISUNG
//-------------------------------------------------------------------------------------------------

CASE BasisStationsParameter.stMKs.stStationsNummern.NummerSPS OF

    ;

  ELSE

    // Kippen
    in_bSensorNicht84Grad := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_5_I_7;
    in_bSensorNicht90Grad := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_6_I_8;

    Kippen.bpSensorNicht84Grad := in_bSensorNicht84Grad;
    Kippen.bpSensorNicht90Grad := in_bSensorNicht90Grad;

END_CASE
END_ACTION