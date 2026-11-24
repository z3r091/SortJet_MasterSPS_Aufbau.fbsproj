(* METADATA
{
	"v3Meta": {
		"objectGuid": "9c49712f-5a95-4ffc-acc8-cb6e66235aae"
	}
}
*)
ACTION HochFahren
//_________________________________________________________________________
// ************************ Aktion Zylinder -Hoch ********************
//_________________________________________________________________________
IF (     bpStartHoch
     AND NOT tofRunter.Q
     AND bpFreigabe )
THEN
  CASE steplHoch OF
    // HOCH =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Ausgang zuruecknehmen (Federrueckstell- Ventil faehrt hoch)
           => ohne Endlagensensor immer die volle Bewegungszeit abwarten
      *)
      bpDone := FALSE;
      tonlOben( IN := FALSE );
      tonlBewegungszeitHoch( IN := FALSE );
      out_bRunter := FALSE;

      IF ( bpAbfrageObenVorhanden AND in_bOben ) THEN
        steplHoch := STEP_1000_E;
      ELSE
        wpStatus  := eTransportsperreUndefiniert;
        steplHoch := STEP_10_E;
      END_IF

    // HOCH =====================
    STEP_10_E:
      (* Hinweis:
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bRunter := FALSE;

      tonlOben( IN := bpAbfrageObenVorhanden AND NOT in_bOben,
                PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      tonlBewegungszeitHoch( IN := NOT bpAbfrageObenVorhanden,
                             PT := tpBewegungszeit );

      IF (    ( bpAbfrageObenVorhanden AND in_bOben )
           OR ( NOT bpAbfrageObenVorhanden AND tonlBewegungszeitHoch.Q ) )
      THEN
        steplHoch := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung (nur mit Endlagensensor)
      *)
      IF ( tonlOben.Q ) THEN
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_EINGEFAHREN;
        steplHoch := STEP_900_E;
      END_IF

    // HOCH =====================
    STEP_900_E:
      bpFehler := TRUE;

    // HOCH =====================
    STEP_1000_E:
      // Ohne Sensor ist die Stellung zeitlich angenommen, nicht gemessen
      wpStatus := eTransportsperreOben;
      bpDone := TRUE;

  // HOCH =====================
  END_CASE
ELSE

  IF ( steplHoch > STEP_0_E ) THEN
    bpDone := FALSE;
    tonlOben( IN := FALSE );
    tonlBewegungszeitHoch( IN := FALSE );
    steplHoch := STEP_0_E;
  END_IF

END_IF
END_ACTION