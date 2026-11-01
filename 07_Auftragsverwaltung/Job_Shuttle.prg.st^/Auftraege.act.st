(* METADATA
{
  "v3Meta": {
    "objectGuid": "374beb49-ca7f-40e9-b2ab-7b5100759e7c"
  }
}
*)
ACTION Auftraege
(***************************************************************************************************)
(* AUFTRAG: M_SB0_MMI_SHEET_ORDER_SHUTTLE *)
(***************************************************************************************************)
(* Hinweis:
   - Auftragsdaten an ein Shuttle uebergeben
*)
IF ( M_SB0_MMI_SHEET_ORDER_SHUTTLE ) THEN

  CASE tMmi2SpsInfo.wStationsNr OF
    
    cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
      LocalAuftragsSpeicher REF= AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand];
      M_SB0_MMI_SHEET_ORDER_SHUTTLE := FALSE;

    cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
      LocalAuftragsSpeicher REF= AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wStationsNr];
      M_SB0_MMI_SHEET_ORDER_SHUTTLE := FALSE;
  
  END_CASE

  IF __ISVALIDREF(LocalAuftragsSpeicher) THEN 

    LocalAuftragsSpeicher.NeuerAuftrag.wStationsNr            := tMmi2SpsInfo.wStationsNr;
    LocalAuftragsSpeicher.NeuerAuftrag.rVorabPosition         := tMmi2SpsInfo.rStationsPosition;
    LocalAuftragsSpeicher.NeuerAuftrag.rStationsZielposition  := tMmi2SpsInfo.rStationsPosition;     (* Stationsposition der Quellstation *)
    LocalAuftragsSpeicher.NeuerAuftrag.rAuftragsLaenge        := tMmi2SpsInfo.rAuftragsLaenge;       (* Länge der Scheibe/Batch *)
    LocalAuftragsSpeicher.NeuerAuftrag.rAuftragsHoehe         := tMmi2SpsInfo.rAuftragsHoehe;        (* Höhe der Scheibe/Batch *)
    LocalAuftragsSpeicher.NeuerAuftrag.rAuftragsDicke         := tMmi2SpsInfo.rAuftragsDicke;        (* Dicke der Scheibe/Batch *)
    LocalAuftragsSpeicher.NeuerAuftrag.wErsteLetzteScheibe    := tMmi2SpsInfo.wErsteLetzteScheibe;  (* Kennzeichnung Erste und Letzte Scheibe *)
    LocalAuftragsSpeicher.NeuerAuftrag.wAnzahlScheiben        := tMmi2SpsInfo.wAnzahlScheiben;       (* Anzahl der Scheiben *)
    LocalAuftragsSpeicher.NeuerAuftrag.wStationsWand          := tMmi2SpsInfo.wAuftragsWand;         (* Stationswand der Quellstation *)
    LocalAuftragsSpeicher.NeuerAuftrag.wTransferstationsNr1   := tMmi2SpsInfo.wTransferstationsNr1;  (* Stationsnummer der Zielstation 1 *)
    LocalAuftragsSpeicher.NeuerAuftrag.wTransferstationsNr2   := tMmi2SpsInfo.wTransferstationsNr2;  (* Stationsnummer der Zielstation 2 *)
    LocalAuftragsSpeicher.NeuerAuftrag.rTransferposition1     := tMmi2SpsInfo.rTransferposition1;    (* Stationsposition der Zielstation 1 *)
    LocalAuftragsSpeicher.NeuerAuftrag.rTransferposition2     := tMmi2SpsInfo.rTransferposition2;    (* Stationsposition der Zielstation 2 *)
    LocalAuftragsSpeicher.NeuerAuftrag.wTransferwand          := tMmi2SpsInfo.wTransferwand;         (* Stationswand der Zielstationen 1 *)
    LocalAuftragsSpeicher.NeuerAuftrag.stAuftragsInformationen.wAuftragsInformationen := tMmi2SpsInfo.wAuftragsTyp;            (* Zusaetzliche Auftrags- Informationen *)

    // Soll Drehpos der Folgestation für den Eintransport    
    LocalAuftragsSpeicher.NeuerAuftrag.wTransferVersatzVorne   := tMmi2SpsInfo.rTransferstationModellversatzVorne;
    // Soll Drehpos der Folgestation nach dem Eintransport    
    LocalAuftragsSpeicher.NeuerAuftrag.wTransferVersatzHinten  := tMmi2SpsInfo.rTransferstationModellversatzHinten;

    (* Hinweis:
       - Zuweisung der Bits "erste" und "letzte" Scheibe 
    *)
    ErsteUndLetzteScheibeBits( wpErsteUndLetzteScheibe:= tMmi2SpsInfo.wErsteLetzteScheibe ,
                               wpLetzteScheibe => wlLetzteScheibe,
                               wpErsteScheibe  => wlErsteScheibe );

    LocalAuftragsSpeicher.NeuerAuftrag.bLetzteScheibe  := wlLetzteScheibe > 0;   (* Stationsposition der Zielstation 2 *)
    LocalAuftragsSpeicher.NeuerAuftrag.bErsteScheibe   := wlErsteScheibe  > 0;        (* Stationswand der Zielstationen *)

    (* Hinweis:
       - 0 -> Eintransport
       - 1 -> Austransport
    *)
    IF ( tMmi2SpsInfo.wAuftragsTyp.0 ) THEN
      LocalAuftragsSpeicher.NeuerAuftrag.wAuftrag := eStation_Austransport;
    ELSE
      LocalAuftragsSpeicher.NeuerAuftrag.wAuftrag := eStation_Eintransport;
    END_IF

    LocalAuftragsSpeicher(bpNeuerAuftrag := TRUE);

  END_IF

END_IF

(***************************************************************************************************)
(* AUFTRAG: M_SB0_MMI_SortierungInsertExtractionShuttleData *)
(***************************************************************************************************)
(* Hinweis:
   - Austransportschlitten mit einem Scheibenvortransport-Auftrag versehen 
*)
IF ( M_SB0_MMI_SortierungInsertExtractionShuttleData ) THEN

  M_SB0_MMI_SortierungInsertExtractionShuttleData := FALSE;

  IF ( bgTransfershuttleVortransportAktivieren ) THEN

    (* ---------------------------------------------------------------------------------------
    //  TRANSFERSHUTTLE VORTRANSPORT
    //         
    //  Hinweis:
    //  - VortransportNummer_TS2 = 0   => Vortransport mit nur einem Transfershuttle
    //  - VortransportNummer_TS1 <> 0  => Vortransport im Transfershuttle-Verbund
    // ---------------------------------------------------------------------------------------*)
    IF ( tMmi2SpsInfo.wVortransportNummer_TS2 = 0  ) THEN

      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.rStationsZielposition := tMmi2SpsInfo.rVortransportSollPosition_TS1;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.rAuftragsLaenge       := tMmi2SpsInfo.rVortransportStrecke;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.wTransferstationsNr1  := 0;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.wTransferstationsNr2  := 0;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.rTransferposition1    := tMmi2SpsInfo.rVortransportSollPosition_TS1;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.rTransferposition2    := 0;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.stAuftragsInformationen.cBIT_BUFFERSLOT_THICKNESS := ( tMmi2SpsInfo.wSlotThickness = 1 );
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.wAuftrag := eStation_Vortransport;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1](bpNeuerAuftrag := TRUE);

    ELSE
      VailiderenTransfershuttleVerbund ( wTransferstation1 := tMmi2SpsInfo.wVortransportNummer_TS1 ,
                                         wTransferstation2 := tMmi2SpsInfo.wVortransportNummer_TS2 ,
                                         wTransferstationMaster => tMmi2SpsInfo.wVortransportNummer_TS1,
                                         wTransferstationSlave  => tMmi2SpsInfo.wVortransportNummer_TS2 );

      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.rStationsZielposition := tMmi2SpsInfo.rVortransportSollPosition_TS1;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.rAuftragsLaenge       := tMmi2SpsInfo.rVortransportStrecke;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.wTransferstationsNr1  := tMmi2SpsInfo.wVortransportNummer_TS1;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.wTransferstationsNr2  := tMmi2SpsInfo.wVortransportNummer_TS2;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.rTransferposition1    := tMmi2SpsInfo.rVortransportSollPosition_TS1;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.rTransferposition2    := tMmi2SpsInfo.rVortransportSollPosition_TS2;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.stAuftragsInformationen.cBIT_BUFFERSLOT_THICKNESS := ( tMmi2SpsInfo.wSlotThickness = 1 );
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1].NeuerAuftrag.wAuftrag              := eStation_Vortransport;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wVortransportNummer_TS1](bpNeuerAuftrag := TRUE);

    END_IF

  ELSE

    (* Hinweis:
       - Quittierung des Vortransportes 
    *)
    wSps2MmiQuittierungVortransportStationsNr1 := tMmi2SpsInfo.wVortransportNummer_TS1;
    wSps2MmiQuittierungVortransportStationsNr2 := tMmi2SpsInfo.wVortransportNummer_TS2;
    wSps2MmiQuittierungVortransportStatus      := 1; (* 0  = nicht Erfolgreich / 1 = erfolgreich *)
    rSps2MmiQuittierungVortransportWegStrecke  := tMmi2SpsInfo.rVortransportStrecke;

    MsgToMmi(auftragsnr_w := SB0_SPS_SortierungQuittExtractionShuttleData );

  END_IF

END_IF

(***************************************************************************************************)
(* AUFTRAG: M_SB0_MMI_SHUTTLE_INFORMATION *)
(***************************************************************************************************)
IF ( M_SB0_MMI_SHUTTLE_INFORMATION ) THEN

  M_SB0_MMI_SHUTTLE_INFORMATION := FALSE;

  CASE tMmi2SpsInfo.wAuftrag_ShuttleNummer OF

    cERSTE_STATION..cLETZTE_STATION:
      ;
    cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
      IF tMmi2SpsInfo.wAuftrag_ShuttleWand = 0 THEN // TODO
        tMmi2SpsInfo.wAuftrag_ShuttleWand := 1;
      END_IF
      CASE tMmi2SpsInfo.wAuftrag_ShuttleWand OF

          cWAND_1,
            cWAND_2:
          IF ( VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].wAuftrag = eStation_Kein_Auftrag ) THEN
            VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].rLaenge                := tMmi2SpsInfo.rAuftrag_Laenge;
            VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].rDicke                 := tMmi2SpsInfo.rAuftrag_Dicke;
            VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].wTransferStation       := tMmi2SpsInfo.wAuftrag_TranferStation;
            VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].wAuftragstyp           := tMmi2SpsInfo.wAuftrag_Modus;
            VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].wShuttleWandNummer     := tMmi2SpsInfo.wAuftrag_ShuttleWand;
            VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].wTransferWand          := tMmi2SpsInfo.wAuftrag_TransferWand;
            VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].wShuttleNummer         := tMmi2SpsInfo.wAuftrag_ShuttleNummer;

            VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].stAuftragsInformationen.wAuftragsInformationen := tMmi2SpsInfo.wAuftrag_Modus;
            VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, tMmi2SpsInfo.wAuftrag_ShuttleWand].wAuftrag := eStation_VorabAuftrag;
      
          END_IF
       
        cWAND_1_2: //eigentlich Wand 1 und 2, da dies Bitcodiert ist, kommt dies als Wand3
          FOR wlIndexWand := cWAND_1 TO cANZAHL_WAENDE DO
     
            IF ( VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].wAuftrag = eStation_Kein_Auftrag ) THEN

              VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].rLaenge                := tMmi2SpsInfo.rAuftrag_Laenge;
              VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].rDicke                 := tMmi2SpsInfo.rAuftrag_Dicke;
              VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].wTransferStation       := tMmi2SpsInfo.wAuftrag_TranferStation;
              VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].wAuftragstyp           := tMmi2SpsInfo.wAuftrag_Modus;
              VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].wShuttleWandNummer     := wlIndexWand;
              VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].wTransferWand          := tMmi2SpsInfo.wAuftrag_TransferWand;
              VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].wShuttleNummer         := tMmi2SpsInfo.wAuftrag_ShuttleNummer;
      
              VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].stAuftragsInformationen.wAuftragsInformationen := tMmi2SpsInfo.wAuftrag_Modus;
              VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, wlIndexWand].wAuftrag := eStation_VorabAuftrag;
      
            END_IF

          END_FOR

        ELSE
          ;

      END_CASE

    cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
      IF ( NOT Job_Shuttle.abpStarteParalleleBausteinAnsteuerung[tMmi2SpsInfo.wAuftrag_ShuttleNummer] ) THEN
        Job_Shuttle.VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, cWAND_1].rLaenge                := tMmi2SpsInfo.rAuftrag_Laenge;
        Job_Shuttle.VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, cWAND_1].rDicke                 := tMmi2SpsInfo.rAuftrag_Dicke;
        Job_Shuttle.VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, cWAND_1].wTransferStation       := tMmi2SpsInfo.wAuftrag_TranferStation;
        Job_Shuttle.VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, cWAND_1].wAuftragstyp           := tMmi2SpsInfo.wAuftrag_Modus;
        Job_Shuttle.VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, cWAND_1].wShuttleWandNummer     := tMmi2SpsInfo.wAuftrag_ShuttleWand;
        Job_Shuttle.VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, cWAND_1].wTransferWand          := tMmi2SpsInfo.wAuftrag_TransferWand;
        Job_Shuttle.VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, cWAND_1].wShuttleNummer         := tMmi2SpsInfo.wAuftrag_ShuttleNummer;

        Job_Shuttle.VorAbAuftragsDaten[tMmi2SpsInfo.wAuftrag_ShuttleNummer, cWAND_1].stAuftragsInformationen.wAuftragsInformationen := tMmi2SpsInfo.wAuftrag_Modus;

        Job_Shuttle.abpStarteParalleleBausteinAnsteuerung[tMmi2SpsInfo.wAuftrag_ShuttleNummer] := TRUE;
      END_IF

    ELSE
      (* Fehlerbehandlung:
      *)
      wpgFehlerdaten[0] := tMmi2SpsInfo.wAuftrag_ShuttleNummer;
      wpgFehlerdaten[1] := tMmi2SpsInfo.wAuftrag_TranferStation;
      SpsError( eFehler_Station, 
                cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_STATION, 
                tMmi2SpsInfo.wAuftrag_ShuttleNummer, 
                AutomatikkreisBestimmen(tMmi2SpsInfo.wAuftrag_ShuttleNummer), 
                wpgFehlerdaten );

  END_CASE

END_IF

(***************************************************************************************************)
(* AUFTRAG: M_SB0_MMI_GETSORTIERUNGSHUTTLEPOS *)
(***************************************************************************************************)
(* Hinweis:
   - Verfarhlogik
     => Absetzen der Positionen
     => Melden der IST- Position wenn die Positionierung aufgrund eines 
        Fehler [ Verfahrfreigabe fehlt ] nicht durchgefuehrt werden kann   
*)
IF ( M_SB0_MMI_GETSORTIERUNGSHUTTLEPOS ) THEN

  M_SB0_MMI_GETSORTIERUNGSHUTTLEPOS := FALSE;

  SendShuttlePosition();

END_IF

(***************************************************************************************************)
(* AUFTRAG: M_SB0_MMI_TS_REPOSITIONING_LITES *)
(***************************************************************************************************)

(* Hinweis:
   - Funktion zum zurueckfahren der Glaeser und neu Positionieren im Speicher
*)
IF ( M_SB0_MMI_TS_REPOSITIONING_LITES ) THEN
  M_SB0_MMI_TS_REPOSITIONING_LITES := FALSE;

  CASE tMmi2SpsInfo.wStationsNr OF

    cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wStationsNr           := tMmi2SpsInfo.wStationsNr;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rStationsZielposition := tMmi2SpsInfo.rStationsPosition;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wTransferstationsNr1  := tMmi2SpsInfo.wTransferstationsNr1;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rModellVersatzHinten  := tMmi2SpsInfo.rModellversatzHinten;

      IF ( tMmi2SpsInfo.rAuftragsDicke = 0 ) THEN
        AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rAuftragsDicke        := 4.0;
      ELSE
        AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rAuftragsDicke        := 19.0;
      END_IF

      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wAuftrag := eStation_Scheibenkorrektur;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wStationsNr](bpNeuerAuftrag := TRUE);

      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wTransferstationsNr1].NeuerAuftrag.wStationsNr           := tMmi2SpsInfo.wTransferstationsNr1;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wTransferstationsNr1].NeuerAuftrag.rStationsZielposition := tMmi2SpsInfo.rTransferposition1;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wTransferstationsNr1].NeuerAuftrag.wTransferstationsNr1  := tMmi2SpsInfo.wStationsNr;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wTransferstationsNr1].NeuerAuftrag.rModellVersatzHinten  := tMmi2SpsInfo.rModellversatzHinten;

      IF ( tMmi2SpsInfo.rAuftragsDicke = 0 ) THEN
        AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wTransferstationsNr1].NeuerAuftrag.rAuftragsDicke        := 4.0;
      ELSE
        AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wTransferstationsNr1].NeuerAuftrag.rAuftragsDicke        := 19.0;
      END_IF


      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wTransferstationsNr1].NeuerAuftrag.wAuftrag := eStation_Transportkopplung;
      AuftragsSpeicherTransfershuttle[tMmi2SpsInfo.wTransferstationsNr1](bpNeuerAuftrag := TRUE);

  END_CASE

END_IF

(***************************************************************************************************)
(* AUFTRAG: M_SB0_MMI_SORTIERUNGCANcELSHUTTLEDATA *)
(***************************************************************************************************)
(* Hinweis:
   - Abbrechen eines aktiven Shuttleauftrags
*)
IF ( M_SB0_MMI_SORTIERUNGCANCELSHUTTLEDATA ) THEN

  M_SB0_MMI_SortierungCancelShuttleData := FALSE;

  CASE tMmi2SpsInfo.wCancelShuttleDataShuttleNr OF

    cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
      IF ( AuftragsdatenWand[tMmi2SpsInfo.wCancelShuttleDataShuttleNr, cWAND_1].wAuftrag <> eStation_Kein_Auftrag ) THEN
        AuftragsdatenWand[tMmi2SpsInfo.wCancelShuttleDataShuttleNr, cWAND_1].wAuftrag :=  eStation_Kein_Auftrag;
      END_IF

    cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
      IF ( Job_Shuttle.AuftragsdatenTransfershuttle[tMmi2SpsInfo.wCancelShuttleDataShuttleNr].wAuftrag <> eStation_Kein_Auftrag ) THEN
        Job_Shuttle.AuftragsdatenTransfershuttle[tMmi2SpsInfo.wCancelShuttleDataShuttleNr].wAuftrag :=  eStation_Kein_Auftrag;
      END_IF

  END_CASE 

END_IF

(***************************************************************************************************)
(* S T A R T - Fächerwagen Suche mittels Sensor *)
(***************************************************************************************************)

IF ( M_SB0_MMI_POSITIONMEASUREONOFF ) THEN

  M_SB0_MMI_POSITIONMEASUREONOFF := FALSE;

  IF ( tMmi2SpsInfo.wShuttleFWSucheAN_AUS = 1 ) THEN
    AuftragsSpeicherWand[tMmi2SpsInfo.wShuttleNummerFWSuche, cWAND_1].NeuerAuftrag.wAuftrag := eStation_RackSuche;
    AuftragsSpeicherWand[tMmi2SpsInfo.wShuttleNummerFWSuche, cWAND_1](bpNeuerAuftrag := TRUE);
  ELSE
    IF ( AuftragsdatenWand[tMmi2SpsInfo.wShuttleNummerFWSuche, cWAND_1].wAuftrag = eStation_RackSuche ) THEN
      AuftragsdatenWand[tMmi2SpsInfo.wShuttleNummerFWSuche, cWAND_1].wAuftrag := eStation_Kein_Auftrag;
    END_IF
  END_IF

END_IF

(***************************************************************************************************)
(* SHUTTLE DEAKTIVIEREN VIA MMI *)
(***************************************************************************************************)
IF ( M_SB0_MMI_STATIONSTATUS ) THEN

  CASE tMmi2SpsInfo.wStationsNummer OF

    cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
      starrShuttleBasisParameter[tMmi2SpsInfo.wStationsNummer].stMKs.bDeaktivieren := tMmi2SpsInfo.wStationsStatusWord2.0;
      M_SB0_MMI_STATIONSTATUS := FALSE;

    cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
      starrTransfershuttleBasisParameter[tMmi2SpsInfo.wStationsNummer].stMKs.bDeaktivieren := tMmi2SpsInfo.wStationsStatusWord2.0;
      M_SB0_MMI_STATIONSTATUS := FALSE;

  END_CASE

END_IF
END_ACTION