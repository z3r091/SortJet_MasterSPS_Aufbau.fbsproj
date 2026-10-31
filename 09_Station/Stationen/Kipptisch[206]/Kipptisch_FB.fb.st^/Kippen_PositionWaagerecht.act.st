(* METADATA
{
	"v3Meta": {
		"objectGuid": "1a562a31-6670-4c27-9ca3-75f83477db53"
	}
}
*)
ACTION Kippen_PositionWaagerecht
(***************************************************************************************************)
(* AKTION KIPPEN WAAGERECHT *)
(***************************************************************************************************)
IF ( blStartePositionWaagerecht ) THEN
	
  // Ausnahmesituation
  IF ( Kippen.bpFehler ) THEN
    Kippen.bpStartKippenAb := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplKippenWaagerecht := STEP_900_E;
  END_IF

  CASE steplKippenWaagerecht OF

(* KIPPEN WAAGERECHT =========================== *)
    STEP_0_E:
      blBewegungAbgeschlossen := FALSE;
      Kippen.bpStartKippenAb := TRUE;

      steplKippenWaagerecht := STEP_10_E;

(* KIPPEN WAAGERECHT =========================== *)
    STEP_10_E:
       IF ( Kippen.bpDone ) THEN
         Kippen.bpStartKippenAb := FALSE;
         steplKippenWaagerecht := STEP_1000_E;
       END_IF

(* KIPPEN WAAGERECHT =========================== *)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(* KIPPEN WAAGERECHT =========================== *)
    STEP_1000_E:
      blBewegungAbgeschlossen := TRUE;

(* KIPPEN WAAGERECHT =========================== *)
  END_CASE
ELSE
  IF ( steplKippenWaagerecht > STEP_0_E ) THEN
    Kippen.bpStartKippenAb  := FALSE;
    blBewegungAbgeschlossen := FALSE;
    steplKippenWaagerecht := STEP_0_E;
  END_IF
END_IF
END_ACTION