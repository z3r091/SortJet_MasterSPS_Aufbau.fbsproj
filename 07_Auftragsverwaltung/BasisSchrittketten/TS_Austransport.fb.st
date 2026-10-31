(* METADATA
{
  "v3Meta": {
    "objectGuid": "0f3a9f54-24b3-4180-b764-650377bf6b92"
  }
}
*)
FUNCTION_BLOCK TS_Austransport
VAR_INPUT
    
  (* BOOLEAN *)
  bpReset                : BOOL;
  
  (* WORD *)
  wStation               : WORD;
  
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
(* STEUERUNG: AUSTRANSPORT  *)
(***************************************************************************************************)
IF ( Auftragsdaten.wAuftrag = eStation_Austransport ) THEN
  CASE steplSchritt OF
(*AUSTRANSPORT  ===========================================*)
    STEP_0_E:
      (* Hinweis:
         - Sicherheitskreis puefen
         - Austransport aktiv 
      *)
      IF ( checkSafetyCircuitsNotBlocked(starrTransferShuttleBasisParameter[wStation])
        AND NOT starrTransfershuttleBasisParameter[wStation].bReset )
      THEN
         steplSchritt := STEP_10_E;
      END_IF

(*AUSTRANSPORT  ===========================================*)
    STEP_10_E:
      (* Anmerkung
         - Zielstation abfragen ob diese bereit ist zum Austransport         
      *)
	    wlAustransportstation := Auftragsdaten.wTransferstationsNr1;
      ilScheibenZuQuittieren := WORD_TO_INT(Auftragsdaten.wAnzahlScheiben);

      starrTransfershuttleBasisParameter[wStation].bRueckwaertsTransportieren[cWAND_1] := FALSE;

      CASE wlAustransportstation OF

        (* Hinweis:
           - Verfahrbahrer Speicher
        *)
        cERSTE_FREMDANLAGE_AUSLAUF..cLETZTE_FREMDANLAGE_AUSLAUF:
		      starrTransfershuttleBasisParameter[wStation].InGlasTransportNachfolger[cWAND_1] := starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].OutGlasTransport[cWAND_1];
          starrFremdanlageAuslaufStationBasisParameter[wlAustransportstation].InGlasTransportVorgaenger[cWAND_1] := starrTransfershuttleBasisParameter[wStation].OutGlasTransport[cWAND_1];
          steplSchritt := STEP_20_E;

        cERSTE_STATION..cLETZTE_STATION:
          IF ( Job_Stationen.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag  = eStation_Eintransport ) THEN
		        starrTransfershuttleBasisParameter[wStation].InGlasTransportNachfolger[cWAND_1] := starrStationBasisParameter[wlAustransportstation].OutGlasTransport[Auftragsdaten.wTransferwand];
            steplSchritt := STEP_20_E;
          END_IF
		  
          (* Ausnahmesituation:
             - Shuttle hat den falschen Auftragsstatus 
          *)
          IF ( Job_Stationen.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag  <> eStation_Eintransport ) THEN
            wpgFehlerdaten[0] := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
            wpgFehlerdaten[1] := wlAustransportstation;
            wpgFehlerdaten[2] := Job_Stationen.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag;

            SpsError( eFehler_Station,
                      cMELDUNG_AUFTRAGSDATEN_AUFTRAGSTATUS_GLAS_EMPFAENGER_UNGUELTIG,
                      starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                      wpgFehlerdaten
                     );
            steplSchritt := STEP_900_E;
          END_IF
		
        (* Hinweis:
           - Ruecktransport durch den Speicher beruecksichtigen
        *)
        cERSTES_INPUTSHUTTLE..cLETZTES_INPUTSHUTTLE,
        cERSTES_OUTPUTSHUTTLE..cLETZTES_OUTPUTSHUTTLE:
          IF ( Job_Shuttle.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag  = eStation_Eintransport ) THEN
            steplSchritt := STEP_20_E;
          END_IF

          (* Ausnahmesituation:
             - Shuttle hat den falschen Auftragsstatus 
          *)
          IF ( Job_Shuttle.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag  <> eStation_Eintransport ) THEN
            wpgFehlerdaten[0] := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
            wpgFehlerdaten[1] := wlAustransportstation;
            wpgFehlerdaten[2] := Job_Shuttle.AuftragsdatenWand[wlAustransportstation, Auftragsdaten.wTransferwand].wAuftrag;

            SpsError( eFehler_Station,
                      cMELDUNG_AUFTRAGSDATEN_AUFTRAGSTATUS_GLAS_EMPFAENGER_UNGUELTIG,
                      starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                      wpgFehlerdaten
                     );
            steplSchritt := STEP_900_E;
          END_IF

      END_CASE

      (* Fehlerbehandlung:
         - Shuttle
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrTransfershuttleBasisParameter[wStation].wFehlerNummer,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrTransfershuttleBasisParameter[wStation].awFehlerInformationen );

        steplSchritt := STEP_900_E;
      END_IF

(*AUSTRANSPORT  ===========================================*)
    STEP_20_E:
      (* Hinweis:
         - Starten des Austransport
      *)
      starrTransfershuttleBasisParameter[wStation].pAuftrag[cWAND_1] := Auftragsdaten;
      starrTransfershuttleBasisParameter[wStation].bAustransport[cWAND_1] := TRUE;
      starrTransfershuttleBasisParameter[wStation].bRueckwaertsTransportieren[cWAND_1] := ( starrTransferShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.Station[wlAustransportstation] = Rueckwaertig );
      ilScheibenZuQuittieren := WORD_TO_INT( Auftragsdaten.wAnzahlScheiben);
	  
      steplSchritt := STEP_400_E;

(*AUSTRANSPORT ===============================================*)
    STEP_400_E:
      (* ---------------------------------------------------------------------------------------
      //  QUITTIERUNGEN UND AUSTRANSPORT- ABSCHLUSS
      //         
      //  Hinweis:
      //  - Scheibenquittieren: Message zur MMI
      // ---------------------------------------------------------------------------------------*)

      IF ( starrTransfershuttleBasisParameter[wStation].OutGlasTransport[cWAND_1].bQuittScheibe ) THEN

        IF ( ilScheibenZuQuittieren > 0 ) AND starrTransfershuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aAustransporte.bStationQuittiertScheibe[wlAustransportstation] THEN

          wSps2MmiZielStation  := Auftragsdaten.wTransferstationsNr1;
          wSps2MmiQuellStation := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          wSps2MmiZielWand     := Auftragsdaten.wTransferwand;
          wSps2MmiQuellWand    := cWAND_1;
          dwSps2MmiWartezeit   := starrTransfershuttleBasisParameter[wStation].dwWartezeit[cWAND_1];
          wSPS2MMIAuftragstyp  := 1;

          MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
        END_IF

        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;

      END_IF

      (* Hinweis:
         - Abschliessen des Austransports
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bAustransportAbgeschlossen[cWAND_1] ) THEN

        starrTransfershuttleBasisParameter[wStation].bAustransport[cWAND_1]                 := FALSE;
        starrTransfershuttleBasisParameter[wStation].bRueckwaertsTransportieren[cWAND_1]    := FALSE;

        steplSchritt := STEP_410_E;
      END_IF

      (* Fehlerbehandlung
         - Transfershuttle
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bFehler ) THEN

        IF ( aTransfershuttles[wStation].bpAnforderungBetriebsstopp ) THEN

          (* Hinweis:
             - Ausnahmefehler des TS an die MMI melden
          *)
          IF ( bgAktivierungTransfershuttleSystemcheck ) THEN
            wgSps2MmiShuttleNr                 := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
            wSps2MmiFehlertyp                  := aTransfershuttles[wStation].wpAusnahmefehlerTyp;
            MsgToMmi(auftragsnr_w := SB0_SPS_TRANSFERSHUTTLEFEHLER );
          END_IF

          bpFehler := TRUE;

        END_IF

        starrTransfershuttleBasisParameter[wStation].bAustransport[cWAND_1] := FALSE;
        SpsError( eFehler_Station,
                  starrTransfershuttleBasisParameter[wStation].wFehlerNummer,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrTransfershuttleBasisParameter[wStation].awFehlerInformationen );

        steplSchritt := STEP_900_E;
      END_IF

(*AUSTRANSPORT ==============================================*)
    STEP_410_E:
      (* Anmerkung:
         - Gueltige Anzahl von Scheiben wurden quittiert
      *)
      IF ( ilScheibenZuQuittieren = 0 ) THEN  
        starrTransfershuttleBasisParameter[wStation].bAustransport[cWAND_1] := FALSE;
        steplSchritt := STEP_1000_E;

      (* Anmerkung:
         - Zu wenig Scheiben quittiert
      *)
      ELSIF ( ilScheibenZuQuittieren > 0 ) THEN
        wpgFehlerdaten[0] := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := cWAND_1;

        SpsError( eFehler_Station,
                  cMELDUNG_STATION_ZUWENIG_SCHEIBEN_QUITTIERT_WAND_AUSTRANSPORT,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );

                starrTransfershuttleBasisParameter[wStation].bAustransport[cWAND_1] := FALSE;
                steplSchritt := STEP_900_E;

        (* Anmerkung:
           - Zu viele Scheiben quittiert
        *)
      ELSIF ( ilScheibenZuQuittieren < 0 ) THEN
        wpgFehlerdaten[0] := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := cWAND_1;

        SpsError( eFehler_Station,
                  cMELDUNG_STATION_ZUVIELE_SCHEIBEN_QUITTIERT_WAND_AUSTRANSPORT,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );
        
        starrTransfershuttleBasisParameter[wStation].bAustransport[cWAND_1] := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

(*AUSTRANSPORT  ===========================================*)
    STEP_900_E:
      bpFehler := TRUE;

(*AUSTRANSPORT  ===========================================*)
    STEP_1000_E:
      bpDone := TRUE;
	  
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

      (* Hinweis:
         - Pruefen ob die Transferkopplung geloest werden muss
      *)
      IF ( PruefungWertImIntervall(Auftragsdaten.wTransferstationsNr2, cERSTES_TRANSFERSHUTTLE, cLETZTES_TRANSFERSHUTTLE) ) THEN

        IF ( Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2].wAuftrag = eStation_Transportkopplung ) THEN
          Job_Shuttle.abpResetTransportkopplung[Auftragsdaten.wTransferstationsNr2] := TRUE;
        END_IF

      END_IF

(*AUSTRANSPORT  ===========================================*)
  END_CASE
END_IF

IF bpReset THEN
  bpDone := FALSE;
  bpReset := FALSE;
  bpFehler := FALSE;
  starrTransfershuttleBasisParameter[wStation].bAustransport[cWAND_1] := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK