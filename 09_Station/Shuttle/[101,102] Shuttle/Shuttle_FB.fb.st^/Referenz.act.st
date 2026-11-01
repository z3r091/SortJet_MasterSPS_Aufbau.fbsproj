(* METADATA
{
  "v3Meta": {
    "objectGuid": "c8cf14a0-c27d-4720-ab84-3f437e2a9850"
  }
}
*)
ACTION Referenz
//-------------------------------------------------------------------------------------------------
// AKTION REFERENZIEREN
//-------------------------------------------------------------------------------------------------
IF ( blBetriebsartReferenz ) THEN
  CASE steplReferenz OF
    // REFERENZ =============================
    STEP_0_E:
      BasisStationsParameter.bReferenzAbgeschlossen := FALSE;

      steplReferenz := STEP_10_E;

    // REFERENZ =============================
    STEP_10_E:
      (* Hinweis:
         - Nur Referenz fahren wenn keine Referenzierte Achse vorliegt,
           ansonsten da Absolutgeber nur in Hand Referenzfahrt starten
      *)
      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        Wandverstellung[wlIndex].bpReferenz := NOT Wandverstellung[wlIndex].bpInReferenz;
      END_FOR
      Querfahrt.bpStartReferenz := NOT Querfahrt.bpInReference;

      steplReferenz := STEP_20_E;

    // REFERENZ =============================
    STEP_20_E:
      (* Hinweis:
         - Referenzieren des Bausteins abgeschlossen
      *)
      blDone := TRUE;

      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        blDone := blDone AND ( Wandverstellung[wlIndex].bpDone OR NOT Wandverstellung[wlIndex].bpReferenz );
      END_FOR

      IF blDone AND ( Querfahrt.bpDone OR Querfahrt.bpInReference ) THEN
        steplReferenz := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - -wandverstellung
      *)
      FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
        IF ( Wandverstellung[wlIndex].bpFehler ) THEN
          Wandverstellung[wlIndex].bpReferenz := FALSE;
          BasisStationsParameter.wFehlerNummer := Wandverstellung[wlIndex].wpFehlerNr;
          steplReferenz := STEP_900_E;
        END_IF
      END_FOR

    // REFERENZ =============================
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

    // REFERENZ =============================
    STEP_1000_E:
      BasisStationsParameter.bReferenzAbgeschlossen := TRUE;

  // REFERENZ ===============================
  END_CASE
ELSE
  IF ( steplReferenz > STEP_0_E ) THEN
    FOR wlIndex := cWAND_1 TO cANZAHL_WAENDE DO
      Wandverstellung[wlIndex].bpReferenz := FALSE;
    END_FOR
    BasisStationsParameter.bReferenzAbgeschlossen := FALSE;
    steplReferenz := STEP_0_E;
  END_IF
END_IF
END_ACTION