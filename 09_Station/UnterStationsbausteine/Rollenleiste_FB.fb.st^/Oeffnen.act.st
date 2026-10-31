(* METADATA
{
  "v3Meta": {
    "objectGuid": "a6e102a8-bab7-42fc-8599-6d946601164e"
  }
}
*)
ACTION Oeffnen
(***************************************************************************************************)
(* AKTION - ROLLENLEISTE OEFFNEN *)
(***************************************************************************************************)

IF ( bpStarteOeffnen
 AND NOT bpStarteSchliessen )
THEN

  CASE steplSchrittketteOeffnen OF
(* OEFFNEN =================================================*)
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Pruefen der Pneumatik- Zylinderstellung
      *)
      IF ( NOT in_bGeoeffnet ) THEN
        tonlRollenleisteGeoeffnet(IN := FALSE);

        out_bOeffnen:= TRUE;

        steplSchrittketteOeffnen := STEP_10_E;
      ELSE
        steplSchrittketteOeffnen := STEP_1000_E;

      END_IF

(* OEFFNEN =================================================*)
    STEP_10_E:
      (* Hinweis:
         - Initialisieren der Timer
         - Pruefen ob die Zylinder ihre Bewegung abgeschlossen haben
      *)
      tonlRollenleisteGeoeffnet( IN := NOT in_bGeoeffnet,
                                 PT := cZEITWERT_UEBERWACHUNG_BEWEGUNG );

      IF (  in_bGeoeffnet ) THEN
        out_bOeffnen := FALSE;
        steplSchrittketteOeffnen := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Timer Zylinder
      *)
      IF ( tonlRollenleisteGeoeffnet.Q ) THEN
        out_bOeffnen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_GLASFUEHRUNG_NICHT_AUSGEFAHREN;
        steplSchrittketteOeffnen := STEP_900_E;
      END_IF

(* OEFFNEN =================================================*)
    STEP_900_E:
      bpFehler := TRUE;

(* OEFFNEN =================================================*)
    STEP_1000_E:
      bpDone := TRUE;

(* OEFFNEN =================================================*)
  END_CASE
END_IF

IF ( NOT bpStarteOeffnen ) THEN

  IF (steplSchrittketteOeffnen > STEP_0_E) THEN
    bpDone := FALSE;
    out_bOeffnen := FALSE;
    steplSchrittketteOeffnen := STEP_0_E;
  END_IF
END_IF
END_ACTION