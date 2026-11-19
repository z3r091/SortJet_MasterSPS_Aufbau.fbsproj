(* METADATA
{
	"v3Meta": {
		"objectGuid": "ddefdab4-8b7d-4340-ad07-01874b542daa"
	}
}
*)
ACTION FehlerAktiv
FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
  ablFehlerAktiv[wlIndex] := FALSE;
END_FOR

FOR wlIndex := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  FOR wlIndexStationen := cERSTE_STATION TO cLETZTE_STATION DO
    IF starrStationBasisParameter[wlIndexStationen].bFehler AND StationInAutomatikkreis(starrStationBasisParameter[wlIndexStationen].stMKs.eaAutomatikkreis, wlIndex) THEN
      ablFehlerAktiv[wlIndex] := TRUE;
    END_IF
  END_FOR

  FOR wlIndexStationen := cERSTES_SHUTTLE TO cLETZTES_SHUTTLE DO
    IF starrShuttleBasisParameter[wlIndexStationen].bFehler AND StationInAutomatikkreis(starrShuttleBasisParameter[wlIndexStationen].stMKs.eaAutomatikkreis, wlIndex) THEN
      ablFehlerAktiv[wlIndex] := TRUE;
    END_IF
  END_FOR

  FOR wlIndexStationen := cERSTES_TRANSFERSHUTTLE TO cLETZTES_TRANSFERSHUTTLE DO
    IF starrTransferShuttleBasisParameter[wlIndexStationen].bFehler AND StationInAutomatikkreis(starrTransferShuttleBasisParameter[wlIndexStationen].stMKs.eaAutomatikkreis, wlIndex) THEN
      (* Hinweis:
         - Ein TS mit 2 Automatikkreisen hat je Seite einen eigenen Fehler (AutomatikFehlerTransfershuttleSetzen):
           nur der Automatikkreis der betroffenen Seite gilt als fehlerhaft
         - Ist in keinem seiner Automatikkreise ein Fehler gesetzt, gilt der Fehler fuer alle seine Automatikkreise
      *)
      blTsSeiteFehlerGesetzt := FALSE;
      FOR wlIndexSeite := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
        IF StationInAutomatikkreis(starrTransferShuttleBasisParameter[wlIndexStationen].stMKs.eaAutomatikkreis, wlIndexSeite) AND Job_Shuttle.abpFehler[wlIndexSeite] THEN
          blTsSeiteFehlerGesetzt := TRUE;
        END_IF
      END_FOR

      IF NOT blTsSeiteFehlerGesetzt OR Job_Shuttle.abpFehler[wlIndex] THEN
        ablFehlerAktiv[wlIndex] := TRUE;
      END_IF
    END_IF
  END_FOR

  FOR wlIndexStationen := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
    IF starrFaecherwagenBasisParameter[wlIndexStationen].bFehler AND StationInAutomatikkreis(starrFaecherwagenBasisParameter[wlIndexStationen].stMKs.eaAutomatikkreis, wlIndex) THEN
      ablFehlerAktiv[wlIndex] := TRUE;
    END_IF
  END_FOR

END_FOR
END_ACTION