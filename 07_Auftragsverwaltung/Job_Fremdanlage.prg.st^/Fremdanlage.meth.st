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
  ptSender                    : REFERENCE TO StationBasisParameter_ST;
  ptAuftragsdatenSender       : REFERENCE TO Auftragsdaten_ST;
  ptAuftragsdatenVorgaenger   : REFERENCE TO Auftragsdaten_ST;
END_VAR

// Hinweis:
// - Glas-Sender ist die Transferstation 1 des Fremdanlagen-Auftrags (Shuttle, Transfershuttle oder Station)
// - Shuttle und Transfershuttle (MK bStationIstShuttle) legen den Auftrag der Fremdanlage selbst an
// - Bei einer Station legt die Fremdanlage den Austransport-Auftrag ihres Vorgaengers an
ptSender              REF= getBasis( AuftragsdatenFremdanlage[wFremdanlage].wTransferstationsNr1 );
ptAuftragsdatenSender REF= getAuftragsdaten( AuftragsdatenFremdanlage[wFremdanlage].wTransferstationsNr1,
                                             AuftragsdatenFremdanlage[wFremdanlage].wTransferwand );
ptAuftragsdatenVorgaenger REF= getAuftragsdaten( wVorgaenger, cWAND_1 );

//-------------------------------------------------------------------------------------------------
// STEUERUNG EINTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( AuftragsdatenFremdanlage[wFremdanlage].wAuftrag = eStation_Eintransport ) THEN
  CASE astplEintransportFremdanlage[wFremdanlage] OF
    // EINTRANSPORT ===========================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      astplEintransportFremdanlage[wFremdanlage] := STEP_10_E;

    // EINTRANSPORT ===========================================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      // GLAS-SENDER PRUEFUNG
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      (* Hinweis:
         - Glas- Sender bestimmen und merken
      *)
      IF (     __ISVALIDREF( ptSender )
           AND_THEN __ISVALIDREF( ptSender.stMKs )
           AND_THEN ptSender.stMKs.stSchnittstellendaten.bStationIstShuttle )
      THEN
        starrFremdanlageAuslaufStationBasisParameter[AuftragsdatenFremdanlage[wFremdanlage].wStationsNr].InGlasTransportVorgaenger[cWAND_1] := ptSender.OutGlasTransport[AuftragsdatenFremdanlage[wFremdanlage].wTransferwand];
        astplEintransportFremdanlage[wFremdanlage] := STEP_40_E;
      ELSE
        astplEintransportFremdanlage[wFremdanlage] := STEP_30_E;
      END_IF

    // EINTRANSPORT ===========================================
    STEP_30_E:
      // ---------------------------------------------------------------------------------------
      // PRUEFUNG AUFTRAGSSTATUS GLAS-SENDER
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------
      IF ( __ISVALIDREF( ptAuftragsdatenVorgaenger ) ) THEN

        IF ( ( ptAuftragsdatenVorgaenger.wAuftrag = eStation_Belegt )
             OR ( ptAuftragsdatenVorgaenger.wAuftrag = eStation_Warte_Auf_Austransport ) )
           OR ( ( ptAuftragsdatenVorgaenger.wAuftrag = eStation_Kein_Auftrag ) AND bDurchtransportierendeStation )
        THEN

          IF bDurchtransportierendeStation THEN
            ptAuftragsdatenVorgaenger := AuftragsdatenUmkopieren(FALSE, TRUE, AuftragsdatenFremdanlage[wFremdanlage]);
            ptAuftragsdatenVorgaenger.wAuftrag := eStation_Durchtransport;
          ELSE
            ptAuftragsdatenVorgaenger := AuftragsdatenUmkopieren(FALSE, FALSE, AuftragsdatenFremdanlage[wFremdanlage]);
            ptAuftragsdatenVorgaenger.wAuftrag := eStation_Austransport;
          END_IF

          astplEintransportFremdanlage[wFremdanlage] := STEP_40_E;

        END_IF

      END_IF

    // EINTRANSPORT ===========================================
    STEP_40_E:
      (* Hinweis:
         - Abgeschlossen, sobald der Glas-Sender seinen Austransport (bzw. Durchtransport) beendet hat
      *)
      IF bDurchtransportierendeStation THEN
        IF ( NOT __ISVALIDREF( ptAuftragsdatenVorgaenger ) ) OR_ELSE ( ptAuftragsdatenVorgaenger.wAuftrag <> eStation_Durchtransport ) THEN
          astplEintransportFremdanlage[wFremdanlage] := STEP_1000_E;
        END_IF
      ELSE
        IF ( NOT __ISVALIDREF( ptAuftragsdatenSender ) ) OR_ELSE ( ptAuftragsdatenSender.wAuftrag <> eStation_Austransport ) THEN
          astplEintransportFremdanlage[wFremdanlage] := STEP_1000_E;
        END_IF
      END_IF

    // EINTRANSPORT ===========================================
    STEP_900_E:
      abpFehler[wAutomatikkreis] := TRUE;

    // EINTRANSPORT ===========================================
    STEP_1000_E:
      AuftragsdatenFremdanlage[wFremdanlage].wAuftrag := eStation_Kein_Auftrag;

  // EINTRANSPORT ===========================================
  END_CASE
END_IF

IF ( NOT (AuftragsdatenFremdanlage[wFremdanlage].wAuftrag = eStation_Eintransport) ) THEN

  IF ( astplEintransportFremdanlage[wFremdanlage] > STEP_0_E ) THEN
    astplEintransportFremdanlage[wFremdanlage] := STEP_0_E;
  END_IF

END_IF
END_METHOD