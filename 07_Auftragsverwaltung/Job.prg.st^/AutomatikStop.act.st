(* METADATA
{
	"v3Meta": {
		"objectGuid": "f9dc6825-df8b-4543-95cc-7a9d310d851d"
	}
}
*)
ACTION AutomatikStop
(***************************************************************************************************)
(* STOPP AUTOMATIKKREISE - RESET -  *)
(***************************************************************************************************)
(* Hinweis:
   - Bei einem NotAus muss die Anlage in Stop- Versetzt werden, damit nach dem der
     NotAus quittiert wurde die Anlage in der Betriebsart "Hand" steht. 
*)
ftlNotHaltAusgeloest( CLK := NotHalt.bpNotHaltOK );

IF ( ftlNotHaltAusgeloest.Q ) THEN
  M_SB0_MMI_SortierungAutomatik_Stop := TRUE;
  tMmi2SpsInfo.wAutomatikStopArea := cSTOPP_ALLE_AUTOMATIKKREIS;
END_IF

(* Hinweis
   - STOP durch das HMI
*)
IF ( M_SB0_MMI_SortierungAutomatik_Stop ) THEN
  M_SB0_MMI_SortierungAutomatik_Stop := FALSE;

  Initialisierung.bpReset := TRUE;

  FOR i := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  
    mask := SHR(tMmi2SpsInfo.wAutomatikStopArea, i-1);
    IF mask.0 THEN
      M_Automatik_Aktiv[i]                     := FALSE;
      Systemcheck.abpCheck[i]                  := FALSE;
      Job_Stationen.abpReset[i]                := TRUE;
      Job_Shuttle.abpReset[i]                  := TRUE;
      Job_Fremdanlage.abpReset[i]              := TRUE;
      Job_Faecherwagen.abpReset[i]             := TRUE;
      SystemCheck.abpReset[i]                  := TRUE;
      Initialisierung.bpReset                  := TRUE;
      Interface_SLC.bpResetOperatorAcknowledge := TRUE;
    END_IF
  
  END_FOR

END_IF
END_ACTION