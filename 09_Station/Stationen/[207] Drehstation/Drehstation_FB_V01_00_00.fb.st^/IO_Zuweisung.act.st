(* METADATA
{
	"v3Meta": {
		"objectGuid": "c4b742aa-bbcd-4c0d-8dcb-d30d0f57abc8"
	}
}
*)
ACTION IO_Zuweisung
//-------------------------------------------------------------------------------------------------
// IO ZUWEISUNG
//-------------------------------------------------------------------------------------------------

CASE BasisStationsParameter.stMKs.stStationsNummern.NummerSPS OF

  cSTATION_207:

    // Gebläse
    in_bMotorstarter_Geblaese_OK := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_6_I_8;

    Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_5 := Geblaese.bpStarteGeblaese; // Start Gebläse 1
    Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_6 := Geblaese.bpStarteGeblaese; // Start Gebläse 2

    // Kippen
    in_bSensorNicht90Grad := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_3_I_5; // kippen max (90 Grad), Oeffner
    in_bSensorNicht84Grad := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_4_I_6; // kippen min (84 Grad), Oeffner

    Kippen.bpSensorNicht84Grad := in_bSensorNicht84Grad;
    Kippen.bpSensorNicht90Grad := in_bSensorNicht90Grad;

END_CASE
END_ACTION