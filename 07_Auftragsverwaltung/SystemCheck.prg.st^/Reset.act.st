(* METADATA
{
	"v3Meta": {
		"objectGuid": "c82983ad-c0e7-4e08-a2e4-b90c50d3f8d7"
	}
}
*)
ACTION Reset
(***************************************************************************************************)
(* RESET *)
(***************************************************************************************************)
(* Hinweis:
   - Fehlerbit zuruecksetzen
   - Shuttledatenbit zuruecksetzen  
   - Merker zuruecksetzen [Welches Transfershuttle benutzt wurde]
*)
FOR wlIndexAutomatikkreis := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  IF ( abpReset[wlIndexAutomatikkreis] ) THEN

    abpFehler[wlIndexAutomatikkreis] := FALSE;

    FOR wlIndexStationsnummer := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
      IF StationInAutomatikkreis(starrShuttleBasisParameter[wlIndexStationsnummer].stMKs.eaAutomatikkreis, wlIndexAutomatikkreis) THEN
        abpStationsDatenErhalten[wlIndexStationsnummer, cWAND_1] := FALSE;
		  ablShuttleCheckAktiv[wlIndexStationsnummer] := FALSE;
      END_IF
    END_FOR

    FOR wlIndexStationsnummer := cERSTE_STATION TO cLETZTE_STATION DO
      IF StationInAutomatikkreis(starrStationBasisParameter[wlIndexStationsnummer].stMKs.eaAutomatikkreis, wlIndexAutomatikkreis) THEN
        abpStationsDatenErhalten[wlIndexStationsnummer, cWAND_1] := FALSE;
		  ablStationCheckAktiv[wlIndexStationsnummer] := FALSE;
      END_IF
    END_FOR

    abpReset[wlIndexAutomatikkreis] := FALSE;
    
    wlAktiverZyklus := 1;
    
    FOR wlIndexSystemcheckZyklus := 1 TO wgAnzahlSystemcheckZyklen DO
      ablCheck[wlIndexAutomatikkreis, wlIndexSystemcheckZyklus] := FALSE;
      ablCheckDone[wlIndexAutomatikkreis, wlIndexSystemcheckZyklus] := FALSE;
    END_FOR

  END_IF

END_FOR
END_ACTION