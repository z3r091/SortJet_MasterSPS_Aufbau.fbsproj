(* METADATA
{
	"v3Meta": {
		"objectGuid": "5c155a10-ce85-4210-b01a-06059d9fcd6d"
	}
}
*)
ACTION SystemCheck
//-------------------------------------------------------------------------------------------------
// AKTION SYSTEMCHECK
//-------------------------------------------------------------------------------------------------
IF ( blBetriebartCheck ) THEN
  (* Fehlerbehandlung:
     - Glastransport
     - Kippbaustein
  *)
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpCheck := FALSE;
    out_bDrosselklappeOeffnen := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF
  
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplCheck := STEP_900_E;
  END_IF
  
  CASE steplCheck OF
    // SYSTEM CHECK=========================
    STEP_0_E:
      (* Hinweis:
         - Zuerst Prüfung ob der Sicherheitskreis quittiert wurde.
      *)
      BasisStationsParameter.bStationBelegt[cWAND_1] := FALSE;

      IF ( BasisStationsParameter.bFreigabe ) THEN

        steplCheck := STEP_10_E;

      ELSE

        BasisStationsParameter.bStationBelegt[cWAND_1] := ( Glastransport.bpSensorEinlauf
                                                            OR Glastransport.bpSensorAuslauf 
                                                            OR Glastransport.bpSensorEinlaufVorAb 
                                                            OR Glastransport.bpSensorAuslaufVorAb );

        wSPS2MMIStationsNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;

        IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
          wSPS2MMIStationsStatusWord1 := cSTATUS_STATION_BELEGT;
        ELSE
          wSPS2MMIStationsStatusWord1 := cSTATUS_STATION_FREI;
        END_IF

        MsgToMmi( auftragsnr_w := SB0_SPS_STATIONSTATUS);

        SpsHinweis( eFehler_Station,
                    cMELDUNG_ANLEGEN_SICHERHEITSKREIS,
                    BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                    BasisStationsParameter.awFehlerInformationen );

        IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
          rSps2MmiMessungScheibenlaenge       := 0.0;
          wSps2MmiMessungStationNummer        := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
          wSps2MmiMessungSlotNummer           := cEBENE_1;
          iSps2MmiMessungScheibenanzahl       := 1;
          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

        ELSE
          rSps2MmiMessungScheibenlaenge       := 0.0;
          wSps2MmiMessungStationNummer        := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
          wSps2MmiMessungSlotNummer           := cEBENE_1;
          iSps2MmiMessungScheibenanzahl       := 0;
          MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

        END_IF

        steplCheck := STEP_800_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_10_E:
      IF ( tonlFreigabeErhalten.Q ) THEN

        IF ( in_bMotorschutzGeblaese_Ok ) THEN
          // blGeblaeseAnforderung     := TRUE;
          out_bDrosselklappeOeffnen := TRUE;
          steplCheck := STEP_20_E;
        ELSE
          out_bDrosselklappeOeffnen := FALSE;
          BasisStationsParameter.wFehlerNummer := cMELDUNG_ANTRIEB_GEBLAESE;
          steplCheck := STEP_900_E;
        END_IF

      END_IF

    // SYSTEM CHECK=========================
    STEP_20_E:
      (* Anmerkung:
         - Wand gekippt oder senkrecht
             => senkrecht : Glastransport vor bis Station frei oder Sensor belegt dann Station belegt oder frei
             => waagerecht: Glastransport zurück bis Station frei oder Sensor belegt dann Station zwar belegt aber Scheibe muss neu angelegt werden
         -  Zentrierleiste evtl. überprüfen
      *)
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];

      IF (BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1]) THEN

        CASE Kippen.epKippStatus OF

          eKippen_Position_84Grad:
            Glastransport.bpCheck := TRUE;
            Glastransport.bpCheckMitNachfolger := FALSE;
            steplCheck := STEP_100_E;

          eKippen_Position_90Grad:
            Glastransport.bpCheck := TRUE;
            Glastransport.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];
            steplCheck := STEP_100_E;

          eKippen_Default:
            Kippen.epZielPosition := eKippen_Position_84Grad;
            Kippen.bpPositionieren := TRUE;
            steplCheck := STEP_30_E;

        END_CASE

      ELSE

        Glastransport.bpCheckMitVorgaenger := BasisStationsParameter.bCheckMitVorgaenger[cWAND_1];
        Glastransport.bpCheckMitNachfolger := BasisStationsParameter.bCheckMitNachfolger[cWAND_1];

        Glastransport.bpCheck := TRUE;

        steplCheck := STEP_100_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_30_E:
      (* Hinweis:
         - Station in eine definierte Position gekippt
      *)
      IF ( Kippen.bpDone
           OR ( Kippen.epZielPosition = Kippen.epKippStatus ) )
      THEN
        Kippen.bpPositionieren := FALSE;
        steplCheck := STEP_20_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_100_E:
      BasisStationsParameter.bStationBelegt[cWAND_1] := Glastransport.bpStationBelegt;

      IF ( Glastransport.bprtScheibe ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben + 1;
      END_IF

      IF ( ftlGlastransportCheckMitNachfolger.Q ) THEN
        BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben := BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben - 1;
      END_IF

      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpCheck := FALSE;
        steplCheck := STEP_110_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_110_E:
      // ---------------------------------------------------------------------------------------
      // OPTION - KOMPONENTEN ANSTEUERN
      //
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      Kippen.epZielPosition := eKippen_Position_84Grad;
      Kippen.bpPositionieren := BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1];

      steplCheck := STEP_120_E;

    // SYSTEM CHECK=========================
    STEP_120_E:
      IF ( (Kippen.bpDone OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1]) ) THEN
        Kippen.bpPositionieren := FALSE;
        steplCheck := STEP_200_E;
      END_IF

    // SYSTEM CHECK=========================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  STATUSNACHRICHT AN DIE HMI SENDEN
      //
      //  Hinweis:
      // - n/C
      // ---------------------------------------------------------------------------------------

      IF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        wSPS2MMIStationsNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSPS2MMIStationsStatusWord1 := cSTATUS_STATION_BELEGT;
        MsgToMmi( auftragsnr_w := SB0_SPS_STATIONSTATUS);
        steplCheck := STEP_800_E;

      ELSE
        wSPS2MMIStationsNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        wSPS2MMIStationsStatusWord1 := cSTATUS_STATION_FREI;
        MsgToMmi( auftragsnr_w := SB0_SPS_STATIONSTATUS);
        steplCheck := STEP_800_E;

      END_IF

    // SYSTEM CHECK=========================
    STEP_800_E:
      // ---------------------------------------------------------------------------------------
      // BELADUNGSZUSTAND PRUEFEN UND FOLGE-ZUSTAND BESTIMMEN
      //
      //  Hint:
      //  -  n/c
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Abnahmescheibe: Transferstation = Stationsnummer
         - Aufgabescheibe: Transferstation = Folge- Station (Vorgaenger bzw. Nachfolger )
      *)
      IF ( BasisStationsParameter.pAuftrag[cWAND_1].wTransferstationsNr1 = BasisStationsParameter.stMKs.stStationsNummern.NummerSPS ) THEN
 
        IF ( NOT BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN

        (* Hinweis:
           - Meldung generieren das die Scheibe abgenommen wurde
        *)
        //          wSps2MmiApprovaltableNummer := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
        //        MsgToMmi(auftragsnr_w := SB0_SPS_SHEETREMOVEDAPPROVALWALL);

        END_IF
     
      ELSE

        IF BasisStationsParameter.bStationBelegt[cWAND_1] THEN

          IF ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben = 0 )THEN
              
            SpsHinweis( eFehler_Station,
                        cMELDUNG_SYSTEMCHECK_SCHEIBE_NEU_ANLEGEN,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                        BasisStationsParameter.awFehlerInformationen );
          END_IF

        ELSE

          IF ( BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben >= 1 )THEN

            SpsHinweis( eFehler_Station,
                        cMELDUNG_SYSTEMCHECK_KEINE_SCHEIBE_GEFUNDEN,
                        BasisStationsParameter.stMKs.stStationsNummern.NummerIntern,
                        AutomatikkreisBestimmen(BasisStationsParameter.stMKs.stStationsNummern.NummerSPS),
                        BasisStationsParameter.awFehlerInformationen );

          END_IF

        END_IF

      END_IF

      steplCheck := STEP_1000_E;

    // SYSTEM CHECK=========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

      wSps2MmiMessungStationNummer  := BasisStationsParameter.stMKs.stStationsNummern.NummerIntern;
      wSps2MmiMessungSlotNummer     := cEBENE_1;
      iSps2MmiMessungScheibenanzahl := -1;

      MsgToMmi( auftragsnr_w := SB0_SPS_SETSHEETSONSTATION );

    // SYSTEM CHECK=========================
    STEP_1000_E:
      // Auftrag für erneuten Automatikbetrieb setzen      
      IF //starrStationBasisParameter[BasisStationsParameter.stMKs.stStationsNummern.NummerSPS].stMKs.stStationsOptionen.bScheibeAbnehmenNachEintransport 
        BasisStationsParameter.pAuftrag[cWAND_1].stAuftragsInformationen.cBit_11 // Bit 11 = 1 -> Abnahme
        AND ( BasisStationsParameter.bStationBelegt[cWAND_1] OR BasisStationsParameter.pAuftrag[cWAND_1].wAnzahlScheiben > 0) 
      THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Abnehmen;
      ELSIF ( BasisStationsParameter.bStationBelegt[cWAND_1] ) THEN
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Belegt;
      ELSE
        BasisStationsParameter.pAuftragNachSystemcheck[cWAND_1] := eStation_Kein_Auftrag;
      END_IF

      BasisStationsParameter.bCheckAbgeschlossen := TRUE;

  // SYSTEM CHECK=========================
  END_CASE
ELSE
  IF (steplCheck > 0) THEN
    steplCheck := STEP_0_E;
    BasisStationsParameter.bCheckAbgeschlossen := FALSE;
    out_bDrosselklappeOeffnen := FALSE;
    Kippen.bpPositionieren := FALSE;
    Glastransport.bpCheck := FALSE;
  END_IF
END_IF
END_ACTION