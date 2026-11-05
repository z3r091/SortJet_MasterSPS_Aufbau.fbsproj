(* METADATA
{
  "v3Meta": {
    "objectGuid": "e661d145-3ecc-4be2-8108-76df1f0d3cef"
  }
}
*)
ACTION A_Baustein_Initialisierung
//-------------------------------------------------------------------------------------------------
// BAUSTEIN INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
BasisStationsParameter.awFehlerInformationen[0] := BasisStationsParameter.stMKs.stStationsNummern.NummerExtern;

// Arretierung gehoert fest zur Station, beide Endlagen werden abgefragt
Arretierung.bpAktivieren                  := TRUE;
Arretierung.bpAbfrageAusgefahrenVorhanden := TRUE;
Arretierung.bpAbfrageEingefahrenVorhanden := TRUE;
END_ACTION