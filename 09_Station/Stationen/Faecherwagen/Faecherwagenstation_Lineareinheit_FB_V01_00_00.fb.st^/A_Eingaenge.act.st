(* METADATA
{
  "v3Meta": {
    "objectGuid": "f983f638-d974-42a1-b082-3f78b9808976"
  }
}
*)
ACTION A_Eingaenge
// HARDWARE EINGAENGE

  
blLinearEinheitVorne   :=  in_bLinearEinheit1Vorne AND in_bLinearEinheit2Vorne;
blLinearEinheitHinten  :=  in_bLinearEinheit1Hinten AND in_bLinearEinheit2Hinten;
blLinearEinheitSH      :=  in_bLineareinheit1Umgreifposition AND in_bLineareinheit2Umgreifposition;//Eingangsname noch wie im Plan
blGreiferOffen         :=  in_bGreifer1Offen AND in_bGreifer2Offen;
blGreiferZu            :=  in_bGreifer1Zu AND in_bGreifer2Zu;
END_ACTION