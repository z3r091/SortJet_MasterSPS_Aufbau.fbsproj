(* METADATA
{
	"v3Meta": {
		"objectGuid": "d60e2503-c0a6-4612-86b5-fee558744e41"
	}
}
*)
ACTION FWAuftraege
IF M_SB0_MMI_RELEASERACKLOGIN THEN
  M_SB0_MMI_RELEASERACKLOGIN := FALSE;
  CASE tMmi2SpsInfo.wSps2FaecherwagenStationNr OF
    cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR:
      starrFaecherwagenBasisParameter[tMmi2SpsInfo.wSps2FaecherwagenStationNr].bEintransport[cWAND_1] := TRUE;
  END_CASE
END_IF

IF M_SB0_MMI_SortierungFaecherwagenwechsel THEN
  M_SB0_MMI_SortierungFaecherwagenwechsel := FALSE;
  CASE tMmi2SpsInfo.wSps2FaecherwagenStationNr OF
    cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR:
      starrFaecherwagenBasisParameter[tMmi2SpsInfo.wSps2FaecherwagenStationNr].bAustransport[cWAND_1] := TRUE;
  END_CASE
END_IF

// Faecherwagen in der Station bald voll (MMI): Anzeige am Taster der Station
IF M_SB0_MMI_SORTIERUNGFAECHERWAGENBALDVOLL THEN
  M_SB0_MMI_SORTIERUNGFAECHERWAGENBALDVOLL := FALSE;
  CASE tMmi2SpsInfo.wSps2FaecherwagenStationNr OF
    cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR:
      aFaecherwagenstation[tMmi2SpsInfo.wSps2FaecherwagenStationNr].bpMMIFWBaldVoll := TRUE;
  END_CASE
END_IF
END_ACTION