(* METADATA
{
  "v3Meta": {
    "objectGuid": "c98ba259-e9b4-46df-a992-713a0bef6c02"
  }
}
*)
ACTION Messkopplung
//-------------------------------------------------------------------------------------------------
// AKTION MESSKOPPLUNG
//-------------------------------------------------------------------------------------------------
IF (  BasisStationsParameter.bMesskopplung[cWAND_1]
     AND blBetriebsartAutomatik )
THEN

  // Ausnahmesituation
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpMesskopplung := FALSE;
    BasisStationsParameter.wFehlerNummer :=  Glastransport.wpFehlerNr;
    steplMesskopplung := STEP_900_E;
  END_IF
  
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpStartKippenAuf := FALSE;
    Kippen.bpStartKippenAb  := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplMesskopplung := STEP_900_E;
  END_IF
  
   
  CASE steplMesskopplung OF
    // MESSKOPPLUNG ===================================
    STEP_0_E:
      (* Anmerkung:
         - Kipptisch in Grundstellung schwenken
      *)
      BasisStationsParameter.bMesskopplungAbgeschlossen[cWAND_1] := FALSE;

      steplMesskopplung := STEP_10_E;

    // MESSKOPPLUNG ===================================
    STEP_10_E:
      Kippen.bpStartKippenAb := TRUE;

      steplMesskopplung := STEP_20_E;

    // MESSKOPPLUNG ===================================
    STEP_20_E:
      IF (  ( Kippen.bpDone )
           AND ( Kippen.epKippStatus = eKippen_Position_0Grad ) )
      THEN
        Querfahrt.bpPositionieren := FALSE;
        Kippen.bpStartKippenAb    := FALSE;

        steplMesskopplung := STEP_30_E;
      END_IF

    // MESSKOPPLUNG ===================================
    STEP_30_E:
      (* Anmerkung:
         - Starten des Prozesses
      *)
      Glastransport.bpMesskopplung := TRUE;

    // MESSKOPPLUNG ===================================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // MESSKOPPLUNG ===================================
    STEP_1000_E:
      BasisStationsParameter.bMesskopplungAbgeschlossen[cWAND_1] := TRUE;

  // MESSKOPPLUNG ===================================
  END_CASE
ELSE

  IF ( steplMesskopplung > STEP_0_E ) THEN
    Glastransport.bpMesskopplung := FALSE;

    Kippen.bpStartKippenAuf := FALSE;
    Kippen.bpStartKippenAb  := FALSE;

    BasisStationsParameter.bMesskopplungAbgeschlossen[cWAND_1] := FALSE;
    steplMesskopplung := STEP_0_E;
  END_IF

END_IF
END_ACTION