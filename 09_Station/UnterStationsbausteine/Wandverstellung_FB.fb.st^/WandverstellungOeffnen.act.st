(* METADATA
{
  "v3Meta": {
    "objectGuid": "88d8ef90-0d8b-4c36-86be-9ad736299879"
  }
}
*)
ACTION WandverstellungOeffnen
(* @TEXT_IMPLEMENTATION := 'ST' *)
(***************************************************************************************************)
(* AKTION - Wandverstellung öffnen *)
(***************************************************************************************************)

IF ( bpWandverstellungOeffnen
     AND NOT bpWandverstellungSchliessen )
THEN

  CASE steplWandverstellungOeffnen OF
    (* Wandverstellung öffnen =====================*)
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Pruefen der Pneumatik- Zylinderstellung
      *)
      IF ( NOT in_bWandEinlaufseiteGeoeffnet
           OR NOT in_bWandAuslaufseiteGeoeffnet )
      THEN
        tonlEingefahrenWandEinlaufseite(IN := FALSE);
        tonlEingefahrenWandAuslaufseite(IN := FALSE);

        out_bWandverstellungOeffnen:= TRUE;

        steplWandverstellungOeffnen := STEP_10_E;

      ELSE
        steplWandverstellungOeffnen := STEP_1000_E;

      END_IF

    (* Wandverstellung öffnen =====================*)
    STEP_10_E:
      (* Hinweis:
         - Initialisieren der Timer
         - Pruefen ob die Zylinder ihre Bewegung abgeschlossen haben
      *)
      tonlEingefahrenWandEinlaufseite(IN := NOT in_bWandEinlaufseiteGeoeffnet, PT:= T#5s );
      tonlEingefahrenWandAuslaufseite(IN := NOT in_bWandAuslaufseiteGeoeffnet, PT:= T#5s );


      IF (  in_bWandEinlaufseiteGeoeffnet
           AND in_bWandAuslaufseiteGeoeffnet )
      THEN
        out_bWandverstellungOeffnen := FALSE;
        steplWandverstellungOeffnen := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder Wand
         - Zylinder Scheibenfuehrung
      *)
      IF ( tonlEingefahrenWandEinlaufseite.Q ) THEN
        out_bWandverstellungOeffnen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_WAND_NICHT_EINGEFAHREN;
        steplWandverstellungOeffnen := STEP_900_E;
      END_IF

      IF ( tonlEingefahrenWandAuslaufseite.Q ) THEN
        out_bWandverstellungOeffnen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_WAND_NICHT_EINGEFAHREN;
        steplWandverstellungOeffnen := STEP_900_E;
      END_IF

    (* Wandverstellung öffnen =====================*)
    STEP_900_E:
      bpFehler := TRUE;

    (* Wandverstellung öffnen =====================*)
    STEP_1000_E:
      bpDone := TRUE;

  (* Wandverstellung öffnen =====================*)
  END_CASE
END_IF

IF ( NOT bpWandverstellungOeffnen ) THEN

  IF (steplWandverstellungOeffnen > STEP_0_E) THEN
    bpDone := FALSE;
    out_bWandverstellungOeffnen := FALSE;
    steplWandverstellungOeffnen := STEP_0_E;
  END_IF
END_IF
END_ACTION