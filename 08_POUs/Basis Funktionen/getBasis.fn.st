(* METADATA
{
	"v3Meta": {
		"objectGuid": "cb0abf05-d74d-4b59-9143-e94abaf551fa"
	}
}
*)
FUNCTION getBasis : REFERENCE TO  StationBasisParameter_ST
VAR_INPUT

  // WORD
  wpMmiNummer  : WORD; // Stationsnummer von der die Auftraege geprueft werden sollen

END_VAR
CASE wpMmiNummer OF

  cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
    getBasis REF= starrShuttleBasisParameter[wpMmiNummer];

  cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
    getBasis REF= starrTransfershuttleBasisParameter[wpMmiNummer];

  cERSTE_STATION..cLETZTE_STATION:
    getBasis REF= starrStationBasisParameter[wpMmiNummer];

  cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR:
    getBasis REF= starrFaecherwagenBasisParameter[wpMmiNummer];

  cERSTE_FREMDANLAGE_EINLAUF..cLETZTE_FREMDANLAGE_EINLAUF:
    getBasis REF= starrFremdanlageEinlaufStationBasisParameter[wpMmiNummer];

  cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
    getBasis REF= starrFremdanlageAuslaufStationBasisParameter[wpMmiNummer];

END_CASE
END_FUNCTION