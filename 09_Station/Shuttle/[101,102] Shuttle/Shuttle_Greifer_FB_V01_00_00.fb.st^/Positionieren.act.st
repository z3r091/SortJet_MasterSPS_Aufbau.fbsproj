(* METADATA
{
	"v3Meta": {
		"objectGuid": "340d8f94-9a3d-444f-a344-cdb75928ee9e"
	}
}
*)
ACTION Positionieren
//-------------------------------------------------------------------------------------------------
// AKTION: POSITIONIEREN [GREIFER HINTER DIE GLASKANTE]
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Der eingefahrene Greifer wird um rOffsetPosition hinter die Glaskante gestellt, bereit fuer den Austransport
   - Glaskante = Weg bis zum Sensor der Greiferseite + ( Scheibenlaenge - Weg der Scheibe ueber den Sensor )
   - Auch als Vorabpositionierung waehrend der Querfahrt (Laenge aus den Vorab-Auftragsdaten)
*)
IF (     bpPositionieren
     AND bpFreigabe
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
    steplPositionieren := STEP_900_E;
  END_IF

  IF ( GreiferHub.bpFehler ) THEN
    wpFehlerNr := GreiferHub.wpFehlerNr;
    steplPositionieren := STEP_900_E;
  END_IF

  // Ausnahmesituation: keine Greiferzange auf der aktiven Greiferseite
  IF ( NOT blZangeSeiteVorhanden ) THEN
    wpFehlerNr := cMELDUNG_AUFTRAGSDATEN_SHUTTLE_GREIFER_AUFTRAGSTYP_UNGUELTIG;
    steplPositionieren := STEP_900_E;
  END_IF

  (* Hinweis:
     - Zeitueberwachung der Wartestellen: Timer bei jedem Schrittwechsel neu starten
  *)
  IF ( steplPositionieren <> steplPositionierenMerker ) THEN
    tonlUeberwachungPositionieren( IN := FALSE );
    steplPositionierenMerker := steplPositionieren;
  END_IF

  CASE steplPositionieren OF
    // POSITIONIEREN ==============================
    STEP_0_E:
      (* Hinweis:
         - Warten bis die Greiferachse bereit und referenziert ist
         - Greifer einfahren
      *)
      bpPositionierungAbgeschlossen := FALSE;
      bpVorpositioniertEintransport := FALSE;

      tonlUeberwachungPositionieren( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( tonlAntriebFreigegeben.Q AND Antrieb.bpIstReferenziert ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        GreiferHub.bpStartAusfahren := FALSE;
        GreiferHub.bpStartEinfahren := TRUE;

        steplPositionieren := STEP_10_E;
      END_IF

      IF ( tonlUeberwachungPositionieren.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ANTRIEB_NICHT_BEREIT;
        steplPositionieren := STEP_900_E;
      END_IF

    // POSITIONIEREN ==============================
    STEP_10_E:
      (* Hinweis:
         - Greifer eingefahren, Zielposition berechnen und pruefen
      *)
      tonlUeberwachungPositionieren( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartEinfahren := FALSE;

        // Weg der Scheibe ueber den Sensor nach der Laenge der zu positionierenden Scheibe
        IF (     ( ppParameterGreifer.rLaengeUebergroesseScheibe > 0.0 )
             AND ( rpGlaslaenge >= ppParameterGreifer.rLaengeUebergroesseScheibe ) )
        THEN
          rlZielPosition := ppParameterGreifer.rWegGlasUebergabepositionLang;
        ELSE
          rlZielPosition := ppParameterGreifer.rWegGlasUebergabeposition;
        END_IF

        rlZielPosition := rlWegBisZumSensor
                          + rlRichtung * ( rpGlaslaenge - rlZielPosition )
                          + rlRichtung * ppParameterGreifer.rOffsetPosition;

        IF (     ( rlZielPosition < ppParameterGreifer.rMaximalPosition )
             AND ( rlZielPosition > ppParameterGreifer.rMinimalPosition ) )
        THEN
          M_Fahren( epBetriebsart     := ABSOLUT,
                    rpZielPosition    := rlZielPosition,
                    rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit );
          steplPositionieren := STEP_20_E;
        ELSE
          awpFehlerInformationen[0] := stStationsNummern.NummerExtern;
          awpFehlerInformationen[1] := REAL_TO_WORD( rlZielPosition );
          awpFehlerInformationen[2] := REAL_TO_WORD( ppParameterGreifer.rMinimalPosition );
          awpFehlerInformationen[3] := REAL_TO_WORD( ppParameterGreifer.rMaximalPosition );
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_VERFAHRBEREICH;
          steplPositionieren := STEP_900_E;
        END_IF
      END_IF

      IF ( tonlUeberwachungPositionieren.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_EINGEFAHREN;
        steplPositionieren := STEP_900_E;
      END_IF

    // POSITIONIEREN ==============================
    STEP_20_E:
      tonlUeberwachungPositionieren( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplPositionieren := STEP_1000_E;
      END_IF

      IF ( tonlUeberwachungPositionieren.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplPositionieren := STEP_900_E;
      END_IF

    // POSITIONIEREN ==============================
    STEP_900_E:
      Antrieb.wpBetriebsart       := KEINE_FUNKTION;
      GreiferHub.bpStartEinfahren := FALSE;
      bpFehler := TRUE;

    // POSITIONIEREN ==============================
    STEP_1000_E:
      bpPositionierungAbgeschlossen := TRUE;

  // POSITIONIEREN ==============================
  END_CASE

ELSE

  IF ( steplPositionieren > STEP_0_E ) THEN
    bpPositionierungAbgeschlossen := FALSE;
    Antrieb.wpBetriebsart         := KEINE_FUNKTION;
    GreiferHub.bpStartEinfahren   := FALSE;
    tonlUeberwachungPositionieren( IN := FALSE );
    steplPositionieren       := STEP_0_E;
    steplPositionierenMerker := STEP_0_E;
  END_IF

END_IF
END_ACTION