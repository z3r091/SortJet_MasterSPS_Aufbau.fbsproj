(* METADATA
{
  "v3Meta": {
    "objectGuid": "d947f7e3-36ae-4f51-bc45-a36dc679eb63"
  }
}
*)
ACTION A_VisuVariante
//-------------------------------------------------------------------------------------------------
// STATUS FUER DIE VISU: LINEAREINHEIT
//-------------------------------------------------------------------------------------------------
// Endlagen mit dem Index des zugehoerigen Handfunktions-Bits (siehe Aktion Handfunktionen)
IF PruefungWertImIntervall( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS,
                            cERSTE_FAECHERWAGENSTATIONS_NR,
                            cLETZTE_FAECHERWAGENSTATIONS_NR )
THEN
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bWagenErkannt     := blTagPresent;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bLichtschrankeOK  := bpLichtschranke_OK;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[0]      := in_bGegenhalterOffen;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[1]      := in_bGegenhalterZu;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[2]      := in_bEntriegelungGeschlossen;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[3]      := in_bEntriegelungOffen;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[7]      := blLinearEinheitVorne;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[8]      := blLinearEinheitHinten;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[9]      := blLinearEinheitSH;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[11]     := blGreiferOffen;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[12]     := blGreiferZu;
END_IF
END_ACTION