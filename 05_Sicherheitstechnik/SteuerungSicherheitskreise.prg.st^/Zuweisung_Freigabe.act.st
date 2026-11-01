(* METADATA
{
  "v3Meta": {
    "objectGuid": "b5d583d3-89c4-4d74-8416-e72ac3d75b2b"
  }
}
*)
ACTION Zuweisung_Freigabe
//-------------------------------------------------------------------------------------------------
// ZUWEISUNG DER FREIGABEN
//-------------------------------------------------------------------------------------------------

// Stationen
FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  IF checkSafetyCircuitsConfigured(starrStationBasisParameter[wlIndex]) THEN //Prüfen ob ein SK konfiguriert ist
    starrStationBasisParameter[wlIndex].bFreigabe := ( NotHalt.bpNotHaltOK AND checkSafetyCircuitsClosed(starrStationBasisParameter[wlIndex]) ) OR bgSicherheitstechnikBruecken;
  ELSE
    starrStationBasisParameter[wlIndex].bFreigabe := NotHalt.bpNotHaltOK OR bgSicherheitstechnikBruecken;
  END_IF
END_FOR

// Shuttle 
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  starrShuttleBasisParameter[wlIndex].bFreigabe :=  ( NotHalt.bpNotHaltOK AND checkSafetyCircuitsClosed(starrShuttleBasisParameter[wlIndex]) ) OR bgSicherheitstechnikBruecken;
END_FOR

// Transfershuttle
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
  starrTransfershuttleBasisParameter[wlIndex].bFreigabe :=  ( NotHalt.bpNotHaltOK AND checkSafetyCircuitsClosed(starrTransfershuttleBasisParameter[wlIndex]) ) OR bgSicherheitstechnikBruecken;
END_FOR

// Fächerwagenstationen
FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
  IF checkSafetyCircuitsConfigured(starrFaecherwagenBasisParameter[wlIndex]) THEN //Prüfen ob ein SK konfiguriert ist
    starrFaecherwagenBasisParameter[wlIndex].bFreigabe := ( NotHalt.bpNotHaltOK AND checkSafetyCircuitsClosed(starrFaecherwagenBasisParameter[wlIndex]) ) OR bgSicherheitstechnikBruecken;
  ELSE
    starrFaecherwagenBasisParameter[wlIndex].bFreigabe := NotHalt.bpNotHaltOK OR bgSicherheitstechnikBruecken;
  END_IF
END_FOR

// Schnittstelle Auslauf
FOR wlIndex := cERSTE_FREMDANLAGE_AUSLAUF TO cLETZTE_FREMDANLAGE_AUSLAUF DO
  IF checkSafetyCircuitsConfigured(starrFremdanlageAuslaufStationBasisParameter[wlIndex]) THEN //Prüfen ob ein SK konfiguriert ist
    starrFremdanlageAuslaufStationBasisParameter[wlIndex].bFreigabe := ( NotHalt.bpNotHaltOK AND checkSafetyCircuitsClosed(starrFremdanlageAuslaufStationBasisParameter[wlIndex]) ) OR bgSicherheitstechnikBruecken;
  ELSE
    starrFremdanlageAuslaufStationBasisParameter[wlIndex].bFreigabe := NotHalt.bpNotHaltOK OR bgSicherheitstechnikBruecken;
  END_IF
END_FOR

// Schnittstelle Einlauf
FOR wlIndex := cERSTE_FREMDANLAGE_EINLAUF TO cLETZTE_FREMDANLAGE_EINLAUF DO
  IF checkSafetyCircuitsConfigured(starrFremdanlageEinlaufStationBasisParameter[wlIndex]) THEN //Prüfen ob ein SK konfiguriert ist
    starrFremdanlageEinlaufStationBasisParameter[wlIndex].bFreigabe := ( NotHalt.bpNotHaltOK AND checkSafetyCircuitsClosed(starrFremdanlageEinlaufStationBasisParameter[wlIndex]) ) OR bgSicherheitstechnikBruecken;
  ELSE
    starrFremdanlageEinlaufStationBasisParameter[wlIndex].bFreigabe := NotHalt.bpNotHaltOK OR bgSicherheitstechnikBruecken;
  END_IF
END_FOR
END_ACTION