(* METADATA
{
  "v3Meta": {
    "objectGuid": "599a2527-67c0-435b-86b2-c85e4327919a"
  }
}
*)
ACTION Zuweisung_Automatik
(***************************************************************************************************)
(* ZUWEISUNG DES AUTOMATIKKREISES  *)
(***************************************************************************************************)

// Stationen
FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
  IF __ISVALIDREF(starrStationBasisParameter[wlIndex].stMKs) THEN
	  IF ( PruefungWertImIntervallAutomatikkreise( starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, cERSTER_AUTOMATIKKREIS, cLETZTER_AUTOMATIKKREIS) ) THEN 
		 starrStationBasisParameter[wlIndex].bAutomatik := AutomatikAktiv(wlIndex) OR Visu_Start_Auto OR bgVISUAutomatikModusStation[wlIndex];
	  ELSE
		 starrStationBasisParameter[wlIndex].bAutomatik := FALSE;
	  END_IF
  END_IF
END_FOR

// Shuttle 
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
  IF __ISVALIDREF(starrShuttleBasisParameter[wlIndex].stMKs) THEN
    IF ( PruefungWertImIntervallAutomatikkreise( starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, cERSTER_AUTOMATIKKREIS, cLETZTER_AUTOMATIKKREIS) ) THEN
		 starrShuttleBasisParameter[wlIndex].bAutomatik := AutomatikAktiv(wlIndex) OR Visu_Start_Auto OR bgVISUAutomatikModusShuttle[wlIndex];
	  ELSE
		 starrShuttleBasisParameter[wlIndex].bAutomatik := FALSE;
    END_IF
  END_IF
END_FOR

// Transfershuttle
FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE  DO
  IF __ISVALIDREF(starrTransfershuttleBasisParameter[wlIndex].stMKs) THEN
    IF ( PruefungWertImIntervallAutomatikkreise( starrTransfershuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis, cERSTER_AUTOMATIKKREIS, cLETZTER_AUTOMATIKKREIS) ) THEN
      starrTransfershuttleBasisParameter[wlIndex].bAutomatik :=  AutomatikAktiv(wlIndex) OR Visu_Start_Auto OR bgVISUAutomatikModusShuttle[wlIndex];
    ELSE
      starrTransfershuttleBasisParameter[wlIndex].bAutomatik := FALSE;
    END_IF
  END_IF
END_FOR

// Fächerwagenstationen
FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
  IF __ISVALIDREF(starrFaecherwagenBasisParameter[wlIndex].stMKs) THEN
    IF ( PruefungWertImIntervallAutomatikkreise( starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, cERSTER_AUTOMATIKKREIS, cLETZTER_AUTOMATIKKREIS) ) THEN
       starrFaecherwagenBasisParameter[wlIndex].bAutomatik := AutomatikAktiv(wlIndex) OR Visu_Start_Auto;
    ELSE
      starrFaecherwagenBasisParameter[wlIndex].bAutomatik := FALSE;
    END_IF
  END_IF
END_FOR

// Schnittstelle Auslauf
FOR wlIndex := cERSTE_FREMDANLAGE_AUSLAUF TO cLETZTE_FREMDANLAGE_AUSLAUF DO
  IF __ISVALIDREF(starrFremdanlageAuslaufStationBasisParameter[wlIndex].stMKs) THEN
    IF ( PruefungWertImIntervallAutomatikkreise( starrFremdanlageAuslaufStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, cERSTER_AUTOMATIKKREIS, cLETZTER_AUTOMATIKKREIS) ) THEN
      starrFremdanlageAuslaufStationBasisParameter[wlIndex].bAutomatik := AutomatikAktiv(wlIndex) OR Visu_Start_Auto;
    ELSE
      starrFremdanlageAuslaufStationBasisParameter[wlIndex].bAutomatik := FALSE;
    END_IF
  END_IF
END_FOR

// Schnittstelle Einlauf
FOR wlIndex := cERSTE_FREMDANLAGE_EINLAUF TO cLETZTE_FREMDANLAGE_EINLAUF DO
  IF __ISVALIDREF(starrFremdanlageEinlaufStationBasisParameter[wlIndex].stMKs) THEN
    IF ( PruefungWertImIntervallAutomatikkreise( starrFremdanlageEinlaufStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, cERSTER_AUTOMATIKKREIS, cLETZTER_AUTOMATIKKREIS) ) THEN
      starrFremdanlageEinlaufStationBasisParameter[wlIndex].bAutomatik := AutomatikAktiv(wlIndex) OR Visu_Start_Auto;
    ELSE
      starrFremdanlageEinlaufStationBasisParameter[wlIndex].bAutomatik := FALSE;
    END_IF
  END_IF
END_FOR
END_ACTION