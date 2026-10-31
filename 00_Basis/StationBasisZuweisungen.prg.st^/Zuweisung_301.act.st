(* METADATA
{
  "v3Meta": {
    "objectGuid": "f22c61c3-e14c-4dd4-a956-6cafd549323c"
  }
}
*)
ACTION Zuweisung_301
// Zuweisung der MK's
starrFaecherwagenBasisParameter[cSTATION_301].stMKs REF= apgMKFaecherwagenstation[cSTATION_301];

// Zuweisung Sammel-IOs
bgDruckluftFaecherwagenstationenOK := in_bDruckluftFaecherwagenOK;
END_ACTION