(* METADATA
{
	"v3Meta": {
		"objectGuid": "ba21d831-07aa-4eb0-a98f-ca51ada32f1d"
	}
}
*)
ACTION Reset
(***************************************************************************************************)
(* AKTION: RESET *)
(***************************************************************************************************)

FOR wlIndexReset := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  IF ( abpReset[wlIndexReset] ) THEN

    ablNachrichtEmpfangen[1]     := FALSE;
    ablNachrichtEmpfangen[2]     := FALSE;
    blUeberwachungFolgeNachricht := FALSE;
    abpReset[wlIndexReset]       := FALSE;

    // Schnittstelle Auslauf Reset
    FOR wlIndex := cERSTE_FREMDANLAGE_AUSLAUF TO cLETZTE_FREMDANLAGE_AUSLAUF DO
      IF StationInAutomatikkreis(starrFremdanlageAuslaufStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wlIndexReset) THEN
        AuftragsdatenFremdanlage[wlIndex].wAuftrag := eStation_Kein_Auftrag;
        starrFremdanlageAuslaufStationBasisParameter[wlIndex].bReset := NOT starrFremdanlageAuslaufStationBasisParameter[wlIndex].stMKs.bDeaktivieren;
      END_IF
    END_FOR
  
    // Schnittstelle Einlauf Reset
    FOR wlIndex := cERSTE_FREMDANLAGE_EINLAUF TO cLETZTE_FREMDANLAGE_EINLAUF DO
      IF StationInAutomatikkreis(starrFremdanlageEinlaufStationBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wlIndexReset) THEN
        AuftragsdatenFremdanlage[wlIndex].wAuftrag := eStation_Kein_Auftrag;
        starrFremdanlageEinlaufStationBasisParameter[wlIndex].bReset := NOT starrFremdanlageEinlaufStationBasisParameter[wlIndex].stMKs.bDeaktivieren;
      END_IF
    END_FOR

  END_IF

END_FOR
END_ACTION