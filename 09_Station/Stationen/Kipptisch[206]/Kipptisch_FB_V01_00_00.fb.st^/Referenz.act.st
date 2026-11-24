(* METADATA
{
	"v3Meta": {
		"objectGuid": "5ac2a813-d3de-47c3-bb02-33db481fa75c"
	}
}
*)
ACTION Referenz
//-------------------------------------------------------------------------------------------------
// AKTION REFERENZ
//-------------------------------------------------------------------------------------------------
IF ( blBetriebsartReferenz ) THEN

  // Ausnahmesituation
  IF ( Kippen.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] ) THEN
    Kippen.bpReferenz := FALSE;
    BasisStationsParameter.wFehlerNummer := Kippen.wpFehlerNr;
    steplReferenz := STEP_900_E;
  END_IF

  IF ( Querfahrt.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt ) THEN
    Querfahrt.bpReferenz := FALSE;
    BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
    steplReferenz := STEP_900_E;
  END_IF

  CASE steplReferenz OF
    // REFERENZ ===========================
    STEP_0_E:
      BasisStationsParameter.bReferenzAbgeschlossen := FALSE;

      (* Hinweis:
         - Achsen nur referenzieren, wenn sie laut Ausbaustufe vorhanden und noch nicht referenziert sind
      *)
      Kippen.bpReferenz    := BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] AND NOT Kippen.bpInReferenz;
      Querfahrt.bpReferenz := BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt       AND NOT Querfahrt.bpInReferenz;

      steplReferenz := STEP_10_E;

    // REFERENZ ===========================
    STEP_10_E:
      IF ( ( Kippen.bpDone OR NOT Kippen.bpReferenz ) AND ( Querfahrt.bpDone OR NOT Querfahrt.bpReferenz ) ) THEN
        Kippen.bpReferenz    := FALSE;
        Querfahrt.bpReferenz := FALSE;
        steplReferenz := STEP_1000_E;
      END_IF

    // REFERENZ ===========================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // REFERENZ ===========================
    STEP_1000_E:
      BasisStationsParameter.bReferenzAbgeschlossen := TRUE;

  // REFERENZ ===========================
  END_CASE
ELSE
  IF ( steplReferenz > STEP_0_E ) THEN
    Kippen.bpReferenz    := FALSE;
    Querfahrt.bpReferenz := FALSE;
    BasisStationsParameter.bReferenzAbgeschlossen := FALSE;
    steplReferenz := STEP_0_E;
  END_IF
END_IF
END_ACTION