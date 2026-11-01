(* METADATA
{
  "v3Meta": {
    "objectGuid": "ceff7ec0-8422-4f2f-902e-5124ad2e42bc"
  }
}
*)
FUNCTION_BLOCK Station_Austransport
VAR_INPUT
    
  // BOOLEAN
  bpReset                : BOOL;
  
  // WORD
  wStation               : WORD;
  wWand                  : WORD;
  
  // STRUKTUR
  Auftragsdaten          : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                 : BOOL;
  bpFehler               : BOOL;

END_VAR
VAR
    
  // BOOLEAN
  blStationQuittiertScheiben      : BOOL;
  blGegenstelleIstShuttle         : BOOL;
  
  // INT
  ilScheibenZuQuittieren          : INT;
  
  // WORD
  wlAustransportstation           : WORD;
  wlAustransportstationVorgaenger : WORD;

  // REFERENZ
  Gegenstelle                     : REFERENCE TO StationBasisParameter_ST;

  // STEPS
  steplSchritt           : STEPS_TE;

END_VAR

//-------------------------------------------------------------------------------------------------
// STEUERUNG AUSTRANSPORT
//-------------------------------------------------------------------------------------------------
IF Auftragsdaten.wAuftrag = eStation_Austransport THEN
  CASE steplSchritt OF
    // AUSTRANSPORT =================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
        steplSchritt := STEP_10_E;
      END_IF

    // AUSTRANSPORT ==================================================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  OPTIONALE - PRUEFUNG DER GLASDATEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------
      steplSchritt := STEP_20_E;

      IF NOT AuftragsdatenPruefen( wStation, wWand, Auftragsdaten) THEN
        steplSchritt := STEP_900_E;
      END_IF

    // AUSTRANSPORT =================================
    STEP_20_E:
      (* Hinweis:
         - Uebergabe der Quellstation [Sender] fuer den Austransport [Zum ueberpruefen des Zustandes der Station]
      *)
      wlAustransportstation := Auftragsdaten.wTransferstationsNr1;

      (* Hinweis:
         - Nach einem Systemcheck mit übergroßen Scheiben kann es sein das die Scheibe noch zum Teil auf der Vorgänger Station liegt. Im Systemcheck wird dann "eStation_Warte_Auf_Austransport_Nachfolger" gesetzt
         - Die Station muss dann in Austransport gesetzt weren
      *)

      wlAustransportstationVorgaenger := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wVorgaengerStation;
      IF ( PruefungWertImIntervall( wlAustransportstationVorgaenger, cERSTE_STATION,cLETZTE_STATION ) ) THEN  // Prüfen ob eine gültige Station zugewiesen
        IF ( starrStationBasisParameter[wlAustransportstationVorgaenger].pAuftrag[wWand].wAuftrag = eStation_Warte_Auf_Austransport_Nachfolger ) THEN
          Job_Stationen.AuftragsdatenWand[wlAustransportstationVorgaenger,wWand]         := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
          starrStationBasisParameter[wlAustransportstationVorgaenger].pAuftrag[wWand].wAuftrag := eStation_Austransport;
        END_IF
      END_IF 

      (* Hinweis:
         - Zuweisung Transportkopplung
      *)
      CASE wlAustransportstation OF

        // Shuttles
        cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
          (* Hinweis:
             - Transportkopplung
          *)
          IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[Auftragsdaten.wTransferstationsNr1] = Vorwaertig ) THEN
            starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrShuttleBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
          ELSE
            starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrShuttleBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
          END_IF

          steplSchritt := STEP_30_E;

        // Stationen
        cERSTE_STATION..cLETZTE_STATION:

          (* Hinweis:
             - Ist diese Station ein Shuttle, muss sie den Auftrag an die Gegenstelle geben, sofern diese kein Shuttle ist
          *)
          Gegenstelle REF= getBasis( Auftragsdaten.wTransferstationsNr1 );
          blGegenstelleIstShuttle := __ISVALIDREF( Gegenstelle ) AND_THEN __ISVALIDREF( Gegenstelle.stMKs ) AND_THEN Gegenstelle.stMKs.stSchnittstellendaten.bStationIstShuttle;

          // Station ist ein Shuttle
          IF starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.bStationIstShuttle AND NOT blGegenstelleIstShuttle THEN
            IF ( ( Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand].wAuftrag = eStation_Belegt )
                 OR ( Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand].wAuftrag = eStation_Kein_Auftrag ) )
            THEN

              Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand]          := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
              Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand].wAuftrag := eStation_Eintransport;
              
              // Transportkopplung
              IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[Auftragsdaten.wTransferstationsNr1] = Vorwaertig ) THEN
                starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
              ELSE 
                starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
              END_IF
              
              steplSchritt := STEP_30_E;
            END_IF

          ELSE

            // Transportkopplung
            IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[Auftragsdaten.wTransferstationsNr1] = Vorwaertig ) THEN
              starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
            ELSE 
              starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
            END_IF

            steplSchritt := STEP_30_E;

          END_IF

        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
          IF ( Auftragsdaten.wTransferstationsNr2 <> 0 ) THEN
            IF   ( Job_Fremdanlage.AuftragsdatenFremdanlage[wlAustransportstation].wAuftrag = eStation_Kein_Auftrag )
                 AND ( Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr2, Auftragsdaten.wTransferwand].wAuftrag = eStation_Kein_Auftrag )
            THEN
              steplSchritt := STEP_30_E;
            END_IF
          ELSE
            IF starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.bStationIstShuttle THEN
              IF ( Job_Fremdanlage.AuftragsdatenFremdanlage[wlAustransportstation].wAuftrag = eStation_Kein_Auftrag ) THEN
                starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrFremdanlageAuslaufStationBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[cWAND_1];
                starrFremdanlageAuslaufStationBasisParameter[Auftragsdaten.wTransferstationsNr1].InGlasTransportVorgaenger[cWAND_1] :=  starrStationBasisParameter[wStation].OutGlasTransport[wWand];
                steplSchritt := STEP_30_E;
              END_IF
            ELSE
              starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrFremdanlageAuslaufStationBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[cWAND_1];
              starrFremdanlageAuslaufStationBasisParameter[Auftragsdaten.wTransferstationsNr1].InGlasTransportVorgaenger[cWAND_1] :=  starrStationBasisParameter[wStation].OutGlasTransport[wWand];
              steplSchritt := STEP_30_E;
            END_IF
          END_IF

        cERSTE_FREMDANLAGE_EINLAUF..cLETZTE_FREMDANLAGE_EINLAUF:
          ;

        cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR:
          ;

        ELSE
          wpgFehlerdaten[0] := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
          wpgFehlerdaten[1] := wlAustransportstation;
          SpsError( eFehler_Station,
                    cMELDUNG_AUFTRAGSDATEN_FALSCHE_AUSLAUFSTATION,
                    starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );

          steplSchritt := STEP_900_E;

      END_CASE

    // AUSTRANSPORT =================================
    STEP_30_E:

      (* Hinweis:
         - Scheibenquittierung
      *)
      ilScheibenZuQuittieren := WORD_TO_INT(Auftragsdaten.wAnzahlScheiben);

      (* Hinweis:
         - Auftragsdaten zuweisen
      *)
      starrStationBasisParameter[wStation].pAuftrag[wWand] := Auftragsdaten;

      (* Hinweis:
         - Auftrags- Optionen bestimmen und zuweisen
      *)
      // Drehen
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition                  := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Kippen[Auftragsdaten.wTransferstationsNr1];
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachEintransport := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachAustransport := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.KippenNachAustransport[Auftragsdaten.wTransferstationsNr1];

      IF ( Auftragsdaten.rAuftragsDicke < wgUnterteilerMinMaxGlasdicke ) THEN
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung16mm;
      ELSE
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung29mm;
      END_IF
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition := REAL_TO_WORD(Auftragsdaten.rStationsZielposition);
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachAustransport := REAL_TO_WORD(Auftragsdaten.rTransferposition2);
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eGlastransport := 0;;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eHub := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eQuerachse := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eAchsrichtung := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Achsrichtung[Auftragsdaten.wTransferstationsNr1];
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.wMaxTransportGeschwindigkeit:= 0;
      
      starrStationBasisParameter[wStation].bScheibentrennen[wWand] := FALSE;
      starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[Auftragsdaten.wTransferstationsNr1] = Rueckwaertig );


      steplSchritt := STEP_35_E;

    // AUSTRANSPORT =================================
    STEP_35_E:
      // Im Step 35 wird in dem vererbten FB Anlagenspezifische Auftragsoptionen gesetzt         
      starrStationBasisParameter[wStation].bAustransport[wWand] := TRUE;
      steplSchritt := STEP_40_E;

    // AUSTRANSPORT =================================
    STEP_40_E:

      (* Hinweis:
         - Scheibenzaehler dekrementieren
         - Scheibe quittieren, sofern dies nötig ist
      *)
      blStationQuittiertScheiben := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[wlAustransportstation];
      
      IF ( starrStationBasisParameter[wStation].OutGlasTransport[wWand].bQuittScheibe ) THEN

        IF ( ilScheibenZuQuittieren > 0 ) AND blStationQuittiertScheiben THEN

          wSps2MmiZielStation  := Auftragsdaten.wTransferstationsNr1;
          wSps2MmiQuellStation := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          wSps2MmiZielWand     := Auftragsdaten.wTransferwand;
          wSps2MmiQuellWand    := Auftragsdaten.wStationsWand;
          dwSps2MmiWartezeit   := starrStationBasisParameter[wStation].dwWartezeit[wWand];

          IF starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.bStationIstShuttle THEN
            wSPS2MMIAuftragstyp  := 1;
          ELSE
            wSPS2MMIAuftragstyp  := 0;
          END_IF; 

          MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
          
        END_IF

        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;

      END_IF

      (* Hinweis:
         - Abschliessen des Austransport
      *)
      IF ( starrStationBasisParameter[wStation].bAustransportAbgeschlossen[wWand] ) THEN
        starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
        starrStationBasisParameter[wStation].bAustransport[wWand] := FALSE;
        steplSchritt := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Station
      *)
      IF ( starrStationBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrStationBasisParameter[wStation].wFehlerNummer,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrStationBasisParameter[wStation].awFehlerInformationen );

        starrStationBasisParameter[wStation].bAustransport[wWand] := FALSE;
        starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================================
    STEP_100_E:
      (* Anmerkung:
         - Gueltige Anzahl von Scheiben wurden quittiert
      *)
      IF ( ilScheibenZuQuittieren = 0 ) THEN
        steplSchritt := STEP_1000_E;

      (* Anmerkung:
         - Zu wenig Scheiben quittiert
      *)
      ELSIF ( ilScheibenZuQuittieren > 0 ) THEN
        wpgFehlerdaten[0] := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := wWand;

        SpsError( eFehler_Station,
                  cMELDUNG_STATION_ZUWENIG_SCHEIBEN_QUITTIERT_AUSTRANSPORT,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );

        steplSchritt := STEP_900_E;

      (* Anmerkung:
         - Zu viele Scheiben quittiert
      *)
      ELSIF ( ilScheibenZuQuittieren < 0 ) THEN
        wpgFehlerdaten[0] := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := wWand;

        SpsError( eFehler_Station,
                  cMELDUNG_STATION_ZUVIELE_SCHEIBEN_QUITTIERT_AUSTRANSPORT,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );

        steplSchritt := STEP_900_E;
      END_IF

    // AUSTRANSPORT =================================
    STEP_900_E:
      bpFehler := TRUE;

    // AUSTRANSPORT =================================
    STEP_1000_E:
      bpDone := TRUE;
      IF Auftragsdaten.stAuftragsInformationen.cBIT_SRCSTATION_EMPTY THEN
        Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;
      ELSE
        Auftragsdaten.wAuftrag := eStation_Belegt;
      END_IF
  END_CASE

END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpReset := FALSE;
  bpDone := FALSE;
  steplSchritt := STEP_0_E;
  starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
  starrStationBasisParameter[wStation].bAustransport[wWand] := FALSE;
END_IF
END_FUNCTION_BLOCK