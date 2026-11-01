(* METADATA
{
  "v3Meta": {
    "objectGuid": "cbd86a1a-2b1b-4bb8-8376-0ac7e57824ec"
  }
}
*)
ACTION Verfahren
//-------------------------------------------------------------------------------------------------
// VERFAHREN
//-------------------------------------------------------------------------------------------------

IF ( bpVerfahreShuttle 
     OR bgVisuVerfahreShuttle[stStationsNummern.NummerSPS] ) 
THEN

  (* Fehlerbehandlung:
     - Querfahrt
  *)
  IF ( Antrieb.bpFehler ) THEN
    wpFehlerNr := cMELDUNG_ANTRIEB_QUERFAHRT;
    Antrieb.wpBetriebsart  := KEINE_FUNKTION;
    STEP_Mov_Shuttle_W := STEP_900_E;
  END_IF

  CASE STEP_Mov_Shuttle_W OF
    // VERFAHREN =================================
    STEP_0_E:
      bpDone := FALSE;
      wSps2ShuttleStopped[stStationsNummern.NummerSPS] := 0;

      (* Hinweis:
      *)
      IF ( ABS(rpDestinationPosition - rpAktPosition) > 0.5) THEN

        IF (  Antrieb.bpIstReferenziert
             AND bpFreigabe ) 
        THEN

          blFreigabeGesetzt := TRUE;
          Antrieb.bpFreigabe := TRUE;

          IF Antrieb.bpReglerBereit THEN

            (* Hinweis:
               - Verfahrfreigabe überprüfen
                 => Fehlt: Abbruch des Verfahr-Auftrags
            *)
            IF ( bpVerfahrfreigabe ) THEN
              STEP_Mov_Shuttle_W := STEP_10_E;
            ELSE
              STEP_Mov_Shuttle_W := STEP_140_E;
            END_IF

          ELSE

            tonlAntriebNichtBetriebsbereit( IN := NOT Antrieb.bpReglerBereit , PT := T#10S);

            IF tonlAntriebNichtBetriebsbereit.Q THEN
              Antrieb.wpBetriebsart := KEINE_FUNKTION;
              wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
              STEP_Mov_Shuttle_W := STEP_900_E;
            END_IF

          END_IF

        ELSE
          (* Hinweis:
             - Keine Freigabe: dann prüfen ob überhaupt verfahren werden muss
          *)
          IF ( ABS( rpDestinationPosition - rpAktPosition ) < 0.5 ) THEN
            STEP_Mov_Shuttle_W := STEP_1000_E;
          END_IF

        END_IF

      ELSE
        //  zu kleine PositionsÃ¤nderung, KEIN Verfahren nÃ¶tig !
        //  Hinweis: gilt nur fÃ¼r die Shuttleantriebe einer Sortierung !
        STEP_Mov_Shuttle_W := STEP_1000_E;
      END_IF

    // VERFAHREN =================================
    STEP_5_E:
      tonlWarteAufReset(IN:=FALSE);
      Antrieb.wpBetriebsart :=  AntriebsBetriebsart_EN.RESET;
      STEP_Mov_Shuttle_W := STEP_8_E;

    // VERFAHREN =================================
    STEP_8_E:
      (* Hinweis:
         - Antrieb Fehler zurücksetzen
      *)
      tonlWarteAufReset(IN := NOT Antrieb.bpDone, PT := T#5S);

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        STEP_Mov_Shuttle_W := STEP_0_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( tonlWarteAufReset.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_ZURUECKGESETZT;
        STEP_Mov_Shuttle_W := STEP_900_E;
      END_IF

    // VERFAHREN =================================
    STEP_10_E:
      IF ( NOT Antrieb.bpMaxSchalterBelegt
           AND NOT Antrieb.bpMinSchalterBelegt )
      THEN
        STEP_Mov_Shuttle_W := STEP_50_E;
      ELSE
        STEP_Mov_Shuttle_W := STEP_20_E;
      END_IF

    // VERFAHREN =================================
    STEP_20_E:
      // MAXIMUM Endschalter belegt:
      //   per HANDMINUS/PLUS versuchen frei zu fahren
      tonlEndschalterFreifahren(IN := TRUE, PT:= T#10s);
      toflHardwareEndschalterFrei( IN := (  Antrieb.bpMaxSchalterBelegt
                                           OR Antrieb.bpMinSchalterBelegt),
                                   PT := t#1s);

      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpHandGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;

      IF ( Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart := HANDMINUS;
      END_IF

      IF ( Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart := HANDPLUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        STEP_Mov_Shuttle_W := STEP_30_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND ( Antrieb.bpMaxSchalterBelegt
                 OR Antrieb.bpMinSchalterBelegt ))
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_QUERFAHRT_ENDSCHALTER_NICHT_FREI;
        STEP_Mov_Shuttle_W := STEP_900_E;
      END_IF

    // VERFAHREN =================================
    STEP_30_E:
      (* Hinweis:
         - Antrieb steht
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        STEP_Mov_Shuttle_W := STEP_50_E;
      END_IF

    // VERFAHREN =================================
    STEP_50_E:
      (* Hinweis:
         - Geschwindigkeit / Beschleunigung / Verzoegerung uebergeben
      *)
      IF NOT bpShuttleFaecherwagenSuche AND NOT wpAuftragsTyp.1 THEN // wpAuftragsTyp.1 = RackSuche aktiv

        IF ( bpAutomatikAktiv ) THEN

          Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpMaxGeschwindigkeit;
          Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
          Antrieb.rpRuckzeit         := ppAntriebsInformationen.rpMaxRuckzeit;

        ELSE

          IF NOT bgVisuVerfahreShuttle[stStationsNummern.NummerSPS] THEN
            Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpHandGeschwindigkeit;
            Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
            Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
            Antrieb.rpRuckzeit         := ppAntriebsInformationen.rpMaxRuckzeit;
          END_IF

        END_IF

      ELSE // Fächerwagensuche aktiv

        Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpGeschwindigkeitMessen;
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpReduzierteBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        Antrieb.rpRuckzeit         := ppAntriebsInformationen.rpMaxRuckzeit;

      END_IF

      IF ( ( Antrieb.rpGeschwindigkeit < 400 ) OR ( ABS(rpDestinationPosition - Antrieb.rpIstPosition) < 400.0 ) ) THEN
        Antrieb.rpRuckzeit := ppAntriebsInformationen.rpMaxRuckzeit * 10;
      END_IF

      Antrieb.rpZielPosition := rpDestinationPosition;
      Antrieb.wpBetriebsart := ABSOLUT;

      STEP_Mov_Shuttle_W := STEP_120_E;

    // VERFAHREN =================================
    STEP_120_E:
      (* Hinweis:
         - Antrieb hat seine Ziel-Position erreicht
      *)
      IF( Antrieb.bpDone
          AND ( ABS( rpDestinationPosition - rpAktPosition ) < rgMKZielPositionToleranz ) )
      THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        STEP_Mov_Shuttle_W := STEP_1000_E;
      END_IF

      (* Hinweis:
         - die Verfahrfreigabe wird waehrend des verfahrens genommen
            => Sensor belegt etc.
      *)
      IF ( NOT bpVerfahrfreigabe ) THEN
        Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpBeschleunigung := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpRuckzeit       := ppAntriebsInformationen.rpMaxRuckzeit;
        Antrieb.wpBetriebsart    := KEINE_FUNKTION;
        Antrieb.rpZielPosition   := Antrieb.rpIstPosition;

        // wSps2MmiMeasureSlotNummer  := 0; 0 =  Shuttle bremst noch / 1 = Shuttle gestoppt und steht
        wgSps2MmiShuttleNr                                  := stStationsNummern.NummerIntern;
        rSps2MmiShuttlePosition[0]                          := Antrieb.rpIstPosition;
        wSps2ShuttleStopped[stStationsNummern.NummerIntern] := 0;
        MsgToMmi(SB0_SPS_SHUTTLEVORABPOSITIONIERUNGABBRUCH);

        // Medlung ausgeben das ein Verfahrabbruch stattgefunden hat
        wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
        SpsHinweis( eFehler_Station, 
                    cMELDUNG_QUERFAHRT_VERFAHRABBRUCH, 
                    stStationsNummern.NummerExtern,
                    AutomatikkreisBestimmen(stStationsNummern.NummerIntern), 
                    wpgFehlerdaten );

        STEP_Mov_Shuttle_W := STEP_130_E;

      END_IF

    // VERFAHREN =================================
    STEP_130_E:
      (* Hinweis:
         - Verfahrauftrag wurde abgebrochen und wird neu gestartet
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        Antrieb.rpZielPosition := Antrieb.rpIstPosition;

        bpAuftragsstatusZuruecksetzen := TRUE;
        // wSps2MmiMeasureSlotNummer := 0; 0 = Shuttle bremst noch / 1 = Shuttle gestoppt und steht
        wgSps2MmiShuttleNr := stStationsNummern.NummerIntern;
        rSps2MmiShuttlePosition[0] := Antrieb.rpIstPosition;
        wSps2ShuttleStopped[stStationsNummern.NummerSPS] := 1;
        MsgToMmi(SB0_SPS_SHUTTLEVORABPOSITIONIERUNGABBRUCH);

        STEP_Mov_Shuttle_W := STEP_140_E;
      END_IF

    // VERFAHREN =================================
    STEP_140_E:
      (* Hinweis:
         - Verfahrauftrag wird abgebrochen und von der Oberflaeche neu angestossen
      *)
      bpVerfahreShuttle := FALSE;

      bpAbbruchPositionierung       := TRUE;
      bpAuftragsstatusZuruecksetzen := TRUE;

    // VERFAHREN =================================
    STEP_900_E:
      bpFehler:=TRUE;
      blFreigabeGesetzt := FALSE;

    // VERFAHREN =================================
    STEP_1000_E:
      bpDone := TRUE;
      blFreigabeGesetzt := FALSE;

  // VERFAHREN =================================
  END_CASE
END_IF

IF ( NOT bpVerfahreShuttle AND NOT bgVisuVerfahreShuttle[stStationsNummern.NummerSPS] ) THEN

  IF( STEP_Mov_Shuttle_W > STEP_0_E )THEN
    bpDone := FALSE;
    blFreigabeGesetzt := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    Antrieb.rpVerzoegerung   := ppAntriebsInformationen.rpMaxVerzoegerung;
    STEP_Mov_Shuttle_W := STEP_0_E;
    tonlAntriebNichtBetriebsbereit(IN:=FALSE);
  END_IF

END_IF
END_ACTION