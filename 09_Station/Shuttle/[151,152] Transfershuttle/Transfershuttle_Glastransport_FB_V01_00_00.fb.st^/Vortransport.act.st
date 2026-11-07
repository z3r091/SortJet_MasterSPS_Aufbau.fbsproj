(* METADATA
{
	"v3Meta": {
		"objectGuid": "688bf5fb-374b-4ef1-b3ec-2a5fade55400"
	}
}
*)
ACTION Vortransport
//-------------------------------------------------------------------------------------------------
// AKTION: VORTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( bpVortransport
     AND bpAutomatikAktiv )
THEN

  (* Ausnahmefehler:
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.rpGeschwindigkeit := REAL#0;
    Antrieb.wpBetriebsart     := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplVortransport := STEP_900_E;
  END_IF


  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplVortransport OF
    // VORTRANSPORT ==============================
    STEP_0_E:
      IF ( Antrieb.bpReglerBereit )THEN
        Antrieb.rpGeschwindigkeit := REAL#0;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        steplVortransport := STEP_5_E;
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit ),
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplVortransport := STEP_900_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_5_E:
      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;
      steplVortransport := STEP_6_E;

    // VORTRANSPORT ==============================
    STEP_6_E:
      IF Antrieb.bpDone THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_10_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_10_E:
      // ---------------------------------------------------------------------------------------
      //  VORTRANSPORT IM TRANSFERSHUTTLE VERBUND
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      IF ( bpTransfershuttleVerbundAktiv ) THEN

        blSchnittstelle_bAnforderungTransportVerbund := TRUE;

        IF ( stpInTransportVerbund.bBereitZumTransportVerbund ) THEN
          steplVortransport := STEP_20_E;
        END_IF

      ELSE
        steplVortransport := STEP_20_E;

      END_IF

    // VORTRANSPORT ==============================
    STEP_20_E:
      (* Anmerkung:
         - Timer zum prüfen der Einlauf- Auslauf- Sensoren [Luftdruck] zuruecksetzen
         - Timer zum heben und Senken des Shuttles zuruecksetzen
      *)
      tonlEinlaufsensorTesten(IN:= FALSE);
      tonlAuslaufsensorTesten(IN:= FALSE);
      tonlWartenAufAnheben(IN:=FALSE);
      tonlWartenAufSenken(IN:=FALSE);

      steplVortransport := STEP_100_E;

    // VORTRANSPORT ==============================
    STEP_100_E:
      // Ueberpruefung ob die Luftsensoren frei sind und richtig durchschalten
      //   - Einlauf- Auslauf- Sensoren
      blScheibenKontrolleAuslaufseiteEin := TRUE;
      blScheibenKontrolleEinlaufseiteEin := TRUE;

      tonlEinlaufsensorTesten(IN := NOT bpSensorScheibenKontrolleEinlaufseiteFrei, PT := t#5s);
      tonlAuslaufsensorTesten(IN := NOT bpSensorScheibenKontrolleAuslaufseiteFrei, PT := t#5s);

      IF  ( bpSensorScheibenKontrolleEinlaufseiteFrei
            AND bpSensorScheibenKontrolleAuslaufseiteFrei )
      THEN
        steplVortransport := STEP_110_E;
      END_IF

      (* Fehlerbehandlung:
         - Einlaufseite frei
         - Auslaufseite frei
      *)
      IF ( tonlEinlaufsensorTesten.Q ) THEN
        wpFehlerNr := cMELDUNG_TS_EINLAUFSENSOR_WIRD_NICHT_FREI;
        steplVortransport := STEP_900_E;
      END_IF

      IF ( tonlAuslaufsensorTesten.Q ) THEN
        wpFehlerNr := cMELDUNG_TS_AUSLAUFSENSOR_WIRD_NICHT_FREI;
        steplVortransport := STEP_900_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_110_E:
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
      blScheibenKontrolleAuslaufseiteEin := TRUE;
      blScheibenKontrolleEinlaufseiteEin := TRUE;

      tonlWartenAufAnheben(IN := NOT blBereitZumGlastransport, PT := t#10s);

      IF ( blBereitZumGlastransport ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_120_E;
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
        END_IF

        steplVortransport := STEP_900_E;
        bpOutBereitZumEintransport := FALSE;
      END_IF

    // VORTRANSPORT ==============================
    STEP_120_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DES VORTRANSPORTS
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------
      rlAntriebsPositionBeiStart := Antrieb.rpIstPosition;
      rlAntriebsPositionStartVortransport := Antrieb.rpIstPosition;
      rpVorpositionierterWeg := REAL#0;

      Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVorpositionieren;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.rpZielPosition    := rpVorpositionierweg;
      Antrieb.wpBetriebsart     := RESTWEG;

      steplVortransport := STEP_130_E;

    // VORTRANSPORT ==============================
    STEP_130_E:
      IF ( NOT Antrieb.bpDone
           AND Antrieb.bpAntrieblaeuft )
      THEN
        steplVortransport := STEP_140_E;
      END_IF

      IF ( blAuslaufsensor ) THEN
        rlAntriebspositionBeiAuslaufSensorBelegung :=Antrieb.rpIstPosition;
        bpScheibeFaehrtUeberAuslauf := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_200_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_140_E:
      IF ( Antrieb.bpDone
           AND NOT Antrieb.bpAntrieblaeuft )
      THEN
        rpVorpositionierterWeg := ABS(Antrieb.rpIstPosition - rlAntriebsPositionStartVortransport);
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_300_E;
      END_IF

      IF ( blAuslaufsensor ) THEN
        rlAntriebspositionBeiAuslaufSensorBelegung :=Antrieb.rpIstPosition;
        bpScheibeFaehrtUeberAuslauf := TRUE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_200_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_200_E:
      // ---------------------------------------------------------------------------------------
      //  VERSUCH AUSLAUFSENSOR FREI FAHREN
      //
      //  Hinweis:
      // - Wenn der Antrieb nicht mehr dreht Versuchen dem Sensor frei zu fahren
      // ---------------------------------------------------------------------------------------
      Antrieb.wpBetriebsart := KEINE_FUNKTION;

      IF ( NOT toflAntriebLaeuft.Q ) THEN
        rlWegDifferenzNachStopSensorBelegung := ABS(rlAntriebspositionBeiAuslaufSensorBelegung - Antrieb.rpIstPosition);
        steplVortransport := STEP_210_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_210_E:
      (* Hinweis:
         - Antrieb verfahren (Handfahren)
      *)
      IF ( Antrieb.bpReglerBereit ) THEN

        rlAntriebsPositionBeiStart  := Antrieb.rpIstPosition;

        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := (ppAntriebsInformationen.rpMaxBeschleunigung);
        Antrieb.rpVerzoegerung    := (ppAntriebsInformationen.rpMaxVerzoegerung);
        Antrieb.wpBetriebsart     := HANDMINUS;

        steplVortransport := STEP_220_E;
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit ),
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplVortransport := STEP_900_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_220_E:
      (* Anmerkung:
         - Auslaufsensor frei
         - Strecke die maximal Verfahren werden darf zum Sensor freifahren
         - Einlaufsensor belegt sofoert mit einem Fehlerbeenden
      *)
      IF ( NOT blAuslaufsensor ) THEN
        // Tatsaechlich vorpositionierter Weg nach dem Freifahren des Auslaufsensors
        rpVorpositionierterWeg := ABS(Antrieb.rpIstPosition - rlAntriebsPositionStartVortransport);
        bpScheibeFaehrtUeberAuslauf := FALSE;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplVortransport := STEP_300_E;
      END_IF

      IF ( ABS(rlAntriebsPositionBeiStart - Antrieb.rpIstPosition) >
           (ppParameterBaustein.rMaxPosAuslaufSensorFreiFahren + rlWegDifferenzNachStopSensorBelegung) )
      THEN
        rpVorpositionierterWeg := ABS(Antrieb.rpIstPosition - rlAntriebsPositionStartVortransport);
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplVortransport := STEP_900_E;
      END_IF

      IF ( blEinlaufsensor ) THEN
        rpVorpositionierterWeg := ABS(Antrieb.rpIstPosition - rlAntriebsPositionStartVortransport);
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplVortransport := STEP_900_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_300_E:
      // ---------------------------------------------------------------------------------------
      //  RIEMEN UND ABFRAGEN SENKEN
      //
      //  Hinweis:
      // - n/c
      // ---------------------------------------------------------------------------------------

      out_bShuttleAnheben := FALSE;

      out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
      blScheibenKontrolleAuslaufseiteEin    := FALSE;
      out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
      blScheibenKontrolleEinlaufseiteEin    := FALSE;

      tonlWartenAufSenken( IN:= NOT bpBereitZumVerfahren , PT:=t#10s);

      IF ( bpBereitZumVerfahren ) THEN
        steplVortransport := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport oben
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

        steplVortransport := STEP_900_E;
        bpOutBereitZumEintransport := FALSE;
      END_IF

    // VORTRANSPORT ==============================
    STEP_900_E:
      bpFehler := TRUE;

    // VORTRANSPORT ==============================
    STEP_1000_E:
      bpDone := TRUE;

  // VORTRANSPORT ==============================
  END_CASE
ELSE
  IF ( steplVortransport > STEP_0_E ) THEN
    bpDone := FALSE;
    out_bShuttleAnheben := FALSE;

    out_bScheibenKontrolleAuslaufSeiteAuf := FALSE;
    blScheibenKontrolleAuslaufseiteEin    := FALSE;
    out_bScheibenKontrolleEinlaufSeiteAuf := FALSE;
    blScheibenKontrolleEinlaufseiteEin    := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    tonlAntriebNichtFreigegeben( IN := FALSE );
    steplVortransport := STEP_0_E;
  END_IF
END_IF
//_________________________________________________________________________
// ************************ ENDE Glas- Vortransport **********************
//_________________________________________________________________________
END_ACTION