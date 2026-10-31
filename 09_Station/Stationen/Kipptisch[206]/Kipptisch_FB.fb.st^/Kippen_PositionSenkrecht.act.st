(* METADATA
{
  "v3Meta": {
    "objectGuid": "acd285c0-5968-45ed-a443-a47253079003"
  }
}
*)
ACTION Kippen_PositionSenkrecht
(***************************************************************************************************)
(* AKTION KIPPEN SENKRECHT [84-90 GRAD] *)
(***************************************************************************************************)
IF ( blStartePositionSenkrecht ) THEN
	
  // Ausnahmesituation
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpStartKippenAuf := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplKippenSenkrecht := STEP_900_E;
  END_IF
	  
  CASE steplKippenSenkrecht OF

(* KIPPEN SENKRECHT =========================== *)
    STEP_0_E:
      blBewegungAbgeschlossen := FALSE;
      Kippen.bpStartKippenAuf := TRUE;
      steplKippenSenkrecht := STEP_10_E;

(* KIPPEN SENKRECHT =========================== *)
    STEP_10_E:
      IF ( Kippen.bpDone ) THEN
        Kippen.bpStartKippenAuf := FALSE;
        steplKippenSenkrecht := STEP_1000_E;
      END_IF

(* KIPPEN SENKRECHT =========================== *)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(* KIPPEN SENKRECHT =========================== *)
    STEP_1000_E: 
      blBewegungAbgeschlossen := TRUE;

(* KIPPEN SENKRECHT =========================== *)
  END_CASE
ELSE
  IF ( steplKippenSenkrecht > STEP_0_E ) THEN
    Kippen.bpStartKippenAuf := FALSE;
    blBewegungAbgeschlossen := FALSE;
    steplKippenSenkrecht := STEP_0_E;
  END_IF
END_IF
END_ACTION