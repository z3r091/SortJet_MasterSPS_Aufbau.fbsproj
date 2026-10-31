(* METADATA
{
	"v3Meta": {
		"objectGuid": "d20ae107-ce5b-4166-b2bd-9e4de3a442ef"
	}
}
*)
FUNCTION_BLOCK Shuttle_Durchtransport
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
  
  (* WORD *)
  wlEintransportstation : WORD;
  wlAustransportstation : WORD;

  (* INT *)
  ilScheibenZuQuittieren : INT;
  
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
      IF checkSafetyCircuitsNotBlocked(starrShuttleBasisParameter[wStation]) AND NOT bgShuttleEintransportSperren[wStation] AND NOT bgShuttleAustransportSperren[wStation]  THEN
        steplSchritt := STEP_10_E;
      END_IF

(* DURCHTRANSPORT ================================================== *)
    STEP_10_E:
      (* Auftragsdaten pruefen:
        - Sollte es fehler in der Auftragsdatenstruktur geben wird in den Fehlerschritt 900
          gesprungen. Die Fehlerauswertung findet in der Funktion Shuttledaten_Pruefen statt.
      *)
      steplSchritt := STEP_20_E;

      IF NOT AuftragsdatenPruefen( wStation, wWand, Auftragsdaten) THEN
        steplSchritt := STEP_900_E;
      END_IF

(* DURCHTRANSPORT ================================= *)
     STEP_20_E:
      (* Hinweis:
         - Kopplung fuer diesen Auftrag neu bestimmen. Sonst ueberschreibt ein Merker aus dem letzten Auftrag den Fehlerschritt.
      *)
      blKopplungGefundenEintransport := FALSE;
      blKopplungGefundenAustransport := FALSE;

      (* Hinweis
         - Uebergabe der Quellstation [Sender] fuer den Austransport [Zum ueberpruefen des Zustandes der Station]       
      *)
      wlEintransportstation := Auftragsdaten.wTransferstationsNr1;
      wlAustransportstation := Auftragsdaten.wTransferstationsNr2;
	  
       (* Hinweis:
          - Zuweisung Transportkopplung
       *)
      CASE wlEintransportstation OF

	    // Stationen
        cERSTE_STATION..cLETZTE_STATION:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Vorwaertig ) THEN
            starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[wlEintransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
          ELSE
            starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[wlEintransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
	        END_IF
		      blKopplungGefundenEintransport := TRUE;

        ELSE
          wpgFehlerdaten[0] := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
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

	    // Stationen
        cERSTE_STATION..cLETZTE_STATION:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Vorwaertig ) THEN
            starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrStationBasisParameter[wlAustransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
          ELSE
            starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrStationBasisParameter[wlAustransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
	      END_IF
		  blKopplungGefundenAustransport := TRUE;

        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
          (* Hinweis:
             - Transportkopplung 
          *)
          IF ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Vorwaertig ) THEN
            starrShuttleBasisParameter[wStation].InGlasTransportNachfolger[wWand] := starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].OutGlasTransport[cWAND_1];
          ELSE
            starrShuttleBasisParameter[wStation].InGlasTransportVorgaenger[wWand] := starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].OutGlasTransport[cWAND_1];
	      END_IF
		  blKopplungGefundenAustransport := TRUE;
		  
        ELSE
          wpgFehlerdaten[0] := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
          wpgFehlerdaten[1] := wlAustransportstation;
          SpsError( eFehler_Station,
                    cMELDUNG_AUFTRAGSDATEN_FALSCHE_AUSLAUFSTATION,
                    starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );

          steplSchritt := STEP_900_E;

      END_CASE
	  
	  IF blKopplungGefundenEintransport AND blKopplungGefundenAustransport THEN
        steplSchritt := STEP_30_E;
	  END_IF

(* DURCHTRANSPORT ================================= *)
     STEP_30_E:

      (* Hinweis:
         - Scheibenquittierung 
      *)
      ilScheibenZuQuittieren := WORD_TO_INT(Auftragsdaten.wAnzahlScheiben);
	  
      (* Hinweis:
         - Auftrags- Optionen bestimmen und zuweisen
      *)
      Auftragsdaten.stAuftragsOptionen.eKippen_SollPosition := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Kippen[wlEintransportstation];

      IF ( Auftragsdaten.rAuftragsDicke < wgUnterteilerMinMaxGlasdicke ) THEN
        Auftragsdaten.stAuftragsOptionen.eDickenverstellung := eZylinderStellung16mm;
      ELSE
        Auftragsdaten.stAuftragsOptionen.eDickenverstellung := eZylinderStellung23mm;
      END_IF
      Auftragsdaten.stAuftragsOptionen.eDrehen_Sollposition := 0;
      Auftragsdaten.stAuftragsOptionen.eDrehen_Sollposition_NachAustransport := 0;
      Auftragsdaten.stAuftragsOptionen.eKippen_SollPosition_NachAustransport := 0;
      Auftragsdaten.stAuftragsOptionen.eGlastransport := 0;
      Auftragsdaten.stAuftragsOptionen.eHub := 0;
      Auftragsdaten.stAuftragsOptionen.eQuerachse := 0;
      Auftragsdaten.stAuftragsOptionen.eAchsrichtung := 0;
      Auftragsdaten.stAuftragsOptionen.wMaxTransportGeschwindigkeit:= 0;
      Auftragsdaten.stAuftragsOptionen.eDrehen_Sollposition_NachEintransport := 0;
      Auftragsdaten.stAuftragsOptionen.eKippen_SollPosition_NachEintransport := 0;
      
      (* Hinweis:
         Auftragsdaten zuweisen und Eintransport der Station starten
      *)
      starrShuttleBasisParameter[wStation].pAuftrag[wWand] := Auftragsdaten;

      starrShuttleBasisParameter[wStation].bScheibentrennen[wWand]           := FALSE;
      starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Rueckwaertig ) 
                                                                            AND ( starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig );
      starrShuttleBasisParameter[wStation].bDurchtransport[wWand]            := TRUE;

      steplSchritt := STEP_40_E;

(* AUSTRANSPORT ================================= *)
     STEP_40_E:

      (* Hinweis:
         - Scheibenzaehler dekrementieren
         - Scheibe quittieren, sofern dies nötig ist
      *)
      blStationQuittiertScheiben := starrShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[wlEintransportstation];
      
      IF ( starrShuttleBasisParameter[wStation].OutGlasTransport[wWand].bQuittScheibe ) THEN

        IF ( ilScheibenZuQuittieren > 0 ) AND blStationQuittiertScheiben THEN

          wSps2MmiZielStation  := starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          wSps2MmiQuellStation := wlEintransportstation;
          wSps2MmiZielWand     := Auftragsdaten.wStationsWand;
          wSps2MmiQuellWand    := Auftragsdaten.wTransferwand;
          dwSps2MmiWartezeit   := starrShuttleBasisParameter[wStation].dwWartezeit[wWand];
          wSPS2MMIAuftragstyp  := 0;

          MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
          
        END_IF

        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;

      END_IF

      (* Hinweis:
         - Abschliessen des Austransport
      *)
      IF ( starrShuttleBasisParameter[wStation].bDurchtransportAbgeschlossen[wWand] ) THEN
        starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
        starrShuttleBasisParameter[wStation].bDurchtransport[wWand] := FALSE;
        steplSchritt := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Station
      *)
      IF ( starrShuttleBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station, 
                  starrShuttleBasisParameter[wStation].wFehlerNummer, 
                  starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern, 
                  AutomatikkreisBestimmen(starrShuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrShuttleBasisParameter[wStation].awFehlerInformationen );
						
        starrShuttleBasisParameter[wStation].bDurchtransport[wWand] := FALSE;
        starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
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
  blKopplungGefundenEintransport := FALSE;
  blKopplungGefundenAustransport := FALSE;
  steplSchritt := STEP_0_E;
  starrShuttleBasisParameter[wStation].bRueckwaertsTransportieren[wWand] := FALSE;
  starrShuttleBasisParameter[wStation].bDurchtransport[wWand] := FALSE;
END_IF
END_FUNCTION_BLOCK