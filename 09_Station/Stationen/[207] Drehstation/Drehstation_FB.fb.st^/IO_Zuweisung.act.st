(* METADATA
{
	"v3Meta": {
		"objectGuid": "c4b742aa-bbcd-4c0d-8dcb-d30d0f57abc8"
	}
}
*)
ACTION IO_Zuweisung
(***************************************************************************************************)
(* IO ZUWEISUNG *)
(***************************************************************************************************)

CASE BasisStationsParameter.stMKs.stStationsNummern.NummerSPS OF
 
  cSTATION_207:	
  
	// Gebläse
    in_bMotorstarter_Geblaese_OK := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_6_I_8;
	
    Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_5 := %MX218.1; // Start Gebläse 1
    Glastransport.Antrieb.wpAusgaengeUmrichter.cXG37_O_6 := %MX218.1; // Start Gebläse 2
	 
    Kippen.bpSensorNicht84Grad := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_3_I_5;
    Kippen.bpSensorNicht90Grad := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_4_I_6;

END_CASE
END_ACTION