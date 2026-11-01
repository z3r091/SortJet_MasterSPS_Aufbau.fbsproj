(* METADATA
{
  "v3Meta": {
    "objectGuid": "661b0014-2353-4746-8e31-b09b650916e4"
  }
}
*)
ACTION Kippen_Schuetz
(******************************************************************************)
(* KIPPEN SCHÜTZ *)
(******************************************************************************)
IF ( bpPositionieren ) THEN

  IF(  bpSensorEinlauf ) THEN
    wpFehlerNr := cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT;
    out_bKippenAbSetzen  := FALSE;
    out_bKippenAufSetzen := FALSE;
    steplKippenSchuetz := STEP_900_E;
  END_IF
  
  IF (bpSensorAuslauf ) THEN
    wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
    out_bKippenAbSetzen  := FALSE;
    out_bKippenAufSetzen := FALSE;
    steplKippenSchuetz := STEP_900_E;
  END_IF
  
  IF ( tonlMaxWarteZeit.Q )THEN
    wpFehlerNr := cMELDUNG_KIPPEN_KIPPT_NICHT_AB;
    out_bKippenAbSetzen  := FALSE;
    out_bKippenAufSetzen := FALSE;
    steplKippenSchuetz := STEP_900_E;
  END_IF

  CASE steplKippenSchuetz OF
    (*KIPPEN SCHÜTZ AUFKIPPEN =================================*)
    STEP_0_E:
      // Keine Sollposition vorgegeben
      IF ( epZielPosition = eKippen_Default ) THEN
        out_bKippenAufSetzen := FALSE;
        out_bKippenAbSetzen := FALSE;
        steplKippenSchuetz := STEP_1000_E;

      // Kippen auf 90Grad
      ELSIF ( epZielPosition = eKippen_Position_90Grad ) THEN
        IF ( in_bSensorNicht90Grad ) THEN
          out_bKippenAufSetzen := TRUE;
          steplKippenSchuetz := STEP_10_E;
        ELSE
          out_bKippenAufSetzen := FALSE;
          steplKippenSchuetz := STEP_1000_E;
        END_IF

      // Kippen auf 84Grad
      ELSE
        steplKippenSchuetz := STEP_100_E;
      END_IF

    (*KIPPEN SCHÜTZ AUFKIPPEN =================================*)
    STEP_10_E:
      IF ( NOT in_bSensorNicht90Grad ) THEN
        out_bKippenAufSetzen := FALSE;
        steplKippenSchuetz := STEP_1000_E;
      END_IF

    (*KIPPEN SCHÜTZ ABKIPPEN ==========================*)
    STEP_100_E:
      IF ( epZielPosition = eKippen_Position_84Grad ) THEN
        IF ( in_bSensorNicht84Grad ) THEN
          out_bKippenAbSetzen := TRUE;
          steplKippenSchuetz := STEP_110_E;
        ELSE
          out_bKippenAbSetzen := FALSE;
          steplKippenSchuetz := STEP_1000_E;
        END_IF
      ELSE
        wpFehlerNr := cMELDUNG_KIPPEN_ZIEL_POSITION_UNGUELTIG;
        steplKippenSchuetz := STEP_900_E;
      END_IF

    (*KIPPEN SCHÜTZ ABKIPPEN ==========================*)
    STEP_110_E:
      IF ( NOT in_bSensorNicht84Grad ) THEN
        out_bKippenAbSetzen := FALSE;
        steplKippenSchuetz := STEP_1000_E;
      END_IF

    (*KIPPEN SCHÜTZ =================================*)
    STEP_900_E:
      bpFehler := TRUE;

    (*KIPPEN SCHÜTZ =================================*)
    STEP_1000_E:
      bpDone := TRUE;

  (*KIPPEN SCHÜTZ =================================*)
  END_CASE

ELSE

  IF ( steplKippenSchuetz > STEP_0_E ) THEN
    steplKippenSchuetz := STEP_0_E;
    out_bKippenAbSetzen  := FALSE;
    out_bKippenAufSetzen := FALSE;
    bpDone               := FALSE;
  END_IF
END_IF
END_ACTION