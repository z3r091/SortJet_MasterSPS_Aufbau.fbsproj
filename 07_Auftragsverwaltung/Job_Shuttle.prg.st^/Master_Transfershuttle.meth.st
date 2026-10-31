(* METADATA
{
  "v3Meta": {
    "objectGuid": "5a2b5255-704a-40f5-acbe-9caa573edc30"
  }
}
*)
METHOD INTERNAL Master_Transfershuttle
VAR_INPUT
  wStation : WORD; 
END_VAR


(*****************************************************9**********************************************)
(* STEUERUNG: EINTRANSPORT *)
(***************************************************************************************************)

IF ( AuftragsdatenTransfershuttle[wStation].wAuftrag = eStation_Eintransport ) THEN
  (* Hinweis: Aufruf der Schrittkette *)
  TS_Eintransport[wStation]( Auftragsdaten := AuftragsdatenTransfershuttle[wStation], wStation := wStation );
  (* Hinweis: Abschluss der Schrittkette *)
  IF TS_Eintransport[wStation].bpDone THEN
    AuftragsdatenTransfershuttle[wStation] := TS_Eintransport[wStation].Auftragsdaten;
    TS_Eintransport[wStation](bpReset := TRUE);
  END_IF
  (* Hinweis: Fehler-Auswertung *)
  blFehlerTS[wStation] := TS_Eintransport[wStation].bpFehler;
  IF rtlFehlerTS[wStation].Q THEN
    IF ( starrTransfershuttleBasisParameter[wStation].bRueckwaertsTransportieren[cWAND_1] ) THEN
      AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_AUSLAUFSEITE);
      IF aTransfershuttles[wStation].bpAnforderungBetriebsstopp THEN
        AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_EINLAUFSEITE);
      END_IF
    ELSE
      AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_EINLAUFSEITE);
      IF aTransfershuttles[wStation].bpAnforderungBetriebsstopp THEN
        AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_AUSLAUFSEITE);
      END_IF
    END_IF
  END_IF
ELSE
   (* Hinweis: Reset der Schrittkette *)
  IF ( TS_Eintransport[wStation].steplSchritt <> STEP_0_E ) THEN 
    TS_Eintransport[wStation](bpReset := TRUE);
  END_IF
END_IF

(*****************************************************9**********************************************)
(* STEUERUNG: AUSTRANSPORT *)
(***************************************************************************************************)

IF ( AuftragsdatenTransfershuttle[wStation].wAuftrag = eStation_Austransport ) THEN
   (* Hinweis: Aufruf der Schrittkette *)
   TS_Austransport[wStation]( Auftragsdaten := AuftragsdatenTransfershuttle[wStation], wStation := wStation );
   (* Hinweis: Abschluss der Schrittkette *)
   IF TS_Austransport[wStation].bpDone THEN
     AuftragsdatenTransfershuttle[wStation] := TS_Austransport[wStation].Auftragsdaten;
     TS_Austransport[wStation](bpReset := TRUE);
   END_IF
   (* Hinweis: Fehler-Auswertung *)
   blFehlerTS[wStation] := TS_Austransport[wStation].bpFehler;
   IF rtlFehlerTS[wStation].Q THEN
     IF ( starrTransfershuttleBasisParameter[wStation].bRueckwaertsTransportieren[cWAND_1] ) THEN
       AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_EINLAUFSEITE);
       IF aTransfershuttles[wStation].bpAnforderungBetriebsstopp THEN
         AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_AUSLAUFSEITE);
       END_IF
     ELSE
       AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_AUSLAUFSEITE);
       IF aTransfershuttles[wStation].bpAnforderungBetriebsstopp THEN
         AutomatikFehlerTransfershuttleSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler, cSPEICHER_EINLAUFSEITE);
       END_IF
     END_IF
   END_IF
ELSE
   (* Hinweis: Reset der Schrittkette *)
  IF ( TS_Austransport[wStation].steplSchritt <> STEP_0_E ) THEN 
    TS_Austransport[wStation](bpReset := TRUE);
  END_IF
END_IF

(*****************************************************9**********************************************)
(* STEUERUNG: VORTRANSPORT *)
(***************************************************************************************************)

IF ( AuftragsdatenTransfershuttle[wStation].wAuftrag = eStation_Vortransport ) THEN
  (* Hinweis: Aufruf der Schrittkette *)
  TS_Vortransport[wStation]( Auftragsdaten := AuftragsdatenTransfershuttle[wStation], wStation := wStation);
  (* Hinweis: Abschluss der Schrittkette *)
  IF TS_Vortransport[wStation].bpDone THEN
    AuftragsdatenTransfershuttle[wStation] := TS_Vortransport[wStation].Auftragsdaten;
    TS_Vortransport[wStation](bpReset := TRUE);
  END_IF
  (* Hinweis: Fehler-Auswertung *)
  blFehlerTS[wStation] := TS_Vortransport[wStation].bpFehler;
  IF rtlFehlerTS[wStation].Q THEN
    AutomatikFehlerSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis: Reset der Schrittkette *)
  IF ( TS_Vortransport[wStation].steplSchritt <> STEP_0_E ) THEN 
    TS_Vortransport[wStation](bpReset := TRUE);
  END_IF
END_IF

(*****************************************************9**********************************************)
(* STEUERUNG: QUERFAHRT *)
(***************************************************************************************************)

IF ( AuftragsdatenTransfershuttle[wStation].wAuftrag = eStation_Vorabpositionierung ) THEN
  (* Hinweis: Aufruf der Schrittkette *)
  TS_Querfahrt[wStation]( Auftragsdaten := AuftragsdatenTransfershuttle[wStation], wStation := wStation );
  (* Hinweis: Abschluss der Schrittkette *)
  IF TS_Querfahrt[wStation].bpDone THEN
    AuftragsdatenTransfershuttle[wStation] := TS_Querfahrt[wStation].Auftragsdaten;
    TS_Querfahrt[wStation](bpReset := TRUE);
  END_IF
  (* Hinweis: Fehler-Auswertung *)
  blFehlerTS[wStation] := TS_Querfahrt[wStation].bpFehler;
  IF rtlFehlerTS[wStation].Q THEN
    AutomatikFehlerSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);
  END_IF
ELSE
  (* Hinweis: Reset der Schrittkette *)
  IF ( TS_Querfahrt[wStation].steplSchritt <> STEP_0_E ) THEN 
    TS_Querfahrt[wStation](bpReset := TRUE);
  END_IF
END_IF

(***************************************************************************************************)
(* STEUERUNG: SPEICHERFACHVALIDIERUNG *)
(***************************************************************************************************)
IF (  abpSpeicherfachValidierung[wStation] ) THEN
  CASE asteplSpeicherfachValidierung[wStation] OF
(* SPEICHERFACHVALIDIERUNG =============================*)
    STEP_0_E:
      (* Hinweis:
         - Option: Sicherstellen das der Output-Sicherheitskreis geschlossen ist
      *) 
      IF checkSafetyCircuitsNotBlocked(starrTransferShuttleBasisParameter[wStation])
        AND NOT starrTransfershuttleBasisParameter[wStation].bReset
      THEN
        awlStatusSpeichervalidierung[wStation]   := cAUFTRAG_KEIN_STATUS;
        asteplSpeicherfachValidierung[wStation] := STEP_10_E;
      END_IF

(* SPEICHERFACHVALIDIERUNG =============================*)
    STEP_10_E:
      (* ---------------------------------------------------------------------------------------
      //  PRUEFEN TRANSFERSHUTTLE VERBUND
      //         
      //  Hinweis:
      //  - wTransfershuttle_Nummer2 = 0   => Vortransport mit nur einem Transfershuttle
      //  - wTransfershuttle_Nummer2 <> 0  => Vortransport im Transfershuttle-Verbund
      // ---------------------------------------------------------------------------------------*)

      IF ( starrAuftragsdatenSpeicherfachValidierung[wStation].wTransferstationsNr2 <> 0 )  THEN

        awlVerbundTransfershuttle[wStation] := AuftragsdatenTransfershuttle[wStation].wTransferstationsNr2;

        IF ( AuftragsdatenTransfershuttle[awlVerbundTransfershuttle[wStation]].wAuftrag = eStation_Kein_Auftrag ) THEN
          asteplSpeicherfachValidierung[wStation] := STEP_20_E;
        END_IF

      ELSE
        (* Hinweis:
           - Informationen uebergeben und die Validierung starten
        *)
        starrTransfershuttleBasisParameter[wStation].pAuftrag[cWAND_1] := starrAuftragsdatenSpeicherfachValidierung[wStation];
        aTransfershuttles[wStation].bpStarteSpeicherfachValidierung := TRUE;

        asteplSpeicherfachValidierung[wStation] := STEP_100_E;

     END_IF

(* SPEICHERFACHVALIDIERUNG =============================*)
    STEP_20_E:

      (* Hinweis:
         - Transfershuttle koppeln
      *)
      aTransfershuttles[wStation].stpInTransportVerbund                             := aTransfershuttles[awlVerbundTransfershuttle[wStation]].stpOutTransportVerbund;
      aTransfershuttles[awlVerbundTransfershuttle[wStation]].stpInTransportVerbund  := aTransfershuttles[wStation].stpOutTransportVerbund;

      (* Hinweis:
         - Auftragsdaten uebergeben
      *)
      AuftragsdatenTransfershuttle[awlVerbundTransfershuttle[wStation]].rAuftragsDicke        := starrAuftragsdatenSpeicherfachValidierung[wStation].rAuftragsDicke ;
      AuftragsdatenTransfershuttle[awlVerbundTransfershuttle[wStation]].rStationsZielposition := starrAuftragsdatenSpeicherfachValidierung[wStation].rTransferposition2 ;
      AuftragsdatenTransfershuttle[awlVerbundTransfershuttle[wStation]].wStationsNr           := starrAuftragsdatenSpeicherfachValidierung[wStation].wTransferstationsNr2 ;
      AuftragsdatenTransfershuttle[awlVerbundTransfershuttle[wStation]].wAuftrag              := eStation_Transportkopplung;

      (* Hinweis:
         - Auftragsdaten uebergeben
      *)
      starrTransfershuttleBasisParameter[wStation].pAuftrag[cWAND_1] := starrAuftragsdatenSpeicherfachValidierung[wStation];
      aTransfershuttles[wStation].bpStarteSpeicherfachValidierung := TRUE;

      asteplSpeicherfachValidierung[wStation] := STEP_100_E;

(* SPEICHERFACHVALIDIERUNG =============================*)
    STEP_100_E:
      (* ---------------------------------------------------------------------------------------
      //  AUSWERTUNG TRANSFERSHUTTLE - SPEICHERFACH VALIDIERUNG
      //         
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------*)

      IF ( aTransfershuttles[wStation].bpSpeicherfachValidierungAbgeschlossen ) THEN
        aTransfershuttles[wStation].bpStarteSpeicherfachValidierung := FALSE;
        awlStatusSpeichervalidierung[wStation] := cAUFTRAG_ERFOLGREICH;

        asteplSpeicherfachValidierung[wStation] := STEP_120_E;
      END_IF

      (* Fehlverhalten
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bFehler ) THEN

        aTransfershuttles[wStation].bpStarteSpeicherfachValidierung := FALSE;
        awlStatusSpeichervalidierung[wStation] := cAUFTRAG_FEHLER;

        asteplSpeicherfachValidierung[wStation] := STEP_120_E;

        (* Hinweis:
           - Meldung an die HMI generieren. 
             => Gesendet wird: Shuttlenummer \Position \Fehlertyp
        *)
        wgSps2MmiShuttleNr                 := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
        rgSPS2MMIExtractionShuttlePosition := starrTransfershuttleBasisParameter[wStation].rAktuellePositionQuerfahrt;
        wSps2MmiFehlertyp                  := aTransfershuttles[wStation].wpAusnahmefehlerTyp;
        MsgToMmi(auftragsnr_w := SB0_SPS_TRANSFERSHUTTLEFEHLER );(* Fehlermeldung ans MMI für den folgenden Systemcheck *)


        (* Hinweis:
           - Fehlermeldung generieren
        *)
        SpsError( eFehler_Station,
                  starrTransfershuttleBasisParameter[wStation].wFehlerNummer,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrTransfershuttleBasisParameter[wStation].awFehlerInformationen );

    END_IF

(* SPEICHERFACHVALIDIERUNG =============================*)
    STEP_120_E:
      wgSps2MmiShuttleNr         := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
      wSps2MmiValidierungsStatus := awlStatusSpeichervalidierung[wStation];
      MsgToMmi(auftragsnr_w := SB0_SPS_TRANSFERSHUTTLECHECK_ABGESCHLOSSEN );(* Fehlermeldung ans MMI für den folgenden Systemcheck *)

      asteplSpeicherfachValidierung[wStation] := SEL( awlStatusSpeichervalidierung[wStation] = cAUFTRAG_FEHLER,
                                                          STEP_1000_E,
                                                          STEP_900_E );

(* SPEICHERFACHVALIDIERUNG =============================*)
    STEP_900_E:
      AutomatikFehlerSetzen(starrTransferShuttleBasisParameter[wStation].stMKs.eaAutomatikkreis, abpFehler);

(* SPEICHERFACHVALIDIERUNG =============================*)
    STEP_1000_E:
      abpSpeicherfachValidierung[wStation] := FALSE;

      (* Hinweis:
         - Pruefen ob die Transferkopplung geloest werden muss
      *)
      IF ( PruefungWertImIntervall(AuftragsdatenTransfershuttle[wStation].wTransferstationsNr2, cERSTES_TRANSFERSHUTTLE, cLETZTES_TRANSFERSHUTTLE) ) THEN

        IF ( AuftragsdatenTransfershuttle[AuftragsdatenTransfershuttle[wStation].wTransferstationsNr2].wAuftrag = eStation_Transportkopplung ) THEN
          AuftragsdatenTransfershuttle[AuftragsdatenTransfershuttle[wStation].wTransferstationsNr2].wAuftrag := eStation_Kein_Auftrag;
        END_IF

      END_IF

(* SPEICHERFACHVALIDIERUNG =============================*)
  END_CASE

END_IF

IF ( NOT abpSpeicherfachValidierung[wStation] ) THEN

  IF ( asteplSpeicherfachValidierung[wStation] > STEP_0_E ) THEN
    aTransfershuttles[wStation].bpStarteSpeicherfachValidierung := FALSE;
    asteplSpeicherfachValidierung[wStation] := STEP_0_E;
  END_IF

END_IF
END_METHOD