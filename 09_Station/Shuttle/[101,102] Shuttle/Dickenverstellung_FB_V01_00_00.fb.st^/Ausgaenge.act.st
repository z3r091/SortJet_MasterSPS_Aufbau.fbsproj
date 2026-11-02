(* METADATA
{
  "v3Meta": {
    "objectGuid": "7de78188-4102-4179-a46c-2283be76f7f9"
  }
}
*)
ACTION Ausgaenge
//-------------------------------------------------------------------------------------------------
// BAUSTEIN: AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Ausgang:
//   - Status ob der Baustein angesteuert wird
bpResourceAktiv := ( bpStartePositionierung );


// Ausgang:
//   - Ache in Referenz
bpInReferenz    := Antrieb.bpIstReferenziert;


(* Anmerkung:
   - Realisierung durch ein ENUM
*)
IF (ABS (Antrieb.rpIstPosition - ppParameterBaustein.rPosition_Minimal ) <= ppParameterBaustein.rToleranz ) THEN
  eStatusStellung := eZylinderStellung16mm;

ELSIF (ABS (Antrieb.rpIstPosition - ppParameterBaustein.rPosition_Mittel ) <= ppParameterBaustein.rToleranz ) THEN
  eStatusStellung := eZylinderStellung23mm;

ELSIF (ABS (Antrieb.rpIstPosition - ppParameterBaustein.rPosition_Maximal ) <= ppParameterBaustein.rToleranz ) THEN
  eStatusStellung := eZylinderStellung29mm;

ELSE
  eStatusStellung := eZylinderUndefiniert;

END_IF
END_ACTION