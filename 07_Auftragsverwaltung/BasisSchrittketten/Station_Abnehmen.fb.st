(* METADATA
{
	"v3Meta": {
		"objectGuid": "c33fea17-eb20-4bc7-9a81-45f784503e7d"
	}
}
*)
FUNCTION_BLOCK Station_Abnehmen
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

  // INT
  ilScheibenZuQuittieren :  INT;
  
  // STEPS
  steplSchritt           : STEPS_TE;

END_VAR

//-------------------------------------------------------------------------------------------------
// STEUERUNG ABNEHMEN
//-------------------------------------------------------------------------------------------------
IF ( Auftragsdaten.wAuftrag = eStation_Abnehmen ) THEN
  CASE steplSchritt OF
    // ABNEHMEN =================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
        steplSchritt := STEP_10_E;
      END_IF

    // ABNEHMEN =================================
    STEP_10_E:
      starrStationBasisParameter[wStation].pAuftrag[cWAND_1] := Auftragsdaten;
      starrStationBasisParameter[wStation].bAbnehmen := TRUE;

      steplSchritt := STEP_20_E;

    // ABNEHMEN =================================
    STEP_20_E:
      IF (  starrStationBasisParameter[wStation].OutGlasTransport[cWAND_1].bQuittScheibe
           AND ilScheibenZuQuittieren > 0 )
      THEN
        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;
      END_IF

      IF (ilScheibenZuQuittieren <= 0 ) THEN
        steplSchritt := STEP_30_E;
      END_IF

    // ABNEHMEN =================================
    STEP_30_E:
      (* Hinweis:
         - Glas wurde abgenommen
      *)
      IF ( starrStationBasisParameter[wStation].bAbnehmenAbgeschlossen ) THEN
        starrStationBasisParameter[wStation].bAbnehmen := FALSE;

        // Nachricht:
        //   - Das der Bediener die Scheibe abgenommen hat
        //     => Quittierung fuer Glas abgenommen
        //   - Nachricht dient nur zur Ueberwachung
        //   Wichtig:
        //   - Es kann sich aber immer noch Glas auf der Station befinden wenn der Bediener die Scheibe nicht entfernt hat
        wSps2MmiStationsNummer := starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern;
        MsgToMmi(auftragsnr_w := SB0_SPS_SHEETREMOVEDAPPROVALWALL);

        steplSchritt := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Anlegewand
      *)
      IF ( starrStationBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrStationBasisParameter[wStation].wFehlerNummer,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrStationBasisParameter[wStation].awFehlerInformationen );

        starrStationBasisParameter[wStation].bAbnehmen := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

    // ABNEHMEN =================================
    STEP_900_E:
      bpFehler := TRUE;

    // ABNEHMEN =================================
    STEP_1000_E:
      bpDone := TRUE;
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

  // ABNEHMEN =================================
  END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpDone := FALSE;
  bpReset := FALSE;
  steplSchritt := STEP_0_E;
  starrStationBasisParameter[wStation].bAbnehmen := FALSE;
END_IF
END_FUNCTION_BLOCK