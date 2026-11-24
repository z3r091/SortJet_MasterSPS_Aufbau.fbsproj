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

  // BOOL
  bNurStartBlockierende : BOOL := FALSE; // TRUE: nur Sicherheitskreise beruecksichtigen, die Systemcheck und Initialisierung blockieren [MK bBlockiertStart]

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

    IF findInWORDArray AND ( NOT bNurStartBlockierende OR apgMKSicherheiskreis[wlIndexSicherheitskreis].bBlockiertStart ) THEN
      checkSafetyCircuitsClosedFromAutomaticCircuit :=
                                                      checkSafetyCircuitsClosedFromAutomaticCircuit
                                                      AND Sicherheitskreis[wlIndexSicherheitskreis].bpSicherheitskreisGeschlossen;
    END_IF

  END_IF

END_FOR
END_FUNCTION