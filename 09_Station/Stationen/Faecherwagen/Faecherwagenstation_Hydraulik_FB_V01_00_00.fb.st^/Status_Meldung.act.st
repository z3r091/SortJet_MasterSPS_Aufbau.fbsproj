(* METADATA
{
	"v3Meta": {
		"objectGuid": "65e65a36-f904-4182-a427-08abe435d94c"
	}
}
*)
ACTION Status_Meldung
//-------------------------------------------------------------------------------------------------
// STATUS DER STATION AN MMI (OPTION AGV)
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Bei Aenderung (Faecherwagen da, RFID gelesen, Beladeposition) und bei neuer MMI-Verbindung
     SB0_SPS_STATUSRACKSTATION senden
*)
IF ( BasisStationsParameter.stMKs.stStationsAufbau.bAGV ) THEN

  tonlRFIDGelesen( IN := in_bRFID_DataValid, PT := T#1S );
  ftlRFIDNichtMehrGelesen( CLK := tonlRFIDGelesen.Q );

  (* Fehlerbehandlung:
     - RFID-Chip im eingeschleusten Zustand nicht mehr lesbar: Faecherwagen nicht richtig eingeschleust
  *)
  IF     blStationBeladen
     AND BasisStationsParameter.stMKs.stStationsAufbau.bRFID
     AND NOT BasisStationsParameter.bFehler
     AND ftlRFIDNichtMehrGelesen.Q
  THEN
    wpFehlerNr := cMELDUNG_FAECHERWAGEN_RFID_CHIP_NICHT_LESBAR;
    SpsError( eFehler_Station,
              wpFehlerNr,
              BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
              AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
              BasisStationsParameter.awFehlerInformationen );

    BasisStationsParameter.wFehlerNummer := wpFehlerNr;
    BasisStationsParameter.bFehler       := TRUE;
  END_IF

  // Status bei Aenderung oder neuer MMI-Verbindung melden
  IF    ( wlStationStatusWord.0 <> ( in_bRFID_DataValid OR tonlMutingSensorenBelegt.Q ) )
     OR ( wlStationStatusWord.1 <> tonlRFIDGelesen.Q )
     OR ( wlStationStatusWord.2 <> bpStatusStationInBeladePosition )
     OR Job.rtlMmiOk.Q
  THEN
    wlStationStatusWord.0 := in_bRFID_DataValid OR tonlMutingSensorenBelegt.Q;
    wlStationStatusWord.1 := tonlRFIDGelesen.Q;
    wlStationStatusWord.2 := bpStatusStationInBeladePosition;

    igRackStationNumber := WORD_TO_INT( BasisStationsParameter.stMKs.stStationsNummern.NummerSPS );
    wgRackPresent       := 0;
    wgRackPresent.0     := wlStationStatusWord.0;
    igRackNumber        := BYTE_TO_INT( bylRFID_Nummer );
    MsgToMmi( auftragsnr_w := SB0_SPS_STATUSRACKSTATION );
  END_IF

END_IF
END_ACTION