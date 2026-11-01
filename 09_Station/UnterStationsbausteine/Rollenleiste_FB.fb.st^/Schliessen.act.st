(* METADATA
{
  "v3Meta": {
    "objectGuid": "644194fb-de79-4a5a-b76c-01cbc9d34ede"
  }
}
*)
ACTION Schliessen
//-------------------------------------------------------------------------------------------------
// AKTION - Rollenleiste schließen
//-------------------------------------------------------------------------------------------------
IF ( bpStarteSchliessen
     AND NOT bpStarteOeffnen )
THEN

  CASE steplSchrittketteSchliessen OF
    // SCHLIESSEN ========================================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Pruefen der Pneumatik- Zylinderstellung
      *)
      IF ( NOT in_bGeschlossen ) THEN
        tonlRollenleisteGeschlossen( IN := FALSE );

        out_bSchliessen := TRUE;

        steplSchrittketteSchliessen := STEP_10_E;
      ELSE
        steplSchrittketteSchliessen := STEP_1000_E;

      END_IF

    // SCHLIESSEN ========================================
    STEP_10_E:
      (* Hinweis:
         - Initialisieren der Timer
         - Pruefen ob die Zylinder ihre Bewegung abgeschlossen haben
      *)
      tonlRollenleisteGeschlossen( IN := NOT in_bGeschlossen,
                                   PT:= cZEITWERT_UEBERWACHUNG_BEWEGUNG );

      IF (  in_bGeschlossen ) THEN
        out_bSchliessen := FALSE;

        steplSchrittketteSchliessen := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Timer Zylinder
      *)
      IF ( tonlRollenleisteGeschlossen.Q ) THEN
        out_bSchliessen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_GLASFUEHRUNG_NICHT_EINGEFAHREN;
        steplSchrittketteSchliessen := STEP_900_E;
      END_IF

    // SCHLIESSEN ========================================
    STEP_900_E:
      bpFehler := TRUE;

    // SCHLIESSEN ========================================
    STEP_1000_E:
      bpDone := TRUE;

  END_CASE
END_IF

// SCHLIESSEN ========================================
IF ( NOT bpStarteSchliessen ) THEN

  IF (steplSchrittketteSchliessen > STEP_0_E) THEN
    bpDone := FALSE;
    out_bSchliessen := FALSE;
    steplSchrittketteSchliessen := STEP_0_E;
  END_IF

END_IF
END_ACTION