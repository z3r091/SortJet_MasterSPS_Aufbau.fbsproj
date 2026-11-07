(* METADATA
{
	"v3Meta": {
		"objectGuid": "2c76242e-df1a-45ee-a644-3bee45d641cc"
	}
}
*)
PROGRAM StationBasisZuweisungen
VAR

  // BOOL
  blErsterZyklus              : BOOL := TRUE;
  in_bDruckluftFaecherwagenOK : BOOL;

  // WORD
  wlIndex   : WORD;

END_VAR
//-------------------------------------------------------------------------------------------------
// INITIALISIERUNG
//-------------------------------------------------------------------------------------------------
IF ( blErsterZyklus ) THEN

  M_AufrufeZuweisungen();
  
  // Fehlerinformationen zuweisen
  FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
    IF __ISVALIDREF(starrFaecherwagenBasisParameter[wlIndex].stMKs) THEN
      starrFaecherwagenBasisParameter[wlIndex].awFehlerInformationen[0] := starrFaecherwagenBasisParameter[wlIndex].stMKs.stStationsNummern.NummerExtern;
    END_IF
  END_FOR

  FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO  
    IF __ISVALIDREF(starrStationBasisParameter[wlIndex].stMKs) THEN
      starrStationBasisParameter[wlIndex].awFehlerInformationen[0] := starrStationBasisParameter[wlIndex].stMKs.stStationsNummern.NummerExtern;   
    END_IF
  END_FOR
  
  FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO  
    IF __ISVALIDREF(starrShuttleBasisParameter[wlIndex].stMKs) THEN
      starrShuttleBasisParameter[wlIndex].awFehlerInformationen[0] := starrShuttleBasisParameter[wlIndex].stMKs.stStationsNummern.NummerExtern;   
    END_IF
  END_FOR
  
  FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO  
    IF __ISVALIDREF(starrTransfershuttleBasisParameter[wlIndex].stMKs) THEN
      starrTransfershuttleBasisParameter[wlIndex].awFehlerInformationen[0] := starrTransfershuttleBasisParameter[wlIndex].stMKs.stStationsNummern.NummerExtern;   
    END_IF
  END_FOR
  
  FOR wlIndex := cERSTE_FREMDANLAGE_AUSLAUF TO cLETZTE_FREMDANLAGE_AUSLAUF DO  
    IF __ISVALIDREF(starrFremdanlageAuslaufStationBasisParameter[wlIndex].stMKs) THEN
      starrFremdanlageAuslaufStationBasisParameter[wlIndex].awFehlerInformationen[0] := starrFremdanlageAuslaufStationBasisParameter[wlIndex].stMKs.stStationsNummern.NummerExtern;   
    END_IF
  END_FOR
  
  FOR wlIndex := cERSTE_FREMDANLAGE_EINLAUF TO cLETZTE_FREMDANLAGE_EINLAUF DO  
    IF __ISVALIDREF(starrFremdanlageEinlaufStationBasisParameter[wlIndex].stMKs) THEN
      starrFremdanlageEinlaufStationBasisParameter[wlIndex].awFehlerInformationen[0] := starrFremdanlageEinlaufStationBasisParameter[wlIndex].stMKs.stStationsNummern.NummerExtern;   
    END_IF
  END_FOR
  
  blErsterZyklus := FALSE;
END_IF
END_PROGRAM