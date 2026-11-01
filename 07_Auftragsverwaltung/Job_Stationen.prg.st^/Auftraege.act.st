(* METADATA
{
  "v3Meta": {
    "objectGuid": "798febcb-6f60-456b-b36c-821ba17e31fa"
  }
}
*)
ACTION Auftraege
//-------------------------------------------------------------------------------------------------
// AUFTRAEGE: M_SB0_MMI_SortierungInputInQueue
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Anlegetische \ Anlegewaende \ etc. mit einem Auftrag versehen
*)
IF ( M_SB0_MMI_SortierungInputInQueue ) THEN

 
  CASE tMmi2SpsInfo.wSortierungsInputInQueueStationNr OF

    cERSTE_STATION..cLETZTE_STATION:
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.rAuftragsHoehe       := tMmi2SpsInfo.rInputInQueueHoehe;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.rAuftragsLaenge      := tMmi2SpsInfo.rInputInQueueLaenge;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.rAuftragsDicke       := tMmi2SpsInfo.rInputInQueueDicke;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.bLetzteScheibe       := 1;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.wStationsNr          := tMmi2SpsInfo.wSortierungsInputInQueueStationNr;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.wTransferwand        := tMmi2SpsInfo.wSlotZielStation;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.wAnzahlScheiben      := 1; // es ist immer nur eine Scheibe anzulegen !
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.bErsteScheibe        := 1;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.bModell              := tMmi2SpsInfo.wModellStatus.0;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.rModellVersatzVorne  := tMmi2SpsInfo.rModellVersatzVorne;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.rModellVersatzHinten := tMmi2SpsInfo.rModellversatzHinten;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.wTransferstationsNr1 := tMmi2SpsInfo.wSourceTable;

      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1].NeuerAuftrag.wAuftrag := eStation_Anlegen;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputInQueueStationNr, cWAND_1](bpNeuerAuftrag:=TRUE);

      M_SB0_MMI_SortierungInputInQueue := FALSE;

  END_CASE

END_IF

//-------------------------------------------------------------------------------------------------
// AUFTRAEGE: M_SB0_MMI_SORTIERUNGCANCELQUEUEDATA
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Aktiven Auftrag eines Anlegetisches loeschen
*)
IF ( M_SB0_MMI_SORTIERUNGCANCELQUEUEDATA ) THEN

  (* Hinweis:
     - Dieser Auftrag darf nur im Automatik- Betrieb validiert \ bearbeitet werden
       => Sendet die HMI diesen Befehl z.B. im Handbetrieb würde der Merker fuer den Abbruch des Anlegeauftrags gesetzt und beim wechsel in den Automatikbetrieb
          würde der nächste Auftrag dann geloescht bzw. abgebrochen und damit verworfen.
       WICHTIG:
     - Sicherstellen das die Stationen diesem Automatikkreis auch angehoehren
  *)
  CASE tMmi2SpsInfo.wDeleteStationNr OF 

    cERSTE_STATION..cLETZTE_STATION:
      IF NOT AutomatikAktiv(tMmi2SpsInfo.wDeleteStationNr) THEN
        M_SB0_MMI_SORTIERUNGCANCELQUEUEDATA := FALSE;
      ELSE

        IF ( AuftragsdatenWand[tMmi2SpsInfo.wDeleteStationNr, cWAND_1].wAuftrag = eStation_Anlegen ) THEN
          AuftragsdatenWand[tMmi2SpsInfo.wDeleteStationNr, cWAND_1].wAuftrag := eStation_Kein_Auftrag;
          Anlegen[tMmi2SpsInfo.wDeleteStationNr, cWAND_1](bpReset:=TRUE);
        ELSIF ( AuftragsdatenWand[tMmi2SpsInfo.wDeleteStationNr, cWAND_1].wAuftrag = eStation_Hoehenmessung ) THEN
          AuftragsdatenWand[tMmi2SpsInfo.wDeleteStationNr, cWAND_1].wAuftrag := eStation_Kein_Auftrag;
          Glashoehenmessung[tMmi2SpsInfo.wDeleteStationNr, cWAND_1](bpReset:=TRUE);
        ELSIF ( AuftragsdatenWand[tMmi2SpsInfo.wDeleteStationNr, cWAND_1].wAuftrag = eStation_Messfahrt ) THEN
          AuftragsdatenWand[tMmi2SpsInfo.wDeleteStationNr, cWAND_1].wAuftrag := eStation_Kein_Auftrag;
          Glaslaengenmessung[tMmi2SpsInfo.wDeleteStationNr, cWAND_1](bpReset:=TRUE);
        ELSE
          abpAbbruchAnlegeauftrag[tMmi2SpsInfo.wDeleteStationNr] := TRUE;
        END_IF

        M_SB0_MMI_SORTIERUNGCANCELQUEUEDATA := FALSE;

      END_IF

  END_CASE

END_IF

//-------------------------------------------------------------------------------------------------
// AUFTRAG: M_SB0_MMI_SHEET_ORDER_STATION
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - -
*)
IF ( M_SB0_MMI_SHEET_ORDER_STATION ) THEN
  
  IF ( tMmi2SpsInfo.wAuftragsWand = 0 ) THEN // WORKAROUND MMI
    tMmi2SpsInfo.wAuftragsWand := 1;
  END_IF
  IF ( tMmi2SpsInfo.wTransferwand = 0 ) THEN // WORKAROUND MMI
    tMmi2SpsInfo.wTransferwand := 1;
  END_IF

  CASE tMmi2SpsInfo.wStationsNr OF

    cERSTE_STATION..cLETZTE_STATION:
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.bModell                 := FALSE;

      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.wStationsNr             := tMmi2SpsInfo.wStationsNr;          // Stationswand der Quellstation
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.wStationsWand           := tMmi2SpsInfo.wAuftragsWand;        // Stationswand der Quellstation
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.rStationsZielposition   := tMmi2SpsInfo.rStationsPosition;    // Stationsposition der Quellstation
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.rAuftragsLaenge         := tMmi2SpsInfo.rAuftragsLaenge;      // Länge der Scheibe/Batch
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.rAuftragsHoehe          := tMmi2SpsInfo.rAuftragsHoehe;       // Höhe der Scheibe/Batch
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.rAuftragsDicke          := tMmi2SpsInfo.rAuftragsDicke;       // Dicke der Scheibe/Batch
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.wErsteLetzteScheibe     := tMmi2SpsInfo.wErsteLetzteScheibe;  // Kennzeichnung Erste und Letzte Scheibe
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.wAnzahlScheiben         := tMmi2SpsInfo.wAnzahlScheiben;      // Anzahl der Scheiben
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.wTransferstationsNr1    := tMmi2SpsInfo.wTransferstationsNr1; // Stationsnummer der Zielstation 1
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.wTransferstationsNr2    := tMmi2SpsInfo.wTransferstationsNr2; // Stationsnummer der Zielstation 2
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.rTransferposition1      := tMmi2SpsInfo.rTransferposition1;   // Stationsposition der Zielstation 1
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.rTransferposition2      := tMmi2SpsInfo.rTransferposition2;   // Stationsposition der Zielstation 2
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.wTransferwand           := tMmi2SpsInfo.wTransferwand;        // Stationswand der Zielstationen
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.stAuftragsInformationen.wAuftragsInformationen  := tMmi2SpsInfo.wAuftragsTyp;         // Informationen zum Auftrag: Bit 1: Ein-Aus-Transport | Bit 2: Station entladen | Bit 3: Ziel FW | Bit 4-7: Wand entladen | etc.

      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.rModellVersatzVorne     := tMmi2SpsInfo.rModellVersatzVorne;
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.rModellVersatzHinten    := tMmi2SpsInfo.rModellversatzHinten;
    
      IF ((tMmi2SpsInfo.rModellVersatzVorne > 0) OR (tMmi2SpsInfo.rModellVersatzHinten > 0 ) ) THEN
        AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.bModell              := TRUE;
      END_IF

      (* Hinweis:
         - Zuweisung der Bits "erste" und "letzte" Scheibe
      *)
 
      ErsteUndLetzteScheibeBits( wpErsteUndLetzteScheibe:= tMmi2SpsInfo.wErsteLetzteScheibe ,
                                 wpLetzteScheibe => wlLetzteScheibe,
                                 wpErsteScheibe  => wlErsteScheibe );

      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.bLetzteScheibe  := wlLetzteScheibe > 0;  // Stationsposition der Zielstation 2
      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.bErsteScheibe   := wlErsteScheibe  > 0;  // Stationswand der Zielstationen

      IF ( tMmi2SpsInfo.wAuftragsTyp.0 ) THEN
        AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.wAuftrag := eStation_Austransport;
      ELSE
        AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand].NeuerAuftrag.wAuftrag := eStation_Eintransport;
      END_IF

      AuftragsSpeicherWand[tMmi2SpsInfo.wStationsNr, tMmi2SpsInfo.wAuftragsWand]( bpNeuerAuftrag := TRUE );


      M_SB0_MMI_SHEET_ORDER_STATION := FALSE;

    cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_EINLAUF:
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wStationsNr            := tMmi2SpsInfo.wStationsNr;          // Stationswand der Quellstation
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wStationsWand          := tMmi2SpsInfo.wAuftragsWand;        // Stationswand der Quellstation
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rStationsZielposition  := tMmi2SpsInfo.rStationsPosition;    // Stationsposition der Quellstation
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rAuftragsLaenge        := tMmi2SpsInfo.rAuftragsLaenge;      // Länge der Scheibe/Batch
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rAuftragsHoehe         := tMmi2SpsInfo.rAuftragsHoehe;       // Höhe der Scheibe/Batch
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rAuftragsDicke         := tMmi2SpsInfo.rAuftragsDicke;       // Dicke der Scheibe/Batch
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wErsteLetzteScheibe    := tMmi2SpsInfo.wErsteLetzteScheibe;  // Kennzeichnung Erste und Letzte Scheibe
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wAnzahlScheiben        := tMmi2SpsInfo.wAnzahlScheiben;      // Anzahl der Scheiben
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wTransferstationsNr1   := tMmi2SpsInfo.wTransferstationsNr1; // Stationsnummer der Zielstation 1
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wTransferstationsNr2   := tMmi2SpsInfo.wTransferstationsNr2; // Stationsnummer der Zielstation 2
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rTransferposition1     := tMmi2SpsInfo.rTransferposition1;   // Stationsposition der Zielstation 1
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rTransferposition2     := tMmi2SpsInfo.rTransferposition2;   // Stationsposition der Zielstation 2
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wTransferwand          := tMmi2SpsInfo.wTransferwand;        // Stationswand der Zielstationen
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.stAuftragsInformationen.wAuftragsInformationen := tMmi2SpsInfo.wAuftragsTyp;         // Informationen zum Auftrag: Bit 1: Ein-Aus-Transport | Bit 2: Station entladen | Bit 3: Ziel FW | Bit 4-7: Wand entladen | etc.


      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rModellVersatzVorne  := tMmi2SpsInfo.rModellVersatzVorne;
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.rModellVersatzHinten := tMmi2SpsInfo.rModellversatzHinten;

      IF ((tMmi2SpsInfo.rModellVersatzVorne > 0) OR (tMmi2SpsInfo.rModellVersatzHinten > 0 ) ) THEN
        Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.bModell              := TRUE;
      END_IF

      (* Hinweis:
         - Zuweisung der Bits "erste" und "letzte" Scheibe
      *)
      ErsteUndLetzteScheibeBits( wpErsteUndLetzteScheibe:= tMmi2SpsInfo.wErsteLetzteScheibe ,
                                 wpLetzteScheibe => wlLetzteScheibe,
                                 wpErsteScheibe  => wlErsteScheibe );

      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.bLetzteScheibe  := wlLetzteScheibe > 0;  // Stationsposition der Zielstation 2
      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.bErsteScheibe   := wlErsteScheibe  > 0;  // Stationswand der Zielstationen

      IF ( tMmi2SpsInfo.wAuftragsTyp.0 ) THEN
        Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wAuftrag := eStation_Austransport;
      ELSE
        Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr].NeuerAuftrag.wAuftrag := eStation_Eintransport;
      END_IF

      Job_Fremdanlage.AuftragsSpeicherFremdanlage[tMmi2SpsInfo.wStationsNr]( bpNeuerAuftrag := TRUE );
 
      M_SB0_MMI_SHEET_ORDER_STATION := FALSE;

    ELSE

      M_SB0_MMI_SHEET_ORDER_STATION := FALSE;
    
      wpgFehlerdaten[0] := tMmi2SpsInfo.wStationsNr;
      wpgFehlerdaten[1] := tMmi2SpsInfo.wAuftragsWand;
      SpsError( eFehler_Station,
                cMELDUNG_AUFTRAGSDATEN_UNGUELTIGE_STATION,
                tMmi2SpsInfo.wStationsNr,
                AutomatikkreisBestimmen(tMmi2SpsInfo.wStationsNr),
                wpgFehlerdaten );

  END_CASE

END_IF

//-------------------------------------------------------------------------------------------------
// AUFTRAG: M_SB0_MMI_MEASSURERESULT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Scheibeneinlauffreigabe für Anlegetisch
     => Gilt fuer Stationen mit einem Scanner
*)
IF ( M_SB0_MMI_MEASSURERESULT ) THEN

  M_SB0_MMI_MEASSURERESULT := FALSE;

  CASE (tMmi2SpsInfo.wMmiNummerAnlegeStation) OF

    cERSTE_STATION..cLETZTE_STATION:
      ;
    //Anlegewand202.bpFreigabeScheibe      := (tMmi2SpsInfo.wFreigabe = 1);
    //Anlegewand202.bpKeineFreigabeScheibe := (tMmi2SpsInfo.wFreigabe = 0);

    ELSE
      wpgFehlerdaten[0]:= tMmi2SpsInfo.wMmiNummerAnlegeStation;
      wpgFehlerdaten[1]:= tMmi2SpsInfo.wFreigabeStation;
      SpsError( eFehler_Station,
                cMELDUNG_SCANNER_NACHRICHT_FALSCHE_STATION,
                tMmi2SpsInfo.wMmiNummerAnlegeStation,
                AutomatikkreisBestimmen(tMmi2SpsInfo.wMmiNummerAnlegeStation),
                wpgFehlerdaten );
 
  END_CASE

END_IF

//-------------------------------------------------------------------------------------------------
// AUFTRAG: M_SB0_MMI_STATIONSTATUS
//-------------------------------------------------------------------------------------------------
IF ( M_SB0_MMI_STATIONSTATUS ) THEN

  M_SB0_MMI_STATIONSTATUS := FALSE;

  CASE tMmi2SpsInfo.wStationsNummer OF

    // -------------------------------------------------------------------
    cERSTE_STATION..cLETZTE_STATION:
      (* Hinweis:
         - Aktivieren / Deaktivieren der Station
      *)
      starrStationBasisParameter[tMmi2SpsInfo.wStationsNummer].stMKs.bDeaktivieren := ( NOT tMmi2SpsInfo.wStationsStatusWord7.0 );


    // -------------------------------------------------------------------
    cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
      (* Hinweis:
         - Aktivieren / Deaktivieren der Station
      *)
      starrShuttleBasisParameter[tMmi2SpsInfo.wStationsNummer].stMKs.bDeaktivieren := ( NOT tMmi2SpsInfo.wStationsStatusWord7.0 );


    // -------------------------------------------------------------------
    cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
      (* Hinweis:
         - Aktivieren / Deaktivieren der Station
      *)
      starrTransfershuttleBasisParameter[tMmi2SpsInfo.wStationsNummer].stMKs.bDeaktivieren := ( NOT tMmi2SpsInfo.wStationsStatusWord7.0 );


    // -------------------------------------------------------------------
    cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR:
      (* Hinweis:
         - Aktivieren / Deaktivieren der Station
      *)
      starrFaecherwagenBasisParameter[tMmi2SpsInfo.wStationsNummer].stMKs.bDeaktivieren := ( NOT tMmi2SpsInfo.wStationsStatusWord7.0 );
      aFaecherwagenstation[tMmi2SpsInfo.wStationsNummer].wlRFID_Nummer_Schreiben := tMmi2SpsInfo.wStationsStatusWord8;


    // -------------------------------------------------------------------
    ELSE
      wpgFehlerdaten[0] := tMmi2SpsInfo.wStationsNummer;
      wpgFehlerdaten[1] := tMmi2SpsInfo.wStationsStatusWord5;
      SpsHinweis( eFehler_Mmi,
                  cMELDUNG_MMI_AUFTRAGSDATEN_UNGUELTIGE_STATIONSNUMMER,
                  0,
                  AutomatikkreisBestimmen(0),
                  wpgFehlerdaten );

  END_CASE

END_IF

//-------------------------------------------------------------------------------------------------
// AUFTRAG: M_SB0_MMI_REQUESTTILTSTATION
//-------------------------------------------------------------------------------------------------

(* Hinweis:
   - Auftrag zum leeren einer Station (Starten eines Austransports)
*)
IF ( M_SB0_MMI_REQUESTTILTSTATION ) THEN

  CASE tMmi2SpsInfo.wSortierungsInputSwingStationNr OF

    cERSTE_STATION..cLETZTE_STATION:
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputSwingStationNr, cWAND_1].NeuerAuftrag.wAuftrag      := eStation_Vortransport;
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputSwingStationNr, cWAND_1].NeuerAuftrag.wStationsNr   := tMmi2SpsInfo.wSortierungsInputSwingStationNr; 
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputSwingStationNr, cWAND_1].NeuerAuftrag.wStationsWand := cWAND_1; 
      AuftragsSpeicherWand[tMmi2SpsInfo.wSortierungsInputSwingStationNr, cWAND_1]( bpNeuerAuftrag := TRUE );

    ELSE
      wpgFehlerdaten[0] := tMmi2SpsInfo.wSortierungsInputSwingStationNr;
      SpsHinweis( eFehler_Mmi,
                  cMELDUNG_MMI_AUFTRAGSDATEN_UNGUELTIGE_STATIONSNUMMER,
                  0,
                  AutomatikkreisBestimmen(0),
                  wpgFehlerdaten );

  END_CASE

  M_SB0_MMI_REQUESTTILTSTATION := FALSE;

END_IF
END_ACTION