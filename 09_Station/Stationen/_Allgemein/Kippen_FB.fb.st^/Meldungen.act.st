(* METADATA
{
  "v3Meta": {
    "objectGuid": "1683cb70-0556-4fca-9870-2bd9f9631bb2"
  }
}
*)
ACTION Meldungen
(***************************************************************************************************)
(* BAUSTEIN: AUSNAHMESITUATION *)
(***************************************************************************************************)
IF ( bpPositionieren ) THEN

  IF ( bpSensorAuslaufVorgaenger ) THEN
    wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_VORGAENGER;
    bpFehler := TRUE;
    bpPositionieren := FALSE;
  END_IF

  IF ( bpSensorEinlaufNachfolger ) THEN
    wpFehlerNr := cMELDUNG_KIPPEN_EINLAUFSENSOR_NACHFOLGER;
    bpFehler := TRUE;
    bpPositionieren := FALSE;
  END_IF

END_IF

(* Ausnahmesituation:
   - Beide Sensoren belegt
*)
IF ( NOT bpSensorNicht84Grad AND NOT bpSensorNicht90Grad ) AND ppParameterBaustein.bKippenMitSchuetz THEN
  bpFehler := TRUE;
  wpFehlerNr := cMELDUNG_KIPPEN_BEIDE_KIPPSENSOREN_BELEGT;

  (* Hinweis:
     - Variablen zuruecksetzen
  *)
  bpPositionieren   := FALSE;
  out_bKippen84Grad := FALSE;
  out_bKippen90Grad := FALSE;

END_IF

(* Hinweis:
   - Auswertung erfolgt erst nach 4 Sekunden nach dem Starten
*)


IF ( tonlFehlermeldungUnterdrueckenAntriebOK.Q ) THEN

  IF ( NOT in_bMotorstarter_OK ) AND bpTeilnehmerErreichbar THEN
    bpFehler := TRUE;
    wpFehlerNr := cMELDUNG_KIPPEN_SICHERUNG_NICHT_OK;

    (* Hinweis:
       - Variablen zuruecksetzen
    *)  
    bpPositionieren   := FALSE;
    out_bKippen84Grad := FALSE;
    out_bKippen90Grad := FALSE;

  END_IF

END_IF
END_ACTION