(* METADATA
{
  "v3Meta": {
    "objectGuid": "97dd6b9c-083d-47d5-ad19-d2fe11b9c8f1"
  }
}
*)
ACTION A_Visu
//-------------------------------------------------------------------------------------------------
// STATUS FUER DIE VISU
//-------------------------------------------------------------------------------------------------
// Allgemeiner Teil fuer alle Varianten; die Variante ergaenzt Faecherwagen, Lichtschranke und
// ihre Endlagen (abEndlage, Index = Bit der zugehoerigen Handfunktion)
IF PruefungWertImIntervall( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS,
                            cERSTE_FAECHERWAGENSTATIONS_NR,
                            cLETZTE_FAECHERWAGENSTATIONS_NR )
THEN
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bBoxInHomePosition             := bpBoxInHomePosition;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bStatusStationInBeladePosition := bpStatusStationInBeladePosition;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bAuftragAktiv                  := bpAuftragAktiv;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bFehler                        := BasisStationsParameter.bFehler;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].eStatus                        := eLetzterStatus;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bRolltorOben                   := NOT in_bNichtRolltorGeoeffnet;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bRolltorUnten                  := bpRolltorUnten;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].wRFID_Nummer                   := wlRFID_Nummer;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[5]                   := NOT in_bNichtRolltorGeoeffnet;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[6]                   := bpRolltorUnten;
END_IF
END_ACTION