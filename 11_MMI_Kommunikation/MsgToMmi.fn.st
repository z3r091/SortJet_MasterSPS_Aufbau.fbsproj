(* METADATA
{
	"v3Meta": {
		"objectGuid": "db865b54-9f7d-484b-b18c-e3bd89594534"
	}
}
*)
FUNCTION MsgToMmi : BOOL
// ------ Senden von Nachrichten zum MMI ------
VAR_INPUT
  auftragsnr_w: WORD;
END_VAR
VAR
  msg_st  : SpsMessage;
  
  wlIndex : WORD;

  wlAnzahl, wlWert, wlBenoetigt : WORD;
END_VAR
CASE( auftragsnr_w ) OF

    // Aktive Handfunktionen: Stationsnummer, niedriges Word, hohes Word.
    SB0_SPS_HANDFUNKTION_STATUS,
      SB0_SPS_SHUTTLEHANDFUNKTION_STATUS:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 6;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSps2MmiStationsNummer );
    HMI_PutDWORD( pbyAddr := ADR( msg_st.awDaten[1] ), dwVal := dwSps2MmiHandfunktionenStatus );

  (* Hinweis:
     - Versionsstring
  *)
  SB0_SPS_SPSVERSION:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := INT_TO_WORD(LEN(sSpsVersion) + 1);
  // HMI_PutString( pbyAddr := ADR(msg_st.awDaten[0]), wVal := sSpsVersion);

  (* Hinweis:
     - Maschinen Statusmeldung
  *)
  SB0_SPS_SETBETRIEBSART:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 20;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := awSPS2MMIMaschineStatusWord[1] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[1] ), wVal := awSPS2MMIMaschineStatusWord[2] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[2] ), wVal := awSPS2MMIMaschineStatusWord[3] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[3] ), wVal := awSPS2MMIMaschineStatusWord[4] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[4] ), wVal := awSPS2MMIMaschineStatusWord[5] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[5] ), wVal := awSPS2MMIMaschineStatusWord[6] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[6] ), wVal := awSPS2MMIMaschineStatusWord[7] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[7] ), wVal := awSPS2MMIMaschineStatusWord[8] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[8] ), wVal := awSPS2MMIMaschineStatusWord[9] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[9] ), wVal := awSPS2MMIMaschineStatusWord[10] );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[10] ), wVal := awSPS2MMIMaschineStatusWord[11] );

  (* Hinweis:
     - Quittung des Anlegeauftrages
       => Scheibe wurde vermessen und kann ins System eingebucht werden
       WORD [1] und [2] sind reserviert für Höhe
       WORD [3] und [4] sind reserviert für Länge
  *)
  SB0_SPS_SortierungQuittInputInQueue:  // Auftrag für den Anlegetisch
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 14;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSps2MmiInputtableNummer );// Tischnummer
    HMI_PutDWORD( pbyAddr := ADR( msg_st.awDaten[6] ), dwVal := dwSps2MmiWartezeit );

  (* Hinweis:
     - -Event-State einer Station
  *)
  SBO_SPS_STATIONSEVENT:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 2;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSps2MmiStationsNummer );// Stationsnummer
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[1] ), wVal := wSPS2MMIStationEventStatus );// Station Event-Typ

    
  SB0_SPS_ErrorMSG:
    msg_st.wAuftrag := auftragsnr_w;  // Konstanten Nr. !!
    msg_st.wLaenge := 10;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSps2MmiErrorNumber );// + Parameter z.B.: Fehlernummer des Antriebes
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[1] ), wVal := wSps2MmiErrorShuttleNumber );// + Parameter z.B.: Shuttlenummer
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[2] ), wVal := wSps2MmiErrorShuttleSchritt );// + Parameter z.B.: Schrittkettenschritt
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[3] ), wVal := wSps2MmiErrorShuttlePosition4 );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[4] ), wVal := wSps2MmiErrorShuttlePosition5 );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[5] ), wVal := wSps2MmiErrorShuttlePosition6 );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[6] ), wVal := wSps2MmiErrorShuttlePosition7 );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[7] ), wVal := wSps2MmiErrorShuttlePosition8 );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[8] ), wVal := wSps2MmiErrorShuttlePosition9 );


  SB0_SPS_DEBUG_TRACE:
    msg_st.wAuftrag := auftragsnr_w;  // Konstanten Nr. !!
    msg_st.wLaenge := 9;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSps2MmiDebugLogWord1); // + Parameter z.B.: Fehlernummer des Antriebes
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[1] ), wVal := wSps2MmiDebugLogWord2); // + Parameter z.B.: Shuttlenummer
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[2] ), wVal := wSps2MmiDebugLogWord3); // + Parameter z.B.: Schrittkettenschritt
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[3] ), wVal := wSps2MmiDebugLogWord4);
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[4] ), wVal := wSps2MmiDebugLogWord5);
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[5] ), wVal := wSps2MmiDebugLogWord6);
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[6] ), wVal := wSps2MmiDebugLogWord7);
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[7] ), wVal := wSps2MmiDebugLogWord8);
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[8] ), wVal := wSps2MmiDebugLogWord9);
        
  (* Hinweis:
     - Nachricht fuer die Scheibenmessung der Stationen
  *)
  SB0_SPS_SETSHEETSONSTATION:
    // Die Wandnummer wird Bitcodiert übergeben. In der SPS wird sie aber Dezimal benötigt
    // Wand 3
    IF ( wSps2MmiMessungSlotNummer = 3) THEN
      wSps2MmiMessungSlotNummer  := 4;
    END_IF
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 3;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSps2MmiMessungStationNummer );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[1] ), wVal := wSps2MmiMessungSlotNummer );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[2] ), wVal := INT_TO_WORD(iSps2MmiMessungScheibenanzahl) );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[3] ), rVal := rSps2MmiMessungScheibenlaenge );
    
  (* Hinweis:
     - Auftragsquittierung fuer die Scheibenvorpositionierung im Speicher mit dem Transfershuttle
  *)
  SB0_SPS_SortierungQuittExtractionShuttleData: //
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 6;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSps2MmiQuittierungVortransportStationsNr1 );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[1] ), wVal := wSps2MmiQuittierungVortransportStatus );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[2] ), rVal := rgSPS2MMIExtractionShuttleGefahrenerWeg );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[4] ), wVal := wSps2MmiQuittierungVortransportStationsNr2 );

    
  SB0_SPS_SORTIERUNGQUITTUNGVONISOLINIE:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 2;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSps2MmiQuittISOLineNr );
    HMI_PutDWORD( pbyAddr := ADR( msg_st.awDaten[1] ), dwVal := dwSps2MmiWartezeit );

    
  (* Hinweis:
     - Transporstatus der Eckuebergabe/Anlegetisch [Scanner] zum MMI
  *)
  SB0_SPS_TRANSPORTSTATE:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 7;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSPS2MMITRANSPORTSTATE );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[1] ), wVal := wSPS2MMITransportstateStation );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[2] ), rVal := rSPS2MMITransportStateLenght );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[4] ), rVal := rSPS2MMITransportStateHigh );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[6] ), wVal := wSPS2MMITransportstateGap );


  SB0_SPS_SHEETONINPUTTABLE:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 4;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wSps2MmiInputtableNummer );
    HMI_PutDWORD( pbyAddr := ADR( msg_st.awDaten[1] ), dwVal := dwSps2MmiWartezeit );

  SB0_SPS_TURNSTATIONPOSITION:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 6;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wgSps2MmiDrehStation );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ), wVal  := wgSps2MmiPosDrehStation );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[2] ), wVal  := wgSps2MmiOldPosDrehStation );

    
  SB0_SPS_SYSTEMCHECKFINISHED:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 1;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wSps2MmiCheckArea );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ), wVal  := wSps2MmiCheckSuccessful );

  SB0_SPS_SETSHEETSONSHUTTLE:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 14;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wSps2MmiMeasureShuttleNummer );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ), wVal  := wSps2MmiMessungSlotNummer );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[2] ), wVal  := INT_TO_WORD(iSps2MmiMessungScheibenanzahl) );
    FOR wlIndex:=0 TO cMaxScheibenBeiScheibenMessung DO
      HMI_PutREAL(  pbyAddr := ADR( msg_st.awDaten[(2*(wlIndex)) + 3] ), rVal  := rSps2MmiMeasureResult[wlIndex] );
    END_FOR
    
    // Werte zuruecksetzen
    wSps2MmiMeasureShuttleNummer  := 0;
    wSps2MmiMessungSlotNummer     := 0;
    iSps2MmiMessungScheibenanzahl := 0;

  (* Hinweis:
     - GETTER: Anfrage des Stations- Status [z.B. Status Ein-/Aus- Transport]
  *)
  SB0_SPS_GETSTATIONSTATUS:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 2;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wSps2MmiStationsNummer );
    

  SB0_SPS_SHUTTLEVORABPOSITIONIERUNGUPDATE:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 4;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wSps2MmiQuittVorabShuttleNr );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[1] ), rVal := rgSPS2MMIExtractionShuttlePosition );

  SB0_SPS_QUITTSHUTTLEVORABPOSITIONIERUNG:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 4;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := wSps2MmiQuittVorabShuttleNr );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[1] ), rVal := rgSPS2MMIExtractionShuttlePosition );


  SB0_SPS_SORTIERUNGSHUTTLEPOS:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 30;
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[0] ),  rVal := rSps2MmiShuttlePosition[0] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[2] ),  rVal := rSps2MmiShuttlePosition[1] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[4] ),  rVal := rSps2MmiShuttlePosition[2] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[6] ),  rVal := rSps2MmiShuttlePosition[3] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[8] ),  rVal := rSps2MmiShuttlePosition[4] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[10] ), rVal := rSps2MmiShuttlePosition[5] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[12] ), rVal := rSps2MmiShuttlePosition[6] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[14] ), rVal := rSps2MmiShuttlePosition[7] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[16] ), rVal := rSps2MmiShuttlePosition[8] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[18] ), rVal := rSps2MmiShuttlePosition[9] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[20] ), rVal := rSps2MmiShuttlePosition[10] );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[22] ), rVal := rSps2MmiShuttlePosition[11] );

  SB0_SPS_SHUTTLEVORABPOSITIONIERUNGABBRUCH:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 4;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wgSps2MmiShuttleNr );
    HMI_PutREAL( pbyAddr := ADR( msg_st.awDaten[1] ),  rVal := rSps2MmiPosition );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[3] ), wVal  := wSps2ShuttleStopped[wgSps2MmiShuttleNr] );
    
    SB0_SPS_TRANSFERSHUTTLEBUFFERSLOTPOS,
      SB0_SPS_LIFTEDTRANSFERSHUTTLEPOSITION:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 6;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wgSps2MmiShuttleNr );
    HMI_PutREAL(  pbyAddr := ADR( msg_st.awDaten[1] ), rVal  := wSps2MmiValidierungsPosition );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[3] ), wVal  := wSps2MmiValidierungsSpeicher );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[4] ), wVal  := wSps2MmiValidierungsFach );
    
    
  SB0_SPS_SHUTTLEVORABPOSITIONIERUNGREADY:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 3;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wSps2MmiStationsNummer );
    HMI_PutREAL(  pbyAddr := ADR( msg_st.awDaten[1] ), rVal  := rSps2MmiPosition );
    
    argZuletztQuittiertePositionShuttle[wSps2MmiStationsNummer] := rSps2MmiPosition;
    
    
  SB0_SPS_TRANSFERSHUTTLEFEHLER:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 6;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wgSps2MmiShuttleNr );
    HMI_PutREAL(  pbyAddr := ADR( msg_st.awDaten[1] ), rVal  := rgSPS2MMIExtractionShuttlePosition );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[3] ), wVal  := wSps2MmiFehlertyp );


  SB0_SPS_TRANSFERSHUTTLECHECK_ABGESCHLOSSEN:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 6;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ), wVal  := wgSps2MmiShuttleNr );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ), wVal  := wSps2MmiValidierungsStatus );
    

  SB0_SPS_FACHAUFNAHMEDATEN:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 4;
    HMI_PutREAL(  pbyAddr := ADR( msg_st.awDaten[1] ), rVal  := rSPS2MMIFachaufnahmePosition );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[3] ), wVal  := wSPS2MMIFachaufnahmeAnalogwert );
    
    
  (* Hinweis:
     - Neue Nachricht zum quittieren von Aufträgen
  *)
  SB0_SPS_QUIT_SHEET_ORDER:
    msg_st.wAuftrag   := auftragsnr_w;
    msg_st.wLaenge    := 4;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2MmiZielStation );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ),  wVal  := wSps2MmiQuellStation );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[2] ),  wVal  := wSps2MmiZielWand );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[3] ),  wVal  := wSps2MmiQuellWand );
    HMI_PutDWORD( pbyAddr := ADR( msg_st.awDaten[4] ), dwVal  := dwSps2MmiWartezeit );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[6] ),  wVal  := wSPS2MMIAuftragstyp );


  SB0_SPS_SCHNITTSTELLENDATENFREMDANLAGE:
    msg_st.wAuftrag    := auftragsnr_w;
    msg_st.wLaenge     := 4;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2Mmi_SationsNummer );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ),  wVal  := wSps2Mmi_NachrichtenIndex );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[2] ),  wVal  := wSps2Mmi_NachrichtenAnzahl );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[3] ),  wVal  := wSps2Mmi_AnzahlScheiben );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[4] ),  dwVal  := adwSps2Mmi_Daten_1[0] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[6] ),  dwVal  := adwSps2Mmi_Daten_1[1] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[8] ),  dwVal  := adwSps2Mmi_Daten_1[2] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[10] ),  dwVal  := adwSps2Mmi_Daten_1[3] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[12] ),  dwVal  := adwSps2Mmi_Daten_2[0] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[14] ),  dwVal  := adwSps2Mmi_Daten_2[1] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[16] ),  dwVal  := adwSps2Mmi_Daten_2[2] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[18] ),  dwVal  := adwSps2Mmi_Daten_2[3] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[20] ),  dwVal  := adwSps2Mmi_Daten_3[0] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[22] ),  dwVal  := adwSps2Mmi_Daten_3[1] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[24] ),  dwVal  := adwSps2Mmi_Daten_3[2] );
    HMI_PutDWORD(  pbyAddr := ADR( msg_st.awDaten[26] ),  dwVal  := adwSps2Mmi_Daten_3[3] );

    
  (* Hinweis:
     - Ausmessen von FW
  *)
  SB0_SPS_POSITIONMEASUREDATA:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 5;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2MmiStationsNummer );
    HMI_PutREAL(  pbyAddr := ADR( msg_st.awDaten[1] ),  rVal  := rSps2MmiPosition );
   
 
    
  SB0_SPS_STATIONSTATUS:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 2;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2MmiStationsNummer );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ),  wVal  := wSPS2MMIStationsStatusWord1 );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[2] ),  wVal  := wSPS2MMIStationsStatusWord2 );


  SB0_SPS_SHEETREMOVEDAPPROVALWALL:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 3;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2MmiStationsNummer );

  SB0_SPS_WATCHDOGTEST:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 3;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2MmiWatchDogTestCount );

    
  // ++++++++++++++++++++++++ Fächerwagenstationen ++++++++++++++++++++++++++++++++++++
  (* Hinweis [FAECHERWAGEN]:
     - Faecherwagenwechsel von Station A nach B erfolgreich
  *)
  SB0_SPS_RACKONLOADINGSTATION:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 3;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2MmiRackPositionNummer );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ),  wVal  := wSps2MmiRackPosition );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[2] ),  wVal  := wSps2MmiRackNumber );


  (* Hinweis [FAECHERWAGEN]:
     - Anforderung zum einbuchen des Faecherwagens
        => Status: 1 = FW auf Station 1 / 2 = FW auf Station 2 / etc.
  *)
  SB0_SPS_RACKLOGIN:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 2;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2FaecherwagenStationNr );

    
  SB0_SPS_SortierungRackinPos: // Fächerwagenwechsel von Station A nach B erfolgreich
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 2;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2FaecherwagenStart );// Wo kommt der Wagen her
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ),  wVal  := wSps2FaecherwagenStart );// Wo geht der Wagen hin

  (* Hinweis:
     - [FAECHERWAGENSTATION] Gibt den Status der Faecherwagenstation zurueck
       => 0 = wird nicht benutzt
       => 1 = frei
       => 2 = belegt
       Wichtig:
       => Groesse des Arrays <awSps2MmmiStatusFaecherwagenstation> beachten ggf. den Index vergroessern
       => <igIndexFaecherwagenDatenSenden> Aufgrund des Datenwortes das bei "0" startet [Index]
  *)
   
  (* Hinweis [FAECHERWAGEN]:
     - Anforderung zum einbuchen des Faecherwagens
        => Status: 1 = FW auf Station 1 / 2 = FW auf Station 2 / etc.
  *)
  SB0_SPS_RACKPOSITION:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 4;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2MmiRackPositionNummer );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ),  wVal  := wSps2MmiRackPosition );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[2] ),  wVal  := wSps2MmiRackNumber );


  SB0_SPS_SETSTATUSLOADINGSTATIONS:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 10;

    igIndexFaecherwagenDatenSenden := 0;

    FOR wlIndex := 0 TO 29 DO
      HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[igIndexFaecherwagenDatenSenden] ),  wVal  := awSps2MmiStatusFaecherwagenstationen[igIndexFaecherwagenDatenSenden] );
      igIndexFaecherwagenDatenSenden := igIndexFaecherwagenDatenSenden + 1;
    END_FOR
    
    
  SB0_SPS_SORTIERUNGRACKSTATIONSTATUS:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 4;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wSps2MmiRackNumber );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ),  wVal  := wSps2MmiRackStatus );// 1 Wagen wird ausgeschleust, 2 Wagen wird Notausgeschleust
    
  //  - Anfrage vom MMI nach dem Status einer EINZELNEN Fächerwagenstation => belegt, Muting OK, RFID-Nr.
  SB0_SPS_STATUSRACKSTATION:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 6;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := INT_TO_WORD(igRackStationNumber) );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ),  wVal  := wgRackPresent );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[2] ),  wVal  := INT_TO_WORD(igRackNumber) );


  (* Hinweis:
     - Antwort auf das Ein- und Ausfahren der Puffer
  *)
  SB0_SPS_PUFFERSTATUS:
    msg_st.wAuftrag := auftragsnr_w;
    msg_st.wLaenge := 6;
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[0] ),  wVal  := wgStatusPuffer101Oben );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[1] ),  wVal  := wgStatusPuffer102Unten );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[2] ),  wVal  := wgStatusPuffer103Oben );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[3] ),  wVal  := wgStatusPuffer104Unten );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[4] ),  wVal  := wgStatusTorOben );
    HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[5] ),  wVal  := wgStatusTorUnten );


  (* Hinweis:
     - Generisches Stations-Update: [0] Station, [1] Updatetyp, [2] Anzahl Werte, danach je Wert: Datentyp + Wert
  *)
  SB0_SPS_STATION_UPDATE:
    msg_st.wAuftrag := auftragsnr_w;
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[0] ), wVal := stStationUpdate.wStationsNummer );
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[1] ), wVal := TO_WORD( stStationUpdate.eUpdateTyp ) );
    wlIndex  := 3;
    wlAnzahl := 0;
    FOR wlWert := 1 TO MIN( stStationUpdate.wAnzahlWerte, 13 ) DO
      // Platzbedarf in Words inkl. Datentyp-Word
      CASE stStationUpdate.astWerte[wlWert].eDatenTyp OF
        UpdateDatenTyp_EN.TYP_WORD, UpdateDatenTyp_EN.TYP_BOOL: wlBenoetigt := 2;
        UpdateDatenTyp_EN.TYP_DWORD, UpdateDatenTyp_EN.TYP_REAL: wlBenoetigt := 3;
        ELSE
          wlBenoetigt := 0;
      END_CASE
      IF ( wlBenoetigt = 0 ) OR ( wlIndex + wlBenoetigt > 30 ) THEN
        EXIT;
      END_IF

      HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[wlIndex] ), wVal := TO_WORD( stStationUpdate.astWerte[wlWert].eDatenTyp ) );
      CASE stStationUpdate.astWerte[wlWert].eDatenTyp OF
        UpdateDatenTyp_EN.TYP_WORD:  HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[wlIndex + 1] ), wVal  := stStationUpdate.astWerte[wlWert].wWert );
        UpdateDatenTyp_EN.TYP_DWORD: HMI_PutDWORD( pbyAddr := ADR( msg_st.awDaten[wlIndex + 1] ), dwVal := stStationUpdate.astWerte[wlWert].dwWert );
        UpdateDatenTyp_EN.TYP_REAL:  HMI_PutREAL(  pbyAddr := ADR( msg_st.awDaten[wlIndex + 1] ), rVal  := stStationUpdate.astWerte[wlWert].rWert );
        UpdateDatenTyp_EN.TYP_BOOL:  HMI_PutWORD(  pbyAddr := ADR( msg_st.awDaten[wlIndex + 1] ), wVal  := SEL( stStationUpdate.astWerte[wlWert].bWert, 0, 1 ) );
      END_CASE
      wlIndex  := wlIndex + wlBenoetigt;
      wlAnzahl := wlAnzahl + 1;
    END_FOR
    HMI_PutWORD( pbyAddr := ADR( msg_st.awDaten[2] ), wVal := wlAnzahl ); // tatsaechlich gesendete Werte
    msg_st.wLaenge := wlIndex * 2;                                        // Laenge in Byte

  ELSE
    MsgToMmi := FALSE;
    RETURN;
END_CASE;

TCPMain.l_fb_SortjetHMI.PutMsg( smpSpsMessage := msg_st, bpTrig := FALSE );
MsgToMmi := TRUE;
END_FUNCTION