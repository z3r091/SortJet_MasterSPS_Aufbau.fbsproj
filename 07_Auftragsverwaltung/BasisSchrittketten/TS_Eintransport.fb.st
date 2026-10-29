(* METADATA
{
	"v3Meta": {
		"objectGuid": "2467a7d0-b543-4c0f-8e2f-d0f3bb8e773e"
	}
}
*)
FUNCTION_BLOCK TS_Eintransport
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
  wlEintransportstation  : WORD;

  (* INT *)
  ilScheibenZuQuittieren : INT;

  (* STEPS *)
  steplSchritt           : STEPS_TE;

END_VAR


(***************************************************************************************************)
(* STEUERUNG: EINTRANSPORT  *)
(***************************************************************************************************)
IF ( Auftragsdaten.wAuftrag = eStation_Eintransport ) THEN
  CASE steplSchritt OF
(*EINTRANSPORT  =============================== ============*)
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefen des Sicherheitskreises
      *)
      IF  (checkSafetyCircuitsNotBlocked(starrTransferShuttleBasisParameter[wStation])
        AND NOT starrTransfershuttleBasisParameter[wStation].bReset )
      THEN
        steplSchritt := STEP_100_E;
      END_IF

(*EINTRANSPORT  ===========================================*)
    STEP_100_E:
      (* Anmerkung
         - Zielstation abfragen ob diese bereit ist zum Austransport         
      *)
	  wlEintransportstation := Auftragsdaten.wTransferstationsNr1;
     ilScheibenZuQuittieren := WORD_TO_INT( Auftragsdaten.wAnzahlScheiben);

      CASE wlEintransportstation OF

        (* Hinweis:
           - Ruecktransport durch den Speicher beruecksichtigen
        *)
        cERSTES_INPUTSHUTTLE..cLETZTES_INPUTSHUTTLE,
        cERSTES_OUTPUTSHUTTLE..cLETZTES_OUTPUTSHUTTLE:
          IF ( Job_Shuttle.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand].wAuftrag = eStation_Austransport ) THEN
            steplSchritt := STEP_110_E;

          ELSE
            wpgFehlerdaten[0] := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
            wpgFehlerdaten[1] := wlEintransportstation;
            wpgFehlerdaten[2] := Job_Shuttle.AuftragsdatenWand[Auftragsdaten.wTransferstationsNr1, Auftragsdaten.wTransferwand].wAuftrag;

            SpsError( eFehler_Station,
                      cMELDUNG_AUFTRAGSDATEN_AUFTRAGSTATUS_GLAS_SENDER_UNGUELTIG,
                      starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                      AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                      wpgFehlerdaten);

            steplSchritt := STEP_900_E;
          END_IF

        ELSE
          wpgFehlerdaten[0] := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
          wpgFehlerdaten[1] := wlEintransportstation;

          SpsError( eFehler_Station,
                    cMELDUNG_AUFTRAGSDATEN_FALSCHE_EINLAUFSTATION,
                    starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                    wpgFehlerdaten );

           steplSchritt := STEP_900_E;

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

(*EINTRANSPORT  ===========================================*)
    STEP_110_E:

      (* Hinweis:
         - Starten des Eintransport
      *)
      IF ( Auftragsdaten.wTransferwand = cWAND_1 ) THEN
        starrTransfershuttleBasisParameter[wStation].bScheibentrennen[cWAND_1] := NOT Auftragsdaten.stAuftragsInformationen.cBIT_SRC_WALL_1_EMPTY;
      ELSE
        starrTransfershuttleBasisParameter[wStation].bScheibentrennen[cWAND_1] := NOT Auftragsdaten.stAuftragsInformationen.cBIT_SRC_WALL_2_EMPTY;
	  END_IF
	  
      starrTransfershuttleBasisParameter[wStation].pAuftrag[cWAND_1] := Auftragsdaten;
      starrTransfershuttleBasisParameter[wStation].bEintransport[cWAND_1] := TRUE;
      starrTransfershuttleBasisParameter[wStation].bRueckwaertsTransportieren[cWAND_1] := ( starrTransferShuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Station[wlEintransportstation] = Rueckwaertig );

      steplSchritt := STEP_400_E;

(*EINTRANSPORT  ===========================================*)
    STEP_400_E:
      (* ---------------------------------------------------------------------------------------
      //  QUITTIERUNGEN UND EINTRANSPORT- ABSCHLUSS
      //         
      //  Hinweis:
      //  - Scheibenquittieren: Message zur MMI
      // ---------------------------------------------------------------------------------------*)

      IF ( starrTransfershuttleBasisParameter[wStation].OutGlasTransport[cWAND_1].bQuittScheibe ) THEN

        IF ( ilScheibenZuQuittieren > 0 ) AND starrTransfershuttleBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.bStationQuittiertScheibe[wlEintransportstation] THEN

          wSps2MmiZielStation  := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
          wSps2MmiQuellStation := Auftragsdaten.wTransferstationsNr1;
          wSps2MmiZielWand     := cWAND_1;
          wSps2MmiQuellWand    := Auftragsdaten.wTransferwand;
          dwSps2MmiWartezeit   := starrTransfershuttleBasisParameter[wStation].dwWartezeit[cWAND_1];
          wSPS2MMIAuftragstyp  := 0;

          MsgToMmi(auftragsnr_w := SB0_SPS_QUIT_SHEET_ORDER );
        END_IF

        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;

      END_IF

      (* Hinweis:
         - Abschliessen des Eintransports ( Transfershuttle )
      *)
      IF( starrTransfershuttleBasisParameter[wStation].bEintransportAbgeschlossen[cWAND_1] ) THEN

        starrTransfershuttleBasisParameter[wStation].bEintransport[cWAND_1] := FALSE;
        steplSchritt := STEP_1000_E;

      END_IF

      (* Fehlerbehandlung
         - Transfershuttle
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bFehler ) THEN

        IF ( aTransfershuttles[wStation].bpAnforderungBetriebsstopp ) THEN

          IF ( bgAktivierungTransfershuttleSystemcheck ) THEN
            wgSps2MmiShuttleNr                 := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
            rgSPS2MMIExtractionShuttlePosition := starrTransfershuttleBasisParameter[wStation].rAktuellePositionQuerfahrt;
            wSps2MmiFehlertyp                  := aTransfershuttles[wStation].wpAusnahmefehlerTyp;
            MsgToMmi(auftragsnr_w := SB0_SPS_TRANSFERSHUTTLEFEHLER );(* Fehlermeldung ans MMI für den folgenden Systemcheck *)
          END_IF

        END_IF

        starrTransfershuttleBasisParameter[wStation].bEintransport[cWAND_1] := FALSE;

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
        starrTransfershuttleBasisParameter[wStation].bEintransport[cWAND_1] := FALSE;
        steplSchritt := STEP_1000_E;

      (* Anmerkung:
         - Zu wenig Scheiben quittiert
      *)
      ELSIF ( ilScheibenZuQuittieren > 0 ) THEN
        wpgFehlerdaten[0] := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := cWAND_1;

        SpsError( eFehler_Station,
                  cMELDUNG_STATION_ZUWENIG_SCHEIBEN_QUITTIERT_WAND_EINTRANSPORT,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );

                starrTransfershuttleBasisParameter[wStation].bEintransport[cWAND_1] := FALSE;
                steplSchritt := STEP_900_E;

        (* Anmerkung:
           - Zu viele Scheiben quittiert
        *)
      ELSIF ( ilScheibenZuQuittieren < 0 ) THEN
        wpgFehlerdaten[0] := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerExtern;
        wpgFehlerdaten[1] := cWAND_1;

        SpsError( eFehler_Station,
                  cMELDUNG_STATION_ZUVIELE_SCHEIBEN_QUITTIERT_WAND_EINTRANSPORT,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  wpgFehlerdaten );
        
        starrTransfershuttleBasisParameter[wStation].bEintransport[cWAND_1] := FALSE;
        steplSchritt := STEP_900_E;
      END_IF
  
(*EINTRANSPORT  ===========================================*)
    STEP_900_E:
      (* Hinweis:
         - Berücksichtigung wie Transportiert wurde
           => Wichtig: Automatikkreis beachten
      *)
      bpFehler := TRUE;

(*EINTRANSPORT  ===========================================*)
    STEP_1000_E:
      bpDone := TRUE;
	  
      (* Hinweis:
         - Beenden des EIntransports [Bereit fuer den naechsten Auftrag]
      *)
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

      (* Hinweis:
         - Pruefen ob die Transferkopplung geloest werden muss
      *)
      IF ( PruefungWertImIntervall(Auftragsdaten.wTransferstationsNr2, cERSTES_TRANSFERSHUTTLE, cLETZTES_TRANSFERSHUTTLE) ) THEN

        IF ( Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2].wAuftrag = eStation_Transportkopplung ) THEN
          Job_Shuttle.abpResetTransportkopplung[Auftragsdaten.wTransferstationsNr2] := TRUE;
        END_IF

      END_IF

(*EINTRANSPORT  ===========================================*)
  END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpDone := FALSE;
  bpReset := FALSE;
  starrTransfershuttleBasisParameter[wStation].bEintransport[cWAND_1] := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK