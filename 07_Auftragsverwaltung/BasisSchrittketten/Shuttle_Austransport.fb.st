(* METADATA
{
	"v3Meta": {
		"objectGuid": "ac2be6b1-afec-449b-a8c9-7faca61891b0"
	}
}
*)
FUNCTION_BLOCK Shuttle_Austransport
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
  wlAustransportstation  : WORD;

  (* INT *)
  ilScheibenZuQuittieren : INT;

  (* STEPS *)
  steplSchritt           : STEPS_TE;

END_VAR
(***************************************************************************************************)
(*  STEUERUNG AUSTRANSPORT *)
(***************************************************************************************************)
IF ( Auftragsdaten.wAuftrag = eStation_Austransport) THEN

  CASE steplSchritt OF

(*AUSTRANSPORT ===============================================*)
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)	
      IF checkSafetyCircuitsNotBlocked(starrShuttleBasisParameter[wStation]) AND NOT bgShuttleAustransportSperren[wStation]  THEN
        steplSchritt := STEP_10_E;
      END_IF

(*AUSTRANSPORT ===============================================*)
    STEP_10_E:
      (* Auftragsdaten pruefen:
        - Sollte es fehler in der Auftragsdatenstruktur geben wird in den Fehlerschritt 900
          gesprungen. Die Fehlerauswertung findet in der Funktion Shuttledaten_Pruefen statt.
      *)
      steplSchritt := STEP_20_E;

      IF NOT AuftragsdatenPruefen( wStation, wWand, Auftragsdaten) THEN
        steplSchritt := STEP_900_E;
      END_IF

(*AUSTRANSPORT ===============================================*)
    STEP_20_E:
      (* ---------------------------------------------------------------------------------------
      //  AUSTRANSPORT BEDINGUNGEN PRUEFEN
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      (* Hinweis
         - Uebergabe der Quellstation [Sender] fuer den Austransport [Zum ueberpruefen des Zustandes der Station]       
      *)
      wlAustransportstation := Auftragsdaten.wTransferstationsNr1;
      
      starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
      starrShuttleBasisParameter[wStation].bTransferstationTransfershuttle[wWand] := FALSE;

      (* Hinweis:
         - Auftragsdaten ans Shuttle übergeben
      *)
      ilScheibenZuQuittieren :=WORD_TO_INT( Auftragsdaten.wAnzahlScheiben);

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
      starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition                  := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Kippen[wlAustransportstation];
      starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachEintransport := 0;
	    starrShuttleBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachAustransport := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.KippenNachAustransport[wlAustransportstation];
	  
	    // Scheibentyp prüfen
  	  starrShuttleBasisParameter[wStation].wGlasTyp[wWand] := eScheibe_Default;
      IF ( Auftragsdaten.rAuftragsLaenge >= starrShuttleBasisParameter[wStation].stMKs.stStationsParameter.rLaengeUebergroesseScheibe ) THEN
        starrShuttleBasisParameter[wStation].wGlasTyp[wWand] := eScheibe_Maximal;
      END_IF
	  
      (* Hinweis:
         - Stations-Zustand pruefen
      *)
      CASE wlAustransportstation OF
          
		    // Transfershuttles
        cERSTES_TRANSFERSHUTTLE..cLETZTES_TRANSFERSHUTTLE:
          steplSchritt := STEP_200_E;
		
		    // Stationen
        cERSTE_STATION..cLETZTE_STATION:
          IF ( ( Job_Stationen.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag = eStation_Kein_Auftrag )
            OR ( Job_Stationen.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag = eStation_Belegt )
            OR ( Job_Stationen.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag = eStation_Durchtransport ) )
          THEN
            steplSchritt := STEP_100_E;
          END_IF

        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
		      IF ( Auftragsdaten.wTransferstationsNr2 <> 0 ) THEN
            IF   ( Job_Fremdanlage.AuftragsdatenFremdanlage[wlAustransportstation].wAuftrag = eStation_Kein_Auftrag )
			        AND ( Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr2, Auftragsdaten.wTransferwand].wAuftrag = eStation_Kein_Auftrag )
            THEN
              steplSchritt := STEP_100_E;
            END_IF
		      ELSE
            IF ( Job_Fremdanlage.AuftragsdatenFremdanlage[wlAustransportstation].wAuftrag = eStation_Kein_Auftrag )
            THEN
              steplSchritt := STEP_100_E;
            END_IF
		      END_IF
		  
	     // Fremdanlage
        cERSTE_FREMDANLAGE_EINLAUF..cLETZTE_FREMDANLAGE_EINLAUF:
		    ;
		  
      ELSE
        wpgFehlerdaten[0] := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := wWand;
        SpsError( eFehler_Station,
                  cMELDUNG_AUFTRAGSDATEN_FALSCHE_AUSLAUFSTATION,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );

        steplSchritt := STEP_900_E;

      END_CASE
	  
(*AUSTRANSPORT ==============================================*)
    STEP_100_E:
      (* Hinweis:
         - Auftrag ab Station übergeben und Shuttle Informationen zuweisen
      *)
      CASE wlAustransportstation OF
          
        (* Stationen *)
        cERSTE_STATION..cLETZTE_STATION:

          IF AutomatikAktiv(wlAustransportstation) THEN

            (* Hinweis:
               - Auftragsdaten in Transferstation kopieren
            *) 
            IF NOT ( Job_Stationen.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag = eStation_Durchtransport ) THEN
              Job_Stationen.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand]           := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
              Job_Stationen.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag  := eStation_Eintransport;
		      	END_IF

            (* Hinweis:
               - Kopplung zur Transferstation herstellen
            *)
            starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[wlAustransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
            starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[wlAustransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
			
            (* Hinweis:
               - Daten an das Shuttle uebergeben 
            *)
            starrShuttleBasisParameter[wStation].bAustransport[wWand]                  := TRUE;
            starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand]     := ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig );

            steplSchritt := STEP_400_E;

          END_IF

        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
		
		      IF ( Auftragsdaten.wTransferstationsNr2 <> 0 ) THEN

            IF AutomatikAktiv(Auftragsdaten.wTransferstationsNr2) THEN

	  	        (* Hinweis:
                 - Kopplung zur Transferstation herstellen
              *)
              starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[Auftragsdaten.wTransferstationsNr2].OutGlasTransport[Auftragsdaten.wTransferwand];
              starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[Auftragsdaten.wTransferstationsNr2].OutGlasTransport[Auftragsdaten.wTransferwand];

              (* Hinweis:
                 - Auftragsdaten in Transferstation kopieren
              *)
              Job_Fremdanlage.AuftragsdatenFremdanlage[wlAustransportstation]          := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
              Job_Fremdanlage.AuftragsdatenFremdanlage[wlAustransportstation].wAuftrag := eStation_Eintransport;

              (* Hinweis:
                 - Daten an das Shuttle uebergeben 
              *)
              starrShuttleBasisParameter[wStation].bAustransport[wWand]                  := TRUE;
              starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand]     := ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig );

              steplSchritt := STEP_400_E;
		
			      END_IF

		      ELSE
			  
	  	      (* Hinweis:
               - Kopplung zur Transferstation herstellen
            *)
            starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].OutGlasTransport[cWAND_1];
            starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].OutGlasTransport[cWAND_1];
            starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].InGlasTransportVorgaenger[cWAND_1] :=  starrShuttleBasisParameter[wStation].OutGlasTransport[wWand];

            (* Hinweis:
               - Auftragsdaten in Transferstation kopieren
            *) 
            Job_Fremdanlage.AuftragsdatenFremdanlage[wlAustransportstation]          := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
            Job_Fremdanlage.AuftragsdatenFremdanlage[wlAustransportstation].wAuftrag := eStation_Eintransport;

            (* Hinweis:
               - Daten an das Shuttle uebergeben 
            *)
            starrShuttleBasisParameter[wStation].bAustransport[wWand]              := TRUE;
            starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig );

            steplSchritt := STEP_400_E;

		      END_IF

        END_CASE

(*AUSTRANSPORT ===============================================*)
    STEP_200_E:
      (* ---------------------------------------------------------------------------------------
      //  EINTRANSPORT MITTELS TRANSFERSHUTTLE
      //         
      //  Hinweis:
      //  - Transferstation2 = 0   => Eintransport mit nur einem Transfershuttle
      //  - Transferstation2 <> 0  => Eintransport im Transfershuttle-Verbund
      // ---------------------------------------------------------------------------------------*)

      IF ( Auftragsdaten.wTransferstationsNr2 = 0 OR starrTransfershuttleBasisParameter[wlAustransportstation].stMKs.stStationsOptionen.stTransfershuttle.bTransferShuttleFuerFaecherwagen ) THEN

        IF (  ( Job_Shuttle.AuftragsdatenTransfershuttle[wlAustransportstation].wAuftrag = eStation_Kein_Auftrag ) ) THEN
          steplSchritt := STEP_210_E;
        END_IF

      ELSE
        VailiderenTransfershuttleVerbund ( wTransferstation1 := wlAustransportstation,
                                           wTransferstation2 := Auftragsdaten.wTransferstationsNr2 );

        IF (  ( Job_Shuttle.AuftragsdatenTransfershuttle[wlAustransportstation].wAuftrag = eStation_Kein_Auftrag )
          AND ( Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2].wAuftrag  = eStation_Kein_Auftrag ) )
        THEN
          steplSchritt := STEP_220_E;
        END_IF

      END_IF

(*AUSTRANSPORT ===============================================*)
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
		  IF ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig ) THEN
        starrTransfershuttleBasisParameter[wlAustransportstation].InGlasTransportNachfolger[wWand] := starrShuttleBasisParameter[wStation].OutGlasTransport[wWand];
        starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrTransfershuttleBasisParameter[wlAustransportstation].OutGlasTransport[wWand];
		
		  ELSE
        starrTransfershuttleBasisParameter[wlAustransportstation].InGlasTransportVorgaenger[wWand] := starrShuttleBasisParameter[wStation].OutGlasTransport[wWand];
        starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrTransfershuttleBasisParameter[wlAustransportstation].OutGlasTransport[wWand];			
		
		  END_IF

        (* Hinweis:
           - TS auf FW koppeln
        *)
	      IF   starrTransfershuttleBasisParameter[wlAustransportstation].stMKs.stStationsOptionen.stTransfershuttle.bTransferShuttleFuerFaecherwagen
         AND IsBetweenWORD(Auftragsdaten.wTransferstationsNr2, cERSTE_FAECHERWAGENSTATIONS_NR, cLETZTE_FAECHERWAGENSTATIONS_NR)
        THEN
          IF ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig ) THEN
            starrTransfershuttleBasisParameter[wlAustransportstation].InGlasTransportVorgaenger[wWand] := starrFaecherwagenBasisParameter[Auftragsdaten.wTransferstationsNr2].OutGlasTransport[cWAND_1];
	        ELSE
            starrTransfershuttleBasisParameter[wlAustransportstation].InGlasTransportNachfolger[wWand] := starrFaecherwagenBasisParameter[Auftragsdaten.wTransferstationsNr2].OutGlasTransport[cWAND_1];
          END_IF
        END_IF

        (* Hinweis:
           - Neuen Auftag in den FIFO [Warteschlange] eintragen
        *)
        Job_Shuttle.AuftragsdatenTransfershuttle[wlAustransportstation]          := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
        Job_Shuttle.AuftragsdatenTransfershuttle[wlAustransportstation].wAuftrag := eStation_Eintransport;
	  
	      starrShuttleBasisParameter[wStation].bScheibentrennen[wWand]                := FALSE; 
	      starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand]      := ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig );
	      starrShuttleBasisParameter[wStation].bAustransport[wWand]                   := TRUE;
	      starrShuttleBasisParameter[wStation].bTransferstationTransfershuttle[wWand] := TRUE;
	  
        steplSchritt := STEP_400_E;

(*AUSTRANSPORT ===============================================*)
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
        starrTransfershuttleBasisParameter[wlAustransportstation].InGlasTransportVorgaenger[wWand] := starrShuttleBasisParameter[wStation].OutGlasTransport[wWand];
        starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrTransfershuttleBasisParameter[wlAustransportstation].OutGlasTransport[wWand];

      ELSE
        starrTransfershuttleBasisParameter[wlAustransportstation].InGlasTransportNachfolger[wWand] := starrShuttleBasisParameter[wStation].OutGlasTransport[wWand];
        starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrTransfershuttleBasisParameter[wlAustransportstation].OutGlasTransport[wWand];

      END_IF

      (* Hinweis:
         - Transfershuttle koppeln
      *)
      aTransfershuttles[wlAustransportstation].stpInTransportVerbund  := aTransfershuttles[Auftragsdaten.wTransferstationsNr2].stpOutTransportVerbund;
      aTransfershuttles[Auftragsdaten.wTransferstationsNr2].stpInTransportVerbund   := aTransfershuttles[wlAustransportstation].stpOutTransportVerbund;

      (* Hinweis:
         - Auftragsdaten an die Transfershuttle uebergeben
      *)
      Job_Shuttle.AuftragsdatenTransfershuttle[wlAustransportstation]          := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
      Job_Shuttle.AuftragsdatenTransfershuttle[wlAustransportstation].wAuftrag := eStation_Eintransport;

      Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2]           := AuftragsdatenUmkopieren(TRUE, FALSE, Auftragsdaten);
      Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2].wAuftrag  := eStation_Transportkopplung;

   
	    starrShuttleBasisParameter[wStation].bScheibentrennen[wWand]                := FALSE; 
	    starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand]      := ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig );
	    starrShuttleBasisParameter[wStation].bAustransport[wWand]                   := TRUE;
	    starrShuttleBasisParameter[wStation].bTransferstationTransfershuttle[wWand] := TRUE;
	  
      steplSchritt := STEP_400_E;

(*AUSTRANSPORT ===============================================*)
    STEP_400_E:
      (* ---------------------------------------------------------------------------------------
      //  QUITTIERUNGEN UND EINTRANSPORT- ABSCHLUSS
      //         
      //  Hinweis:
      //  - Scheibenquittieren: Message zur MMI
      // ---------------------------------------------------------------------------------------*)
      blStationQuittiertScheiben := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[wlAustransportstation];

      IF ( starrShuttleBasisParameter[wStation].OutGlasTransport[wWand].bQuittScheibe ) THEN

        IF ( ilScheibenZuQuittieren > 0 ) THEN

          wSps2MmiZielStation  := Auftragsdaten.wTransferstationsNr1;
          wSps2MmiQuellStation := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          wSps2MmiZielWand     := Auftragsdaten.wTransferwand;
          wSps2MmiQuellWand    := wWand;
          dwSps2MmiWartezeit   := starrShuttleBasisParameter[wStation].dwWartezeit[wWand];
          wSPS2MMIAuftragstyp  := 1;

          MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
        END_IF

        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;

      END_IF

      (* Hinweis:
         - Abschliessen des Austransports
      *)
      IF ( starrShuttleBasisParameter[wStation].bAustransportAbgeschlossen[wWand] ) THEN

        starrShuttleBasisParameter[wStation].bAustransport[wWand]                 := FALSE;
        starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand]    := FALSE;

        steplSchritt := STEP_410_E;
      END_IF

      (* Fehlerbehandlung
         - Inputshuttle
      *)
      IF ( starrShuttleBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrShuttleBasisParameter[wStation].wFehlerNummer,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrShuttleBasisParameter[wStation].awFehlerInformationen );

        steplSchritt := STEP_900_E;
      END_IF

(*AUSTRANSPORT ==============================================*)
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
                  cMELDUNG_STATION_ZUWENIG_SCHEIBEN_QUITTIERT_WAND_AUSTRANSPORT,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );

        steplSchritt := STEP_900_E;

        (* Anmerkung:
           - Zu viele Scheiben quittiert
        *)
      ELSIF ( ilScheibenZuQuittieren < 0 ) THEN
        wpgFehlerdaten[0] := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := wWand;

        SpsError( eFehler_Station,
                  cMELDUNG_STATION_ZUVIELE_SCHEIBEN_QUITTIERT_WAND_AUSTRANSPORT,
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );

        steplSchritt := STEP_900_E;
      END_IF

(*AUSTRANSPORT ===============================================*)
    STEP_900_E:
      bpFehler := TRUE;

(*AUSTRANSPORT ===============================================*)
    STEP_1000_E:
      bpDone := TRUE;
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

(*AUSTRANSPORT ===============================================*)
  END_CASE

END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpDone := FALSE;
  bpReset := FALSE;
  starrShuttleBasisParameter[wStation].bAustransport[wWand] := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK