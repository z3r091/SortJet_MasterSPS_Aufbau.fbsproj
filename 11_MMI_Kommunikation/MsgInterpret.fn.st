(* METADATA
{
	"v3Meta": {
		"objectGuid": "c5198d31-be99-460b-8031-114f442e3133"
	}
}
*)
FUNCTION MsgInterpret : BOOL
VAR_INPUT
  tSpsMessage : SpsMessage;
END_VAR
VAR
  wlIndex : WORD;
  wlTemp  : WORD;
END_VAR


CASE( tSpsMessage.wAuftrag )OF

  // MSG 1
  // Anfrage des Maschinenstatuses
  SB0_MMI_GETBETRIEBSART:
    M_Send_MaschineStatus := TRUE;

	 
  // MSG 2
  // Auftrag für den Anlegetisch (Start_Station) 
  SB0_MMI_SortierungInputInQueue:
    tMmi2SpsInfo.wSortierungsInQueueLineNr         := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));  (*Liniennr. wo das Glas aufgelegt werden soll*)
    tMmi2SpsInfo.wSortierungsInputInQueueStationNr := HMI_GetWORD(ADR(tSpsMessage.awDaten[1])); (* Tischnummer des Anlegetisches *)
    tMmi2SpsInfo.rInputInQueueLaenge               := HMI_GetREAL(ADR(tSpsMessage.awDaten[2]));
    tMmi2SpsInfo.rInputInQueueHoehe                := HMI_GetREAL(ADR(tSpsMessage.awDaten[4]));
    tMmi2SpsInfo.rInputInQueueDicke                := HMI_GetREAL(ADR(tSpsMessage.awDaten[6]));
    tMmi2SpsInfo.wInsertInputShuttleDataCoatedSide := HMI_GetWORD(ADR(tSpsMessage.awDaten[8]));(* Coated_Side *)
    tMmi2Spsinfo.wSortierungInQueueSheetOut        := HMI_GetWORD(ADR(tSpsMessage.awDaten[9]));  (* 0=Glas für Sortjet; 1= Glas nicht für Sortjet *)

    tMmi2SpsInfo.wModellStatus         := HMI_GetWORD(ADR(tSpsMessage.awDaten[11]));
    tMmi2SpsInfo.rModellVersatzVorne   := HMI_GetREAL(ADR(tSpsMessage.awDaten[12]));
    tMmi2SpsInfo.rModellversatzHinten  := HMI_GetREAL(ADR(tSpsMessage.awDaten[14]));
    tMmi2SpsInfo.rModellVersatzVorne2  := HMI_GetREAL(ADR(tSpsMessage.awDaten[16]));
    tMmi2SpsInfo.rModellversatzHinten2 := HMI_GetREAL(ADR(tSpsMessage.awDaten[18]));
    tMmi2SpsInfo.wPrintStatus          := HMI_GetWORD(ADR(tSpsMessage.awDaten[20]));
    tMmi2SpsInfo.wSourceTable          := HMI_GetWORD(ADR(tSpsMessage.awDaten[21]));
    tMmi2SpsInfo.wSlotZielStation      := HMI_GetWORD(ADR(tSpsMessage.awDaten[22]));

    M_SB0_MMI_SortierungInputInQueue := TRUE;

	 
  // MSG 5
  // Starten des SystemCheck
  SB0_MMI_SortierungCheckInputQueue:
    tMmi2SpsInfo.wCheckArea      := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    tMmi2SpsInfo.wCheckRelease   := HMI_GetWORD(ADR(tSpsMessage.awDaten[1]));
    M_SB0_MMI_SortierungCheckInputQueue := TRUE;
    
    
  // MSG 7
  // Beliebige Station irgendeiner Linie die Daten löschen
  SB0_MMI_SORTIERUNGCANCELQUEUEDATA:   (*SB0_MMI_SortierungDelete: *)
    tMmi2SpsInfo.wDeleteStationNr   := HMI_GetWORD(ADR(tSpsMessage.awDaten[0])); (* Tischnummer des Anlegetisches *)
    tMmi2SpsInfo.wDeleteStationSlot := HMI_GetWORD(ADR(tSpsMessage.awDaten[1])); (* Wandnummer  des Anlegetisches *)
    M_SB0_MMI_SORTIERUNGCANCELQUEUEDATA := TRUE;
    
  
  // MSG 8
  // Abbruch des offenen ISO Line Events
  SB0_MMI_SORTIERUNGCANCELISOLINEEVENT:
    M_SB0_MMI_SORTIERUNGCANCELISOLINEEVENT := TRUE;
	 
    
  // MSG 9
  // Auftrag des entsprechenden Shuttles löschen 
  SB0_MMI_SortierungCancelShuttleData:
    tMmi2SpsInfo.wCancelShuttleDataShuttleNr := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    M_SB0_MMI_SortierungCancelShuttleData := TRUE;
	 
    
  // MSG 11 
  // Start Automatik Foerder Transport der Glastransportstationen
  SB0_MMI_SORTIERUNGAUTOMATIKSTART:
    tMmi2SpsInfo.wAutomatikStartTransportLineNr := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    M_SB0_MMI_SORTIERUNGAUTOMATIKSTART := TRUE;
	 

  // MSG 12
  (* Hinweis:
     - Nachricht von der Oberflaeche das ein Automatikkreis gestopt werden soll / muss
       => Index[0] Angabe welcher Automatikkreis gestoppt werden soll
       => Index[1] Angabe welche Automatikkreise schon gestoppt sind 
     - Falls schon einer der beiden Kreise gestoppt wurde, steht im 2. Datenwort eine 3.
       Wenn eine 3 vorkommt, dann diese übernehmen um beide Autokreise, inkl. den Transfershuttlen stoppen
		   *)
  SB0_MMI_SortierungAutomatik_Stop:
    tMmi2SpsInfo.wAutomatikStopArea     := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    tMmi2SpsInfo.wAutomatikStoppedAreas := HMI_GetWORD(ADR(tSpsMessage.awDaten[1]));
    M_SB0_MMI_SortierungAutomatik_Stop := TRUE;
	 

  // MSG 14
  // Vorpositionier der Scheiben im Speicher (Transfershuttle)
  SB0_MMI_SortierungInsertExtractionShuttleData:
    tMmi2SpsInfo.wVortransportNummer_TS1       := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    tMmi2SpsInfo.rVortransportSollPosition_TS1 := HMI_GetREAL(ADR(tSpsMessage.awDaten[1]));
    tMmi2SpsInfo.rVortransportStrecke          := HMI_GetREAL(ADR(tSpsMessage.awDaten[3]));
    tMmi2SpsInfo.wVortransportNummer_TS2       := HMI_GetWORD(ADR(tSpsMessage.awDaten[5]));
    tMmi2SpsInfo.rVortransportSollPosition_TS2 := HMI_GetREAL(ADR(tSpsMessage.awDaten[6]));
    tMmi2SpsInfo.wSlotThickness                := HMI_GetWORD(ADR(tSpsMessage.awDaten[8])); // 0-thin;1-thick

    M_SB0_MMI_SortierungInsertExtractionShuttleData := TRUE;
		

  // MSG 15  
  // Fächerwagenwechsel auch von verschiedenen Stationen möglich 
  SB0_MMI_SORTIERUNGFAECHERWAGENWECHSEL:
    tMmi2SpsInfo.wFaecherwagenwechsel       := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));   (* DestStation / Zielstation *)
    tMmi2SpsInfo.wSps2FaecherwagenStationNr := HMI_GetWORD(ADR(tSpsMessage.awDaten[1]));   (* SourceStation / Startstation *)
    M_SB0_MMI_SortierungFaecherwagenwechsel:=TRUE;
	 
	 
  // MSG 22
  // HANDFUNKTIONEN: Stationen
  SB0_MMI_SetHandfunktion:
    FOR wlIndex := 0 TO (tSpsMessage.wLaenge-1) BY 6 DO
      
    IF ( HMI_GetWORD(ADR(tSpsMessage.awDaten[0])) >= cERSTE_FAECHERWAGENSTATIONS_NR ) THEN
        adwgHandfunktionenFaecherwagenStationen[HMI_GetWORD(ADR(tSpsMessage.awDaten[wlIndex/2]))] := HMI_GetDWORD(ADR(tSpsMessage.awDaten[( (wlIndex)/2 )+1]));
      ELSE
        adwgHandfunktionenStationen[HMI_GetWORD(ADR(tSpsMessage.awDaten[wlIndex/2]))] := HMI_GetDWORD(ADR(tSpsMessage.awDaten[( (wlIndex)/2 )+1]));
      END_IF      
      
    END_FOR
	 
	 
  // MSG 23
  // HANDFUNKTIONEN: Shuttle
  SB0_MMI_SetShuttleHandFunktion:
    IF HMI_GetWORD(ADR(tSpsMessage.awDaten[0])) >= cERSTE_STATION THEN
      FOR wlIndex := 0 TO (tSpsMessage.wLaenge-1) BY 6 DO
        adwgHandfunktionenStationen[HMI_GetWORD(ADR(tSpsMessage.awDaten[wlIndex/2]))] := HMI_GetDWORD(ADR(tSpsMessage.awDaten[( (wlIndex)/2 )+1]));
      END_FOR
    ELSIF HMI_GetWORD(ADR(tSpsMessage.awDaten[0])) >= cERSTES_TRANSFERSHUTTLE THEN
      FOR wlIndex := 0 TO (tSpsMessage.wLaenge-1) BY 6 DO
        adwgHandfunktionenTransfershuttle[HMI_GetWORD(ADR(tSpsMessage.awDaten[wlIndex/2]))] := HMI_GetDWORD(ADR(tSpsMessage.awDaten[( (wlIndex)/2 )+1]));
      END_FOR
    ELSE
      FOR wlIndex := 0 TO (tSpsMessage.wLaenge-1) BY 6 DO
        adwgHandfunktionenShuttle[HMI_GetWORD(ADR(tSpsMessage.awDaten[wlIndex/2]))] := HMI_GetDWORD(ADR(tSpsMessage.awDaten[( (wlIndex)/2 )+1]));
      END_FOR
    END_IF
	 
	 
  // MSG 30
  // Scheibenmessung OK -> Freigabe für die Eckübergabe des Sortjets  0 = nicht OK / 1 = OK
  SB0_MMI_MEASSURERESULT:
    M_SB0_MMI_MEASSURERESULT:=TRUE;
    tMmi2SpsInfo.wFreigabe               := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));(* Freigabe *)
    tMmi2SpsInfo.wMmiNummerAnlegeStation := HMI_GetWORD(ADR(tSpsMessage.awDaten[1]));

	 
  // MSG 31
  // Unabhaengige Quittung der Sondergläser durch Tasterdruck anfordern 
  SB0_MMI_ISOQUITTUNG:
    M_SB0_MMI_ISOQUITTUNG:=TRUE;
    tMmi2SpsInfo.wISOStation    := HMI_GetWORD(ADR(tSpsMessage.awDaten[0])); (* Tischnummer des Anlegetisches *)(* Liniennummer *)
    tMmi2SpsInfo.wISOAuftragsID := HMI_GetWORD(ADR(tSpsMessage.awDaten[1]));(* Auftrags ID *)
	 
	 
  // MSG 39
  // Bestaetigung der Faecherwagenanmeldung vom MMI
  SB0_MMI_RELEASERACKLOGIN:
    M_SB0_MMI_RELEASERACKLOGIN := TRUE;
    tMmi2SpsInfo.wSps2FaecherwagenStationNr  := HMI_GetWORD(ADR(tSpsMessage.awDaten[0])); (* Stationsnummer wo der Wagen eingeschleust werden soll *)
    tMmi2SpsInfo.wlFreigabeEinschleuseJaNein := HMI_GetWORD(ADR(tSpsMessage.awDaten[1])); (* Freigabe zum Einschleusen = 1 / Freigegebenen Wagen wieder löschen = 0 *)
    

  // MSG 40
  // Anfrage vom MMI nach dem Status einer EINZELNEN Fächerwagenstation => belegt, Muting OK, RFID-Nr. 
  SB0_MMI_GETSTATUSRACKSTATION:
   M_SB0_MMI_GETSTATUSRACKSTATION := TRUE;
    tMmi2SpsInfo.wSps2FaecherwagenStationNr := HMI_GetWORD(ADR(tSpsMessage.awDaten[0])); (* Stationsnummer wo angefragt wird *)
  (* - Freigabe eines mittles AGV eingeschleusten Wagen das Tor zu öffnen *)

  // MSG 41
  SB0_MMI_DOCKRACK:
   M_SB0_MMI_DOCKRACK := TRUE;
    tMmi2SpsInfo.wSps2FaecherwagenStationNr := HMI_GetWORD(ADR(tSpsMessage.awDaten[0])); 

	 
  // MSG 43
  (* Hinweis [FAECHERWAGEN]:
     - MMI Anfrage, welche Fächerwagenstationen belegt sind 
       => <igIndexFaecherwagenDaten> wird zum Auslesen der Daten benoetigt da hier der Index bei "0" anfaengt
  *)  
  SB0_MMI_REQUESTSTATUSLOADINGSTATIONS:
    igIndexFaecherwagenDatenEmpfangen := 0;
    FOR wlIndex := cERSTE_FAECHERWAGENSTATIONS_NR TO cLETZTE_FAECHERWAGENSTATIONS_NR DO
      tMmi2SpsInfo.awAnfrageStatusDerFaecherwagenstation[wlIndex] := HMI_GetWORD(ADR(tSpsMessage.awDaten[igIndexFaecherwagenDatenEmpfangen]));
      igIndexFaecherwagenDatenEmpfangen := igIndexFaecherwagenDatenEmpfangen + 1;
    END_FOR
    M_SB0_MMI_REQUESTSTATUSLOADINGSTATIONS := bgEtherCatOK;
  
	 
  // MSG 51 
  SB0_MMI_REQUESTTILTSTATION:
    tMmi2SpsInfo.wSortierungsInputSwingStationNr := HMI_GetWORD(ADR(tSpsMessage.awDaten[0])); (*Stationsnummer *)
    M_SB0_MMI_REQUESTTILTSTATION := TRUE;
        
	 
  // MSG 53
  // Positionierung ueber die Oberflaeche [Verfahrlogik]
  SB0_MMI_SHUTTLEVORABPOSITIONIERUNG:
    tMmi2SpsInfo.wVorabStationsNr        := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    tMmi2SpsInfo.rVorabPositionierung    := HMI_GetREAL(ADR(tSpsMessage.awDaten[1]));
    tMmi2SpsInfo.rVorabUpdateZeit        := HMI_GetREAL(ADR(tSpsMessage.awDaten[3]));
    tMmi2SpsInfo.wVorabAuftragstyp       := HMI_GetWORD(ADR(tSpsMessage.awDaten[16]));
    M_SB0_MMI_SHUTTLEVORABPOSITIONIERUNG := TRUE;


  // MSG 55
  // Fachaufnahme 
  SB0_MMI_FACHAUFNAHMESTART:
    wlTemp := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));  
    AutomatischeFachaufnahme.bpStarteFachaufnahme := wlTemp.0;
    AutomatischeFachaufnahme.wpMMINummer          := HMI_GetWORD(ADR(tSpsMessage.awDaten[2]));
	 
	
  // MSG 56 
  // Shuttle Fächerwagen ausmessen
  SB0_MMI_POSITIONMEASUREONOFF:
    tMmi2SpsInfo.wShuttleNummerFWSuche := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    tMmi2SpsInfo.wShuttleFWSucheAN_AUS := HMI_GetWORD(ADR(tSpsMessage.awDaten[1]));

    M_SB0_MMI_POSITIONMEASUREONOFF := TRUE;
	 

  // MSG 67
  // STATUS: Stationen (SystemCheck) 
  SB0_MMI_STATIONSTATUS:
    tMmi2SpsInfo.wStationsNummer      := HMI_GetWORD(ADR(tSpsMessage.awDaten[0])); (* Station Nr. *)
    tMmi2SpsInfo.wStationsStatusWord1 := HMI_GetWORD(ADR(tSpsMessage.awDaten[1])); (* Manueller Modus *)
    tMmi2SpsInfo.wStationsStatusWord2 := HMI_GetWORD(ADR(tSpsMessage.awDaten[2])); (* Schleifen *)
    tMmi2SpsInfo.wStationsStatusWord3 := HMI_GetWORD(ADR(tSpsMessage.awDaten[3])); (* Modelle *)
    tMmi2SpsInfo.wStationsStatusWord4 := HMI_GetWORD(ADR(tSpsMessage.awDaten[4])); (* Ebene /Slotnummer *)
    tMmi2SpsInfo.wStationsStatusWord5 := HMI_GetWORD(ADR(tSpsMessage.awDaten[5])); (* Drehposition *)
    tMmi2SpsInfo.wStationsStatusWord6 := HMI_GetWORD(ADR(tSpsMessage.awDaten[6])); (* Blockiert *)
    tMmi2SpsInfo.wStationsStatusWord7 := HMI_GetWORD(ADR(tSpsMessage.awDaten[7])); (* 0 = inaktiv | 1 = aktiv *)

    M_SB0_MMI_STATIONSTATUS := TRUE;
	 
	 
  // MSG 68
  // DATEN FÜR DEN SYSTEMCHECK
   SB0_MMI_SYSTEMCHECKSTATION:
     M_SB0_MMI_SYSTEMCHECKSTATION := TRUE;
     tMmi2SpsInfo.wSystemCheckStationMmiNummer          := HMI_GetWORD(ADR(tSpsMessage.awDaten[0])); (* Stationsnummer *)
     tMmi2SpsInfo.wSystemCheckStationScheibenanzahl     := HMI_GetWORD(ADR(tSpsMessage.awDaten[1])); (* Scheibenanzahl [Gibt an wieviele Scheiben auf der Station sind] *)
     tMmi2SpsInfo.wSystemCheckStationZielstation        := HMI_GetWORD(ADR(tSpsMessage.awDaten[2])); (* Zielstation (lt. MMI) *)
     tMmi2SpsInfo.wSystemCheckStationLetzteScheibe      := HMI_GetWORD(ADR(tSpsMessage.awDaten[3])); (* Die Station ist bei gesetztem Bit- voll beladen *)
     tMmi2SpsInfo.wSystemCheckStationBeschichtungsSeite := HMI_GetWORD(ADR(tSpsMessage.awDaten[4])); (* Beschichtungsseite  *)
     tMmi2SpsInfo.wSystemCheckStationTyp                := HMI_GetWORD(ADR(tSpsMessage.awDaten[5])); (* Hinweis: Kann benutzt werden fuer spezielle Bedingungen -> TeutoGlas Ausrichttypen fuer die Station 211 [Ausrichtfoerderer] *)
     tMmi2SpsInfo.wSystemCheckStationSlot               := HMI_GetWORD(ADR(tSpsMessage.awDaten[6])); (* Wandnr *)    
     tMmi2SpsInfo.rSystemCheckStationSollPosition       := HMI_GetREAL(ADR(tSpsMessage.awDaten[7])); (* Hinweis: Gibt Auskunft ueber die Position an der z.B. ein Antrieb gestanden hat / stehen soll  *)
     tMmi2SpsInfo.rSystemCheckStationScheibenlaenge     := HMI_GetREAL(ADR(tSpsMessage.awDaten[9])); (*** NEU Startposition als ABS. Position **)
     tMmi2SpsInfo.wSytstemCheckStationModellaktiv       := HMI_GetWORD(ADR(tSpsMessage.awDaten[11])); (* Hinweis: die evtl. auf der Station/Shuttle befindliche Scheibe ist ein Modell *)
     tMmi2SpsInfo.rSystemCheckModellVersatzVorne        := HMI_GetREAL(ADR(tSpsMessage.awDaten[12])); (* Modellversatz *)
     tMmi2SpsInfo.rSystemCheckModellVersatzHinten       := HMI_GetREAL(ADR(tSpsMessage.awDaten[14])); (* Modellversatz *)
     tMmi2SpsInfo.wSystemCheckScheibenDicke             := HMI_GetWORD(ADR(tSpsMessage.awDaten[16])); (* Glasdicke ist binär, da für mehrere Wände die Dicke mit gegeben werden muss. Glas bis 13mm = 0 / Glasdicke > 13mm = 1 *)
     tMmi2SpsInfo.rSystemcheckGlasGewicht               := HMI_GetREAL(ADR(tSpsMessage.awDaten[18])); (* Glasgewicht, errechnet vom MMI *)
 
     // Die Wandnummer wird Bitcodiert übergeben. In der SPS wird sie aber Dezimal benötigt
	  // Wand 3
     IF tMmi2SpsInfo.wSystemCheckStationSlot = 4 THEN
		   tMmi2SpsInfo.wSystemCheckStationSlot := 3;
	   END_IF
	   // Wand 4
     IF tMmi2SpsInfo.wSystemCheckStationSlot = 8 THEN
		   tMmi2SpsInfo.wSystemCheckStationSlot := 4;
	   END_IF
		
		
  // MSG 69
  // Anfrage der Oberflaeche um die aktuelle Shuttleposition zu bekommen
  SB0_MMI_GETSORTIERUNGSHUTTLEPOS:
    M_SB0_MMI_GETSORTIERUNGSHUTTLEPOS := TRUE;

	 
  // MSG 70 
  // Anzeige der IO´s im MMI Service  WORT 0: 1 = sichtbar / 0 = unsichtbar  
  SB0_MMI_IOANZEIGE_AKTIVIEREN_DEAKTIVIEREN:
    M_SB0_MMI_IOANZEIGE_AKTIVIEREN_DEAKTIVIEREN := TRUE;
    tMmi2SpsInfo.wlIOsAnzeigeAktivierenDeaktivieren := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
 	  
	  
  // MSG 71
  // Uebergabe der Auftragsdaten von der HMI fuer die Fremdanlage      
  SB0_MMI_AUFTRAGSDATEN_FREMDANLAGE:
    tMmi2SpsInfo.wFremdanlageNr       := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));    
    tMmi2SpsInfo.wNachrichtenIndex    := HMI_GetWORD(ADR(tSpsMessage.awDaten[1]));
    tMmi2SpsInfo.wNachrichtenAnzahl   := HMI_GetWORD(ADR(tSpsMessage.awDaten[2]));
    tMmi2SpsInfo.wScheibenanzahl      := HMI_GetWORD(ADR(tSpsMessage.awDaten[3]));
    tMmi2SpsInfo.adwScheibenID_1[0]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[4]));
    tMmi2SpsInfo.adwScheibenID_1[1]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[6]));
    tMmi2SpsInfo.adwScheibenID_1[2]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[8])); 
    tMmi2SpsInfo.adwScheibenID_1[3]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[10]));
    tMmi2SpsInfo.adwScheibenID_2[0]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[12]));
    tMmi2SpsInfo.adwScheibenID_2[1]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[14]));
    tMmi2SpsInfo.adwScheibenID_2[2]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[16])); 
    tMmi2SpsInfo.adwScheibenID_2[3]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[18]));
    tMmi2SpsInfo.adwScheibenID_3[0]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[20]));
    tMmi2SpsInfo.adwScheibenID_3[1]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[22]));
    tMmi2SpsInfo.adwScheibenID_3[2]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[24])); 
    tMmi2SpsInfo.adwScheibenID_3[3]   := HMI_GetDWORD(ADR(tSpsMessage.awDaten[26]));

    M_SB0_MMI_AUFTRAGSDATEN_FREMDANLAGE := TRUE;
	  

   // MSG 72
   // Auftragsinformationen waehrend der Querfahrt uebertragen
   SB0_MMI_SHUTTLE_INFORMATION:
     tMmi2SpsInfo.wAuftrag_ShuttleNummer   := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
     tMmi2SpsInfo.rAuftrag_Laenge          := HMI_GetReal(ADR(tSpsMessage.awDaten[1]));
     tMmi2SpsInfo.wAuftrag_TranferStation  := HMI_GetWORD(ADR(tSpsMessage.awDaten[3]));
     tMmi2SpsInfo.wAuftrag_Modus           := HMI_GetWORD(ADR(tSpsMessage.awDaten[4]));
     tMmi2SpsInfo.wAuftrag_ShuttleWand     := HMI_GetWORD(ADR(tSpsMessage.awDaten[5]));
     tMmi2SpsInfo.rAuftrag_Dicke           := WORD_TO_REAL(HMI_GetWORD(ADR(tSpsMessage.awDaten[6])));
     tMmi2SpsInfo.wAuftrag_TransferWand    := HMI_GetWORD(ADR(tSpsMessage.awDaten[7]));
    // tMmi2SpsInfo.rAuftrag_Dicke           := HMI_GetReal(ADR(tSpsMessage.awDaten[8]));

    M_SB0_MMI_SHUTTLE_INFORMATION := TRUE;
	 
	  
   // MSG 76
  (* Hinweis:
     - Speicherfachvalidierung mittels Transfershuttle wenn ein Sensor von diesem nicht frei gefahren werden konnte
       bzw. der Einlauf- oder Aulauf- Sensor belegt wurde. Aktin ist dem SystemCheck vorgelagert (Anlage muss ich im Hand-Modus
       befinden
  *)
  SB0_MMI_TRANSFERSHUTTLECHECK:

    tMmi2SpsInfo.wTransfershuttle_Nummer1       := HMI_GetWORD(ADR(tSpsMessage.awDaten[0])); (* HINWEIS: Transfer - Shuttlenummer *)
    tMmi2SpsInfo.wTransfershuttle_Nummer2       := HMI_GetWORD(ADR(tSpsMessage.awDaten[1])); (* HINWEIS: Transfer - Shuttlenummer *)
    tMmi2SpsInfo.wTransfershuttle_GlasDicke     := HMI_GetWORD(ADR(tSpsMessage.awDaten[2])); (* HINWEIS: Unterteilung welche Luftabfrage genommen werden muss *)
    tMmi2SpsInfo.rTransfershuttle_SollPosition1 := HMI_GetReal(ADR(tSpsMessage.awDaten[3])); (* HINWEIS: Soll-Position des Transfershuttles *)
    tMmi2SpsInfo.rTransfershuttle_SollPosition2 := HMI_GetReal(ADR(tSpsMessage.awDaten[5])); (* HINWEIS: Soll-Position des Transfershuttles *)
   
     M_SB0_MMI_TRANSFERSHUTTLECHECK := TRUE;
	  
  // MSG 77/100
  // Testen der Transfershuttlepositionen
  SB0_MMI_TRANSFERSHUTTLEBUFFERSLOTCHECK,
  SB0_MMI_LIFTTRANSFERSHUTTLE:
    IF ( NOT FachkontrolleTransfershuttle.bpStarteFachkontrolle ) THEN
      FachkontrolleTransfershuttle.bpStarteFachkontrolle := TRUE;
      FachkontrolleTransfershuttle.wpStationNumber       := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));;
	    FachkontrolleTransferShuttle.wpSpeicherNr          := HMI_GetWORD(ADR(tSpsMessage.awDaten[1]));
	    FachkontrolleTransferShuttle.wpFachNr              := HMI_GetWORD(ADR(tSpsMessage.awDaten[2]));
      FachkontrolleTransfershuttle.rpPosition            := HMI_GetReal(ADR(tSpsMessage.awDaten[3]));
    END_IF
	  
	 
  // MSG 81 
  SB0_MMI_RESET_ETHERCAT:
    M_SB0_MMI_RESET_ETHERCAT := TRUE;
	 
	 
  // MSG 99
  SB0_MMI_WATCHDOGTEST:
    tMmi2SpsInfo.wWatchDogTestCount  := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    M_SB0_MMI_WATCHDOGTEST := TRUE;
	 
	 
  // MSG 101
  // Neue Nachricht für Aufträge aller Stationen und Shuttle
  SB0_MMI_SHEET_ORDER:
    tMmi2SpsInfo.wStationsNr                             := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));         (* Stationsnummer der Quellstation *)
    tMmi2SpsInfo.rStationsPosition                       := HMI_GetREAL(ADR(tSpsMessage.awDaten[1]));  (* Stationsposition der Quellstation *)
    tMmi2SpsInfo.rAuftragsLaenge                         := HMI_GetREAL(ADR(tSpsMessage.awDaten[3]));  (* Länge der Scheibe/Batch *)
    tMmi2SpsInfo.rAuftragsHoehe                          := HMI_GetREAL(ADR(tSpsMessage.awDaten[5]));  (* Höhe der Scheibe/Batch *)
    tMmi2SpsInfo.rAuftragsDicke                          := HMI_GetREAL(ADR(tSpsMessage.awDaten[7]));  (* Dicke der Scheibe/Batch *)
    tMmi2SpsInfo.rModellVersatzVorne                     := HMI_GetREAL(ADR(tSpsMessage.awDaten[9]));
    tMmi2SpsInfo.rModellversatzHinten                    := HMI_GetREAL(ADR(tSpsMessage.awDaten[11]));
    tMmi2SpsInfo.wErsteLetzteScheibe                     := HMI_GetWORD(ADR(tSpsMessage.awDaten[13]));         (* Kennzeichnung Erste und Letzte Scheibe *)
    tMmi2SpsInfo.wAuftragsWand                           := HMI_GetWORD(ADR(tSpsMessage.awDaten[14]));         (* Stationswand der Quellstation *)
    tMmi2SpsInfo.wAnzahlScheiben                         := HMI_GetWORD(ADR(tSpsMessage.awDaten[15]));         (* Anzahl der Scheiben *)
    tMmi2SpsInfo.wAuftragsTyp                            := HMI_GetWORD(ADR(tSpsMessage.awDaten[16]));         (* Auftragstyp Eintransport, Austransport, etc.*)
    tMmi2SpsInfo.wTransferstationsNr1                    := HMI_GetWORD(ADR(tSpsMessage.awDaten[17]));         (* Stationsnummer der Zielstation 1 *)
    tMmi2SpsInfo.wTransferstationsNr2                    := HMI_GetWORD(ADR(tSpsMessage.awDaten[18]));         (* Stationsnummer der Zielstation 2 *)
    tMmi2SpsInfo.rTransferposition1                      := HMI_GetREAL(ADR(tSpsMessage.awDaten[19]));  (* Stationsposition der Zielstation 1 *)
    tMmi2SpsInfo.rTransferposition2                      := HMI_GetREAL(ADR(tSpsMessage.awDaten[21]));  (* Stationsposition der Zielstation 2 *)
    tMmi2SpsInfo.wTransferwand                           := HMI_GetWORD(ADR(tSpsMessage.awDaten[23]));         (* Stationswand der Zielstationen (1Byte = Station 1, 2Byte = Station 2) *)

    tMmi2SpsInfo.wNachrichtenAnzahl := HMI_GetWORD(ADR(tSpsMessage.awDaten[15]));
    tMmi2SpsInfo.wNachrichtenIndex  := HMI_GetWORD(ADR(tSpsMessage.awDaten[28]));
 
     IF    ( tMmi2SpsInfo.wStationsNr >= cERSTE_STATION )
     THEN
        M_SB0_MMI_SHEET_ORDER_STATION := TRUE;
     ELSE
        M_SB0_MMI_SHEET_ORDER_SHUTTLE := TRUE;
     END_IF


  // MSG 102
  // Override fuer alle Antriebe [0..100 %], Auswertung in Antriebe.prg
  SB0_MMI_DRIVEOVERRIDE:
    tMmi2SpsInfo.wMmi2SpsOverrideValue := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    M_SB0_MMI_DRIVEOVERRIDE := TRUE;


  // MSG 110
  // Funktion zum zurueckfahren der Glaeser und neu Positionieren im Speicher
  SB0_MMI_TS_REPOSITIONING_LITES:
    tMmi2SpsInfo.wStationsNr          := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));  (* Stationsnummer der Quellstation *)
    tMmi2SpsInfo.rStationsPosition    := HMI_GetREAL(ADR(tSpsMessage.awDaten[1]));  (* Stationsposition der Quellstation *)
    tMmi2SpsInfo.wTransferstationsNr1 := HMI_GetWORD(ADR(tSpsMessage.awDaten[3])); 
    tMmi2SpsInfo.rTransferposition1   := HMI_GetREAL(ADR(tSpsMessage.awDaten[4]));  (* Stationsposition der Quellstation *)
    tMmi2SpsInfo.rModellversatzHinten := HMI_GetREAL(ADR(tSpsMessage.awDaten[6])); 
    tMmi2SpsInfo.rAuftragsDicke       := HMI_GetREAL(ADR(tSpsMessage.awDaten[8]));  (* Dicke der Scheibe/Batch *)

    M_SB0_MMI_TS_REPOSITIONING_LITES := TRUE;

  // MSG 111 Ausfahren der Puffer auf der Shuttlebahn
  SB0_MMI_ANFORDERUNG_PUFFER_AUSFAHREN:
    tMmi2SpsInfo.wModusAuswahl := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    M_SB0_MMI_ANFORDERUNG_PUFFER_AUSFAHREN := TRUE;

  // MSG 112 Einfahren der Puffer auf der Shuttlebahn
  SB0_MMI_ANFORDERUNG_PUFFER_EINFAHREN:
    tMmi2SpsInfo.wModusAuswahl := HMI_GetWORD(ADR(tSpsMessage.awDaten[0]));
    M_SB0_MMI_ANFORDERUNG_PUFFER_EINFAHREN := TRUE;
    
ELSE

 MsgInterpret := FALSE;
 RETURN;

END_CASE

MsgInterpret := TRUE;
END_FUNCTION