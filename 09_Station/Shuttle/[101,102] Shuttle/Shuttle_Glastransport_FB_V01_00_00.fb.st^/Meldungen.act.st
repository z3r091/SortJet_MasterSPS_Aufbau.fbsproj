(* METADATA
{
  "v3Meta": {
    "objectGuid": "2900d341-a386-42db-892a-d937de7a65c6"
  }
}
*)
ACTION Meldungen
//-------------------------------------------------------------------------------------------------
// AKTION MELDUNGEN
//-------------------------------------------------------------------------------------------------
IF( Antrieb.bpFehler
    AND NOT (
              steplEintransport            = STEP_900_E
              OR steplEintransportRueckwaertig = STEP_900_E
              OR steplAustransport            = STEP_900_E
              OR steplAustransportRueckwaertig = STEP_900_E
              OR steplVorabpositionieren      = STEP_900_E
              OR steplVorabpositionierenRueckwaertig = STEP_900_E
              OR steplSensorFreiFahren        = STEP_900_E
              OR steplVortransport            = STEP_900_E
              OR steplVortransportRueckwertig = STEP_900_E
              OR steplCheck                   = STEP_900_E
              OR steplReset                   = STEP_900_E
              OR steplReferenz                = STEP_900_E ))
THEN
  wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
  bpFehler := TRUE;
END_IF

IF bgStepLogging THEN

  IF steplCheckMerker <> steplCheck THEN

    stlLogString := CONCAT('Shuttle ', WORD_TO_STRING(stStationsNummern.NummerSPS));
    stlLogString := CONCAT(stlLogString, ' ; Glastr W ');
    stlLogString := CONCAT(stlLogString, WORD_TO_STRING(wpWandNr));
    stlLogString := CONCAT(stlLogString, ' ; SysCheck Alt: ');
    stlLogString := CONCAT(stlLogString, WORD_TO_STRING(steplCheckMerker));
    stlLogString := CONCAT(stlLogString, ' ; SysCheck Neu: ');
    stlLogString := CONCAT(stlLogString, WORD_TO_STRING(steplCheck));

    steplCheckMerker := steplCheck;
  
  END_IF

END_IF
END_ACTION