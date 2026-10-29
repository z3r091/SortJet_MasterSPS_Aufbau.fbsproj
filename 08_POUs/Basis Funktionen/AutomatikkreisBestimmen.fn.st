(* METADATA
{
	"v3Meta": {
		"objectGuid": "9ed7362d-6e8b-45fc-aaf5-a3cbb726335b"
	}
}
*)
FUNCTION AutomatikkreisBestimmen : Automatikkreis_EN
VAR_INPUT
  wpMmiNummer: WORD;
END_VAR
VAR
  wlIndex     : WORD;
  wEmptyArray : Automatikkreis_EN := 0;
END_VAR

CASE wpMmiNummer OF

  cERSTE_STATION..cLETZTE_STATION:
  
    FOR wlIndex := cERSTE_STATION TO cLETZTE_STATION DO
	   IF ( wpMmiNummer = wlIndex ) THEN
      AutomatikkreisBestimmen :=  starrStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis[cERSTER_AUTOMATIKKREIS];
	   END_IF
    END_FOR

  cERSTES_SHUTTLE..cLETZTEs_SHUTTLE:
  
    FOR wlIndex := cERSTES_SHUTTLE TO cLETZTEs_SHUTTLE DO
	   IF ( wpMmiNummer = wlIndex ) THEN
      AutomatikkreisBestimmen :=  starrShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis[cERSTER_AUTOMATIKKREIS];
	   END_IF
    END_FOR
	
  cERSTES_TRANSFERSHUTTLE..cLETZTEs_TRANSFERSHUTTLE:
  
    FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTEs_TRANSFERSHUTTLE DO
	   IF ( wpMmiNummer = wlIndex ) THEN
      AutomatikkreisBestimmen :=  starrTransferShuttleBasisParameter[wlIndex].stMKs.eaAutomatikkreis[cERSTER_AUTOMATIKKREIS];
	   END_IF
    END_FOR

  cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR:
  
    FOR wlIndex := cERSTES_TRANSFERSHUTTLE TO cLETZTEs_TRANSFERSHUTTLE DO
	   IF ( wpMmiNummer = wlIndex ) THEN
      AutomatikkreisBestimmen :=  starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis[cERSTER_AUTOMATIKKREIS];
	   END_IF
    END_FOR

ELSE

  AutomatikkreisBestimmen := wEmptyArray;

END_CASE
END_FUNCTION