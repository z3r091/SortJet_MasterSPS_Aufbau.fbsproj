(* METADATA
{
  "v3Meta": {
    "objectGuid": "79442fd1-2af5-4812-8933-45597606a265"
  }
}
*)
ACTION IO_Zuweisung
(***************************************************************************************************)
(* IO ZUWEISUNG *)
(***************************************************************************************************)

CASE BasisStationsParameter.stMKs.stStationsNummern.NummerSPS OF
 
    ;

  ELSE

    // Kippen
    Kippen.bpSensorNicht84Grad := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_5_I_7;
    Kippen.bpSensorNicht90Grad := Glastransport.Antrieb.udipEingaengeUmrichter.cXG37_6_I_8;
  
    // Durchgang belegt
    bDurchgangBelegt           := Glastransport.Antrieb.udipEingaengeUmrichter.cXG31_2_I_2;
  
END_CASE
END_ACTION