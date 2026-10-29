(* METADATA
{
	"v3Meta": {
		"objectGuid": "339b2ef9-3f23-482c-98f4-06c495d9a955"
	}
}
*)
FUNCTION AutomatikAktiv : BOOL
VAR_INPUT
	wpMmiNummer: WORD;
END_VAR
VAR
	wlIndex: WORD;
END_VAR

AutomatikAktiv := FALSE;

CASE wpMmiNummer OF

  cERSTE_STATION..cLETZTE_STATION:
    FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
		  IF starrStationBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex] <> 0 THEN
          IF M_Automatik_Aktiv[starrStationBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex]] THEN
            AutomatikAktiv := TRUE;
          END_IF
		  ELSE
		  	RETURN;
		  END_IF
    END_FOR

  cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
    FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
		  IF starrShuttleBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex] <> 0 THEN
		  	IF M_Automatik_Aktiv[starrShuttleBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex]] THEN
		  	  AutomatikAktiv := TRUE;
		  	END_IF
		  ELSE
		  	RETURN;
		  END_IF
    END_FOR
	
  cERSTES_TRANSFERSHUTTLE..cLETZTEs_TRANSFERSHUTTLE:
    FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
		  IF starrTransferShuttleBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex] <> 0 THEN
		  	IF M_Automatik_Aktiv[starrTransferShuttleBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex]] THEN
		  	  AutomatikAktiv := TRUE;
		  	END_IF
		  ELSE
		  	RETURN;
		  END_IF
    END_FOR

  cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR:
    FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
		  IF starrFaecherwagenBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex] <> 0 THEN
		  	IF M_Automatik_Aktiv[starrFaecherwagenBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex]] THEN
		  	  AutomatikAktiv := TRUE;
		  	END_IF
		  ELSE
		  	RETURN;
		  END_IF
    END_FOR

  cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
    FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
		  IF starrFremdanlageAuslaufStationBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex] <> 0 THEN
		  	IF M_Automatik_Aktiv[starrFremdanlageAuslaufStationBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex]] THEN
		  	  AutomatikAktiv := TRUE;
		  	END_IF
		  ELSE
		  	RETURN;
		  END_IF
    END_FOR

  cERSTE_FREMDANLAGE_EINLAUF..cLETZTE_FREMDANLAGE_EINLAUF:
    FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
		  IF starrFremdanlageEinlaufStationBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex] <> 0 THEN
		  	IF M_Automatik_Aktiv[starrFremdanlageEinlaufStationBasisParameter[wpMmiNummer].stMKs.eaAutomatikkreis[wlIndex]] THEN
		  	  AutomatikAktiv := TRUE;
		  	END_IF
		  ELSE
		  	RETURN;
		  END_IF
    END_FOR

ELSE

  AutomatikAktiv := FALSE;

END_CASE
END_FUNCTION