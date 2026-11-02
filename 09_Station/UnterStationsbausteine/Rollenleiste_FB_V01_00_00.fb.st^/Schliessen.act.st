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
IF ( bpStarteSchliessen ) THEN

  CASE steplSchrittketteSchliessen OF
    // SCHLIESSEN ========================================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Pruefen der Pneumatik- Zylinderstellung (ohne Endlagensensor immer die volle Bewegungszeit abwarten)
      *)
      bpDone := FALSE;
      tonlRollenleisteGeschlossen( IN := FALSE );
      tonlBewegungszeitSchliessen( IN := FALSE );

      IF ( bpAbfrageGeschlossenVorhanden AND in_bGeschlossen ) THEN
        steplSchrittketteSchliessen := STEP_1000_E;
      ELSE
        steplSchrittketteSchliessen := STEP_10_E;
      END_IF

    // SCHLIESSEN ========================================
    STEP_10_E:
      (* Hinweis:
         - Schliessen, Gegenausgang aus
         - Pruefen ob die Zylinder ihre Bewegung abgeschlossen haben
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bSchliessen := TRUE;
      out_bOeffnen    := FALSE;

      tonlRollenleisteGeschlossen( IN := bpAbfrageGeschlossenVorhanden AND NOT in_bGeschlossen,
                                   PT := cZEITWERT_UEBERWACHUNG_BEWEGUNG );
      tonlBewegungszeitSchliessen( IN := NOT bpAbfrageGeschlossenVorhanden,
                                   PT := tpBewegungszeit );

      IF (    ( bpAbfrageGeschlossenVorhanden AND in_bGeschlossen )
           OR ( NOT bpAbfrageGeschlossenVorhanden AND tonlBewegungszeitSchliessen.Q ) )
      THEN
        out_bSchliessen := FALSE;
        steplSchrittketteSchliessen := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Timer Zylinder (nur mit Endlagensensor)
      *)
      IF ( tonlRollenleisteGeschlossen.Q ) THEN
        out_bSchliessen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_GLASFUEHRUNG_NICHT_EINGEFAHREN;
        steplSchrittketteSchliessen := STEP_900_E;
      END_IF

    // SCHLIESSEN ========================================
    STEP_900_E:
      out_bSchliessen := FALSE;
      bpFehler := TRUE;

    // SCHLIESSEN ========================================
    STEP_1000_E:
      bpDone := TRUE;

  END_CASE
ELSE

  IF ( steplSchrittketteSchliessen > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bSchliessen := FALSE;
    tonlRollenleisteGeschlossen( IN := FALSE );
    tonlBewegungszeitSchliessen( IN := FALSE );
    steplSchrittketteSchliessen := STEP_0_E;
  END_IF

END_IF
END_ACTION