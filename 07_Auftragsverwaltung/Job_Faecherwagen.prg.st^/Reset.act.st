(* METADATA
{
	"v3Meta": {
		"objectGuid": "eaba43f4-39da-4420-8f39-9b1cb8e41c0d"
	}
}
*)
ACTION Reset
//-------------------------------------------------------------------------------------------------
// RESET
//-------------------------------------------------------------------------------------------------
 
FOR wlIndexReset := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  IF ( abpReset[wlIndexReset] ) THEN

    abpReset[wlIndexReset] := FALSE;
    abpFehler[wlIndexReset] := FALSE;

    FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO

      IF StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndex].stMKs.eaAutomatikkreis, wlIndexReset) THEN
        starrFaecherwagenBasisParameter[wlIndex].bReset := TRUE;
      END_IF

    END_FOR

  END_IF

END_FOR
END_ACTION