(* METADATA
{
  "v3Meta": {
    "objectGuid": "5350c6c8-d6e5-4c89-a6bb-419fe93f1607"
  }
}
*)
ACTION Start
//-------------------------------------------------------------------------------------------------
// AKTION: GEBLAESE STARTEN
//-------------------------------------------------------------------------------------------------
IF (  bpStart
     AND NOT bpReset )
THEN
  CASE steplStart OF
    // START =================================
    STEP_0_E:
      bpDone := FALSE;

      IF ( toflMotorschutz.Q ) THEN
        steplStart := STEP_10_E;
      END_IF

    // START =================================
    STEP_10_E:
      IF ( NOT toflWarteAufWiederAnlauf.Q ) THEN
        steplStart := STEP_20_E;
      END_IF

    // START =================================
    STEP_20_E:
      IF ( tonlStartGeblaese.Q ) THEN
        out_bStarteGeblaese := TRUE;
        steplStart := STEP_30_E;
      END_IF

    // START =================================
    STEP_30_E:
      (* Hinweis:
         - Geblaese gestartet
      *)
      bpDone := tonlWarteAufGeblaeseLaeuft.Q;

      (* Fehlerbehandlung:
         - Motorschutzschalter
      *)
      IF ( NOT toflMotorschutz.Q ) THEN
        out_bStarteGeblaese := FALSE;
        wpFehlerNr := cMELDUNG_ANTRIEB_GEBLAESE;
        steplStart := STEP_900_E;
      END_IF

    // START =================================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpFehler := TRUE;

  // START =================================
  END_CASE

ELSE

  (* Hinweis:
     - Reset wegen Abbruch der Schrittkette
  *)
  IF ( steplStart > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bStarteGeblaese := FALSE;
    steplStart := STEP_0_E;
  END_IF

END_IF
END_ACTION