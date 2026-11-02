(* METADATA
{
  "v3Meta": {
    "objectGuid": "88d8ef90-0d8b-4c36-86be-9ad736299879"
  }
}
*)
ACTION WandverstellungOeffnen
// @TEXT_IMPLEMENTATION := 'ST'
//-------------------------------------------------------------------------------------------------
// AKTION - Wandverstellung öffnen
//-------------------------------------------------------------------------------------------------
IF ( bpWandverstellungOeffnen ) THEN

  CASE steplWandverstellungOeffnen OF
    // Wandverstellung öffnen =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Pruefen der Pneumatik- Zylinderstellung (ohne Endlagensensor immer die volle Bewegungszeit abwarten)
      *)
      bpDone := FALSE;
      tonlEingefahrenWandEinlaufseite( IN := FALSE );
      tonlEingefahrenWandAuslaufseite( IN := FALSE );
      tonlBewegungszeitOeffnen( IN := FALSE );

      IF ( bpAbfrageGeoeffnetVorhanden AND in_bWandEinlaufseiteGeoeffnet AND in_bWandAuslaufseiteGeoeffnet ) THEN
        steplWandverstellungOeffnen := STEP_1000_E;
      ELSE
        epWandStatus := eWandOeffnung_Undefiniert;
        steplWandverstellungOeffnen := STEP_10_E;
      END_IF

    // Wandverstellung öffnen =====================
    STEP_10_E:
      (* Hinweis:
         - Oeffnen, Gegenausgang aus
         - Pruefen ob die Zylinder ihre Bewegung abgeschlossen haben
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bWandverstellungOeffnen    := TRUE;
      out_bWandverstellungSchliessen := FALSE;

      tonlEingefahrenWandEinlaufseite( IN := bpAbfrageGeoeffnetVorhanden AND NOT in_bWandEinlaufseiteGeoeffnet, PT := T#5s );
      tonlEingefahrenWandAuslaufseite( IN := bpAbfrageGeoeffnetVorhanden AND NOT in_bWandAuslaufseiteGeoeffnet, PT := T#5s );
      tonlBewegungszeitOeffnen( IN := NOT bpAbfrageGeoeffnetVorhanden, PT := tpBewegungszeit );

      IF (    ( bpAbfrageGeoeffnetVorhanden AND in_bWandEinlaufseiteGeoeffnet AND in_bWandAuslaufseiteGeoeffnet )
           OR ( NOT bpAbfrageGeoeffnetVorhanden AND tonlBewegungszeitOeffnen.Q ) )
      THEN
        out_bWandverstellungOeffnen := FALSE;
        steplWandverstellungOeffnen := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder Wand Einlauf- / Auslaufseite (nur mit Endlagensensor)
      *)
      IF ( tonlEingefahrenWandEinlaufseite.Q OR tonlEingefahrenWandAuslaufseite.Q ) THEN
        out_bWandverstellungOeffnen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_WAND_NICHT_EINGEFAHREN;
        steplWandverstellungOeffnen := STEP_900_E;
      END_IF

    // Wandverstellung öffnen =====================
    STEP_900_E:
      out_bWandverstellungOeffnen := FALSE;
      bpFehler := TRUE;

    // Wandverstellung öffnen =====================
    STEP_1000_E:
      // Ohne Sensor ist die Stellung zeitlich angenommen, nicht gemessen
      IF NOT bpAbfrageGeoeffnetVorhanden THEN
        epWandStatus := eWandOeffnung_Offen;
      END_IF
      bpDone := TRUE;

  // Wandverstellung öffnen =====================
  END_CASE
ELSE

  IF ( steplWandverstellungOeffnen > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bWandverstellungOeffnen := FALSE;
    tonlEingefahrenWandEinlaufseite( IN := FALSE );
    tonlEingefahrenWandAuslaufseite( IN := FALSE );
    tonlBewegungszeitOeffnen( IN := FALSE );
    steplWandverstellungOeffnen := STEP_0_E;
  END_IF

END_IF
END_ACTION