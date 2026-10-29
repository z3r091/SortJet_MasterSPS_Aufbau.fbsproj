(* METADATA
{
	"v3Meta": {
		"objectGuid": "784d627f-301a-4038-b341-0bc4022717c8"
	}
}
*)
FUNCTION_BLOCK Station_Inspektion EXTENDS Station_Abnehmen

(* Hinweis:
   - Master aufrufen
*)
SUPER^();
(***************************************************************************************************)
(* STEUERUNG ABNEHMEN *)
(***************************************************************************************************)
IF ( Auftragsdaten.wAuftrag = eStation_Abnehmen ) THEN
  CASE steplSchritt OF

(* ABNEHMEN ================================= *)
    STEP_10_E:
      starrStationBasisParameter[wStation].pAuftrag[cWAND_1] := Auftragsdaten;
      IF starrStationBasisParameter[wStation].pAuftrag[cWAND_1] THEN
        starrStationBasisParameter[wStation].bAbnehmen := TRUE;
      ELSE
        starrStationBasisParameter[wStation].bInspektion := TRUE;
      END_IF  

      steplSchritt := STEP_20_E;

(* ABNEHMEN ================================= *)
    STEP_20_E:
      IF (  starrStationBasisParameter[wStation].OutGlasTransport[cWAND_1].bQuittScheibe
        AND ilScheibenZuQuittieren > 0 )
      THEN
        ilScheibenZuQuittieren := ilScheibenZuQuittieren - 1;
      END_IF

      IF (ilScheibenZuQuittieren <= 0 ) THEN
         steplSchritt := STEP_30_E;
      END_IF

(* ABNEHMEN ================================= *)
    STEP_30_E:
      (* Hinweis:
         - Glas wurde abgenommen
      *)
      IF ( starrStationBasisParameter[wStation].bAbnehmenAbgeschlossen ) THEN
        starrStationBasisParameter[wStation].bAbnehmen := FALSE;

        (* Nachricht:
           - Das der Bediener die Scheibe abgenommen hat
             => Quittierung fuer Glas abgenommen
           - Nachricht dient nur zur Ueberwachung
           Wichtig:
           - Es kann sich aber immer noch Glas auf der Station befinden wenn der Bediener die Scheibe nicht entfernt hat
        *)
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
                  AutomatikkreisBestimmen(starrStationBasisParameter[wStation].stMKs.stStationsNummern.NummerIntern),
                  starrStationBasisParameter[wStation].awFehlerInformationen );

        starrStationBasisParameter[wStation].bAbnehmen := FALSE;
        steplSchritt := STEP_900_E;
      END_IF

(* ABNEHMEN ================================= *)
    STEP_900_E:
      bpFehler := TRUE;

(* ABNEHMEN ================================= *)
    STEP_1000_E:
      bpDone := TRUE;
      Auftragsdaten.wAuftrag := eStation_Kein_Auftrag;

(* ABNEHMEN ================================= *)
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