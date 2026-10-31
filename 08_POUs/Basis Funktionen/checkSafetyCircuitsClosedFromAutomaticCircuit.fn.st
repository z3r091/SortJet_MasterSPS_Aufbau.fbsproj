(* METADATA
{
  "v3Meta": {
    "objectGuid": "6a4b769b-603d-4996-8e76-e26c1b994362"
  }
}
*)
FUNCTION checkSafetyCircuitsClosedFromAutomaticCircuit : BOOL
VAR_INPUT

  // WORD
  wlAutomatikkreis : WORD;

END_VAR
VAR
  // BOOL 
  findInWORDArray               : BOOL;
  bSicherheitskreisIstDurchgang : BOOL;
  
  // WORD
  wlIndexSicherheitskreis : WORD;

  // ENUM
  INDEX : Automatikkreis_EN;

END_VAR

// DIESE FUNKTION BERÜCKSICHTIGT KEINE DURCHGÄNGE !!!
checkSafetyCircuitsClosedFromAutomaticCircuit := TRUE;

FOR wlIndexSicherheitskreis := cERSTER_SICHERHEITSKREIS TO cLETZTER_SICHERHEITSKREIS DO

  bSicherheitskreisIstDurchgang := FALSE;

  FOR INDEX := cERSTER_DURCHGANG TO cANZAHL_DURCHGANGE DO
    IF apgMKDurchgang[INDEX].eZuBlockierenderSK = wlIndexSicherheitskreis THEN
      bSicherheitskreisIstDurchgang := TRUE;
      EXIT;
    END_IF
  END_FOR

  IF NOT bSicherheitskreisIstDurchgang THEN

    findInWORDArray := FALSE;

    FOR INDEX := cERSTER_AUTOMATIKKREIS TO cLETZTER_AUTOMATIKKREIS DO
      IF apgMKSicherheiskreis[wlIndexSicherheitskreis].eaAutomatikkreis[INDEX] = wlAutomatikkreis THEN
        findInWORDArray := TRUE;
        EXIT;
      END_IF
    END_FOR

    IF findInWORDArray THEN
      checkSafetyCircuitsClosedFromAutomaticCircuit :=
        checkSafetyCircuitsClosedFromAutomaticCircuit
        AND Sicherheitskreis[wlIndexSicherheitskreis].bpSicherheitskreisGeschlossen;
    END_IF

  END_IF

END_FOR
END_FUNCTION