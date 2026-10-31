(* METADATA
{
  "v3Meta": {
    "objectGuid": "2888d22d-60f2-42c5-998f-ee490528315c"
  }
}
*)
ACTION Vortransport
(****************************************************************************************)
(* AKTION VORTRANSPORT *)
(****************************************************************************************)
IF ( BasisStationsParameter.bVortransport[cWAND_1]
  AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpVortransport := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplVortransport := STEP_900_E;
  END_IF 
  
  
  CASE steplVortransport OF
(*VORTRANSPORT =====================*)
    STEP_0_E:
      BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;
      steplVortransport := STEP_10_E;

(*VORTRANSPORT =====================*)
    STEP_10_E:
      (* Hinweis:
         - Starten des Vortransports
      *)
      CASE Drehen.epDrehPositionsStatus OF

        eDrehPosition0Grad:
          Glastransport.bpVortransport := TRUE;

        eDrehPosition180Grad:
          Glastransport.bpVortransportRueckwaertig := TRUE;

      END_CASE

      steplVortransport := STEP_20_E;

(*VORTRANSPORT =====================*)
    STEP_20_E:
      (* Anmerkung:
         - Vortransport abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpVortransport := FALSE;
        Glastransport.bpVortransportRueckwaertig := FALSE;
        steplVortransport := STEP_1000_E;
      END_IF

(*VORTRANSPORT =====================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*VORTRANSPORT =====================*)
    STEP_1000_E:
      BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := TRUE;

(*VORTRANSPORT =====================*)
  END_CASE
ELSE
  IF (steplVortransport > STEP_0_E) THEN
    Glastransport.bpVortransport             := FALSE;
    Glastransport.bpVortransportRueckwaertig := FALSE;

    BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;

    steplVortransport           := STEP_0_E;
  END_IF
END_IF
END_ACTION