(* METADATA
{
	"v3Meta": {
		"objectGuid": "ef0e6bd6-f193-4042-91aa-a4cc00e8bd0d"
	}
}
*)
ACTION A_VisuVariante
//-------------------------------------------------------------------------------------------------
// STATUS FUER DIE VISU: EINFACH
//-------------------------------------------------------------------------------------------------
// Endlagen mit dem Index des zugehoerigen Handfunktions-Bits (siehe Aktion Handfunktionen)
IF PruefungWertImIntervall( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS,
                            cERSTE_FAECHERWAGENSTATIONS_NR,
                            cLETZTE_FAECHERWAGENSTATIONS_NR )
THEN
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bWagenErkannt    := bpFaecherwagenVorhanden;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].bLichtschrankeOK := TRUE; // keine Lichtschranke an der Station
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[1]     := blArretierungOffen;
  astgFaecherwagenstatusVisu[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].abEndlage[2]     := blArretierungGeschlossen;
END_IF
END_ACTION