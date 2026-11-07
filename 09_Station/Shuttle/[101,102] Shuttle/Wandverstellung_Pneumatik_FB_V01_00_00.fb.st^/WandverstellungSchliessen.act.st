(* METADATA
{
	"v3Meta": {
		"objectGuid": "455c6579-2815-4822-93f0-4ccae62364dc"
	}
}
*)
ACTION WandverstellungSchliessen
//-------------------------------------------------------------------------------------------------
// AKTION - WANDOEFFNUNG VERSTELLEN [Min- Max- Position]
//-------------------------------------------------------------------------------------------------
IF ( bpWandverstellungSchliessen ) THEN

  CASE steplWandverstellungSchliessen OF
    // Wandverstellung schließen =====================
    STEP_0_E:
      (* Anmerkung:
         - Timer zuruecksetzen
         - Pruefen der Pneumatik- Zylinderstellung (ohne Endlagensensor immer die volle Bewegungszeit abwarten)
      *)
      bpDone := FALSE;
      tonlAusgefahrenWandEinlaufseite( IN := FALSE );
      tonlAusgefahrenWandAuslaufseite( IN := FALSE );
      tonlBewegungszeitSchliessen( IN := FALSE );

      IF ( bpAbfrageGeschlossenVorhanden AND in_bWandEinlaufseiteGeschlossen AND in_bWandAuslaufseiteGeschlossen ) THEN
        steplWandverstellungSchliessen := STEP_1000_E;
      ELSE
        steplWandverstellungSchliessen := STEP_10_E;
      END_IF

    // Wandverstellung schließen =====================
    STEP_10_E:
      (* Hinweis:
         - Schliessen, Gegenausgang aus
         - Pruefen ob die Zylinder ihre Bewegung abgeschlossen haben
         - Ohne Endlagensensor nur die Bewegungszeit auswerten
      *)
      out_bWandverstellungSchliessen := TRUE;
      out_bWandverstellungOeffnen    := FALSE;

      tonlAusgefahrenWandEinlaufseite( IN := bpAbfrageGeschlossenVorhanden AND NOT in_bWandEinlaufseiteGeschlossen, PT := T#5s );
      tonlAusgefahrenWandAuslaufseite( IN := bpAbfrageGeschlossenVorhanden AND NOT in_bWandAuslaufseiteGeschlossen, PT := T#5s );
      tonlBewegungszeitSchliessen( IN := NOT bpAbfrageGeschlossenVorhanden, PT := tpBewegungszeit );

      IF (    ( bpAbfrageGeschlossenVorhanden AND in_bWandEinlaufseiteGeschlossen AND in_bWandAuslaufseiteGeschlossen )
           OR ( NOT bpAbfrageGeschlossenVorhanden AND tonlBewegungszeitSchliessen.Q ) )
      THEN
        out_bWandverstellungSchliessen := FALSE;
        steplWandverstellungSchliessen := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Zylinder Wand Einlauf- / Auslaufseite (nur mit Endlagensensor)
      *)
      IF ( tonlAusgefahrenWandEinlaufseite.Q OR tonlAusgefahrenWandAuslaufseite.Q ) THEN
        out_bWandverstellungSchliessen := FALSE;
        wpFehlerNr := cMELDUNG_ZYLINDER_WAND_NICHT_AUSGEFAHREN;
        steplWandverstellungSchliessen := STEP_900_E;
      END_IF

    // Wandverstellung schließen =====================
    STEP_900_E:
      out_bWandverstellungSchliessen := FALSE;
      bpFehler := TRUE;

    // Wandverstellung schließen =====================
    STEP_1000_E:
      bpDone := TRUE;

  END_CASE
ELSE

  IF ( steplWandverstellungSchliessen > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bWandverstellungSchliessen := FALSE;
    tonlAusgefahrenWandEinlaufseite( IN := FALSE );
    tonlAusgefahrenWandAuslaufseite( IN := FALSE );
    tonlBewegungszeitSchliessen( IN := FALSE );
    steplWandverstellungSchliessen := STEP_0_E;
  END_IF

END_IF
END_ACTION