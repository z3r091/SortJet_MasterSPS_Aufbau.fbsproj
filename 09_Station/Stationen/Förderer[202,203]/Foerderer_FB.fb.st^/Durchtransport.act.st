(* METADATA
{
  "v3Meta": {
    "objectGuid": "712de05f-a316-424e-bc3e-5f90bc67e47e"
  }
}
*)
ACTION Durchtransport
//-------------------------------------------------------------------------------------------------
// AKTION DURCHTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( BasisStationsParameter.bDurchtransport[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpDurchtransport := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplDurchtransport := STEP_900_E;
  END_IF
  
  
  CASE steplDurchtransport OF
    // DURCHTRANSPORT =============================
    STEP_0_E:
      BasisStationsParameter.bDurchtransportAbgeschlossen[cWAND_1] := FALSE;

      steplDurchtransport := STEP_10_E;

    // AUSTRANSPORT =============================
    STEP_10_E:
      Glastransport.pAuftrag := BasisStationsParameter.pAuftrag[cWAND_1];
      Glastransport.bpDurchtransport := TRUE;

      steplDurchtransport := STEP_20_E;

    // DURCHTRANSPORT =============================
    STEP_20_E:
      IF ( Glastransport.bpDone )  THEN
        Glastransport.bpDurchtransport := FALSE;
        steplDurchtransport := STEP_1000_E;
      END_IF

    // DURCHTRANSPORT =============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // DURCHTRANSPORT =============================
    STEP_1000_E:
      BasisStationsParameter.bDurchtransportAbgeschlossen[cWAND_1] := TRUE;

  // DURCHTRANSPORT =============================
  END_CASE
ELSE
  IF (steplDurchtransport > STEP_0_E) THEN
    BasisStationsParameter.bDurchtransportAbgeschlossen[cWAND_1] := FALSE;
    Glastransport.bpDurchtransport := FALSE;
    steplDurchtransport := STEP_0_E;
  END_IF
END_IF
END_ACTION