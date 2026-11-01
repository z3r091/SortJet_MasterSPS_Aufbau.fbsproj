(* METADATA
{
  "v3Meta": {
    "objectGuid": "24f6bf01-bc74-4925-b8ee-76f0bb76d8b3"
  }
}
*)
ACTION Meldungen
// Ausnahmesituation:
//   - Beide Sensoren belegt
IF ( NOT in_bVerstellungGeoeffnet AND NOT in_bVerstellungGeschlossen ) THEN
  bpFehler := TRUE;
  wpFehlerNr := cMELDUNG_HUB_BEIDE_HUBSENSOREN_BELEGT;

  (* Hinweis:
     - Variablen zuruecksetzen
  *)
  bpVerstellungOeffnen       := FALSE;
  bpVerstellungSchliessen    := FALSE;
  out_bVerstellungSchliessen := FALSE;
  out_bVerstellungOeffnen    := FALSE;

END_IF

(* Hinweis:
   - Auswertung erfolgt erst nach 4 Sekunden nach dem Starten
*)
IF ( tonlFehlermeldungUnterdrueckenAntriebOK.Q ) THEN

  IF ( NOT in_bMotorstarter_OK OR NOT in_bSicherungMotorOK ) THEN
    bpFehler := TRUE;
    wpFehlerNr := cMELDUNG_HUB_SICHERUNG_NICHT_OK;

    (* Hinweis:
       - Variablen zuruecksetzen
    *)
    bpVerstellungOeffnen       := FALSE;
    bpVerstellungSchliessen    := FALSE;
    out_bVerstellungSchliessen := FALSE;
    out_bVerstellungOeffnen    := FALSE;

  END_IF

END_IF

IF ( NOT in_bBremseOK ) THEN
  bpFehler := TRUE;
  wpFehlerNr := cMELDUNG_HUB_BREMSE_NICHT_OK;

  (* Hinweis:
     - Variablen zuruecksetzen
  *)
  bpVerstellungOeffnen       := FALSE;
  bpVerstellungSchliessen    := FALSE;
  out_bVerstellungSchliessen := FALSE;
  out_bVerstellungOeffnen    := FALSE;

END_IF

IF ( NOT in_bMotorstarter_OK OR NOT in_bSicherungMotorOK ) THEN
  bpFehler := TRUE;
  wpFehlerNr := cMELDUNG_HUB_SICHERUNG_NICHT_OK;

  (* Hinweis:
     - Variablen zuruecksetzen
  *)
  bpVerstellungOeffnen       := FALSE;
  bpVerstellungSchliessen    := FALSE;
  out_bVerstellungSchliessen := FALSE;
  out_bVerstellungOeffnen    := FALSE;

END_IF
END_ACTION