(* METADATA
{
  "v3Meta": {
    "objectGuid": "39b32981-2725-4023-b633-5cdc76a7fe8a"
  }
}
*)
ACTION Kippen_Schuetz
(****************************************************************************************)
(* POSITIONIEREN *)
(****************************************************************************************)

IF ( bpPositionieren ) THEN

  // Ausnahmesituation
  IF ( bpSensorAuslauf
    AND NOT bpSensorEinlauf )
  THEN
    wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
    steplPositionieren := STEP_900_E;

  ELSIF ( bpSensorEinlauf
    AND NOT bpSensorAuslauf )
  THEN
    wpFehlerNr := cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT;
    steplPositionieren := STEP_900_E;

  ELSIF ( bpSensorEinlauf
    AND   bpSensorAuslauf )
  THEN
    wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
    steplPositionieren := STEP_900_E;

  END_IF


  CASE steplPositionieren OF
(*POSITIONIEREN =================================== *)
    STEP_0_E:
      (* Hinweis:
         - Variablen zurueck setzen
         - Pruefen ob der Antrieb bereit zum verfahrern ist
      *)
      bpDone := FALSE;
      bpPositionierenAbgeschlossen := FALSE;

      steplPositionieren := STEP_10_E;


(*POSITIONIEREN =================================== *)
    STEP_10_E:
      (* Hinweis:
         - Es darf weder der Einlauf noch der Auslauf- Sensor während der Dreh-Bewegung belegt sein
      *)
      IF NOT ( bpSensorEinlauf OR bpSensorAuslauf OR bpSensorAuslaufVorgaenger ) THEN

        IF NOT ( epKippStatus = epZielPosition ) THEN

          steplPositionieren := STEP_40_E;

        ELSE

          steplPositionieren := STEP_1000_E;

        END_IF

      ELSE

        IF ( bpSensorAuslauf AND NOT bpSensorEinlauf ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
          steplPositionieren := STEP_900_E;

        ELSIF ( bpSensorEinlauf AND NOT bpSensorAuslauf  ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT;
          steplPositionieren := STEP_900_E;

        ELSIF ( bpSensorAuslaufVorgaenger  ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_VORGAENGER;
          steplPositionieren := STEP_900_E;

        ELSE
          wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
          steplPositionieren := STEP_900_E;

        END_IF

      END_IF

(*POSITIONIEREN =================================== *)
    STEP_40_E:
      (* ---------------------------------------------------------------------------------------
      //  STARTEN DER ABSOLUT- POSITIONIERUNG
      //         
      //  Hinweis:
      // - Uebergabe der Zielposition fuer den Antrieb
      // ---------------------------------------------------------------------------------------*)
      CASE epZielPosition OF

        eKippen_Position_84Grad:
           out_bKippen84Grad  := TRUE;

        eKippen_Position_90Grad:
           out_bKippen90Grad  := TRUE;

        ELSE
          wpFehlerNr := cMELDUNG_KIPPEN_ZIEL_POSITION_UNGUELTIG;
          steplPositionieren := STEP_900_E;

      END_CASE

      steplPositionieren := STEP_120_E;


(*POSITIONIEREN =================================== *)
    STEP_120_E:
      (* Hinweis:
         - Bewegung abgeschlossen
      *)
     CASE epZielPosition OF

        
        eKippen_Position_84Grad:

          IF ( NOT bpSensorNicht84Grad AND bpSensorNicht90Grad) THEN
            out_bKippen84Grad := FALSE;
            steplPositionieren := STEP_1000_E;
          END_IF

         (* Ausnahmefehler:
             - Sensoren
          *)    
          IF ( tonlMaxWarteZeit.Q )THEN
            wpFehlerNr := cMELDUNG_KIPPEN_KIPPT_NICHT_AB;
            out_bKippen84Grad := FALSE;
            steplPositionieren := STEP_900_E;
          END_IF


        eKippen_Position_90Grad:

          IF ( NOT bpSensorNicht90Grad AND bpSensorNicht84Grad) THEN
            out_bKippen90Grad := FALSE;
            steplPositionieren := STEP_1000_E;
          END_IF

         (* Ausnahmefehler:
             - Sensoren
          *)    
          IF ( tonlMaxWarteZeit.Q )THEN
            wpFehlerNr := cMELDUNG_KIPPEN_KIPPT_NICHT_AUF;
            out_bKippen90Grad := FALSE;
            steplPositionieren := STEP_900_E;
          END_IF

      END_CASE
 
(*POSITIONIEREN =================================== *)
    STEP_900_E:
      bpFehler := TRUE;

(*POSITIONIEREN =================================== *)
    STEP_1000_E:
    out_bKippen84Grad := FALSE;
    out_bKippen90Grad := FALSE;
      bpDone := TRUE;
      bpPositionierenAbgeschlossen := TRUE;

(*POSITIONIEREN =================================== *)
  END_CASE

END_IF

IF ( NOT bpPositionieren ) THEN

  IF ( steplPositionieren > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bKippen84Grad := FALSE;
    out_bKippen90Grad := FALSE;
    bpPositionierenAbgeschlossen := FALSE;
    steplPositionieren := STEP_0_E;
  END_IF

END_IF
END_ACTION