(* METADATA
{
  "v3Meta": {
    "objectGuid": "b272f643-831b-42e0-8c4f-868bd25374f4"
  }
}
*)
FUNCTION_BLOCK TS_Transportkopplung
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

  // STEPS
  steplSchritt           : STEPS_TE;

END_VAR
//-------------------------------------------------------------------------------------------------
// STEUERUNG: TRANSPORTKOPPLUNG
//-------------------------------------------------------------------------------------------------
IF ( Auftragsdaten.wAuftrag = eStation_Transportkopplung ) THEN
  CASE steplSchritt OF
    // TRANSPORTKOPPLUNG ===========================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefen des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation])
         AND NOT starrTransfershuttleBasisParameter[wStation].bReset
      THEN
        steplSchritt := STEP_100_E;
      END_IF

    // TRANSPORTKOPPLUNG ===========================================
    STEP_100_E:

      starrTransfershuttleBasisParameter[wStation].pAuftrag[cWAND_1] := Auftragsdaten;
      starrTransfershuttleBasisParameter[wStation].bTransportkopplung[cWAND_1] := TRUE;

      steplSchritt := STEP_110_E;

    // TRANSPORTKOPPLUNG ===========================================
    STEP_110_E:
      (* Fehlerbehandlung:
         - Transfershuttle
      *)
      IF ( starrTransfershuttleBasisParameter[wStation].bFehler ) THEN

        starrTransfershuttleBasisParameter[wStation].bTransportkopplung[cWAND_1] := FALSE;

        SpsError( eFehler_Station,
                  starrTransfershuttleBasisParameter[wStation].wFehlerNummer,
                  starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrTransfershuttleBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrTransfershuttleBasisParameter[wStation].awFehlerInformationen );

        steplSchritt := STEP_900_E;

      END_IF

    // TRANSPORTKOPPLUNG ===========================================
    STEP_900_E:
      bpFehler := TRUE;

    // TRANSPORTKOPPLUNG ===========================================
    STEP_1000_E:
      bpDone := TRUE;

  // TRANSPORTKOPPLUNG ===========================================
  END_CASE
END_IF

IF bpReset THEN
  starrTransfershuttleBasisParameter[wStation].bTransportkopplung[cWAND_1] := FALSE;
  steplSchritt := STEP_0_E;
  bpFehler := FALSE;
  bpDone := FALSE;
  bpReset := FALSE;
END_IF
END_FUNCTION_BLOCK