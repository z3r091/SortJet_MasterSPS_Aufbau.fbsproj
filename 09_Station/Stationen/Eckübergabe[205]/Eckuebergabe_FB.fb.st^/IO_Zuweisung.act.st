(* METADATA
{
  "v3Meta": {
    "objectGuid": "ae102d04-ec53-4753-bdfc-5ff6b302540e"
  }
}
*)
ACTION IO_Zuweisung
//==================================================================================================
// IO ZUWEISUNG
//==================================================================================================
CASE BasisStationsParameter.stMKs.stStationsNummern.NummerSPS OF

  ;

ELSE

  // Hubrahmen (Signale ueber den Umrichter der X-Achse)
  Hubrahmen.in_bStatusZylinderEingefahren := Glastransport_X.Antrieb.udipEingaengeUmrichter.cXG37_5_I_7;
  Hubrahmen.in_bStatusZylinderAusgefahren := Glastransport_X.Antrieb.udipEingaengeUmrichter.cXG37_6_I_8;

  Glastransport_X.Antrieb.wpAusgaengeUmrichter.cXG37_O_5 := Hubrahmen.out_bZylinderEinfahren;
  Glastransport_X.Antrieb.wpAusgaengeUmrichter.cXG37_O_6 := Hubrahmen.out_bZylinderAusfahren;

END_CASE
END_ACTION