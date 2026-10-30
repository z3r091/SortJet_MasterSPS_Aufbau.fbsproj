(* METADATA
{
	"v3Meta": {
		"objectGuid": "db6c6d03-f822-435f-8f93-f5a504a5ce8d"
	}
}
*)
FUNCTION_BLOCK Station_Eintransport
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
  blGegenstelleIstShuttle    : BOOL;
  
  (* WORD *)
  wlEintransportstation  : WORD;

  (* INT *)
  ilScheibenZuQuittieren : INT;

  (* REFERENZ *)
  Gegenstelle            : REFERENCE TO StationBasisParameter_ST;

  (* STEPS *)
  steplSchritt           : STEPS_TE;

END_VAR

(***************************************************************************************************)
(* STEUERUNG: EINTRANSPORT  *)
(***************************************************************************************************)
IF ( Auftragsdaten.wAuftrag = eStation_Eintransport ) THEN
  CASE steplSchritt OF
(* EINTRANSPORT ================================================== *)
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation])  OR bgInbetriebnahmeBit THEN
        steplSchritt := STEP_10_E;
      END_IF

(* EINTRANSPORT ================================================== *)
    STEP_10_E:
      (* ---------------------------------------------------------------------------------------
      //  OPTIONALE - PRUEFUNG DER GLASDATEN
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)
      steplSchritt := STEP_20_E;

      IF NOT AuftragsdatenPruefen( wStation, wWand, Auftragsdaten) THEN
        steplSchritt := STEP_900_E;
      END_IF

(* EINTRANSPORT ================================================== *)
    STEP_20_E:
      (* ---------------------------------------------------------------------------------------
      //  OPTIONALE - PRUEFUNG DER GLASDATEN
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)
	  
      // Glastyp festlegen
      IF ( Auftragsdaten.rAuftragsLaenge > starrStationBasisParameter[wStation].stMKs.stStationsParameter.rLaengeUebergroesseScheibe ) THEN
        starrStationBasisParameter[wStation].wGlasTyp[wWand] := eScheibe_Maximal;
	    ELSE
        starrStationBasisParameter[wStation].wGlasTyp[wWand] := eScheibe_Default;    
      END_IF
	  
     steplSchritt := STEP_30_E;

(* EINTRANSPORT ================================================== *)
    STEP_30_E:
      (* Hinweis
         - Uebergabe der Quellstation [Sender] fuer den Austransport [Zum ueberpruefen des Zustandes der Station]       
      *)
      wlEintransportstation := Auftragsdaten.wTransferstationsNr1;
	  
      (* Hinweis:
         - Zuweisung Transportkopplung
      *)
      CASE wlEintransportstation OF

	      // Shuttles
        cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[Auftragsdaten.wTransferstationsNr1] = Vorwaertig ) THEN
            starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrShuttleBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
          ELSE
            starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrShuttleBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
          END_IF
          
          steplSchritt := STEP_40_E;

	      // Stationen
        cERSTE_STATION..cLETZTE_STATION:

          (* Hinweis:
             - Ist die Gegenstelle selbst ein Shuttle, bekommt sie keinen Auftrag von uns, wir bekommen ihn von ihr
          *)
          Gegenstelle REF= getBasis( wlEintransportstation );
          blGegenstelleIstShuttle := __ISVALIDREF( Gegenstelle ) AND_THEN __ISVALIDREF( Gegenstelle.stMKs ) AND_THEN Gegenstelle.stMKs.stSchnittstellendaten.bStationIstShuttle;

          IF ( ( Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand].wAuftrag = eStation_Belegt )
            OR ( Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand].wAuftrag = eStation_Warte_Auf_Austransport ) )
			      OR blGegenstelleIstShuttle
          THEN

             // Ist der Vorgänger ein Shuttle, dann keinen Auftrag schreiben... Wir kriegen dann den Auftrag von ihm          
		        IF NOT blGegenstelleIstShuttle THEN
              Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand]          := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
              Job_Stationen.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand].wAuftrag := eStation_Austransport;
            END_IF
          
            // Transportkopplung
            IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[Auftragsdaten.wTransferstationsNr1] = Vorwaertig ) THEN
              starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
            ELSE
              starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[Auftragsdaten.wTransferstationsNr1].OutGlasTransport[Auftragsdaten.wTransferwand];
	          END_IF
          
            steplSchritt := STEP_40_E;
          END_IF

        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
          ;
		  
        cERSTE_FREMDANLAGE_EINLAUF..cLETZTE_FREMDANLAGE_EINLAUF:
          ;
		  
        cERSTE_FAECHERWAGENSTATIONS_NR..cLETZTE_FAECHERWAGENSTATIONS_NR:
          ;

      ELSE
        wpgFehlerdaten[0] := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := wlEintransportstation;
        SpsError( eFehler_Station,
                  cMELDUNG_AUFTRAGSDATEN_FALSCHE_EINLAUFSTATION,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );

        steplSchritt := STEP_900_E;

      END_CASE
	  
(* EINTRANSPORT ================================================== *)
    STEP_40_E:
      (* Hinweis:
         - Scheibenquittierung 
      *)
      ilScheibenZuQuittieren := WORD_TO_INT(Auftragsdaten.wAnzahlScheiben);
	  
      (* Hinweis:
         Auftragsdaten zuweisen
      *)
      starrStationBasisParameter[wStation].pAuftrag[wWand] := Auftragsdaten;
	  
      (* Hinweis:
         - Auftrags- Optionen bestimmen und zuweisen
      *)
	  // Kippen
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition                  := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Kippen[Auftragsdaten.wTransferstationsNr1];
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachEintransport := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.KippenNachEintransport[Auftragsdaten.wTransferstationsNr1];
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachAustransport := 0;  
		  
      IF ( Auftragsdaten.rAuftragsDicke < wgMKScheibenDicke13mm ) THEN
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung16mm;
      ELSIF ( Auftragsdaten.rAuftragsDicke <= wgMKScheibenDicke19mm ) THEN
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung23mm;
      ELSE
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung29mm;
      END_IF

      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition := REAL_TO_WORD(Auftragsdaten.rStationsZielposition);
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport := REAL_TO_WORD(Auftragsdaten.rTransferposition2);
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachAustransport := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eGlastransport := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eHub := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eQuerachse := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eAchsrichtung := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Achsrichtung[Auftragsdaten.wTransferstationsNr1];
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.wMaxTransportGeschwindigkeit:= 0;
      
      IF ( Auftragsdaten.wTransferwand = cWAND_1 ) THEN
        starrStationBasisParameter[wStation].bScheibentrennen[wWand] := NOT Auftragsdaten.stAuftragsInformationen.cBIT_SRC_WALL_1_EMPTY;
      ELSE
        starrStationBasisParameter[wStation].bScheibentrennen[wWand] := NOT Auftragsdaten.stAuftragsInformationen.cBIT_SRC_WALL_2_EMPTY;
	  END_IF
      starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[Auftragsdaten.wTransferstationsNr1] = Rueckwaertig );

      steplSchritt := STEP_45_E;

(* EINTRANSPORT ================================================== *)
    STEP_45_E:
	  // Im Step 45 wird in dem vererbten FB Anlagenspezifische Auftragsoptionen gesetzt      
      starrStationBasisParameter[wStation].bEintransport[wWand] := TRUE;
      steplSchritt := STEP_50_E;
	
(* EINTRANSPORT ================================================== *)
    STEP_50_E:
      (* Hinweis:
         - Scheibenzaehler dekrementieren
         - Scheibe quittieren, sofern dies nötig ist
      *)
      blStationQuittiertScheiben := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[wlEintransportstation];
        
      IF ( starrStationBasisParameter[wStation].OutGlasTransport[wWand].bQuittScheibe ) THEN

        IF ( ilScheibenZuQuittieren > 0 ) AND blStationQuittiertScheiben THEN

          wSps2MmiZielStation  := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          wSps2MmiQuellStation := Auftragsdaten.wTransferstationsNr1;
          wSps2MmiZielWand     := Auftragsdaten.wStationsWand;
          wSps2MmiQuellWand    := Auftragsdaten.wTransferwand;
          dwSps2MmiWartezeit   := starrStationBasisParameter[wStation].dwWartezeit[wWand];
          wSPS2MMIAuftragstyp  := 0;

          MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
          
        END_IF

        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;

      END_IF

      (* Hinweis:
         - Abschliessen des Eintransports
      *)
      IF ( starrStationBasisParameter[wStation].bEintransportAbgeschlossen[wWand] ) THEN
        starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
        starrStationBasisParameter[wStation].bEintransport[wWand] := FALSE;
        steplSchritt := STEP_1000_E;
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
						
        starrStationBasisParameter[wStation].bEintransport[wWand] := FALSE;
        starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

(* EINTRANSPORT ================================================== *)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  OPTIONAL - PRUEFUNG DER SCHEIBENQUITTIERUNG
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      IF ( ilScheibenZuQuittieren = 0) THEN
        steplSchritt := STEP_1000_E;

      (* Anmerkung:
         - Zu wenig Scheiben quittiert
      *)
      ELSIF ( ilScheibenZuQuittieren > 0 ) THEN
        wpgFehlerdaten[0] := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := wWand;
        SpsError( eFehler_Station, 
                  cMELDUNG_STATION_ZUWENIG_SCHEIBEN_QUITTIERT_EINTRANSPORT, 
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
                  cMELDUNG_STATION_ZUVIELE_SCHEIBEN_QUITTIERT_EINTRANSPORT, 
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern, 
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern), 
                  wpgFehlerdaten );
        steplSchritt := STEP_900_E;

      END_IF

(* EINTRANSPORT ================================================== *)
    STEP_900_E:
      bpFehler := TRUE;

(* EINTRANSPORT ================================================== *)
    STEP_1000_E:
      bpDone := TRUE;
	  IF starrStationBasisParameter[wStation].stMKs.stStationsOptionen.bScheibeAbnehmenNachEintransport THEN
        Auftragsdaten.wAuftrag := eStation_Abnehmen;
	  ELSIF Auftragsdaten.bLetzteScheibe THEN
        Auftragsdaten.wAuftrag := eStation_Warte_Auf_Austransport;
	  ELSE
        Auftragsdaten.wAuftrag := eStation_Belegt;
	  END_IF

(* EINTRANSPORT ================================================== *)
 END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpReset := FALSE;
  bpDone := FALSE;
  steplSchritt := STEP_0_E;
  starrStationBasisParameter[wStation].bScheibentrennen[wWand] := FALSE;
  starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
  starrStationBasisParameter[wStation].bEintransport[wWand] := FALSE;
END_IF
END_FUNCTION_BLOCK