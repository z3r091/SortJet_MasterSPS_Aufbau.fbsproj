(* METADATA
{
	"v3Meta": {
		"objectGuid": "82a7ab83-6d97-4992-8583-d2407cc9730b"
	}
}
*)
FUNCTION_BLOCK TS_Vortransport
VAR_INPUT
    
  // BOOLEAN
  bpReset                : BOOL;
  
  // WORD
  wStation               : WORD;
  
  // STRUKTUR
  Auftragsdaten          : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  // BOOLEAN
  bpDone                 : BOOL;
  bpFehler               : BOOL;

END_VAR
VAR
     
  // WORD
  wlVerbundStation       : WORD;

  // STEPS
  steplSchritt           : STEPS_TE;

END_VAR
//-------------------------------------------------------------------------------------------------
// STEUERUNG: VORTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( Auftragsdaten.wAuftrag = eStation_Vortransport ) THEN
  CASE steplSchritt OF
    // VORTRANSPORT ==============================================
    STEP_0_E:
      IF (  checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation])
           AND NOT starrTransfershuttleBasisParameter[wStation].bReset )
      THEN

        steplSchritt := STEP_100_E;

        IF ( Auftragsdaten.rStationsZielposition > aTransfershuttles[wStation].Querfahrt.Antrieb.rpMaxPosition ) THEN
          wpgFehlerdaten[0] := wStation;
          SysMemCpy( ADR( wpgFehlerdaten[1] ), ADR ( aTransfershuttles[wStation].Querfahrt.Antrieb.rpMaxPosition ), 4 );
          SysMemCpy( ADR( wpgFehlerdaten[3] ), ADR ( Auftragsdaten.rStationsZielposition ), 4 );

          SpsError( eFehler_Station,
                    cMELDUNG_AUFTRAGSDATEN_ZIELPOSITION_ZU_GROSS,
                    starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten );

          steplSchritt := STEP_900_E;
        END_IF

        IF ( Auftragsdaten.rStationsZielposition < aTransfershuttles[wStation].Querfahrt.Antrieb.rpMinPosition ) THEN
          wpgFehlerdaten[0] := wStation;
          SysMemCpy( ADR( wpgFehlerdaten[1] ), ADR ( aTransfershuttles[wStation].Querfahrt.Antrieb.rpMinPosition ), 4 );
          SysMemCpy( ADR( wpgFehlerdaten[3] ), ADR ( Auftragsdaten.rStationsZielposition ), 4 );

          SpsError( eFehler_Station,
                    cMELDUNG_AUFTRAGSDATEN_ZIELPOSITION_ZU_KLEIN,
                    starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                    AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                    wpgFehlerdaten );
          steplSchritt := STEP_900_E;
        END_IF

      END_IF

    // VORTRANSPORT ==============================================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  PRUEFEN TRANSFERSHUTTLE VERBUND
      //
      //  Hinweis:
      //  - Transferstation2 = 0   => Vortransport mit nur einem Transfershuttle
      //  - Transferstation2 <> 0  => Vortransport im Transfershuttle-Verbund
      // ---------------------------------------------------------------------------------------

      IF ( Auftragsdaten.wTransferstationsNr2 = 0 ) THEN

        IF ( NOT starrTransfershuttleBasisParameter[wStation].bAuftragAktiv ) THEN
          starrTransfershuttleBasisParameter[wStation].pAuftrag[cWAND_1]      := Auftragsdaten;
          aTransfershuttles[wStation].rpVorpositionierWeg                     := Auftragsdaten.rAuftragsLaenge;
          starrTransfershuttleBasisParameter[wStation].bVortransport[cWAND_1] := TRUE;
          steplSchritt := STEP_400_E;
        END_IF

      ELSE
        wlVerbundStation := Auftragsdaten.wTransferstationsNr2;

        IF ( Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2].wAuftrag = eStation_Kein_Auftrag ) THEN
          steplSchritt := STEP_200_E;
        END_IF

      END_IF

    // VORTRANSPORT ==============================================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  TRANSFERSHUTTLE VERBUND
      //
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      IF ( NOT starrTransfershuttleBasisParameter[wStation].bAuftragAktiv ) THEN

        (* Hinweis:
           - Transfershuttle koppeln
        *)
        aTransfershuttles[wStation].stpInTransportVerbund                             := aTransfershuttles[wlVerbundStation].stpOutTransportVerbund;
        aTransfershuttles[wlVerbundStation].stpInTransportVerbund  := aTransfershuttles[wStation].stpOutTransportVerbund;

        (* Hinweis:
           - Auftragsdaten uebergeben
        *)
        Job_Shuttle.AuftragsdatenTransfershuttle[wlVerbundStation].rStationsZielposition := Auftragsdaten.rTransferposition2 ;
        Job_Shuttle.AuftragsdatenTransfershuttle[wlVerbundStation].wStationsNr           := Auftragsdaten.wTransferstationsNr2 ;
        Job_Shuttle.AuftragsdatenTransfershuttle[wlVerbundStation].wAuftrag:= eStation_Transportkopplung;

        (* Hinweis:
           - Auftragsdaten uebergeben
        *)
        starrTransfershuttleBasisParameter[wStation].pAuftrag[cWAND_1]      := Auftragsdaten;
        aTransfershuttles[wStation].rpVorpositionierWeg                     := Auftragsdaten.rAuftragsLaenge;
        starrTransfershuttleBasisParameter[wStation].bVortransport[cWAND_1] := TRUE;

        steplSchritt := STEP_400_E;

      END_IF

    // VORTRANSPORT ==============================================
    STEP_400_E:
      // ---------------------------------------------------------------------------------------
      //  TRANSFERSHUTTLE VORTRANSPORT ABGESCHLOSSEN
      //
      //  Hinweis:
      //  - n/c
      // ---------------------------------------------------------------------------------------

      IF ( starrTransfershuttleBasisParameter[wStation].bVortransportAbgeschlossen[cWAND_1] ) THEN

        (* Hinweis:
           - Nachricht an die HMMI
        *)
        wSps2MmiQuittierungVortransportStationsNr1 := starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
        wSps2MmiQuittierungVortransportStationsNr2 := Auftragsdaten.wTransferstationsNr2;
        wSps2MmiQuittierungVortransportStatus      := 1; // 0  = nicht Erfolgreich / 1 = erfolgreich
        rSps2MmiQuittierungVortransportWegStrecke  := aTransfershuttles[wStation].rpVorpositionierterWeg;

        MsgToMmi(auftragsnr_w := SB0_SPS_SortierungQuittExtractionShuttleData );

        starrTransfershuttleBasisParameter[wStation].bVortransport[cWAND_1] := FALSE;

        steplSchritt := STEP_1000_E;
      END_IF

      (* Hinweis:
         - -Ausnahmefehler
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrTransfershuttleBasisParameter[wStation].wFehlerNummer,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrTransfershuttleBasisParameter[wStation].awFehlerInformationen );

        starrTransfershuttleBasisParameter[wStation].bVortransport[cWAND_1] := FALSE;

        steplSchritt := STEP_900_E;
      END_IF

    // VORTRANSPORT ==============================================
    STEP_900_E:
      bpFehler := TRUE;

    // VORTRANSPORT ==============================================
    STEP_1000_E:
      bpDone := TRUE;

      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

      (* Hinweis:
         - Pruefen ob die Transferkopplung geloest werden muss
      *)
      IF ( PruefungWertImIntervall(Auftragsdaten.wTransferstationsNr2, cERSTES_TRANSFERSHUTTLE, cLETZTES_TRANSFERSHUTTLE) ) THEN

        IF ( Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2].wAuftrag = eStation_Transportkopplung ) THEN
          Job_Shuttle.AuftragsdatenTransfershuttle[Auftragsdaten.wTransferstationsNr2].wAuftrag := eStation_Kein_Auftrag;
        END_IF

      END_IF

  // VORTRANSPORT ==============================================
  END_CASE
END_IF

IF bpReset THEN
  starrTransfershuttleBasisParameter[wStation].bVortransport[cWAND_1] := FALSE;
  bpDone   := FALSE;
  bpReset  := FALSE;
  bpFehler := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK