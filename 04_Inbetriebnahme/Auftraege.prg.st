(* METADATA
{
	"v3Meta": {
		"objectGuid": "a6c9830e-3a54-4ecc-9aab-6fa636712e84"
	}
}
*)
PROGRAM Auftraege

VAR_INPUT

  (* BOOLEAN *)
  bgInbetriebnahmeAblaeufe                   : BOOL;
  bgInbetriebnahmeAnlegeAuftrag              : BOOL;
  bgInbetriebnahmeStationsauftrag            : BOOL;
  bgInbetriebnahmeShuttelAuftrag             : BOOL;
  bgInbetriebnahmeShuttelverfahrAuftrag      : BOOL;
  bgButtonVortransportTransfershuttleAuftrag : BOOL; 
  bgButtonAnlegeAuftrag                      : BOOL;
  bgButtonStationsAuftrag                    : BOOL;
  bgAuftragGenerieren                        : BOOL;
  
  bgStartAufgekippt                          : BOOL;
  bgEndeAufgekippt                           : BOOL;

  (* Hinweis:
     - Station- Auftraege
  *)
  wlInbetriebnahmeStationsnummer                    : WORD;
  rlInbetriebnahmeStation_SollPosition              : REAL :=REAL#0;
  wlInbetriebnahmeAuftragstyp                       : WORD := 0;
  rlInbetriebnahmeScheibenlaenge                    : REAL;
  rlInbetriebnahmeScheibenhoehe                     : REAL;
  rlInbetriebnahmeScheibenversatzhinten1            : REAL;
  rlInbetriebnahmeScheibenversatzvorne1             : REAL;
  wlInbetriebnahmeQuellwand                         : WORD := 1;
  wlInbetriebnahmeScheibenanzahlWand1               : WORD := 1;
  wlInbetriebnahme_Glasdicke                        : WORD := 5;
  wlModelstatus                                     : WORD;
  wlInbetriebnahmeStation_TransferStation_1         : WORD :=WORD#0;
  wlInbetriebnahmeStation_TransferStation_2         : WORD :=WORD#0;
  rlInbetriebnahmeStation_TransferStationPosition_1 : REAL :=REAL#0;
  rlInbetriebnahmeStation_TransferStationPosition_2 : REAL :=REAL#0;
  wlTransferwand                                    : WORD;
 

  bgInbetriebnahmeShuttleEintransportAuftrag   : BOOL;
  bgInbetriebnahmeShuttleAustransportAuftrag   : BOOL;
  bgInbetriebnahmeShuttleDurchtransportAuftrag : BOOL;

  (* Hinweis:
     - Shuttle- Auftraege
  *)
  wlInbetriebnahmeShuttlenummer                     : WORD;
  rlInbetriebnahmeShuttleposition                   : REAL;
  wlInbetriebnahmeShuttle_Scheibenanzahl            : WORD := 1;
  rlInbetriebnahmeShuttleStationsWand               : WORD := 1;
  wlInbetriebnahmeShuttle_TransferWand              : WORD := 1;
  wlInbetriebnahmeShuttle_Transferstation_1         : WORD := 0;
  wlInbetriebnahmeShuttle_Transferstation_2         : WORD := 0;
  rlInbetriebnahmeShuttle_TransferStationPosition_1 : REAL :=REAL#0;
  rlInbetriebnahmeShuttle_TransferStationPosition_2 : REAL :=REAL#0;
  wlInbetriebnahmeShuttle_Glasdicke                 : WORD := 4;
  rlInbetriebnahmeShuttleZeit                       : REAL := 500;


  (* Hinweis:
     - TS- Auftraege
  *)
  wlVortransportNummer_TS1                          : WORD := 0;
  wlVortransportNummer_TS2                          : WORD := 0;
  rlVortransportStrecke                             : REAL := 0;
  rlVortransportSollPosition_TS1                    : REAL := 0;
  rlVortransportSollPosition_TS2                    : REAL := 0;


  (* Hinweis
     - Buttons \ Textfields Quittierung 
  *)
  wgGlasSender,
  wgGlasEmpfaenger,
  wgTransferWandGlasSenser,
  wgQuittungAuftragstyp,
  wgTransferWandGlasEmpfaenger : WORD;
  bgNachrichtQuitturungGenerieren : BOOL;

  (* Hinweis:
     - Buttons Stationen
  *)
  arrbpButtonStationsAuswahl     : ARRAY [201..230] OF BOOL;
  arrbpButtonFremdanlageAuswahl  : ARRAY [401..420] OF BOOL;
  bgButtonLetzteScheibeWand1     : BOOL;
  bgButtonErsteScheibeWand1      : BOOL;
  bgButtonStationLeer            : BOOL;


  (* Hinweis:
     - Buttons Shuttle
  *)
  bgShuttleVerfahren           : BOOL;
  bgButtonShuttleAuftragSetzen : BOOL;
  bgButtonSenderWandEntladen   : BOOL;

  bgShuttleAuswahl_101 : BOOL;
  bgShuttleAuswahl_102 : BOOL;
  bgShuttleAuswahl_103 : BOOL;
  bgShuttleAuswahl_104 : BOOL;
  bgShuttleAuswahl_105 : BOOL;
  bgShuttleAuswahl_106 : BOOL;
  bgShuttleAuswahl_150 : BOOL;
  bgShuttleAuswahl_151 : BOOL;
  bgShuttleAuswahl_152 : BOOL;
  bgShuttleAuswahl_153 : BOOL;
  bgShuttleAuswahl_154 : BOOL;
  bgShuttleAuswahl_155 : BOOL;
  bgShuttleAuswahl_156 : BOOL;
  bgShuttleAuswahl_157 : BOOL;
  bgShuttleAuswahl_158 : BOOL;

END_VAR
(***************************************************************************************************)
(* AKTION: INBETRIEBNAHME *)
(***************************************************************************************************)
IF ( bgInbetriebnahmeAblaeufe ) THEN


  (* ---------------------------------------------------------------------------------------
  //  AKTION QUITTIERUNG VON SCHEIBEN
  //         
  //  Hinweis:
  // - Generieren einer Scheiben-Quittierung 
  // ---------------------------------------------------------------------------------------*)
  Quittierung_Stationen();

  (* ---------------------------------------------------------------------------------------
  //  AKTION STATIONSAUFTRAEGE
  //         
  //  Hinweis:
  // - Generieren von Auftraegen fuer die Stationen
  // ---------------------------------------------------------------------------------------*)
  Auftraege_Stationen_Generieren();


  (* ---------------------------------------------------------------------------------------
  //  AKTION SHUTTLESAUFTRAEGE
  //         
  //  Hinweis:
  // - Generieren von Auftraegen fuer die Shuttle
  // ---------------------------------------------------------------------------------------*)
  Auftraege_Shuttle_Generieren();



  (* ---------------------------------------------------------------------------------------
  //  ANLEGE AUFTRAG
  //         
  //  Hinweis:
  // - Anlegeauftrag => M_SB0_MMI_SortierungInputInQueue
  // ---------------------------------------------------------------------------------------*)
  IF ( bgInbetriebnahmeAnlegeAuftrag )  THEN

    bgInbetriebnahmeAnlegeAuftrag := FALSE;

    tMmi2SpsInfo.wSortierungsInputInQueueStationNr := wlInbetriebnahmeStationsnummer;
    tMmi2SpsInfo.rInputInQueueHoehe                := rlInbetriebnahmeScheibenhoehe;
    tMmi2SpsInfo.rInputInQueueLaenge               := rlInbetriebnahmeScheibenlaenge;
    tMmi2SpsInfo.rInputInQueueDicke                := 4;
    tMmi2SpsInfo.wSortierungInQueueSheetOut        := 0;
    tMmi2SpsInfo.wInsertInputShuttleDataCoatedSide := 0;
    tMmi2SpsInfo.wModellStatus                     := wlModelstatus;
    tMmi2SpsInfo.rModellVersatzVorne               := rlInbetriebnahmeScheibenversatzvorne1;
    tMmi2SpsInfo.rModellversatzHinten              := rlInbetriebnahmeScheibenversatzhinten1;
    tMmi2SpsInfo.wErsteLetzteScheibe.0             := bgButtonErsteScheibeWand1;
    tMmi2SpsInfo.wErsteLetzteScheibe.1             := bgButtonLetzteScheibeWand1;

    M_SB0_MMI_SortierungInputInQueue := TRUE;

  END_IF



  (* ---------------------------------------------------------------------------------------
  //  STATIONS AUFTRAG
  //         
  //  Hinweis:
  // - n/c
  // ---------------------------------------------------------------------------------------*)

  IF ( bgInbetriebnahmeStationsauftrag ) THEN

    bgInbetriebnahmeStationsauftrag := FALSE;

    (* Variable
       - Abnullen
    *)
    tMmi2SpsInfo.wErsteLetzteScheibe := WORD#0;

    tMmi2SpsInfo.wStationsNr           := wlInbetriebnahmeStationsnummer;
    tMmi2SpsInfo.rStationsPosition     := rlInbetriebnahmeStation_SollPosition;
    tMmi2SpsInfo.rAuftragsLaenge       := rlInbetriebnahmeScheibenlaenge;
    tMmi2SpsInfo.rAuftragsHoehe        := rlInbetriebnahmeScheibenhoehe;
    tMmi2SpsInfo.rAuftragsDicke        := WORD_TO_REAL(wlInbetriebnahme_Glasdicke);
    tMmi2SpsInfo.rModellVersatzVorne   := rlInbetriebnahmeScheibenversatzvorne1;
    tMmi2SpsInfo.rModellversatzHinten  := rlInbetriebnahmeScheibenversatzhinten1;
    tMmi2SpsInfo.wErsteLetzteScheibe.8 := bgButtonErsteScheibeWand1;
    tMmi2SpsInfo.wErsteLetzteScheibe.0 := bgButtonLetzteScheibeWand1;
    tMmi2SpsInfo.wAuftragsWand         := wlInbetriebnahmeQuellwand;
    tMmi2SpsInfo.wAnzahlScheiben       := wlInbetriebnahmeScheibenanzahlWand1;
    tMmi2SpsInfo.wAuftragsTyp          := wlInbetriebnahmeAuftragstyp;
    tMmi2SpsInfo.wTransferstationsNr1  := wlInbetriebnahmeStation_TransferStation_1;
    tMmi2SpsInfo.rTransferposition1    := rlInbetriebnahmeStation_TransferStationPosition_1;
    tMmi2SpsInfo.wTransferstationsNr2  := wlInbetriebnahmeStation_TransferStation_2;
    tMmi2SpsInfo.rTransferposition2    := rlInbetriebnahmeStation_TransferStationPosition_2;
    tMmi2SpsInfo.wTransferwand         := wlTransferwand;

    tMmi2SpsInfo.wAuftragsTyp.1               := bgButtonStationLeer;

    (* Hinweis:
       - Sender Wand | Ebene | etc.  entladen 
         => Bezieht sich nicht auf die ganze Station
    *)
    tMmi2SpsInfo.wAuftragsTyp.7               := bgButtonSenderWandEntladen;

    M_SB0_MMI_SHEET_ORDER_STATION := TRUE;

  END_IF


  (* ---------------------------------------------------------------------------------------
  //  SHUTTLE AUFTRAG
  //         
  //  Hinweis:
  // - n/c
  // ---------------------------------------------------------------------------------------*)
  (* Hinweis:
     - Shuttle- Verfahren
  *)
  IF (  bgInbetriebnahmeShuttelverfahrAuftrag  ) THEN

    bgInbetriebnahmeShuttelverfahrAuftrag := FALSE;

    tMmi2SpsInfo.wVorabStationsNr        := wlInbetriebnahmeShuttlenummer;
    tMmi2SpsInfo.rVorabPositionierung    := rlInbetriebnahmeShuttleposition;
    tMmi2SpsInfo.rVorabUpdateZeit        := rlInbetriebnahmeShuttleZeit;
    tMmi2SpsInfo.rVorabBeschleunigung    := 0;
    tMmi2SpsInfo.rVorabGeschwindigkeit   := 0;

    M_SB0_MMI_SHUTTLEVORABPOSITIONIERUNG := TRUE;

  END_IF


  (* Hinweis:
     - Shuttle- Verfahren
  *)
  IF ( bgInbetriebnahmeShuttelAuftrag ) THEN

    bgInbetriebnahmeShuttelAuftrag := FALSE;

    (* Variable
       - Abnullen
    *)
    tMmi2SpsInfo.wErsteLetzteScheibe := WORD#0;

    (* Hinweis:
       - Auftragsdaten schreiben
    *)
    tMmi2SpsInfo.wStationsNr           := wlInbetriebnahmeShuttlenummer;
    tMmi2SpsInfo.rStationsPosition     := rlInbetriebnahmeShuttleposition;
    tMmi2SpsInfo.rAuftragsLaenge       := rlInbetriebnahmeScheibenlaenge;
    tMmi2SpsInfo.rAuftragsHoehe        := rlInbetriebnahmeScheibenhoehe;
    tMmi2SpsInfo.rAuftragsDicke        := WORD_TO_REAL(wlInbetriebnahmeShuttle_Glasdicke);
    tMmi2SpsInfo.rModellVersatzVorne   := rlInbetriebnahmeScheibenversatzvorne1;
    tMmi2SpsInfo.rModellversatzHinten  := rlInbetriebnahmeScheibenversatzhinten1;
    tMmi2SpsInfo.wAuftragsWand         := rlInbetriebnahmeShuttleStationsWand;
    tMmi2SpsInfo.wErsteLetzteScheibe.8 := bgButtonErsteScheibeWand1;
    tMmi2SpsInfo.wErsteLetzteScheibe.0 := bgButtonLetzteScheibeWand1;
    tMmi2SpsInfo.wAnzahlScheiben       := wlInbetriebnahmeShuttle_Scheibenanzahl;
    tMmi2SpsInfo.wAuftragsTyp          := wlInbetriebnahmeAuftragstyp;
    tMmi2SpsInfo.wTransferstationsNr1  := wlInbetriebnahmeShuttle_Transferstation_1;
    tMmi2SpsInfo.wTransferstationsNr2  := wlInbetriebnahmeShuttle_Transferstation_2;
    tMmi2SpsInfo.rTransferposition1    := rlInbetriebnahmeShuttle_TransferStationPosition_1;
    tMmi2SpsInfo.rTransferposition2    := rlInbetriebnahmeShuttle_TransferStationPosition_2;
    tMmi2SpsInfo.wTransferwand         := wlInbetriebnahmeShuttle_TransferWand;
	tMmi2SpsInfo.wAuftragsTyp.9        := bgStartAufgekippt;
	tMmi2SpsInfo.wAuftragsTyp.11       := bgEndeAufgekippt;

    (* Hinweis:
       - Auftragsinformation Ein / Austransport
    *)
    IF ( bgInbetriebnahmeShuttleEintransportAuftrag ) THEN
      tMmi2SpsInfo.wAuftragsTyp.0              := FALSE ;
    ELSIF ( bgInbetriebnahmeShuttleAustransportAuftrag ) THEN
      tMmi2SpsInfo.wAuftragsTyp.0              := TRUE ;
    ELSIF ( bgInbetriebnahmeShuttleDurchtransportAuftrag ) THEN
      tMmi2SpsInfo.wAuftragsTyp.0              := FALSE ;
      tMmi2SpsInfo.wAuftragsTyp.1              := TRUE ;
    END_IF

    (* Hinweis:
       - StationEmpty ( Station komplett entladen )
    *)
    tMmi2SpsInfo.wAuftragsTyp.1               := bgButtonStationLeer;

    (* Hinweis:
       - Sender Wand | Ebene | etc.  entladen 
         => Bezieht sich nicht auf die ganze Station
    *)
    tMmi2SpsInfo.wAuftragsTyp.7               := bgButtonSenderWandEntladen;

    bgInbetriebnahmeShuttleEintransportAuftrag := FALSE;
    bgInbetriebnahmeShuttleAustransportAuftrag := FALSE;

    IF ( wlInbetriebnahmeShuttlenummer < cERSTE_STATION ) THEN
      M_SB0_MMI_SHEET_ORDER_SHUTTLE := TRUE;
    ELSE
      M_SB0_MMI_SHEET_ORDER_STATION := TRUE;
    END_IF

  END_IF

  (* Hinweis:
     - Vortransport der Scheiben im Speicher (Transfershuttle)
  *)
  IF (  bgButtonVortransportTransfershuttleAuftrag  ) THEN

    bgButtonVortransportTransfershuttleAuftrag := FALSE;

    tMmi2SpsInfo.wVortransportNummer_TS1       := wlVortransportNummer_TS1;
    tMmi2SpsInfo.rVortransportSollPosition_TS1 := rlVortransportSollPosition_TS1;
    tMmi2SpsInfo.rVortransportStrecke          := rlVortransportStrecke;
    tMmi2SpsInfo.wVortransportNummer_TS2       := wlVortransportNummer_TS2;
    tMmi2SpsInfo.rVortransportSollPosition_TS2 := rlVortransportSollPosition_TS2;

    M_SB0_MMI_SortierungInsertExtractionShuttleData := TRUE;

  END_IF


END_IF
END_PROGRAM