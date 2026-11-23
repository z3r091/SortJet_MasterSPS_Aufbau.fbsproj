(* METADATA
{
	"v3Meta": {
		"objectGuid": "c3dbd95e-5dea-49b1-8dfe-8fb06aba27f0"
	}
}
*)
ACTION Grundstellung
//-------------------------------------------------------------------------------------------------
// AKTION: GRUNDSTELLUNGSFAHRT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Greiferachse in die Grundstellung der Greiferseite fahren und dabei den Greifer einfahren,
     sobald er rWegBisZumSicherenEinklappen hinter der Uebergabeposition steht
   - Ohne Automatik mit Handgeschwindigkeit
*)
IF (     bpStartGrundstellungsfahrt
     AND bpFreigabe )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
    steplGrundstellungsfahrt := STEP_900_E;
  END_IF

  IF ( GreiferHub.bpFehler ) THEN
    wpFehlerNr := GreiferHub.wpFehlerNr;
    steplGrundstellungsfahrt := STEP_900_E;
  END_IF

  (* Hinweis:
     - Zeitueberwachung der Wartestellen: Timer bei jedem Schrittwechsel neu starten
  *)
  IF ( steplGrundstellungsfahrt <> steplGrundstellungsfahrtMerker ) THEN
    tonlUeberwachungGrundstellung( IN := FALSE );
    steplGrundstellungsfahrtMerker := steplGrundstellungsfahrt;
  END_IF

  CASE steplGrundstellungsfahrt OF
    // GRUNDSTELLUNG ==============================
    STEP_0_E:
      bpGrundstellungsfahrtAbgeschlossen := FALSE;
      bpVorpositioniertEintransport      := FALSE;

      tonlUeberwachungGrundstellung( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( tonlAntriebFreigegeben.Q AND Antrieb.bpIstReferenziert ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplGrundstellungsfahrt := STEP_10_E;
      END_IF

      IF ( tonlUeberwachungGrundstellung.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ANTRIEB_NICHT_BEREIT;
        steplGrundstellungsfahrt := STEP_900_E;
      END_IF

    // GRUNDSTELLUNG ==============================
    STEP_10_E:
      (* Hinweis:
         - Greiferachse in die Grundstellung [Home-Position] fahren
      *)
      IF ( bpAutomatikAktiv ) THEN
        Antrieb.rpZielposition    := rlGrundstellungsPosition;
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := ABSOLUT;
      ELSE
        Antrieb.rpZielposition    := rlGrundstellungsPosition;
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := ABSOLUT;
      END_IF

      steplGrundstellungsfahrt := STEP_20_E;

    // GRUNDSTELLUNG ==============================
    STEP_20_E:
      (* Hinweis:
         - Position, ab der der Greifer eingefahren werden darf
      *)
      tonlUeberwachungGrundstellung( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF (    ( rlRichtung * ( Antrieb.rpIstPosition - rlUebergabePosition ) >= ppParameterGreifer.rWegBisZumSicherenEinklappen )
           OR ( Antrieb.bpDone AND ( ABS( Antrieb.rpZielposition - Antrieb.rpIstPosition ) <= cTOLERANZ_POSITION ) ) )
      THEN
        GreiferHub.bpStartAusfahren := FALSE;
        GreiferHub.bpStartEinfahren := TRUE;
        steplGrundstellungsfahrt := STEP_30_E;
      END_IF

      IF ( tonlUeberwachungGrundstellung.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplGrundstellungsfahrt := STEP_900_E;
      END_IF

    // GRUNDSTELLUNG ==============================
    STEP_30_E:
      (* Hinweis:
         - Greifer eingefahren
      *)
      tonlUeberwachungGrundstellung( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartEinfahren := FALSE;
        steplGrundstellungsfahrt := STEP_40_E;
      END_IF

      IF ( tonlUeberwachungGrundstellung.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_EINGEFAHREN;
        steplGrundstellungsfahrt := STEP_900_E;
      END_IF

    // GRUNDSTELLUNG ==============================
    STEP_40_E:
      (* Hinweis:
         - Grundstellung erreicht
      *)
      tonlUeberwachungGrundstellung( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF (     Antrieb.bpDone
          AND ( ABS( Antrieb.rpZielposition - Antrieb.rpIstPosition ) <= cTOLERANZ_POSITION ) ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplGrundstellungsfahrt := STEP_1000_E;
      END_IF

      IF ( tonlUeberwachungGrundstellung.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplGrundstellungsfahrt := STEP_900_E;
      END_IF

    // GRUNDSTELLUNG ==============================
    STEP_900_E:
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      GreiferHub.bpStartEinfahren := FALSE;
      bpFehler := TRUE;

    // GRUNDSTELLUNG ==============================
    STEP_1000_E:
      bpGrundstellungsfahrtAbgeschlossen := TRUE;

  // GRUNDSTELLUNG ==============================
  END_CASE

ELSE

  IF ( steplGrundstellungsfahrt > STEP_0_E ) THEN
    bpGrundstellungsfahrtAbgeschlossen := FALSE;
    Antrieb.wpBetriebsart       := KEINE_FUNKTION;
    GreiferHub.bpStartEinfahren := FALSE;
    tonlUeberwachungGrundstellung( IN := FALSE );
    steplGrundstellungsfahrt       := STEP_0_E;
    steplGrundstellungsfahrtMerker := STEP_0_E;
  END_IF

END_IF
END_ACTION