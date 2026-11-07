(* METADATA
{
	"v3Meta": {
		"objectGuid": "06029a88-39ad-4ab5-99dd-8f7b148e55a4"
	}
}
*)
ACTION Ausfahren
//_________________________________________________________________________
// ************************ Aktion Zylinder -Ausfahren ********************
//_________________________________________________________________________
IF (     bpStartAusfahren
     AND NOT tofEinfahren.Q
     AND bpFreigabe )
THEN
  CASE steplAusfahren OF
    // AUSFAHREN =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Zylinder ausfahren starten (ohne Endlagensensor immer die volle Bewegungszeit abwarten)
      *)
      bpDone := FALSE;
      tonlZylinderAusgefahren( IN := FALSE );
      tonlBewegungszeitAusfahren( IN := FALSE );

      IF ( bpAbfrageAusgefahrenVorhanden AND in_StatusZylinderAusgefahren ) THEN
        steplAusfahren := STEP_1000_E;
      ELSE
        wpStatusZylinder := eZylinderUndefiniert;
        steplAusfahren   := STEP_10_E;
      END_IF

    // AUSFAHREN =====================
    STEP_10_E:
      (* Hinweis:
         - Zylinder ausfahren, Gegenausgang aus
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_ZylinderAusfahren := TRUE;
      out_ZylinderEinfahren := FALSE;

      tonlZylinderAusgefahren( IN := bpAbfrageAusgefahrenVorhanden AND NOT in_StatusZylinderAusgefahren,
                               PT := cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER );
      tonlBewegungszeitAusfahren( IN := NOT bpAbfrageAusgefahrenVorhanden,
                                  PT := tpBewegungszeit );

      IF (    ( bpAbfrageAusgefahrenVorhanden AND in_StatusZylinderAusgefahren )
           OR ( NOT bpAbfrageAusgefahrenVorhanden AND tonlBewegungszeitAusfahren.Q ) )
      THEN
        out_ZylinderAusfahren := FALSE;
        steplAusfahren := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zeitliche- Ueberwachung (nur mit Endlagensensor)
      *)
      IF ( tonlZylinderAusgefahren.Q ) THEN
        out_ZylinderAusfahren := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_NICHT_AUSGEFAHREN;
        steplAusfahren := STEP_900_E;
      END_IF

    // AUSFAHREN =====================
    STEP_900_E:
      out_ZylinderAusfahren := FALSE;
      bpFehler := TRUE;

    // AUSFAHREN =====================
    STEP_1000_E:
      // Ohne Sensor ist die Stellung zeitlich angenommen, nicht gemessen
      wpStatusZylinder := eZylinder1Ausgefahren;
      bpDone := TRUE;

  // AUSFAHREN =====================
  END_CASE
ELSE

  IF ( steplAusfahren > STEP_0_E ) THEN
    bpDone := FALSE;
    out_ZylinderAusfahren := FALSE;
    tonlZylinderAusgefahren( IN := FALSE );
    tonlBewegungszeitAusfahren( IN := FALSE );
    steplAusfahren := STEP_0_E;
  END_IF

END_IF
END_ACTION