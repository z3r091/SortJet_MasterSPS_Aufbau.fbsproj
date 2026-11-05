(* METADATA
{
  "v3Meta": {
    "objectGuid": "acd285c0-5968-45ed-a443-a47253079003"
  }
}
*)
ACTION Kippen_PositionSenkrecht
//-------------------------------------------------------------------------------------------------
// AKTION KIPPEN SENKRECHT [84-90 GRAD]
//-------------------------------------------------------------------------------------------------
IF ( blStartePositionSenkrecht ) THEN

  // Ausnahmesituation
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpPositionieren := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplKippenSenkrecht := STEP_900_E;
  END_IF

  CASE steplKippenSenkrecht OF

    // KIPPEN SENKRECHT ===========================
    STEP_0_E:
      blBewegungAbgeschlossen := FALSE;
      Kippen.epZielPosition := eKippen_Position_90Grad;
      Kippen.bpPositionieren := TRUE;
      steplKippenSenkrecht := STEP_10_E;

    // KIPPEN SENKRECHT ===========================
    STEP_10_E:
      IF ( Kippen.bpDone ) THEN
        Kippen.bpPositionieren := FALSE;
        steplKippenSenkrecht := STEP_1000_E;
      END_IF

    // KIPPEN SENKRECHT ===========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // KIPPEN SENKRECHT ===========================
    STEP_1000_E: 
      blBewegungAbgeschlossen := TRUE;

  // KIPPEN SENKRECHT ===========================
  END_CASE
ELSE
  IF ( steplKippenSenkrecht > STEP_0_E ) THEN
    Kippen.bpPositionieren := FALSE;
    blBewegungAbgeschlossen := FALSE;
    steplKippenSenkrecht := STEP_0_E;
  END_IF
END_IF
END_ACTION