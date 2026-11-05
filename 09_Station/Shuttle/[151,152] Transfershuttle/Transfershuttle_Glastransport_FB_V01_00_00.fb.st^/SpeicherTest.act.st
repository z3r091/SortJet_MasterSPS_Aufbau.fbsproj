(* METADATA
{
  "v3Meta": {
    "objectGuid": "b0e3764e-5034-4602-ba0e-4069f5952f33"
  }
}
*)
ACTION SpeicherTest
// @TEXT_IMPLEMENTATION := 'ST'
//_________________________________________________________________________
// ************************ START Glas- GlastransportTest *********************
//_________________________________________________________________________
IF ( bpGlastransportTest
     AND NOT bpAutomatikAktiv )
THEN

  (* Fehlerbehandlung:
     - Antrieb [Glastransport]
     - Abbruch der Testkette ueber STEP_900_E (Meldung und Hupe nur einmal), danach Warten in STEP_910_E
  *)
  IF ( Antrieb.bpFehler
       AND ( steplGlastransporttest < STEP_900_E ) )
  THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplGlastransporttest := STEP_900_E;
  END_IF

  CASE steplGlastransporttest OF
    // GlastransportTest ==============================
    STEP_0_E:
      (* Anmerkung:
         - Timer zum prüfen der Einlauf- Auslauf- Sensoren [Luftdruck] zuruecksetzen
         - Timer zum heben und Senken des Shuttles zuruecksetzen
      *)
      tonlEinlaufsensorTesten(IN:= FALSE);
      tonlAuslaufsensorTesten(IN:= FALSE);
      tonlWartenAufAnheben(IN:=FALSE);
      tonlWartenAufSenken(IN:=FALSE);

      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit ),
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( Antrieb.bpReglerBereit )THEN
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        tonlAntriebNichtFreigegeben( IN := FALSE );

        steplGlastransporttest := STEP_30_E;

      ELSIF ( tonlAntriebNichtFreigegeben.Q ) THEN
        tonlAntriebNichtFreigegeben( IN := FALSE );
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplGlastransporttest := STEP_900_E;
      END_IF

    // GlastransportTest ==============================
    STEP_30_E:
      // Ueberpruefung ob die Luftsensoren frei sind und richtig durchschalten
      //   - Einlauf- Auslauf- Sensoren
      blScheibenKontrolleAuslaufseiteEin := TRUE;
      blScheibenKontrolleEinlaufseiteEin := TRUE;

      tonlEinlaufsensorTesten(IN := NOT bpSensorScheibenKontrolleEinlaufseiteFrei, PT := t#5s);
      tonlAuslaufsensorTesten(IN := NOT bpSensorScheibenKontrolleAuslaufseiteFrei, PT := t#5s);

      IF  ( bpSensorScheibenKontrolleEinlaufseiteFrei
            AND bpSensorScheibenKontrolleAuslaufseiteFrei )
      THEN
        steplGlastransporttest := STEP_40_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufseite frei
         - Auslaufseite frei
      *)
      IF ( tonlEinlaufsensorTesten.Q ) THEN
        wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_WIRD_NICHT_FREI;
        steplGlastransporttest := STEP_900_E;
      END_IF

      IF ( tonlAuslaufsensorTesten.Q ) THEN
        wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_WIRD_NICHT_FREI;
        steplGlastransporttest := STEP_900_E;
      END_IF

    // GlastransportTest ==============================
    STEP_40_E:
      (* Anmerkung:
         - Transfershuttle heben
         - Einlauf- Auslauf- Sensoren heben
           Die Variable  << blGlastransportUndAbfragenGehoben >> wird gebildet durch:
         - tonlGlastransportOben.Q  | tonlKontrolleEinlaufOben.Q  | blDruckluftAuslaufSeiteOK
           tonlKontrolleAuslaufOben.Q | blDruckluftEinlaufSeiteOK
      *)
      out_bShuttleAnheben := TRUE;
      out_bScheibenKontrolleAuslaufseiteAuf := TRUE;
      out_bScheibenKontrolleEinlaufseiteAuf := TRUE;

      tonlWartenAufAnheben(IN := NOT blBereitZumGlastransport, PT := t#10s);

      IF ( blBereitZumGlastransport ) THEN
        steplGlastransporttest := STEP_45_E;
      END_IF

      (* Fehlerbehandlung:
         - Druckluft
         - Glastransport oben
         - Ein- Aus- Laufsensoren
      *)
      IF ( tonlWartenAufAnheben.Q ) THEN
        // Glastransport oben
        IF ( NOT blSensorGlastransportOben ) THEN
          wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_OBEN;
        // Luftsensoren oben
        ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_OBEN;
        // Luftsensoren oben
        ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteOben ) THEN
          wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_OBEN;
        // Druckluft Ok
        ELSIF NOT blDruckluftEinlaufSeiteOK THEN
          wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_EINLAUF_NICHT_OK;
        // Druckluft Ok
        ELSIF ( NOT blDruckluftAuslaufSeiteOK ) THEN
          wpFehlerNr := cMELDUNG_TS_DRUCKLUFT_AUSLAUF_NICHT_OK;
        ELSE
          wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
        END_IF

        steplGlastransporttest := STEP_900_E;
        bpOutBereitZumEintransport := FALSE;

      END_IF

    // GlastransportTest ==============================
    STEP_45_E:

      IF NOT blEinlaufsensor THEN

        rlAntriebsPositionBeiStart  := Antrieb.rpIstPosition;

        Antrieb.rpGeschwindigkeit := rgAutoGeschwindigkeitTSVortransport;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung * 2;

        Antrieb.rpZielPosition    := 50;
        IF bpOptionTransfershuttleMitUltraschallSensoren THEN
          Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
        ELSE
          Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor1;
        END_IF

        steplGlastransporttest := STEP_50_E;

      ELSE

        steplGlastransporttest := STEP_70_E;


      END_IF

    // GlastransportTest ==============================
    STEP_50_E:
      (* Hinweis:
         - Setzen des Verfahrbefehls
      *)
      IF bpFreigabe THEN
        Antrieb.wpBetriebsart := RESTWEG;
        steplGlastransporttest := STEP_60_E;
      END_IF

    // GlastransportTest ==============================
    STEP_60_E:
      (* Hinweis:
         - Antrieb verfahren
      *)
      IF ( Antrieb.bpDone AND NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        steplGlastransporttest := STEP_70_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > 5300 ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplGlastransporttest := STEP_900_E;
      END_IF

    // GlastransportTest ==============================
    STEP_70_E:

      rlAntriebsPositionBeiStart  := Antrieb.rpIstPosition;

      Antrieb.rpGeschwindigkeit := rgAutoGeschwindigkeitTSVortransport;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung * 2;

      Antrieb.rpZielPosition    := 50;
      IF bpOptionTransfershuttleMitUltraschallSensoren THEN
        Antrieb.wpRestwegMode     := Positiv_Steigend_Sensor2;
      ELSE
        Antrieb.wpRestwegMode     := Positiv_Fallend_Sensor2;
      END_IF

      steplGlastransporttest := STEP_80_E;

    // GlastransportTest ==============================
    STEP_80_E:
      (* Hinweis:
         - Setzen des Verfahrbefehls
      *)
      IF bpFreigabe THEN
        Antrieb.wpBetriebsart := RESTWEG;
        steplGlastransporttest := STEP_90_E;
      END_IF

    // GlastransportTest ==============================
    STEP_90_E:
      (* Hinweis:
         - Antrieb verfahren
      *)
      IF ( Antrieb.bpDone AND NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        steplGlastransporttest := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > 5300 ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_SCHALTET_NICHT;
        steplGlastransporttest := STEP_900_E;
      END_IF

    // GlastransportTest ==============================
    STEP_100_E:

      Antrieb.rpGeschwindigkeit := rgAutoGeschwindigkeitTSVortransport;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung * 2;

      Antrieb.rpZielPosition    := 100;
      IF bpOptionTransfershuttleMitUltraschallSensoren THEN
        Antrieb.wpRestwegMode     := Negativ_Steigend_Sensor1;
      ELSE
        Antrieb.wpRestwegMode     := Negativ_Fallend_Sensor1;
      END_IF

      steplGlastransporttest := STEP_110_E;

    // GlastransportTest ==============================
    STEP_110_E:
      (* Hinweis:
         - Setzen des Verfahrbefehls
      *)
      IF bpFreigabe THEN
        Antrieb.wpBetriebsart := RESTWEG;
        steplGlastransporttest := STEP_120_E;
      END_IF

    // GlastransportTest ==============================
    STEP_120_E:
      (* Hinweis:
         - Antrieb verfahren
      *)
      IF ( Antrieb.bpDone AND NOT Antrieb.bpAntrieblaeuft ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        steplGlastransporttest := STEP_500_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) > 5300 ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_SCHALTET_NICHT;
        steplGlastransporttest := STEP_900_E;
      END_IF

    // GlastransportTest ==============================
    STEP_500_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Glastransport UND ABFRAGEN SENKEN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      out_bShuttleAnheben := FALSE;

      out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
      blScheibenKontrolleAuslaufseiteEin    := FALSE;
      out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
      blScheibenKontrolleEinlaufseiteEin    := FALSE;

      tonlWartenAufSenken( IN:= NOT bpBereitZumVerfahren , PT:=t#10s);

      IF ( bpBereitZumVerfahren ) THEN
        steplGlastransporttest := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport unten
         - Ein- Aus- Laufsensoren
      *)
      IF ( tonlWartenAufSenken.Q ) THEN
        // Glastransport unten
        IF ( NOT blSensorGlastransportUnten ) THEN
          wpFehlerNr := cMELDUNG_TS_MELDET_NICHT_UNTEN;
        // Luftsensoren unten
        ELSIF ( NOT bpSensorScheibenKontrolleEinlaufSeiteUnten ) THEN
          wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_MELDET_NICHT_UNTEN;
        // Luftsensoren unten
        ELSIF ( NOT bpSensorScheibenKontrolleAuslaufSeiteUnten ) THEN
          wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_MELDET_NICHT_UNTEN;
        ELSE
          wpFehlerNr := cMELDUNG_UNDEFINIERTER_ZUSTAND;
        END_IF

        steplGlastransporttest := STEP_900_E;
        bpOutBereitZumEintransport := FALSE;

      END_IF

    // GlastransportTest ==============================
    STEP_900_E:
      bpFehler := TRUE;
      wpgFehlerdaten[0] := stStationsNummern.NummerExtern;
      SpsError( eFehler_Station,
                wpFehlerNr,
                stStationsNummern.NummerIntern,
                AutomatikkreisBestimmen(stStationsNummern.NummerSPS),
                wpgFehlerdaten );

      FOR wlSubIndex := 1 TO cANZAHL_HUPEN DO
        Horn_AK[starrTransfershuttleBasisParameter[stStationsNummern.NummerSPS].stMKs.eaAutomatikkreis[1],wlSubIndex].wpStatusArt      := 0;
        Horn_AK[starrTransfershuttleBasisParameter[stStationsNummern.NummerSPS].stMKs.eaAutomatikkreis[1],wlSubIndex].tpHornZeit       := T#5S;
        Horn_AK[starrTransfershuttleBasisParameter[stStationsNummern.NummerSPS].stMKs.eaAutomatikkreis[1],wlSubIndex].bpHornAktivieren := TRUE;
      END_FOR

      bpOutBereitZumEintransport := FALSE;

      steplGlastransporttest := STEP_910_E;

    // GlastransportTest ==============================
    STEP_910_E:
      ;

    // GlastransportTest ==============================
    STEP_1000_E:
      bpDone:=TRUE;
      bpOutBereitZumEintransport := FALSE;

  // GlastransportTest ==============================
  END_CASE

ELSE

  IF steplGlastransporttest > STEP_0_E THEN
    bpDone:=FALSE;
    bpOutBereitZumEintransport := FALSE;

    out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
    blScheibenKontrolleAuslaufseiteEin    := FALSE;
    out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
    blScheibenKontrolleEinlaufseiteEin    := FALSE;
    out_bShuttleAnheben := FALSE;
    tonlAntriebNichtFreigegeben( IN := FALSE );

    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplGlastransporttest := STEP_0_E;
  END_IF

END_IF
//_________________________________________________________________________
// ************************ ENDE Glas- GlastransportTest **********************
//_________________________________________________________________________
END_ACTION