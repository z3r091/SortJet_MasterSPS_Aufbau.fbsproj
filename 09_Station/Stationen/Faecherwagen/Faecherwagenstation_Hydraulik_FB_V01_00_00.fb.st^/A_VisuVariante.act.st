(* METADATA
{
  "v3Meta": {
    "objectGuid": "ea1f4db2-ad4f-4280-9180-cde0f0672c02"
  }
}
*)
ACTION A_VisuVariante
//-------------------------------------------------------------------------------------------------
// STATUS FUER DIE VISU: HYDRAULIK
//-------------------------------------------------------------------------------------------------
// Endlagen mit dem Index des zugehoerigen Handfunktions-Bits (siehe Aktion Handfunktionen)
IF PruefungWertImIntervall( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS,
                            cERSTE_FAECHERWAGENSTATIONS_NR,
                            cLETZTE_FAECHERWAGENSTATIONS_NR )
THEN
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bWagenErkannt    := blFaecherwagenErkannt;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bLichtschrankeOK := in_bSicherheitsrelaisOK;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[0]     := in_bHubrahmenOben;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[1]     := in_bHubrahmenUnten;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[2]     := in_bFaecherwagenVorne;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[3]     := in_bFaecherwagenHinten;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[7]     := in_bAnschlagOben;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[8]     := in_bAnschlagUnten;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[11]    := in_bZentrierungOffen;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[12]    := in_bZentrierungGeschlossen;
END_IF
END_ACTION