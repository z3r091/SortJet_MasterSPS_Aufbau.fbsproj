(* METADATA
{
	"v3Meta": {
		"objectGuid": "11193127-30f6-42cb-ab25-4fe444daee5f"
	}
}
*)
PROGRAM StartUpCheck
VAR
  aUsedAchsIDs : ARRAY [0..65] OF BOOL;
  aUsedMeldungsnummern : ARRAY [0..2500] OF BOOL;
  aUsedStationNrIntern : ARRAY [cERSTES_SHUTTLE..cLETZTE_FREMDANLAGE_EINLAUF] OF BOOL;
  aUsedStationNrSPS    : ARRAY [cERSTES_SHUTTLE..cLETZTE_FREMDANLAGE_EINLAUF] OF BOOL;

  i : WORD;
  k : WORD;
  cLOG_HANDLE : RTS_IEC_HANDLE := RTS_INVALID_HANDLE;
  NullRef : REFERENCE TO BOOL;
END_VAR

FOR i := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  // wAchsID in den Antriebsinformationen prüfen - niccht doppelt vergeben
  FOR k := cWAND_1 TO cANZAHL_WAENDE DO
    CheckAchsID(starrShuttleBasisParameter[i].stAntriebsparameter.stGlastransport[k].wAchsID);
    CheckAchsID(starrShuttleBasisParameter[i].stAntriebsparameter.stGlastransportSlave[k].wAchsID);
    CheckAchsID(starrShuttleBasisParameter[i].stAntriebsparameter.stWandverstellung[k].wAchsID);
  END_FOR
  CheckAchsID(starrShuttleBasisParameter[i].stAntriebsparameter.stDrehen.wAchsID);
  CheckAchsID(starrShuttleBasisParameter[i].stAntriebsparameter.stKippen.wAchsID);
  CheckAchsID(starrShuttleBasisParameter[i].stAntriebsparameter.stMessachse.wAchsID);
  CheckAchsID(starrShuttleBasisParameter[i].stAntriebsparameter.stQuerfahrt.wAchsID);
  // Konfigurierete Automatikkreise prüfen
  CheckAutomatikkreis(starrShuttleBasisParameter[i]);
  // Konfiguriereten StationsTyp prüfen
  CheckStationsTyp(starrShuttleBasisParameter[i]);
  // Konfigurierete Meldungsnummer prüfen
  CheckMeldungsnummer(starrShuttleBasisParameter[i]);
  // Konfigurierete Stationsnummern prüfen
  CheckStationsnummern(starrShuttleBasisParameter[i]);
  // Konfigurierte Lage der letzten Scheibe prüfen
  checkGlastransportOptionen(starrShuttleBasisParameter[i], TRUE);
END_FOR

FOR i := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  FOR k := cWAND_1 TO cANZAHL_WAENDE DO
    CheckAchsID(starrTransfershuttleBasisParameter[i].stAntriebsparameter.stGlastransport[k].wAchsID);
    CheckAchsID(starrTransfershuttleBasisParameter[i].stAntriebsparameter.stGlastransportSlave[k].wAchsID);
    CheckAchsID(starrTransfershuttleBasisParameter[i].stAntriebsparameter.stWandverstellung[k].wAchsID);
  END_FOR
  CheckAchsID(starrTransfershuttleBasisParameter[i].stAntriebsparameter.stDrehen.wAchsID);
  CheckAchsID(starrTransfershuttleBasisParameter[i].stAntriebsparameter.stKippen.wAchsID);
  CheckAchsID(starrTransfershuttleBasisParameter[i].stAntriebsparameter.stMessachse.wAchsID);
  CheckAchsID(starrTransfershuttleBasisParameter[i].stAntriebsparameter.stQuerfahrt.wAchsID);
  // Konfigurierete Automatikkreise prüfen
  CheckAutomatikkreis(starrTransfershuttleBasisParameter[i]);
  // Konfiguriereten StationsTyp prüfen
  CheckStationsTyp(starrTransfershuttleBasisParameter[i]);
  // Konfigurierete Meldungsnummer prüfen
  CheckMeldungsnummer(starrTransfershuttleBasisParameter[i]);
  // Konfigurierete Stationsnummern prüfen
  CheckStationsnummern(starrTransfershuttleBasisParameter[i]);
END_FOR

FOR i := cERSTE_STATION TO cLETZTE_STATION DO
  FOR k := cWAND_1 TO cANZAHL_WAENDE DO
    CheckAchsID(starrStationBasisParameter[i].stAntriebsparameter.stGlastransport[k].wAchsID);
    CheckAchsID(starrStationBasisParameter[i].stAntriebsparameter.stGlastransportSlave[k].wAchsID);
    IF __ISVALIDREF(starrStationBasisParameter[i].stAntriebsparameter.stGlastransportY) THEN
      CheckAchsID(starrStationBasisParameter[i].stAntriebsparameter.stGlastransportY[k].wAchsID);
    END_IF
    IF __ISVALIDREF(starrStationBasisParameter[i].stAntriebsparameter.stGlastransportYSlave) THEN
      CheckAchsID(starrStationBasisParameter[i].stAntriebsparameter.stGlastransportYSlave[k].wAchsID);
    END_IF
    CheckAchsID(starrStationBasisParameter[i].stAntriebsparameter.stWandverstellung[k].wAchsID);
  END_FOR
  CheckAchsID(starrStationBasisParameter[i].stAntriebsparameter.stDrehen.wAchsID);
  CheckAchsID(starrStationBasisParameter[i].stAntriebsparameter.stKippen.wAchsID);
  CheckAchsID(starrStationBasisParameter[i].stAntriebsparameter.stMessachse.wAchsID);
  CheckAchsID(starrStationBasisParameter[i].stAntriebsparameter.stQuerfahrt.wAchsID);
  // Konfigurierete Automatikkreise prüfen
  CheckAutomatikkreis(starrStationBasisParameter[i]);
  // Konfiguriereten StationsTyp prüfen
  CheckStationsTyp(starrStationBasisParameter[i]);
  // Konfigurierete Meldungsnummer prüfen
  CheckMeldungsnummer(starrStationBasisParameter[i]);
  // Konfigurierete Stationsnummern prüfen
  CheckStationsnummern(starrStationBasisParameter[i]);
  // Konfigurierte Lage der letzten Scheibe prüfen
  checkGlastransportOptionen(starrStationBasisParameter[i], FALSE);
END_FOR

checkMKVerfahrparameter();
checkZentralschmierung();
checkAutomatikkreiseMK();
checkSicherheitskreiseMK();
checkDurchgaenge();
END_PROGRAM