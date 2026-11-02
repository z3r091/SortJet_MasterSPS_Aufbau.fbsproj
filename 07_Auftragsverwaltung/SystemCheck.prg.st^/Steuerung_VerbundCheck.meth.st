(* METADATA
{
  "v3Meta": {
    "objectGuid": "2106329f-ce22-4754-a4e1-a7a15d593805"
  }
}
*)
METHOD PRIVATE Steuerung_VerbundCheck : BOOL
VAR_INPUT
  wpAutomatikkreis : WORD;
  wpZyklus         : WORD;
END_VAR
VAR
  ilNachfolger        : INT;
  wlNachfolger        : WORD;
  wlVorgaenger        : WORD;
  wlPartner           : WORD;
  wlIndexAK           : WORD;
  wlIndexWand         : WORD;
  blVorgaengerImAK    : BOOL;
  blNachfolgerImAK    : BOOL;
  blPartnerPrueftMit  : BOOL;
  stlFesterPartner    : REFERENCE TO StationBasisParameter_ST;
END_VAR

(* Hinweis:
   - Liegt eine Scheibe ueber der Grenze zweier Stationen, pruefen beide Stationen gemeinsam
   - Ein Paar [Vorgaenger => Nachfolger] ergibt sich aus dem Eintransport des Nachfolgers [aEintransporte]
     und gilt, wenn der Auslaufsensor des Vorgaengers und der Einlaufsensor des Nachfolgers belegt sind
   - Ist der Vorgaenger eine Anlegestation [MK bIstAnlegestation], muss er genau eine Scheibe haben
   - Ein Nachfolger der schon mit seinem eigenen Nachfolger prueft, wird nicht zusaetzlich mit seinem Vorgaenger
     verbunden; deshalb wird von der letzten Station zur ersten Station gearbeitet [das Ende der Kette gewinnt]
   - Die Partner koennen in verschiedenen Automatikkreisen liegen; jeder Automatikkreis setzt nur die Flags
     seiner eigenen Stationen
   - Prueft der Automatikkreis des Partners nicht mit, muss er zusaetzlich den Systemcheck machen [Hinweis]
   - Hat eine Station im MK keinen festen Vorgaenger/Nachfolger [dynamisch oder default], wird die Kopplung
     des Glasinterface hier auf den Partner des Paars gesetzt [Job_Stationen koppelt nur feste Partner]
     Die Quittierung im Systemcheck leitet den Partner aus dieser Kopplung ab
*)
FOR ilNachfolger := WORD_TO_INT( cLETZTE_STATION ) TO WORD_TO_INT( cERSTE_STATION ) BY -1 DO

  wlNachfolger := INT_TO_WORD( ilNachfolger );

  FOR wlVorgaenger := cERSTE_STATION TO cLETZTE_STATION DO

    blVorgaengerImAK := StationInAutomatikkreis( starrStationBasisParameter[wlVorgaenger].stMKs.eaAutomatikkreis, wpAutomatikkreis );
    blNachfolgerImAK := StationInAutomatikkreis( starrStationBasisParameter[wlNachfolger].stMKs.eaAutomatikkreis, wpAutomatikkreis );

    IF    ( blVorgaengerImAK OR blNachfolgerImAK )
          AND ( wlVorgaenger <> wlNachfolger )
          AND ( starrStationBasisParameter[wlNachfolger].stMKs.stSchnittstellendaten.aEintransporte.Station[wlVorgaenger] <> TransportRichtung_EN.Default )
          AND starrStationBasisParameter[wlVorgaenger].OutGlasTransport[cWAND_1].bAuslaufsensor
          AND starrStationBasisParameter[wlNachfolger].OutGlasTransport[cWAND_1].bEinlaufsensor
          AND (    NOT starrStationBasisParameter[wlVorgaenger].stMKs.stStationsOptionen.stAnlegetisch.bIstAnlegestation
                OR ( starrStationBasisParameter[wlVorgaenger].pAuftrag[cWAND_1].wAnzahlScheiben = 1 ) )
          AND NOT starrStationBasisParameter[wlNachfolger].bCheckMitNachfolger[cWAND_1]
    THEN

      IF blVorgaengerImAK THEN
        starrStationBasisParameter[wlVorgaenger].bCheckMitNachfolger[cWAND_1] := TRUE;
      END_IF

      IF blNachfolgerImAK THEN
        starrStationBasisParameter[wlNachfolger].bCheckMitVorgaenger[cWAND_1] := TRUE;
      END_IF

      // Kopplung Glasinterface: Vorgaenger => Nachfolger
      stlFesterPartner REF= getBasis( starrStationBasisParameter[wlVorgaenger].stMKs.stSchnittstellendaten.wNachfolgerStation );
      IF NOT __ISVALIDREF( stlFesterPartner ) THEN
        FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
          starrStationBasisParameter[wlVorgaenger].InGlasTransportNachfolger[wlIndexWand] := starrStationBasisParameter[wlNachfolger].OutGlasTransport[cWAND_1];
        END_FOR
      END_IF

      // Kopplung Glasinterface: Nachfolger => Vorgaenger
      stlFesterPartner REF= getBasis( starrStationBasisParameter[wlNachfolger].stMKs.stSchnittstellendaten.wVorgaengerStation );
      IF NOT __ISVALIDREF( stlFesterPartner ) THEN
        FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
          starrStationBasisParameter[wlNachfolger].InGlasTransportVorgaenger[wlIndexWand] := starrStationBasisParameter[wlVorgaenger].OutGlasTransport[cWAND_1];
        END_FOR
      END_IF

      // Liegt nur eine der beiden Stationen im geprueften Automatikkreis, liegt der Partner in einem anderen
      // Automatikkreis und dieser muss den Systemcheck zusaetzlich machen
      IF NOT blVorgaengerImAK OR NOT blNachfolgerImAK THEN

        IF blVorgaengerImAK THEN
          wlPartner := wlNachfolger;
        ELSE
          wlPartner := wlVorgaenger;
        END_IF

        blPartnerPrueftMit := FALSE;
        FOR wlIndexAK := cERSTER_AUTOMATIKKREIS TO cANZAHL_AUTOMATIKKREISE DO
          IF starrStationBasisParameter[wlPartner].stMKs.eaAutomatikkreis[wlIndexAK] <> 0 THEN
            IF abpCheck[starrStationBasisParameter[wlPartner].stMKs.eaAutomatikkreis[wlIndexAK]] THEN
              blPartnerPrueftMit := TRUE;
            END_IF
          END_IF
        END_FOR

        IF NOT blPartnerPrueftMit THEN
          wpgFehlerdaten[0] := AutomatikkreisBestimmen( wlPartner );
          SpsHinweis( eFehler_Station,
                      cMELDUNG_SYSTEMCHECK_VERBUND_ANDERER_AK_NOETIG,
                      wlPartner,
                      wpAutomatikkreis,
                      wpgFehlerdaten );
        END_IF

      END_IF

    END_IF

  END_FOR

END_FOR

Steuerung_VerbundCheck := TRUE;
END_METHOD