(* METADATA
{
  "v3Meta": {
    "objectGuid": "b5642c63-d99d-4628-98fa-0597a9011803"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* BAUSTEIN: AUSNAHMESITUATION *)
(***************************************************************************************************)
IF (bpStartHubAb OR bpStartHubAuf) THEN

  IF ( bpSensorEinlauf ) THEN
    wpFehlerNr := cMELDUNG_HUB_SENSOR_EINLAUF_BELEGT;
    bpFehler      := TRUE;
    bpStartHubAuf := FALSE;
    bpStartHubAb  := FALSE;
    steplHubAb := STEP_900_E;
  END_IF
  
  IF ( bpSensorAuslauf ) THEN
    wpFehlerNr := cMELDUNG_HUB_SENSOR_AUSLAUF_BELEGT;
    bpFehler      := TRUE;
    bpStartHubAuf := FALSE;
    bpStartHubAb  := FALSE;
    steplHubAb := STEP_900_E;
  END_IF

  IF ( bpSensorAuslaufVorgaenger ) THEN
    wpFehlerNr := cMELDUNG_HUB_SENSOR_AUSLAUF_VORGAENGER_BELEGT;
    bpFehler      := TRUE;
    bpStartHubAuf := FALSE;
    bpStartHubAb  := FALSE;
  END_IF

  IF ( bpSensorEinlaufNachfolger ) THEN
    wpFehlerNr := cMELDUNG_HUB_SENSOR_EINLAUF_NACHFOLGER_BELEGT;
    bpFehler      := TRUE;
    bpStartHubAuf := FALSE;
    bpStartHubAb  := FALSE;
  END_IF

END_IF

(* Ausnahmesituation:
   - Beide Sensoren belegt
*)
IF ( NOT in_bSensorNichtoben AND NOT in_bSensorNichtUnten ) THEN
  bpFehler := TRUE;
  wpFehlerNr := cMELDUNG_HUB_BEIDE_HUBSENSOREN_BELEGT;

  (* Hinweis:
     - Variablen zuruecksetzen
  *)
  bpStartHubAuf  := FALSE;
  bpStartHubAb   := FALSE;
  out_bHubAbSetzen  := FALSE;
  out_bHubAufSetzen := FALSE;

END_IF

(* Hinweis:
   - Auswertung erfolgt erst nach 4 Sekunden nach dem Starten
*)


IF ( tonlFehlermeldungUnterdrueckenAntriebOK.Q ) THEN

  IF ( NOT in_bMotorstarter_OK ) THEN
    bpFehler := TRUE;
    wpFehlerNr := cMELDUNG_HUB_SICHERUNG_NICHT_OK;

    (* Hinweis:
       - Variablen zuruecksetzen
    *)
    bpStartHubAuf     := FALSE;
    bpStartHubAb      := FALSE;
    out_bHubAbSetzen  := FALSE;
    out_bHubAufSetzen := FALSE;

  END_IF

END_IF

IF ( NOT in_bLSBremse_OK ) THEN
  bpFehler := TRUE;
  wpFehlerNr := cMELDUNG_HUB_BREMSE_NICHT_OK;

  (* Hinweis:
    - Variablen zuruecksetzen
  *)
  bpStartHubAuf     := FALSE;
  bpStartHubAb      := FALSE;
  out_bHubAbSetzen  := FALSE;
  out_bHubAufSetzen := FALSE;
END_IF

IF ( NOT in_bMotorstarter_OK ) THEN
  bpFehler := TRUE;
  wpFehlerNr := cMELDUNG_HUB_SICHERUNG_NICHT_OK;

  (* Hinweis:
    - Variablen zuruecksetzen
  *)
  bpStartHubAuf     := FALSE;
  bpStartHubAb      := FALSE;
  out_bHubAbSetzen  := FALSE;
  out_bHubAufSetzen := FALSE;

END_IF
END_ACTION