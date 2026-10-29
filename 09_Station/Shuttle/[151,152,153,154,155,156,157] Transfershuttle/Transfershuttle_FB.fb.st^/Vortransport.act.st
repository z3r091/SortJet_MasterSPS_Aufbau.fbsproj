(* METADATA
{
	"v3Meta": {
		"objectGuid": "f8b77be8-0647-4ff3-8684-9c7af09a1ef8"
	}
}
*)
ACTION Vortransport
(***************************************************************************************************)
(* AKTION VORTRANSPORT *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bVortransport[cWAND_1]
  AND BasisStationsParameter.bAutomatik )
THEN
  CASE steplVortransport OF
(*VORTRANSPORT ==============================*)
    STEP_0_E:

      IF ( ReservierungsStatus <> TS_VORTRANSPORT_RESERVIERUNG ) THEN
        ReservierungsStatus := TS_VORTRANSPORT_RESERVIERUNG;
      END_IF

      steplVortransport := STEP_10_E;

(*VORTRANSPORT ==============================*)
    STEP_10_E:
      (* Hinweis:
         - Sicherstellen das sich das Transfershuttle auf der richtigen Position befindet
      *)
      IF ( blZielPositionErreicht ) THEN
        steplVortransport := STEP_20_E;

      ELSE
        BasisStationsParameter.awFehlerInformationen[1] := REAL_TO_WORD(Querfahrt.rpAktPosition);
        BasisStationsParameter.awFehlerInformationen[2] := REAL_TO_WORD(BasisStationsParameter.pAuftrag[cWAND_1].rVorabPosition);
        BasisStationsParameter.wFehlerNummer := cMELDUNG_QUERFAHRT_SOLLPOSITION_NICHT_ERREICHT;

        steplVortransport := STEP_900_E;
      END_IF

(*VORTRANSPORT ==============================*)
    STEP_20_E:
      IF (  Sicherheitskreis[BasisStationsParameter.stMKs.eaSicherheitskreis[0]].bpSicherheitskreisGeschlossen
        AND NOT Sicherheitskreis[BasisStationsParameter.stMKs.eaSicherheitskreis[0]].bpAnforderungSKGestellt )
      THEN
        steplVortransport := STEP_30_E;
      END_IF

(*VORTRANSPORT ==============================*)
    STEP_30_E:
      (* Anmerkung:
         - Shuttle steht an der gewuenschten Position und es kann mit dem Vortransport 
           begonnen werden
      *)
      Glastransport.pAuftrag            := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.rpVorpositionierweg := rpVorpositionierweg;
      Glastransport.bpVortransport      := TRUE;

      steplVortransport     := STEP_40_E;

(*VORTRANSPORT ==============================*)
    STEP_40_E:
      IF ( Glastransport.bpDone ) THEN
        ReservierungsStatus := TS_KEINE_RESERVIERUNG;
        Glastransport.bpVortransport := FALSE;
        steplVortransport := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpVortransport := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplVortransport := STEP_900_E;
      END_IF

(*VORTRANSPORT ==============================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*VORTRANSPORT ==============================*)
    STEP_1000_E:
      BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := TRUE;

(*VORTRANSPORT ==============================*)
  END_CASE
ELSE
  IF ( steplVortransport > STEP_0_E ) THEN
    Glastransport.bpVortransport := FALSE;
    BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;
    steplVortransport := STEP_0_E;
  END_IF
END_IF
END_ACTION