(* METADATA
{
  "v3Meta": {
    "objectGuid": "07a4896b-4b10-421b-8c15-d73c62ab9e42"
  }
}
*)
FUNCTION_BLOCK Shuttle_Eintransport
VAR_INPUT
    
  (* BOOLEAN *)
  bpReset                : BOOL;
  
  (* WORD *)
  wStation               : WORD;
  wWand                  : WORD;
  
  (* STRUKTUR *)
  Auftragsdaten          : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  (* BOOLEAN*)
  bpDone                 : BOOL;
  bpFehler               : BOOL;

END_VAR
VAR
    
  (* BOOLEAN *)  
  blStationQuittiertScheiben : BOOL;
  
  (* WORD *)
  wlEintransportstation  : WORD;

  (* INT *)
  ilScheibenZuQuittieren : INT;

  (* STEPS *)
  steplSchritt           : STEPS_TE;

END_VAR


(***************************************************************************************************)
(* STEUERUNG EINTRANSPORT  *)
(***************************************************************************************************)
IF ( Auftragsdaten.wAuftrag = eStation_Eintransport ) THEN

  CASE steplSchritt OF

(*EINTRANSPORT ==============================================*)
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)	
      IF checkSafetyCircuitsNotBlocked(starrShuttleBasisParameter[wStation]) AND NOT bgShuttleEintransportSperren[wStation] THEN
        steplSchritt := STEP_10_E;
      END_IF

(*EINTRANSPORT ==============================================*)
    STEP_10_E:
      (* Auftragsdaten pruefen:
         - Sollte es fehler in der Auftragsdatenstruktur geben wird in den Fehlerschritt 900
         - gesprungen. Die Fehlerauswertung findet in der Funktion Shuttledaten_Pruefen statt.
      *)
      steplSchritt := STEP_20_E;

      IF NOT AuftragsdatenPruefen( wStation, wWand, Auftragsdaten) THEN
        steplSchritt := STEP_900_E;
      END_IF

(*EINTRANSPORT ==============================================*)
    STEP_20_E:
      (* Hinweis
         - Uebergabe der Quellstation [Sender] fuer den Austransport [Zum ueberpruefen des Zustandes der Station]       
      *)
      wlEintransportstation := Auftragsdaten.wTransferstationsNr1;
      
      starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
      starrShuttleBasisParameter[wStation].bTransferstationTransfershuttle[wWand] := FALSE;

      (* Hinweis:
         - Auftragsdaten ans Shuttle übergeben
      *)
      ilScheibenZuQuittieren := WORD_TO_INT( Auftragsdaten.wAnzahlScheiben );

      (* Hinweis:
         - Auftragsdaten uebergeben
      *)
      starrShuttleBasisParameter[wStation].pAuftrag[wWand] := Auftragsdaten;

      (* Hinweis:
         - Scheibenführung / Wandverstellung anstellen 
         - Aus dem Speicher: Speicherslot dicke nehmen ; von einer Station die Scheibendicke nehmen
      *)
      IF ( starrShuttleBasisParameter[wStation].pAuftrag[wWand].rAuftragsDicke <= wgMKScheibenDicke13mm ) THEN
        starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung    := eZylinderStellung16mm;
      ELSIF ( starrShuttleBasisParameter[wStation].pAuftrag[wWand].rAuftragsDicke <= wgMKScheibenDicke19mm ) THEN
        starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung    := eZylinderStellung23mm;
      ELSIF ( starrShuttleBasisParameter[wStation].pAuftrag[wWand].rAuftragsDicke <= wgMKScheibenDicke24mm ) THEN
        starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung    := eZylinderStellung29mm;
      END_IF
	  
	    // Kippen
      starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition                  := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Kippen[Auftragsdaten.wTransferstationsNr1];
      starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachEintransport := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.KippenNachEintransport[Auftragsdaten.wTransferstationsNr1];
      starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachAustransport := 0;  

      // Glastransport
	    starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eGlastransport := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Glastransport[Auftragsdaten.wTransferstationsNr1];
	  
	    // Scheibentyp prüfen
  	  starrShuttleBasisParameter[wStation].wGlasTyp[wWand] := eScheibe_Default;
      IF ( Auftragsdaten.rAuftragsLaenge >= starrShuttleBasisParameter[wStation].stMKs.stStationsParameter.rLaengeUebergroesseScheibe ) THEN
        starrShuttleBasisParameter[wStation].wGlasTyp[wWand] := eScheibe_Maximal;
      END_IF
	  
      (* Anmerkung
         - Zielstation abfragen ob diese bereit sind zum Austransport    
           => Status der Glas-Sender Station pruefen   
      *)
      CASE wlEintransportstation OF

	     // Shuttles
        cERSTES_SHUTTLE..cLETZTES_SHUTTLE: // ... macht wenig Sinn
		      ;
		  
	    // Transfershuttles
        cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
          steplSchritt := STEP_200_E;
		
	     // Stationen
        cERSTE_STATION..cLETZTE_STATION:
          IF ( ( Job_Stationen.AuftragsdatenWand[wlEintransportstation, Auftragsdaten.wTransferwand].wAuftrag = eStation_Warte_Auf_Austransport )
            OR ( Job_Stationen.AuftragsdatenWand[wlEintransportstation, Auftragsdaten.wTransferwand].wAuftrag = eStation_Belegt ) )
          THEN
            steplSchritt := STEP_100_E;
          END_IF

        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
		      ;
		  
        cERSTE_FREMDANLAGE_EINLAUF..cLETZTE_FREMDANLAGE_EINLAUF:
		      ;

        ELSE
          wpgFehlerdaten[0] := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
          wpgFehlerdaten[1] := wlEintransportstation;
          SpsError( eFehler_Station,
                    cMELDUNG_AUFTRAGSDATEN_FALSCHE_EINLAUFSTATION,
                    starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(wStation),
                    wpgFehlerdaten );

          steplSchritt := STEP_900_E;

      END_CASE

(*EINTRANSPORT ==============================================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  EINTRANSPORT MITTELS STATIONEN [RKT, SF, ETC.]
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      (* Anmerkung
         - Starten des Eintransports [Glas-Empfaenger]       
         - Initiieren des  des Austransports [Glas-Empfaenger]
      *)
      CASE wlEintransportstation OF

        cERSTE_STATION..cLETZTE_STATION:
		
          IF AutomatikAktiv(wlEintransportstation) THEN

            (* Hinweis:
               - Auftragsdaten in Transferstation kopieren
            *)
            Job_Stationen.AuftragsdatenWand[wlEintransportstation, Auftragsdaten.wTransferwand]           := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
            Job_Stationen.AuftragsdatenWand[wlEintransportstation, Auftragsdaten.wTransferwand].wAuftrag  := eStation_Austransport;

            (* Hinweis:
               - Kopplung zur Transferstation herstellen
            *)
            starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[wlEintransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
            starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[wlEintransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
			
            (* Hinweis:
               - Starten des Eintransports 
            *)
            starrShuttleBasisParameter[wStation].bScheibentrennen[wWand] := NOT Auftragsdaten.stAuftragsInformationen.cBIT_SRC_WALL_1_EMPTY;
            starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Rueckwaertig );
            starrShuttleBasisParameter[wStation].bEintransport[wWand] := TRUE;

            steplSchritt := STEP_400_E;

          END_IF
		  
        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
		      ;
		 
        cERSTE_FREMDANLAGE_EINLAUF..cLETZTE_FREMDANLAGE_EINLAUF:
		      ;
		  
      END_CASE

(*EINTRANSPORT ==============================================*)
    STEP_200_E:
      (* ---------------------------------------------------------------------------------------
      //  EINTRANSPORT MITTELS TRANSFERSHUTTLE
      //         
      //  Hinweis:
      //  - Transferstation2 = 0   => Eintransport mit nur einem Transfershuttle
      //  - Transferstation2 <> 0  => Eintransport im Transfershuttle-Verbund
      // ---------------------------------------------------------------------------------------*)

      IF ( Auftragsdaten.wTransferstationsNr2 = 0 OR starrTransfershuttleBasisParameter[wlEintransportstation].stMKs.stStationsOptionen.stTransfershuttle.bTransferShuttleFuerFaecherwagen ) THEN

        IF (  ( Job_Shuttle.AuftragsdatenTransfershuttle[wlEintransportstation].wAuftrag = eStation_Kein_Auftrag ) ) THEN
          steplSchritt := STEP_210_E;
        END_IF

      ELSE
        VailiderenTransfershuttleVerbund ( wTransferstation1 := wlEintransportstation,
                                           wTransferstation2 := Auftragsdaten.wTransferstationsNr2 );

        IF (  ( Job_Shuttle.AuftragsdatenTransfershuttle[wlEintransportstation].wAuftrag = eStation_Kein_Auftrag )
          AND ( Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2].wAuftrag  = eStation_Kein_Auftrag ) )
        THEN
          steplSchritt := STEP_220_E;
        END_IF

      END_IF

(*EINTRANSPORT ==============================================*)
    STEP_210_E:
      (* ---------------------------------------------------------------------------------------
      //  EINTRANSPORT TRANSFERSHUTTLE [DEFAULT]
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      (* Hinweis:
         - Kopplung
      *)
      IF ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Rueckwaertig ) THEN
        starrTransfershuttleBasisParameter[wlEintransportstation].InGlasTransportVorgaenger[wWand] := starrShuttleBasisParameter[wStation].OutGlasTransport[wWand];
        starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrTransfershuttleBasisParameter[wlEintransportstation].OutGlasTransport[wWand];
		
		  ELSE
        starrTransfershuttleBasisParameter[wlEintransportstation].InGlasTransportNachfolger[wWand] := starrShuttleBasisParameter[wStation].OutGlasTransport[wWand];
        starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrTransfershuttleBasisParameter[wlEintransportstation].OutGlasTransport[wWand];
		
		  END_IF

      (* Hinweis:
         - TS auf FW koppeln
      *)
	    IF   starrTransfershuttleBasisParameter[wlEintransportstation].stMKs.stStationsOptionen.stTransfershuttle.bTransferShuttleFuerFaecherwagen
       AND IsBetweenWORD(Auftragsdaten.wTransferstationsNr2, cERSTE_FAECHERWAGENSTATIONS_NR, cLETZTE_FAECHERWAGENSTATIONS_NR)
      THEN
        IF ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Rueckwaertig ) THEN
          starrTransfershuttleBasisParameter[wlEintransportstation].InGlasTransportNachfolger[wWand] := starrFaecherwagenBasisParameter[Auftragsdaten.wTransferstationsNr2].OutGlasTransport[cWAND_1];
	      ELSE
          starrTransfershuttleBasisParameter[wlEintransportstation].InGlasTransportVorgaenger[wWand] := starrFaecherwagenBasisParameter[Auftragsdaten.wTransferstationsNr2].OutGlasTransport[cWAND_1];
        END_IF
      END_IF

      (* Hinweis:
         - Neuen Auftag in den FIFO [Warteschlange] eintragen
      *)
      Job_Shuttle.AuftragsdatenTransfershuttle[wlEintransportstation]          := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
      Job_Shuttle.AuftragsdatenTransfershuttle[wlEintransportstation].wAuftrag := eStation_Austransport;

	    starrShuttleBasisParameter[wStation].bScheibentrennen[wWand]                := FALSE; 
	    starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand]      := ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Rueckwaertig );
	    starrShuttleBasisParameter[wStation].bEintransport[wWand]                   := TRUE;
	    starrShuttleBasisParameter[wStation].bTransferstationTransfershuttle[wWand] := TRUE;
	  
     steplSchritt := STEP_400_E;

(*EINTRANSPORT ==============================================*)
    STEP_220_E:
      (* ---------------------------------------------------------------------------------------
      //  EINTRANSPORT TRANSFERSHUTTLE [VERBUND]
      //         
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------*)

      (* Hinweis:
         - Kopplung
      *)
      IF ( starrShuttleBasisParameter[wStation].stMKs.eStationsTyp = eInputshuttle ) THEN
        starrTransfershuttleBasisParameter[wlEintransportstation].InGlasTransportVorgaenger[cWAND_1] := starrShuttleBasisParameter[wStation].OutGlasTransport[wWand];
        starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrTransfershuttleBasisParameter[wlEintransportstation].OutGlasTransport[cWAND_1];

      ELSE
        starrTransfershuttleBasisParameter[wlEintransportstation].InGlasTransportNachfolger[cWAND_1] := starrShuttleBasisParameter[wStation].OutGlasTransport[wWand];
        starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrTransfershuttleBasisParameter[wlEintransportstation].OutGlasTransport[cWAND_1];

      END_IF


      (* Hinweis:
         - Transfershuttle koppeln
      *)
      aTransfershuttles[wlEintransportstation].stpInTransportVerbund := aTransfershuttles[Auftragsdaten.wTransferstationsNr2].stpOutTransportVerbund;
      aTransfershuttles[Auftragsdaten.wTransferstationsNr2].stpInTransportVerbund  := aTransfershuttles[wlEintransportstation].stpOutTransportVerbund;

      (* Hinweis:
         - Auftragsdaten an die Transfershuttle uebergeben
      *)
      Job_Shuttle.AuftragsdatenTransfershuttle[wlEintransportstation]            := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
      Job_Shuttle.AuftragsdatenTransfershuttle[wlEintransportstation].wAuftrag   := eStation_Austransport;

      Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2]          := AuftragsdatenUmkopieren(TRUE, FALSE, Auftragsdaten);
      Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2].wAuftrag := eStation_Transportkopplung;
	  
	    starrShuttleBasisParameter[wStation].bScheibentrennen[wWand]                := FALSE; 
	    starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand]      := ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Rueckwaertig );
	    starrShuttleBasisParameter[wStation].bEintransport[wWand]                   := TRUE;
	    starrShuttleBasisParameter[wStation].bTransferstationTransfershuttle[wWand] := TRUE;
	  
      steplSchritt := STEP_400_E;

(*EINTRANSPORT ==============================================*)
    STEP_400_E:
      (* Hinweis:
         - Scheibenquittieren [pro Wand] -> Nachricht an die Oberflaeche 
           =>( Oberflaeche prueft nicht die Wandnr. die quittiert werden nur bei einem multiplen  Ein-/Austransport- Auftrag wird die WandNr. geprueft )  
      *)
      blStationQuittiertScheiben := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[wlEintransportstation];

      IF ( starrShuttleBasisParameter[wStation].OutGlasTransport[wWand].bQuittScheibe ) THEN

        IF ( ilScheibenZuQuittieren > 0 ) AND blStationQuittiertScheiben THEN

          wSps2MmiZielStation  := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          wSps2MmiQuellStation := Auftragsdaten.wTransferstationsNr1;
          wSps2MmiZielWand     := wWand;
          wSps2MmiQuellWand    := Auftragsdaten.wTransferwand;
          dwSps2MmiWartezeit   := starrShuttleBasisParameter[wStation].dwWartezeit[wWand];
          wSPS2MMIAuftragstyp  := 0;

          MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
        END_IF

        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;

      END_IF

      (* Anmerkung:
         - Transport abgeschlossen 
      *)
      IF ( starrShuttleBasisParameter[wStation].bEintransportAbgeschlossen[wWand] ) THEN
        starrShuttleBasisParameter[wStation].bEintransport[wWand] := FALSE;
        starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
        steplSchritt := STEP_410_E;
      END_IF

      (* Fehlerbehandlung
         - Shuttle
      *)
      IF ( starrShuttleBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrShuttleBasisParameter[wStation].wFehlerNummer,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(wStation),
                  starrShuttleBasisParameter[wStation].awFehlerInformationen );

        starrShuttleBasisParameter[wStation].bEintransport[wWand] := FALSE;
        starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;

        steplSchritt := STEP_900_E;

      END_IF

(*EINTRANSPORT ==============================================*)
    STEP_410_E:
      (* Anmerkung:
         - Gueltige Anzahl von Scheiben wurden quittiert
      *)
      IF ( ilScheibenZuQuittieren = 0 ) THEN

          steplSchritt := STEP_1000_E;

      (* Anmerkung:
         - Zu wenig Scheiben quittiert
      *)
      ELSIF ( ilScheibenZuQuittieren > 0 ) THEN
        wpgFehlerdaten[0] := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := wWand;

        SpsError( eFehler_Station,
                  cMELDUNG_STATION_ZUWENIG_SCHEIBEN_QUITTIERT_WAND_EINTRANSPORT,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(wStation),
                  wpgFehlerdaten );

        steplSchritt := STEP_900_E;

      (* Anmerkung:
         - Zu viele Scheiben quittiert
      *)
      ELSIF ( ilScheibenZuQuittieren < 0 )  THEN
        wpgFehlerdaten[0] := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := wWand;

        SpsError( eFehler_Station,
                  cMELDUNG_STATION_ZUVIELE_SCHEIBEN_QUITTIERT_WAND_EINTRANSPORT,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(wStation),
                  wpgFehlerdaten );

        steplSchritt := STEP_900_E;

      END_IF

(*EINTRANSPORT ==============================================*)
    STEP_900_E:
      starrShuttleBasisParameter[wStation].bEintransport[wWand] := FALSE;
      starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;

      bpFehler := TRUE;

(*EINTRANSPORT ==============================================*)
    STEP_1000_E:
      (* Hinweis:
         - Beenden des Eintransports [Bereit fuer den naechsten Auftrag]
      *)
      bpDone := TRUE;
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

(*EINTRANSPORT ==============================================*)
  END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpDone := FALSE;
  bpReset := FALSE;
  starrShuttleBasisParameter[wStation].bEintransport[wWand] := FALSE;
  starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
  starrShuttleBasisParameter[wStation].bTransferstationTransfershuttle[wWand] := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK