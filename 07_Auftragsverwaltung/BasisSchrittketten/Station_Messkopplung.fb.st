(* METADATA
{
	"v3Meta": {
		"objectGuid": "d07d57e1-6a50-4547-ad5d-dd99acc1a5ad"
	}
}
*)
FUNCTION_BLOCK Station_Messkopplung
VAR_INPUT

  // BOOLEAN
  bpReset                : BOOL;

  // WORD
  wStation               : WORD;
  wWand                  : WORD;

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
IF ( Auftragsdaten.wAuftrag = eStation_Messkopplung ) THEN
  CASE steplSchritt OF
    // MESSFAHRT ==================================================
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
        steplSchritt := STEP_30_E;
      END_IF

    // MESSFAHRT ==================================================
    STEP_30_E:
      (* Hinweis:
         - Auftragsdaten uebergeben
         - Starten der Glasmessung
      *)
      starrStationBasisParameter[wStation].pAuftrag[wWand] := Auftragsdaten;

      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Kippen[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wVorgaengerStation];
      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eHub                 := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Hub[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wVorgaengerStation];

      IF ( Auftragsdaten.rAuftragsDicke < wgMKScheibenDicke13mm ) THEN
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung16mm;
      ELSIF ( Auftragsdaten.rAuftragsDicke <= wgMKScheibenDicke19mm ) THEN
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung23mm;
      ELSE
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung29mm;
      END_IF

      starrStationBasisParameter[wStation].bMesskopplung[wWand] := TRUE;

      steplSchritt := STEP_100_E;

    // MESSFAHRT ==================================================
    STEP_100_E:
      (* Fehlerbehandlung:
         - Messkopplung
      *)
      IF ( starrStationBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrStationBasisParameter[wStation].wFehlerNummer,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerSPS),
                  starrStationBasisParameter[wStation].awFehlerInformationen );

        starrStationBasisParameter[wStation].bMesskopplung[wWand] := FALSE;
        steplSchritt := STEP_900_E;
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

  // MESSFAHRT ==================================================
  END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpReset := FALSE;
  bpDone := FALSE;
  starrStationBasisParameter[wStation].bMesskopplung[wWand] := FALSE;
  steplSchritt := STEP_0_E;
END_IF
END_FUNCTION_BLOCK