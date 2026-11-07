(* METADATA
{
	"v3Meta": {
		"objectGuid": "379bb71f-09e3-4346-a24a-24b89454f93a"
	}
}
*)
FUNCTION_BLOCK Station_Glaslaengenmessung
VAR_INPUT
    
  // BOOLEAN
  bpReset                : BOOL;
  bpAbbruchAnlegeauftrag : BOOL;
  
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
    
  // STEPS
  steplSchritt           : STEPS_TE;

END_VAR

//-------------------------------------------------------------------------------------------------
// STEUERUNG: MESSUNG
//-------------------------------------------------------------------------------------------------
IF ( Auftragsdaten.wAuftrag = eStation_Messfahrt ) THEN
  CASE steplSchritt OF
    // MESSFAHRT ==================================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
        steplSchritt := STEP_10_E;
      END_IF

      (* Hinweis:
         - Abbruch des Anl
      *)
      IF ( bpAbbruchAnlegeauftrag ) THEN
        bpAbbruchAnlegeauftrag := FALSE;
        bpDone := TRUE;
        Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;
      END_IF

    // MESSFAHRT ==================================================
    STEP_10_E:
      // Glastyp festlegen
      IF ( Auftragsdaten.rAuftragsLaenge > ( starrStationBasisParameter[wStation].stParameterStationskomponenten.stGlastransport[1].rMessstrecke - rgMKWegAnlegetischUebergroesseScheibeBerechnen ) ) THEN
        starrStationBasisParameter[wStation].wGlasTyp[cWAND_1] := eScheibe_Maximal;
      ELSE
        starrStationBasisParameter[wStation].wGlasTyp[cWAND_1] := eScheibe_Default;    
      END_IF

      steplSchritt := STEP_20_E;

    // MESSFAHRT ==================================================
    STEP_20_E:
      (* Hinweis:
         - cMittlereScheibe
           cGrosseScheibe:
           => 1. Option: Anlegetisch kann die Glasvermessung starten ohne die Nachfolgestation
         - cMaxScheibe:
           => 1. Option: Zum vermessen der Scheibe wird die Nachfolgestation benoetigt
      *)
      CASE starrStationBasisParameter[wStation].wGlasTyp[cWAND_1] OF

        cMAXSCHEIBE:
          IF ( Job_Stationen.AuftragsdatenWand[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wNachfolgerStation, cWAND_1].wAuftrag = eStation_Kein_Auftrag ) THEN
            Job_Stationen.AuftragsdatenWand[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wNachfolgerStation, cWAND_1]          := AuftragsdatenUmkopieren(FALSE, FALSE, Auftragsdaten);
            Job_Stationen.AuftragsdatenWand[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wNachfolgerStation, cWAND_1].wAuftrag := eStation_Messkopplung;

            steplSchritt := STEP_30_E;
          END_IF

        ELSE
          steplSchritt := STEP_30_E;

      END_CASE

    // MESSFAHRT ==================================================
    STEP_30_E:
      (* Hinweis:
         - Auftragsdaten uebergeben
         - Starten der Glasmessung
      *)
      starrStationBasisParameter[wStation].pAuftrag[cWAND_1] := Auftragsdaten;
      starrStationBasisParameter[wStation].bGlaslaengenmessung := TRUE;

      steplSchritt := STEP_40_E;

    // MESSFAHRT ==================================================
    STEP_40_E:
      (* Hinweis:
         - Prüfen dass der Auftragsstatus sich geändert hat
      *)
      IF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragAktiv ) THEN
        steplSchritt := STEP_100_E;
      END_IF

    // MESSFAHRT ==================================================
    STEP_100_E:
      (* Hinweis:
         - Glasvermessung abgeschlossen
           => Scheibenvermessung war erfolgreich [Wechsel in den Austransport]
      *)
      IF ( starrStationBasisParameter[wStation].bGlaslaengenmessungAbgeschlossen ) THEN
        starrStationBasisParameter[wStation].bGlaslaengenmessung := FALSE;

        (* Hinweis:
           - Pruefen ob die Betriebsart wieder zurueckgesetzt werden muss
        *)
        steplSchritt := STEP_800_E;

      END_IF

      (* Fehlerbehandlung:
         - Anlegetisch
      *)
      IF ( starrStationBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrStationBasisParameter[wStation].wFehlerNummer,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrStationBasisParameter[wStation].awFehlerInformationen );

        starrStationBasisParameter[wStation].bGlaslaengenmessung := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

    // MESSFAHRT ==================================================
    STEP_800_E:
      (* Hinweis:
         - Ergebnis der Messung prüfen
      *)
      IF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragErfolgreich ) THEN

        wSps2MmiInputtableNummer := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
        dwSps2MmiWartezeit       := starrStationBasisParameter[wStation].dwWartezeit[cWAND_1];
        MsgToMmi(auftragsnr_w    := SB0_SPS_SortierungQuittInputInQueue);  // Auftrag für den Anlegetisch

        CASE starrStationBasisParameter[wStation].wGlasTyp[cWAND_1] OF

          cMAXSCHEIBE:
            Job_Stationen.abpResetTransportkopplung[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wNachfolgerStation, cWAND_1]  := TRUE;
            Job_Stationen.AuftragsdatenWand[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wNachfolgerStation, cWAND_1].wAuftrag := eStation_Kein_Auftrag;

        END_CASE

        steplSchritt := STEP_1000_E;

      ELSIF ( starrStationBasisParameter[wStation].eStatusAuftrag = eAuftragWiederholen ) THEN

        CASE starrStationBasisParameter[wStation].wGlasTyp[cWAND_1] OF

          cMAXSCHEIBE:
            Job_Stationen.abpResetTransportkopplung[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wNachfolgerStation, cWAND_1] := TRUE; 
            Job_Stationen.AuftragsdatenWand[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wNachfolgerStation, cWAND_1].wAuftrag := eStation_Kein_Auftrag;

        END_CASE

        bpDone := TRUE;
        Auftragsdaten.wAuftrag := eStation_Anlegen;

      END_IF

    // MESSFAHRT ==================================================
    STEP_900_E:
      bpFehler := TRUE;

    // MESSFAHRT ==================================================
    STEP_1000_E:
      (* Wichtig:
         - Auftragsstatus zuweisen
      *)
      bpDone := TRUE;
      
      Auftragsdaten.wAuftrag := eStation_Warte_Auf_Austransport;

  // MESSFAHRT ==================================================
  END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpReset := FALSE;
  bpDone := FALSE;
  starrStationBasisParameter[wStation].bGlaslaengenmessung := FALSE;
  steplSchritt := STEP_0_E;    
END_IF
END_FUNCTION_BLOCK