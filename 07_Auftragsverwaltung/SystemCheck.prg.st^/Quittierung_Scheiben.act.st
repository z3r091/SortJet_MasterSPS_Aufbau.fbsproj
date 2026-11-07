(* METADATA
{
	"v3Meta": {
		"objectGuid": "2a70e2fa-dcda-4b8f-820f-05f7864c9862"
	}
}
*)
ACTION Quittierung_Scheiben
//-------------------------------------------------------------------------------------------------
// QUITTIEREN DER SCHEIBEN IM SYSTEMCHECK [VERBUND]
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Meldet eine Station im Systemcheck eine Scheibe [bQuittScheibe], wird sie wie im Auftrag quittiert
   - Die Richtung gibt das eigene Verbund- Flag der Station vor, der Partner steht in der Kopplung des Glasinterface
     [fest aus dem MK oder dynamisch aus Steuerung_VerbundCheck]
   - Check mit Vorgaenger: Die Station ist das Ziel, der Vorgaenger [aEintransporte] ist die Quelle
   - Check mit Nachfolger: Die Station ist die Quelle, der Nachfolger [aAustransporte] ist das Ziel
   - Quittiert wird nur, wenn die Station fuer den Partner quittiert [bStationQuittiertScheibe]
*)
FOR wlIndexQuitt := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO

  IF ( abpCheck[wlIndexQuitt] ) THEN

    FOR wlIndexQuittStation := cERSTE_STATION TO cLETZTE_STATION DO

      stlQuittStation REF= getBasis( wlIndexQuittStation );

      IF    StationInAutomatikkreis( stlQuittStation.stMKs.eaAutomatikkreis, wlIndexQuitt )
            AND stlQuittStation.OutGlasTransport[cWAND_1].bQuittScheibe
      THEN

        // Eintransport: Station = Ziel
        IF stlQuittStation.bCheckMitVorgaenger[cWAND_1] THEN

          wlIndexQuittPartner := stlQuittStation.InGlasTransportVorgaenger[cWAND_1].stStationsNummern.NummerIntern;

          IF PruefungWertImIntervall( wlIndexQuittPartner, cERSTES_SHUTTLE, cLETZTE_FREMDANLAGE_EINLAUF ) THEN
            IF    ( stlQuittStation.stMKs.stSchnittstellendaten.aEintransporte.Station[wlIndexQuittPartner] <> TransportRichtung_EN.Default )
                  AND stlQuittStation.stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[wlIndexQuittPartner]
            THEN
              ScheibenQuittierung( wpQuellstation := wlIndexQuittPartner,
                                   wpZielStation  := wlIndexQuittStation );
            END_IF
          END_IF

        // Austransport: Station = Quelle
        ELSIF stlQuittStation.bCheckMitNachfolger[cWAND_1] THEN

          wlIndexQuittPartner := stlQuittStation.InGlasTransportNachfolger[cWAND_1].stStationsNummern.NummerIntern;

          IF PruefungWertImIntervall( wlIndexQuittPartner, cERSTES_SHUTTLE, cLETZTE_FREMDANLAGE_EINLAUF ) THEN
            IF    ( stlQuittStation.stMKs.stSchnittstellendaten.aAustransporte.Station[wlIndexQuittPartner] <> TransportRichtung_EN.Default )
                  AND stlQuittStation.stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[wlIndexQuittPartner]
            THEN
              IF stlQuittStation.stMKs.stSchnittstellendaten.bStationIstShuttle THEN
                ScheibenQuittierung( wpQuellstation := wlIndexQuittStation,
                                     wpZielStation  := wlIndexQuittPartner,
                                     wpAuftragsTyp  := 1 );
              ELSE
                ScheibenQuittierung( wpQuellstation := wlIndexQuittStation,
                                     wpZielStation  := wlIndexQuittPartner );
              END_IF
            END_IF
          END_IF

        END_IF

      END_IF

    END_FOR

  END_IF

END_FOR
END_ACTION