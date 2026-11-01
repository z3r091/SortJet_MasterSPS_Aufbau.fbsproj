(* METADATA
{
  "v3Meta": {
    "objectGuid": "d7244950-14d1-428a-9790-156c8ff0802c"
  }
}
*)
ACTION Vortransport
//-------------------------------------------------------------------------------------------------
// AKTION VORTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bVortransport[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpVortransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplVortransport := STEP_900_E;
  END_IF
  
  
  CASE steplVortransport OF
    // VORTRANSPORT =====================
    STEP_0_E:
      BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;
      steplVortransport := STEP_10_E;

    // VORTRANSPORT =====================
    STEP_10_E:
      (* Hinweis:
         - Starten des Vortransports
      *)
      Glastransport.bpVortransport := TRUE;

      steplVortransport := STEP_20_E;

    // VORTRANSPORT =====================
    STEP_20_E:
      (* Anmerkung:
         - Vortransport abgeschlossen
      *)
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpVortransport := FALSE;
        steplVortransport := STEP_1000_E;
      END_IF

    // VORTRANSPORT =====================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // VORTRANSPORT =====================
    STEP_1000_E:
      BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := TRUE;

  // VORTRANSPORT =====================
  END_CASE
ELSE
  IF (steplVortransport > STEP_0_E) THEN
    BasisStationsParameter.bVortransportAbgeschlossen[cWAND_1] := FALSE;
    Glastransport.bpVortransport := FALSE;
    steplVortransport := STEP_0_E;
  END_IF
END_IF
END_ACTION