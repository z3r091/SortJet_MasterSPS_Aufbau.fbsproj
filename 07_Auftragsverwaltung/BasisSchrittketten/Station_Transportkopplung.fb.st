(* METADATA
{
  "v3Meta": {
    "objectGuid": "7029972e-eb09-4666-92ad-77d763ae2960"
  }
}
*)
FUNCTION_BLOCK Station_Transportkopplung
VAR_INPUT
    
  (* BOOLEAN *)
  bpReset                : BOOL;
  
  (* WORD *)
  wStation               : WORD;
  wWand                  : WORD;
  
  (* STRUKTUR *)
  Auftragsdaten          : Auftragsdaten_ST;

END_VAR
VAR_OUTPUT

  (* BOOLEAN*)
  bpDone                 : BOOL;
  bpFehler               : BOOL;

END_VAR
VAR

  (* STEPS *)
  steplSchritt           : STEPS_TE;

END_VAR
(***************************************************************************************************)
(* STEUERUNG: MESSUNG *)
(***************************************************************************************************)
IF ( Auftragsdaten.wAuftrag = eStation_Transportkopplung ) THEN
  CASE steplSchritt OF
    (* MESSFAHRT ================================================== *)
    STEP_0_E:
      (* Hinweis:
         - Ueberpruefung des Sicherheitskreises
      *)
      IF checkSafetyCircuitsNotBlocked(starrStationBasisParameter[wStation]) THEN
        steplSchritt := STEP_30_E;
      END_IF

    (* MESSFAHRT ================================================== *)
    STEP_30_E:
      (* Hinweis:
          - Auftragsdaten uebergeben
          - Starten der Glasmessung
       *)
      starrStationBasisParameter[wStation].pAuftrag[wWand] := Auftragsdaten;

      starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eKippen_SollPosition := starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.aEintransporte.Kippen[starrStationBasisParameter[wStation].stMKs.stSchnittstellendaten.wVorgaengerStation];

      IF ( Auftragsdaten.rAuftragsDicke < wgMKScheibenDicke13mm ) THEN
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung16mm;
      ELSIF ( Auftragsdaten.rAuftragsDicke <= wgMKScheibenDicke19mm ) THEN
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung23mm;
      ELSE
        starrStationBasisParameter[wStation].pAuftrag[wWand].stAuftragsOptionen.eDickenverstellung := eZylinderStellung29mm;
      END_IF

      starrStationBasisParameter[wStation].bTransportkopplung[wWand] := TRUE;

      steplSchritt := STEP_100_E;

    (* MESSFAHRT ================================================== *)
    STEP_100_E:
      (* Fehlerbehandlung:
         - Transportkopplung
      *)
      IF ( starrStationBasisParameter[wStation].bFehler ) THEN
        SpsError( eFehler_Station,
                  starrStationBasisParameter[wStation].wFehlerNummer,
                  starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern,
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrStationBasisParameter[wStation].awFehlerInformationen );

        starrStationBasisParameter[wStation].bTransportkopplung[wWand] := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

    (* MESSFAHRT ================================================== *)
    STEP_900_E:
      bpFehler := TRUE;

    (* MESSFAHRT ================================================== *)
    STEP_1000_E:
      (* Wichtig:
         - Auftragsstatus zuweisen
      *)
      bpDone := TRUE;

  (* MESSFAHRT ================================================== *)
  END_CASE
END_IF

IF bpReset THEN
  bpFehler := FALSE;
  bpReset := FALSE;
  bpDone := FALSE;
  starrStationBasisParameter[wStation].bTransportkopplung[wWand] := FALSE;
  steplSchritt := STEP_0_E;    
END_IF
END_FUNCTION_BLOCK