(* METADATA
{
  "v3Meta": {
    "objectGuid": "ccebd1ac-bf4c-4d6d-a13a-6ceb9f77183e"
  }
}
*)
ACTION WandverstellungSchliessen
(* @TEXT_IMPLEMENTATION := 'ST' *)
(***************************************************************************************************)
(* AKTION - WANDOEFFNUNG VERSTELLEN [Min- Max- Position] *)
(***************************************************************************************************)

IF ( bpWandverstellungSchliessen
 AND NOT bpWandverstellungOeffnen )
THEN

  CASE steplWandverstellungSchliessen OF
(* Wandverstellung schließen =====================*)
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Pruefen der Pneumatik- Zylinderstellung
      *)
      IF ( NOT in_bWandEinlaufseiteGeschlossen
        OR NOT in_bWandAuslaufseiteGeschlossen )
      THEN
        tonlAusgefahrenWandEinlaufseite( IN := FALSE );
        tonlAusgefahrenWandAuslaufseite( IN := FALSE );

        out_bWandverstellungSchliessen := TRUE;

        steplWandverstellungSchliessen := STEP_10_E;
      ELSE
        steplWandverstellungSchliessen := STEP_1000_E;

      END_IF

(* Wandverstellung schließen =====================*)
    STEP_10_E:
      (* Hinweis:
         - Initialisieren der Timer
         - Pruefen ob die Zylinder ihre Bewegung abgeschlossen haben
      *)
      tonlAusgefahrenWandEinlaufseite( IN := NOT in_bWandEinlaufseiteGeschlossen, PT:= T#5s );
      tonlAusgefahrenWandAuslaufseite( IN := NOT in_bWandAuslaufseiteGeschlossen, PT:= T#5s );

      IF (  in_bWandEinlaufseiteGeschlossen
        AND in_bWandAuslaufseiteGeschlossen )
      THEN
        out_bWandverstellungSchliessen := FALSE;

        steplWandverstellungSchliessen := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder Wand
      *)
      IF ( tonlAusgefahrenWandEinlaufseite.Q ) THEN
        out_bWandverstellungSchliessen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_WAND_NICHT_AUSGEFAHREN;
        steplWandverstellungSchliessen := STEP_900_E;
      END_IF

      IF ( tonlAusgefahrenWandAuslaufseite.Q ) THEN
        out_bWandverstellungSchliessen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_WAND_NICHT_AUSGEFAHREN;
        steplWandverstellungSchliessen := STEP_900_E;
      END_IF

(* Wandverstellung schließen =====================*)
    STEP_900_E:
      bpFehler := TRUE;

(* Wandverstellung schließen =====================*)
    STEP_1000_E:
      bpDone := TRUE;

  END_CASE
END_IF

(* Wandverstellung schließen =====================*)
IF ( NOT bpWandverstellungSchliessen ) THEN

  IF (steplWandverstellungSchliessen > STEP_0_E) THEN
    bpDone := FALSE;
    out_bWandverstellungSchliessen := FALSE;
    steplWandverstellungSchliessen := STEP_0_E;
  END_IF

END_IF
END_ACTION