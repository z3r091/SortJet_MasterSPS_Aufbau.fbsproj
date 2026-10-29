(* METADATA
{
	"v3Meta": {
		"objectGuid": "2b51cd18-a11d-48d6-a685-bb5f301afb70"
	}
}
*)
FUNCTION_BLOCK Station_Durchtransport
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
  blStationQuittiertScheiben             : BOOL;
  blKopplungGefundenEintransport         : BOOL;
  blKopplungGefundenAustransport         : BOOL;
  
  (* INT *)
  ilScheibenZuQuittieren : INT;
  
  (* WORD *)
  wlEintransportstation : WORD;
  wlAustransportstation : WORD;

  (* STEPS *)
  steplSchritt           : STEPS_TE;

END_VAR

(***************************************************************************************************)
(* STEUERUNG DURCHTRANSPORT *)
(***************************************************************************************************)
IF Auftragsdaten.wAuftrag = eStation_Durchtransport THEN
   CASE steplSchritt OF
(* DURCHTRANSPORT ================================= *)
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
        steplSchritt := STEP_10_E;
      END_IF

(* DURCHTRANSPORT ================================================== *)
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

(* DURCHTRANSPORT ================================= *)
     STEP_20_E:
      (* Hinweis
         - Uebergabe der Quellstation [Sender] fuer den Austransport [Zum ueberpruefen des Zustandes der Station]       
      *)
      wlEintransportstation := Auftragsdaten.wTransferstationsNr1;
      wlAustransportstation := Auftragsdaten.wTransferstationsNr2;
	  
       (* Hinweis:
          - Zuweisung Transportkopplung
       *)
      CASE wlEintransportstation OF

	    // Shuttles
        cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Vorwaertig ) THEN
            starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrShuttleBasisParameter[wlEintransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
          ELSE
            starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrShuttleBasisParameter[wlEintransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
          END_IF
		  blKopplungGefundenEintransport := TRUE;

	    // Stationen
        cERSTE_STATION..cLETZTE_STATION:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Vorwaertig ) THEN
            starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[wlEintransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
          ELSE
            starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[wlEintransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
	      END_IF
		  blKopplungGefundenEintransport := TRUE;

        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlAustransportstation] = Vorwaertig ) THEN
            starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].OutGlasTransport[cWAND_1];
          ELSE
            starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].OutGlasTransport[cWAND_1];
	      END_IF
		  blKopplungGefundenEintransport := TRUE;

        ELSE
          wpgFehlerdaten[0] := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
          wpgFehlerdaten[1] := wlEintransportstation;
          SpsError( eFehler_Station,
                    cMELDUNG_AUFTRAGSDATEN_FALSCHE_EINLAUFSTATION,
                    starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );

          steplSchritt := STEP_900_E;

      END_CASE

       (* Hinweis:
          - Zuweisung Transportkopplung
       *)
      CASE wlAustransportstation OF

	    // Shuttles
        cERSTES_SHUTTLE..cLETZTES_SHUTTLE:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Vorwaertig ) THEN
            starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrShuttleBasisParameter[wlAustransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
          ELSE
            starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrShuttleBasisParameter[wlAustransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
          END_IF
		  blKopplungGefundenAustransport := TRUE;

	    // Stationen
        cERSTE_STATION..cLETZTE_STATION:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Vorwaertig ) THEN
            starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[wlAustransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
          ELSE
            starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[wlAustransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
	      END_IF
		  blKopplungGefundenAustransport := TRUE;

        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Vorwaertig ) THEN
            starrStationBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].OutGlasTransport[cWAND_1];
          ELSE
            starrStationBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].OutGlasTransport[cWAND_1];
	      END_IF
		  blKopplungGefundenAustransport := TRUE;
		  
        ELSE
          wpgFehlerdaten[0] := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
          wpgFehlerdaten[1] := wlAustransportstation;
          SpsError( eFehler_Station,
                    cMELDUNG_AUFTRAGSDATEN_FALSCHE_AUSLAUFSTATION,
                    starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );

          steplSchritt := STEP_900_E;

      END_CASE
	  
	  IF blKopplungGefundenEintransport AND blKopplungGefundenEintransport THEN
        steplSchritt := STEP_30_E;
	  END_IF

(* DURCHTRANSPORT ================================= *)
     STEP_30_E:

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
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Kippen[wlEintransportstation];

      IF ( Auftragsdaten.rAuftragsDicke < wgUnterteilerMinMaxGlasdicke ) THEN
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung16mm;
      ELSE
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung29mm;
      END_IF
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachAustransport := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachAustransport := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eGlastransport := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eHub := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eQuerachse := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eAchsrichtung := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.wMaxTransportGeschwindigkeit:= 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDrehen_Sollposition_NachEintransport := 0;
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition_NachEintransport := 0;

      starrStationBasisParameter[wStation].bScheibentrennen[wWand]           := FALSE;
      starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Rueckwaertig ) 
                                                                            AND ( starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig );
      starrStationBasisParameter[wStation].bDurchtransport[wWand]            := TRUE;

      steplSchritt := STEP_40_E;

(* AUSTRANSPORT ================================= *)
     STEP_40_E:

      (* Hinweis:
         - Scheibenzaehler dekrementieren
         - Scheibe quittieren, sofern dies nötig ist
      *)
      blStationQuittiertScheiben := TRUE;
      
      IF ( starrStationBasisParameter[wStation].OutGlasTransport[wWand].bQuittScheibe ) THEN

        IF ( ilScheibenZuQuittieren > 0 ) AND blStationQuittiertScheiben THEN

          wSps2MmiZielStation  := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          wSps2MmiQuellStation := wlEintransportstation;
          wSps2MmiZielWand     := Auftragsdaten.wStationsWand;
          wSps2MmiQuellWand    := Auftragsdaten.wTransferwand;
          dwSps2MmiWartezeit   := starrStationBasisParameter[wStation].dwWartezeit[wWand];
          wSPS2MMIAuftragstyp  := 0;

          MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
          
        END_IF

        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;

      END_IF

      (* Hinweis:
         - Abschliessen des Austransport
      *)
      IF ( starrStationBasisParameter[wStation].bDurchtransportAbgeschlossen[wWand] ) THEN
        starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
        starrStationBasisParameter[wStation].bDurchtransport[wWand] := FALSE;
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
                  starrStationBasisParameter[wStation].awFehlerInformationen 
                 );
        starrStationBasisParameter[wStation].bDurchtransport[wWand] := FALSE;
        starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

(* DURCHTRANSPORT ================================= *)
     STEP_900_E:
       bpFehler := TRUE;

(* DURCHTRANSPORT ================================= *)
     STEP_1000_E:
       bpDone := TRUE;
       Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

   END_CASE

END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpReset := FALSE;
  bpDone := FALSE;
  steplSchritt := STEP_0_E;
  starrStationBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
  starrStationBasisParameter[wStation].bDurchtransport[wWand] := FALSE;
END_IF
END_FUNCTION_BLOCK