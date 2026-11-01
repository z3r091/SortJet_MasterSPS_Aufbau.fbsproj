(* METADATA
{
  "v3Meta": {
    "objectGuid": "cf66fcf2-cc11-47d6-b197-d71c762428b0"
  }
}
*)
METHOD INTERNAL Fremdanlage
VAR_INPUT
  wFremdanlage                  : WORD;
  wVorgaenger                   : WORD;
  wAutomatikkreis               : WORD;
  bDurchtransportierendeStation : BOOL;
END_VAR
VAR
  bVorgaengerShuttle                   : BOOL;
  ptAuftragsdatenSender                : REFERENCE TO Auftragsdaten_ST;
  ptAuftragsdatenDurchtransportStation : REFERENCE TO Auftragsdaten_ST;
  ptVorgaenger                         : REFERENCE TO StationBasisParameter_ST;
END_VAR

// Hinweis:
// - Ob der Vorgaenger ein Shuttle ist, steht in seiner MK (bStationIstShuttle)
ptVorgaenger REF= getBasis( wVorgaenger );
bVorgaengerShuttle := __ISVALIDREF( ptVorgaenger ) AND_THEN __ISVALIDREF( ptVorgaenger.stMKs ) AND_THEN ptVorgaenger.stMKs.stSchnittstellendaten.bStationIstShuttle;

(***************************************************************************************************)
(* STEUERUNG EINTRANSPORT *)
(***************************************************************************************************)
IF ( AuftragsdatenFremdanlage[wFremdanlage].wAuftrag = eStation_Eintransport ) THEN
  CASE astplEintransportFremdanlage[wFremdanlage] OF
    (* EINTRANSPORT =========================================== *)
    STEP_0_E:
      (* Hinweis:
         Ueberpruefung des Sicherheitskreises
      *)
      astplEintransportFremdanlage[wFremdanlage] := STEP_10_E;

    (* EINTRANSPORT =========================================== *)
    STEP_10_E:
      (* ---------------------------------------------------------------------------------------
      // GLAS-SENDER PRUEFUNG
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)

      (* Hinweis:
         - Glas- Sender bestimmen und merken
      *)
      IF bVorgaengerShuttle THEN
        starrFremdanlageAuslaufStationBasisParameter[AuftragsdatenFremdanlage[wFremdanlage].wStationsNr].InGlasTransportVorgaenger[cWAND_1] := starrShuttleBasisParameter[AuftragsdatenFremdanlage[wFremdanlage].wTransferstationsNr1].OutGlasTransport[AuftragsdatenFremdanlage[wFremdanlage].wTransferwand];
        astplEintransportFremdanlage[wFremdanlage] := STEP_40_E;
      ELSE
        astplEintransportFremdanlage[wFremdanlage] := STEP_30_E;
      END_IF

    (* EINTRANSPORT =========================================== *)
    STEP_30_E:
      (* ---------------------------------------------------------------------------------------
      // PRUEFUNG AUFTRAGSSTATUS GLAS-SENDER
      //         
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------*)
      IF bVorgaengerShuttle THEN
        ptAuftragsdatenSender REF= Job_Shuttle.AuftragsdatenWand[wVorgaenger, cWAND_1];
      ELSE
        ptAuftragsdatenSender REF= Job_Stationen.AuftragsdatenWand[wVorgaenger, cWAND_1];
      END_IF

      IF ( ( ptAuftragsdatenSender.wAuftrag = eStation_Belegt )
           OR ( ptAuftragsdatenSender.wAuftrag = eStation_Warte_Auf_Austransport ) )
         OR ( ( ptAuftragsdatenSender.wAuftrag = eStation_Kein_Auftrag ) AND bDurchtransportierendeStation )
      THEN
    
        IF bDurchtransportierendeStation THEN
          ptAuftragsdatenSender := AuftragsdatenUmkopieren(FALSE, TRUE, AuftragsdatenFremdanlage[wFremdanlage]);
          ptAuftragsdatenSender.wAuftrag := eStation_Durchtransport;
        ELSE
          ptAuftragsdatenSender := AuftragsdatenUmkopieren(FALSE, FALSE, AuftragsdatenFremdanlage[wFremdanlage]);
          ptAuftragsdatenSender.wAuftrag := eStation_Austransport;
        END_IF

        astplEintransportFremdanlage[wFremdanlage] := STEP_40_E;

      END_IF

    (* EINTRANSPORT =========================================== *)
    STEP_40_E:
      IF bDurchtransportierendeStation THEN
        IF ptAuftragsdatenSender.wAuftrag <> eStation_Durchtransport THEN
          astplEintransportFremdanlage[wFremdanlage] := STEP_1000_E;
        END_IF
      ELSE
        IF bVorgaengerShuttle THEN 
          IF Job_Shuttle.AuftragsdatenWand[AuftragsdatenFremdanlage[wFremdanlage].wTransferstationsNr1, cWAND_1].wAuftrag <> eStation_Austransport THEN
            astplEintransportFremdanlage[wFremdanlage] := STEP_1000_E;
          END_IF
        ELSE
          IF AuftragsdatenFremdanlage[wFremdanlage].wTransferstationsNr1 <= cERSTE_STATION THEN
            ptAuftragsdatenDurchtransportStation REF= Job_Shuttle.AuftragsdatenWand[AuftragsdatenFremdanlage[wFremdanlage].wTransferstationsNr1, cWAND_1];
          ELSE
            ptAuftragsdatenDurchtransportStation REF= Job_Stationen.AuftragsdatenWand[AuftragsdatenFremdanlage[wFremdanlage].wTransferstationsNr1, cWAND_1];
          END_IF
      
          IF ptAuftragsdatenDurchtransportStation.wAuftrag <> eStation_Austransport THEN
            astplEintransportFremdanlage[wFremdanlage] := STEP_1000_E;
          END_IF
        END_IF
      END_IF

    (* EINTRANSPORT =========================================== *)
    STEP_900_E:
      abpFehler[wAutomatikkreis] := TRUE;

    (* EINTRANSPORT =========================================== *)
    STEP_1000_E:
      AuftragsdatenFremdanlage[wFremdanlage].wAuftrag := eStation_Kein_Auftrag;

  (* EINTRANSPORT =========================================== *)
  END_CASE
END_IF

IF ( NOT (AuftragsdatenFremdanlage[wFremdanlage].wAuftrag = eStation_Eintransport) ) THEN

  IF ( astplEintransportFremdanlage[wFremdanlage] > STEP_0_E ) THEN
    astplEintransportFremdanlage[wFremdanlage] := STEP_0_E;
  END_IF

END_IF
END_METHOD