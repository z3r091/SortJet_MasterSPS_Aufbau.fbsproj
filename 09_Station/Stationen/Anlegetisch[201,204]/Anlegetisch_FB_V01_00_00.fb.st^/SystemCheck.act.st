(* METADATA
{
  "v3Meta": {
    "objectGuid": "2b4e7d4b-b6b5-4157-accd-f9a533859555"
  }
}
*)
ACTION SystemCheck
//-------------------------------------------------------------------------------------------------
// AKTION: SYSTEMCHECK
//-------------------------------------------------------------------------------------------------
(* Anmerkung:
   - Kein SystemCheck  => Fehler muessen manuell vom Bediener geloest werden
*)
IF( blBetriebartCheck )THEN

  // Ausnahmesituation     
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpCheck := FALSE;
    Glastransport.bpReferenz := FALSE;
    steplCheck := STEP_900_E;
  END_IF
  
  
  CASE steplCheck OF
    // SYSTEM CHECK=========================
    STEP_0_E:
      (* Hinweis:
         - Sicherstellen das der Antrieb keinen Fehler hat
      *)
      BasisStationsParameter.bCheckAbgeschlossen := FALSE;

      IF ( NOT Glastransport.bpFehler ) THEN
        steplCheck := STEP_10_E;

      ELSE
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplCheck := STEP_900_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_10_E:
      (* Hinweis:
         - Bereit zum Referenzieren
      *)
      IF ( BasisStationsParameter.bFreigabe ) THEN
        Glastransport.bpReferenz := TRUE;
        steplCheck := STEP_20_E;
      ELSE
        steplCheck := STEP_30_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_20_E:
      (* Hinweis:
         - Referenz abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpReferenz := FALSE;
        steplCheck := STEP_30_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_30_E:
      IF ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben = 0 ) THEN

        (* Hinweis:
           - Meldung an den Bediener das die Scheibe neu angelegt werden soll
        *)
        IF ( Glastransport.bpSensorAuslauf ) THEN

          IF  BasisStationsParameter.bCheckMitNachfolger[cWAND_1] THEN

            Hubrahmen.bpStartAusfahren := TRUE;
            steplCheck := STEP_100_E;

          ELSE

            SpsHinweis( eFehler_Station,
                        cMELDUNG_SYSTEMCHECK_SCHEIBE_NEU_ANLEGEN,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerIntern),
                        BasisStationsParameter.awFehlerInformationen );

            Hubrahmen.bpStartEinfahren:= TRUE;

            steplCheck := STEP_40_E;


          END_IF

        ELSE

          Hubrahmen.bpStartEinfahren:= TRUE;

          steplCheck := STEP_40_E;

        END_IF

      ELSE

        IF ( Glastransport.bpSensorAuslauf ) THEN
          Hubrahmen.bpStartAusfahren := TRUE;
          steplCheck := STEP_100_E;

        ELSE
          // Meldung ausgeben
          BasisStationsParameter.wFehlerNummer := cMELDUNG_SYSTEMCHECK_SCHEIBE_AUF_SENSOR_AUSLAUF_ERWARTET;
          steplCheck := STEP_900_E;

        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_40_E:
      (* Anmerkung:
         - Hubpalette heben
      *)
      IF ( Hubrahmen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;

        steplCheck := STEP_890_E;
      END_IF

      (* Fehlerbehandlung:
         - Hubpalette hebt nicht in der vorgeschriebenen Zeit bzw. Sensor schaltet nicht
      *)
      IF ( Hubrahmen.bpFehler ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_HUBPALETTE_NICHT_UNTEN;

        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<< Verbund
      //   Anmerkung:
      //   - Hubpalette heben
      IF ( Hubrahmen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        Hubrahmen.bpStartAusfahren := FALSE;

        steplCheck := STEP_110_E;
      END_IF

      (* Fehlerbehandlung:
         - Hubpalette hebt nicht in der vorgeschriebenen Zeit bzw. Sensor schaltet nicht
      *)
      IF ( Hubrahmen.bpFehler ) THEN
        Hubrahmen.bpStartAusfahren := FALSE;
        BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_HUBPALETTE_NICHT_OBEN;

        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_110_E:
      (* Hinweis:
         - Systemcheck des Riemens starten
      *)
      Glastransport.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];
      Glastransport.bpCheck := TRUE;

      steplCheck := STEP_120_E;

    // SYSTEM CHECK=========================
    STEP_120_E:

      IF ( ftlGlastransportCheckMitNachfolger.Q ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben - 1;
      END_IF

      (* Hinweis:
         - Station belegt melden nur wenn auch Glas laut MMI drauf liegen soll
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1] := Glastransport.bpStationBelegt;

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpCheck := FALSE;

        steplCheck := STEP_150_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_150_E:
      (* Hinweis:
         - Hubrahmen wieder einfahren  wenn laut MMI die Scheibe gebucht ist
      *)
      IF ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben = 0 ) THEN

        Hubrahmen.bpStartEinfahren:= TRUE;
        steplCheck := STEP_160_E;
      ELSE

        steplCheck := STEP_890_E;

      END_IF


    // SYSTEM CHECK=========================
    STEP_160_E:
      (* Anmerkung:
         - Hubpalette heben
      *)
      IF ( Hubrahmen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bHubrahmen ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;

        steplCheck := STEP_890_E;
      END_IF

      (* Fehlerbehandlung:
         - Hubpalette hebt nicht in der vorgeschriebenen Zeit bzw. Sensor schaltet nicht
      *)
      IF ( Hubrahmen.bpFehler ) THEN
        Hubrahmen.bpStartEinfahren := FALSE;
        BasisStationsParameter.awFehlerInformationen[1] := cHUBRAHMEN_1;
        BasisStationsParameter.wFehlerNummer := cMELDUNG_HUBPALETTE_NICHT_UNTEN;

        steplCheck := STEP_900_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_890_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NACHRICHT ABSETZEN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Nachricht fuer die Glaslaenge absetzen
      //   - Nachricht muss auch abgesetzt werden wenn die Station leer ist

      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        rSps2MmiMessungScheibenlaenge       := 0;
        wSps2MmiMessungStationNummer        := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        wSps2MmiMessungSlotNummer           := 1;
        iSps2MmiMessungScheibenanzahl       := 1;
        MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

      ELSE
        rSps2MmiMessungScheibenlaenge       := 0;
        wSps2MmiMessungStationNummer        := BasisStationsParameter.stMKs.stStationsNummern.NummerSPS;
        wSps2MmiMessungSlotNummer           := 1;
        iSps2MmiMessungScheibenanzahl       := 0;
        MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

      END_IF

      steplCheck := STEP_1000_E;

    // SYSTEM CHECK=========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // SYSTEM CHECK=========================
    STEP_1000_E:
      // Auftrag für erneuten Automatikbetrieb setzen
      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] AND ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben = 1 ) ) THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Belegt;
      ELSIF Glastransport.bpUebergrosseScheibeUebergang THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Warte_Auf_Austransport_Nachfolger;
      ELSE
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Kein_Auftrag;
      END_IF

      BasisStationsParameter.bCheckAbgeschlossen := TRUE;

  // SYSTEM CHECK=========================
  END_CASE
ELSE
  IF (steplCheck > 0 ) THEN
    BasisStationsParameter.bCheckAbgeschlossen := FALSE;


    Glastransport.bpReferenz     := FALSE;
    Glastransport.bpCheckMitNachfolger := FALSE;
    Glastransport.bpCheck              := FALSE;

    Hubrahmen.bpStartAusfahren := FALSE;
    Hubrahmen.bpStartEinfahren := FALSE;

    steplCheck := STEP_0_E;
  END_IF
END_IF
END_ACTION