(* METADATA
{
	"v3Meta": {
		"objectGuid": "b61e378d-5583-47dc-bc86-2936f87525f9"
	}
}
*)
ACTION Referenz
//-------------------------------------------------------------------------------------------------
// AKTION REFERENZ
//-------------------------------------------------------------------------------------------------
IF ( blBetriebsartReferenz ) THEN

  // Ausnahmesituation
  IF ( Drehen.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bDrehen ) THEN
    Drehen.bpReferenz := FALSE;
    BasisStationsParameter.wFehlerNummer := Drehen.wpFehlerNr;
    steplReferenz := STEP_900_E;
  END_IF

  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpReferenz := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplReferenz := STEP_900_E;
  END_IF

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
      steplReferenz := STEP_10_E;

    // REFERENZ ===========================
    STEP_10_E:
      (* Hinweis:
         -  Starten der Referenzfahrt
      *)
      Drehen.bpReferenz        := BasisStationsParameter.stMKs.stStationsAufbau.bDrehen           AND NOT Drehen.bpInReferenz;
      Kippen.bpReferenz        := BasisStationsParameter.stMKs.stStationsAufbau.bKippen[cWAND_1] AND NOT Kippen.bpInReferenz;
      Querfahrt.bpReferenz     := BasisStationsParameter.stMKs.stStationsAufbau.bQuerfahrt        AND NOT Querfahrt.bpInReferenz;
      Glastransport.bpReferenz := TRUE;
      steplReferenz := STEP_20_E;

    // REFERENZ ===========================
    STEP_20_E:
      (* Hinweis:
         - Referenzfahrt abgeschlossen
      *)
      IF ( Drehen.bpDone OR NOT Drehen.bpReferenz ) THEN
        Drehen.bpReferenz := FALSE;
        steplReferenz := STEP_100_E;
      END_IF

    // REFERENZ ============================
    STEP_100_E:
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpReferenz := FALSE;
        steplReferenz := STEP_200_E;
      END_IF

    // REFERENZ ===========================
    STEP_200_E:
      (* Hinweis:
         - Referenzfahrt abgeschlossen
      *)
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
    BasisStationsParameter.bReferenzAbgeschlossen := FALSE;
    Glastransport.bpReferenz := FALSE;
    Kippen.bpReferenz        := FALSE;
    Drehen.bpReferenz        := FALSE;
    Querfahrt.bpReferenz     := FALSE;
    steplReferenz := STEP_0_E;
  END_IF

END_IF
END_ACTION