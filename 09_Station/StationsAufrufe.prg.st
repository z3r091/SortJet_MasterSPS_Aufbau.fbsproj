(* METADATA
{
  "v3Meta": {
    "objectGuid": "be6a8910-e5b9-4b0e-94d4-dced3fa75632"
  }
}
*)
PROGRAM StationsAufrufe
VAR
  wlIndex : WORD;
END_VAR

(***************************************************************************************************)
(* BAUSTEIN: AUFRUF BAUSTEINE *)
(***************************************************************************************************)
(* Hinweis:
   - Bausteine
*)
FOR wlIndex := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE  DO
  aShuttle[wlIndex]( BasisStationsParameter := starrShuttleBasisParameter[wlIndex] );
END_FOR

FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE  DO
  aTransfershuttles[wlIndex]( BasisStationsParameter := starrTransfershuttleBasisParameter[wlIndex] );
END_FOR

FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR  DO
  aFaecherwagenstation[wlIndex]( BasisStationsParameter := starrFaecherwagenBasisParameter[wlIndex] );
END_FOR

(***************************************************************************************************)
(* BAUSTEIN: BAUSTEINAUFRUF *)
(***************************************************************************************************)

// STATIONEN
Anlegetisch201                   (BasisStationsParameter := starrStationBasisParameter[cSTATION_201]);
Foerderer202                     (BasisStationsParameter := starrStationBasisParameter[cSTATION_202]);
Foerderer203                     (BasisStationsParameter := starrStationBasisParameter[cSTATION_203]);
Anlegetisch204                   (BasisStationsParameter := starrStationBasisParameter[cSTATION_204]);
Eckuebergabe205                  (BasisStationsParameter := starrStationBasisParameter[cSTATION_205]);
Kipptisch206                     (BasisStationsParameter := starrStationBasisParameter[cSTATION_206]);
Drehstation207                   (BasisStationsParameter := starrStationBasisParameter[cSTATION_207]);
Combiwand208                     (BasisStationsParameter := starrStationBasisParameter[cSTATION_208]);

(***************************************************************************************************)
(* BAUSTEIN: SCHNITTSTELLEN *)
(***************************************************************************************************)

aSchnittstelleAuslauf[cSTATION_401] ( BasisStationsParameter := starrFremdanlageAuslaufStationBasisParameter[cSTATION_401],
                                      bpEmpfaengerSensorEinlauf := FALSE );  
                                      
aSchnittstelleEinlauf[cSTATION_501] ( BasisStationsParameter := starrFremdanlageEinlaufStationBasisParameter[cSTATION_501],
                                      bpEmpfaengerSensorEinlauf := FALSE );
END_PROGRAM