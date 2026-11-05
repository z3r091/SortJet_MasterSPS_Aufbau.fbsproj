(* METADATA
{
  "v3Meta": {
    "objectGuid": "f0bc2723-b4fe-47ac-9eaf-c9d7cf8ddb9e"
  }
}
*)
ACTION VorabPositionierungEintransport
//-------------------------------------------------------------------------------------------------
// AKTION: VORABPOSITIONIERUNG EINTRANSPORT
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Waehrend der Querfahrt den Greifer nah an die Wandseite stellen und ausfahren (Taktzeit)
*)
IF (     bpStarteVorabPositionierungEintransport
     AND bpFreigabe
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
    steplVorabPositionierungEintransport := STEP_900_E;
  END_IF

  IF ( GreiferHub.bpFehler ) THEN
    wpFehlerNr := GreiferHub.wpFehlerNr;
    steplVorabPositionierungEintransport := STEP_900_E;
  END_IF

  // Ausnahmesituation: keine Greiferzange auf der aktiven Greiferseite
  IF ( NOT blZangeSeiteVorhanden ) THEN
    wpFehlerNr := cMELDUNG_AUFTRAGSDATEN_SHUTTLE_GREIFER_AUFTRAGSTYP_UNGUELTIG;
    steplVorabPositionierungEintransport := STEP_900_E;
  END_IF

  (* Hinweis:
     - Zeitueberwachung der Wartestellen: Timer bei jedem Schrittwechsel neu starten
  *)
  IF ( steplVorabPositionierungEintransport <> steplVorabPositionierungMerker ) THEN
    tonlUeberwachungVorab( IN := FALSE );
    steplVorabPositionierungMerker := steplVorabPositionierungEintransport;
  END_IF

  CASE steplVorabPositionierungEintransport OF
    // VORABPOSITIONIERUNG EINTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - Kein anderer Ablauf des Greifers aktiv, Greiferachse bereit und referenziert
         - Greifer einfahren
      *)
      bpVorabPositionierungEintransportAbgeschlossen := FALSE;
      bpVorpositioniertEintransport                  := FALSE;

      tonlUeberwachungVorab( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF (     tonlAntriebFreigegeben.Q
           AND Antrieb.bpIstReferenziert
           AND NOT bpStarteEintransport
           AND NOT bpStarteAustransport
           AND NOT bpStartGrundstellungsfahrt
           AND NOT bpPositionieren )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        GreiferHub.bpStartAusfahren := FALSE;
        GreiferHub.bpStartEinfahren := TRUE;

        steplVorabPositionierungEintransport := STEP_10_E;
      END_IF

      IF ( tonlUeberwachungVorab.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ANTRIEB_NICHT_BEREIT;
        steplVorabPositionierungEintransport := STEP_900_E;
      END_IF

    // VORABPOSITIONIERUNG EINTRANSPORT ==============================
    STEP_10_E:
      (* Hinweis:
         - Greifer eingefahren, Vorabposition der Greiferseite anfahren
      *)
      tonlUeberwachungVorab( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartEinfahren := FALSE;

        M_Fahren( epBetriebsart     := ABSOLUT,
                  rpZielPosition    := rlGrundstellungEintransport,
                  rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit );

        steplVorabPositionierungEintransport := STEP_20_E;
      END_IF

      IF ( tonlUeberwachungVorab.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_EINGEFAHREN;
        steplVorabPositionierungEintransport := STEP_900_E;
      END_IF

    // VORABPOSITIONIERUNG EINTRANSPORT ==============================
    STEP_20_E:
      tonlUeberwachungVorab( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        GreiferHub.bpStartEinfahren := FALSE;
        GreiferHub.bpStartAusfahren := TRUE;

        steplVorabPositionierungEintransport := STEP_30_E;
      END_IF

      IF ( tonlUeberwachungVorab.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplVorabPositionierungEintransport := STEP_900_E;
      END_IF

    // VORABPOSITIONIERUNG EINTRANSPORT ==============================
    STEP_30_E:
      (* Hinweis:
         - Greifer ausgefahren
      *)
      tonlUeberwachungVorab( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartAusfahren := FALSE;
        steplVorabPositionierungEintransport := STEP_1000_E;
      END_IF

      IF ( tonlUeberwachungVorab.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_AUSGEFAHREN;
        steplVorabPositionierungEintransport := STEP_900_E;
      END_IF

    // VORABPOSITIONIERUNG EINTRANSPORT ==============================
    STEP_900_E:
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      GreiferHub.bpStartAusfahren := FALSE;
      GreiferHub.bpStartEinfahren := FALSE;
      bpFehler := TRUE;

    // VORABPOSITIONIERUNG EINTRANSPORT ==============================
    STEP_1000_E:
      bpVorabPositionierungEintransportAbgeschlossen := TRUE;
      bpVorpositioniertEintransport                  := TRUE;

  // VORABPOSITIONIERUNG EINTRANSPORT ==============================
  END_CASE

ELSE

  IF ( steplVorabPositionierungEintransport > STEP_0_E ) THEN
    bpVorabPositionierungEintransportAbgeschlossen := FALSE;
    Antrieb.wpBetriebsart       := KEINE_FUNKTION;
    GreiferHub.bpStartAusfahren := FALSE;
    GreiferHub.bpStartEinfahren := FALSE;
    tonlUeberwachungVorab( IN := FALSE );
    steplVorabPositionierungEintransport := STEP_0_E;
    steplVorabPositionierungMerker       := STEP_0_E;
  END_IF

END_IF
END_ACTION