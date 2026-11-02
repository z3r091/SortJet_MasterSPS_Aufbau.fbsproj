(* METADATA
{
  "v3Meta": {
    "objectGuid": "a6e102a8-bab7-42fc-8599-6d946601164e"
  }
}
*)
ACTION Oeffnen
//-------------------------------------------------------------------------------------------------
// AKTION - ROLLENLEISTE OEFFNEN
//-------------------------------------------------------------------------------------------------
IF ( bpStarteOeffnen ) THEN

  CASE steplSchrittketteOeffnen OF
    // OEFFNEN =================================================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Pruefen der Pneumatik- Zylinderstellung (ohne Endlagensensor immer die volle Bewegungszeit abwarten)
      *)
      bpDone := FALSE;
      tonlRollenleisteGeoeffnet( IN := FALSE );
      tonlBewegungszeitOeffnen( IN := FALSE );

      IF ( bpAbfrageGeoeffnetVorhanden AND in_bGeoeffnet ) THEN
        steplSchrittketteOeffnen := STEP_1000_E;
      ELSE
        steplSchrittketteOeffnen := STEP_10_E;
      END_IF

    // OEFFNEN =================================================
    STEP_10_E:
      (* Hinweis:
         - Oeffnen, Gegenausgang aus
         - Pruefen ob die Zylinder ihre Bewegung abgeschlossen haben
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bOeffnen    := TRUE;
      out_bSchliessen := FALSE;

      tonlRollenleisteGeoeffnet( IN := bpAbfrageGeoeffnetVorhanden AND NOT in_bGeoeffnet,
                                 PT := cZEITWERT_UEBERWACHUNG_BEWEGUNG );
      tonlBewegungszeitOeffnen( IN := NOT bpAbfrageGeoeffnetVorhanden,
                                PT := tpBewegungszeit );

      IF (    ( bpAbfrageGeoeffnetVorhanden AND in_bGeoeffnet )
           OR ( NOT bpAbfrageGeoeffnetVorhanden AND tonlBewegungszeitOeffnen.Q ) )
      THEN
        out_bOeffnen := FALSE;
        steplSchrittketteOeffnen := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Timer Zylinder (nur mit Endlagensensor)
      *)
      IF ( tonlRollenleisteGeoeffnet.Q ) THEN
        out_bOeffnen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_GLASFUEHRUNG_NICHT_AUSGEFAHREN;
        steplSchrittketteOeffnen := STEP_900_E;
      END_IF

    // OEFFNEN =================================================
    STEP_900_E:
      out_bOeffnen := FALSE;
      bpFehler := TRUE;

    // OEFFNEN =================================================
    STEP_1000_E:
      bpDone := TRUE;

  // OEFFNEN =================================================
  END_CASE
ELSE

  IF ( steplSchrittketteOeffnen > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bOeffnen := FALSE;
    tonlRollenleisteGeoeffnet( IN := FALSE );
    tonlBewegungszeitOeffnen( IN := FALSE );
    steplSchrittketteOeffnen := STEP_0_E;
  END_IF

END_IF
END_ACTION