(* METADATA
{
	"v3Meta": {
		"objectGuid": "6ca1307e-4395-4b56-b705-4e98a3d86f83"
	}
}
*)
ACTION Austransport
//-------------------------------------------------------------------------------------------------
// AKTION: AUSTRANSPORT [SCHEIBE VOM SHUTTLE IN DEN FAECHERWAGEN SCHIEBEN]
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Voraussetzung: Scheibe steht um rpWegGlasUebergabeposition ueber dem Sensor der Greiferseite und
     der Greifer steht eingefahren hinter der Glaskante (Aktion Positionieren)
   - Der Glastransport ist waehrend des Schiebens auf die Greiferachse gekoppelt
*)
IF (     bpStarteAustransport
     AND bpFreigabe
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
    steplAustransport := STEP_900_E;
  END_IF

  IF ( GreiferHub.bpFehler ) THEN
    wpFehlerNr := GreiferHub.wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF

  // Ausnahmesituation: keine Greiferzange auf der aktiven Greiferseite
  IF ( NOT blZangeSeiteVorhanden ) THEN
    wpFehlerNr := cMELDUNG_AUFTRAGSDATEN_SHUTTLE_GREIFER_AUFTRAGSTYP_UNGUELTIG;
    steplAustransport := STEP_900_E;
  END_IF

  IF ( Zange[ilZange].bpFehler ) THEN
    wpFehlerNr := Zange[ilZange].wpFehlerNr;
    steplAustransport := STEP_900_E;
  END_IF

  (* Hinweis:
     - Zeitueberwachung der Wartestellen: Timer bei jedem Schrittwechsel neu starten
  *)
  IF ( steplAustransport <> steplAustransportMerker ) THEN
    tonlUeberwachungAustransport( IN := FALSE );
    steplAustransportMerker := steplAustransport;
  END_IF

  CASE steplAustransport OF
    // AUSTRANSPORT ==============================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
         - Warten bis die Greiferachse bereit und referenziert ist
      *)
      bprtScheibe                   := FALSE;
      bpAustransportAbgeschlossen   := FALSE;
      bpAnforderungSlaveKopplung    := FALSE;
      bpVorpositioniertEintransport := FALSE;

      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( tonlAntriebFreigegeben.Q AND Antrieb.bpIstReferenziert ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransport := STEP_10_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ANTRIEB_NICHT_BEREIT;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_10_E:
      (* Hinweis:
         - Greifer auf Glashoehe ausfahren
         - Greiferzange auf die Auftragsoeffnung stellen
      *)
      GreiferHub.bpStartEinfahren := FALSE;
      GreiferHub.bpStartAusfahren := TRUE;

      Zange[ilZange].epSollZylinderStellung  := elZangeOeffnung;
      Zange[ilZange].bpStartZylinderBewegung := TRUE;

      steplAustransport := STEP_100_E;

    // AUSTRANSPORT ==============================
    STEP_100_E:
      (* Hinweis:
         - Greifer ausgefahren und Zange offen
           => Greiferzange in das Glas fahren (Glaskante + Korrekturweg)
      *)
      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone AND Zange[ilZange].bpDone ) THEN
        GreiferHub.bpStartAusfahren            := FALSE;
        Zange[ilZange].bpStartZylinderBewegung := FALSE;

        M_Fahren( epBetriebsart     := ABSOLUT,
                  rpZielPosition    := rlWegBisZumSensor
                                       + rlRichtung * ( pAuftrag.rAuftragsLaenge - rpWegGlasUebergabeposition )
                                       - rlRichtung * rlKorrekturOffset,
                  rpGeschwindigkeit := rgGeschwindigkeitVorpositionieren );

        steplAustransport := STEP_110_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        IF ( NOT GreiferHub.bpDone ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_AUSGEFAHREN;
        ELSE
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GEOEFFNET;
        END_IF
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_110_E:
      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransport := STEP_120_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_120_E:
      (* Hinweis:
         - Greiferzange schliessen (Scheibe greifen)
      *)
      Zange[ilZange].epSollZylinderStellung  := eZylinderGeschlossen;
      Zange[ilZange].bpStartZylinderBewegung := TRUE;

      steplAustransport := STEP_125_E;

    // AUSTRANSPORT ==============================
    STEP_125_E:
      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( Zange[ilZange].bpDone ) THEN
        Zange[ilZange].bpStartZylinderBewegung := FALSE;
        bpAnforderungSlaveKopplung := TRUE;
        steplAustransport := STEP_130_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GESCHLOSSEN;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_130_E:
      (* Hinweis:
         - Warten bis der Glastransport auf die Greiferachse gekoppelt ist
         - Scheibe in den Faecherwagen schieben (Uebergabeposition)
      *)
      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungKopplung );

      IF ( bpSlaveKopplungAktiv ) THEN
        rlPositionAntriebBeiStart := Antrieb.rpIstPosition;

        M_Fahren( epBetriebsart     := ABSOLUT,
                  rpZielPosition    := rlUebergabePosition,
                  rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit );

        steplAustransport := STEP_140_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SLAVEANTRIEB_NICHT_BEREIT;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_140_E:
      (* Hinweis:
         - Die erste Strecke bzw. lange Scheiben komplett mit reduzierter Geschwindigkeit,
           damit die Vorderkante sicher hinter die erste Strebe im Faecherwagen faehrt
      *)
      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF (    ( pAuftrag.rAuftragsLaenge >= ppParameterGreifer.rLaengeReduzierteGeschwindigkeit )
           OR ( ABS( Antrieb.rpIstPosition - rlPositionAntriebBeiStart ) < ppParameterGreifer.rLaengeReduzierteGeschwindigkeitAustransport ) )
      THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
      ELSE
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      END_IF

      IF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        bprtScheibe := TRUE;
        steplAustransport := STEP_150_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_150_E:
      (* Hinweis:
         - Scheibe quittiert, Greiferzange oeffnen
      *)
      bprtScheibe := FALSE;

      Zange[ilZange].epSollZylinderStellung  := elZangeOeffnung;
      Zange[ilZange].bpStartZylinderBewegung := TRUE;

      steplAustransport := STEP_160_E;

    // AUSTRANSPORT ==============================
    STEP_160_E:
      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( Zange[ilZange].bpDone ) THEN
        Zange[ilZange].bpStartZylinderBewegung := FALSE;
        steplAustransport := STEP_170_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_GREIFERZANGE_NICHT_GEOEFFNET;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_170_E:
      (* Hinweis:
         - Greiferachse in die Grundstellung fahren (Kopplung bleibt bestehen)
      *)
      M_Fahren( epBetriebsart     := ABSOLUT,
                rpZielPosition    := rlGrundstellungsPosition,
                rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit );

      steplAustransport := STEP_180_E;

    // AUSTRANSPORT ==============================
    STEP_180_E:
      (* Hinweis:
         - Ab rWegBisZumSicherenEinklappen hinter der Uebergabeposition und freiem Sensor der
           Greiferseite den Greifer einfahren
      *)
      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF (     ( rlRichtung * ( Antrieb.rpIstPosition - rlUebergabePosition ) >= ppParameterGreifer.rWegBisZumSicherenEinklappen )
           AND NOT blSensorSeite )
      THEN
        GreiferHub.bpStartAusfahren := FALSE;
        GreiferHub.bpStartEinfahren := TRUE;
        steplAustransport := STEP_190_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        IF ( blSensorSeite ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_SENSOR_WIRD_NICHT_FREI;
        ELSE
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        END_IF
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_190_E:
      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartEinfahren := FALSE;
        steplAustransport := STEP_195_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_EINGEFAHREN;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_195_E:
      (* Hinweis:
         - Grundstellung erreicht
      *)
      tonlUeberwachungAustransport( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( M_PositionErreicht() ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplAustransport := STEP_1000_E;
      END_IF

      IF ( tonlUeberwachungAustransport.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplAustransport := STEP_900_E;
      END_IF

    // AUSTRANSPORT ==============================
    STEP_900_E:
      (* Fehlerbehandlung:
         - Fahrbefehle und Pneumatik-Starts beenden
      *)
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      GreiferHub.bpStartAusfahren            := FALSE;
      GreiferHub.bpStartEinfahren            := FALSE;
      Zange[ilZange].bpStartZylinderBewegung := FALSE;

      bprtScheibe                := FALSE;
      bpAnforderungSlaveKopplung := FALSE;
      bpFehler                   := TRUE;

    // AUSTRANSPORT ==============================
    STEP_1000_E:
      bpAnforderungSlaveKopplung  := FALSE;
      bpAustransportAbgeschlossen := TRUE;

  // AUSTRANSPORT ==============================
  END_CASE

ELSE

  IF ( steplAustransport > STEP_0_E ) THEN

    bprtScheibe                 := FALSE;
    bpAustransportAbgeschlossen := FALSE;
    bpAnforderungSlaveKopplung  := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    GreiferHub.bpStartAusfahren                   := FALSE;
    GreiferHub.bpStartEinfahren                   := FALSE;
    Zange[cZANGE_EINLAUF].bpStartZylinderBewegung := FALSE;
    Zange[cZANGE_AUSLAUF].bpStartZylinderBewegung := FALSE;

    tonlUeberwachungAustransport( IN := FALSE );

    steplAustransport       := STEP_0_E;
    steplAustransportMerker := STEP_0_E;

  END_IF

END_IF
END_ACTION