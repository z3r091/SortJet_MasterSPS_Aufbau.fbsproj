(* METADATA
{
	"v3Meta": {
		"objectGuid": "ce8a7277-bde5-49fb-a4f3-75ebc5e1ddd0"
	}
}
*)
ACTION Vortransport
//-------------------------------------------------------------------------------------------------
// AKTION: VORTRANSPORT
//-------------------------------------------------------------------------------------------------
IF ( bpVortransport
     AND NOT bpEintransport
     AND NOT bpRueckwaertsEintransportieren
     AND bpAutomatikAktiv )
THEN

  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplVortransport := STEP_900_E;
  END_IF

  CASE steplVortransport OF

    // VORTRANSPORT ==============================
    STEP_0_E:

      (* Hinweis:
         - Reduzieren der Geschwindigkeit + Rampen nach Glasgewicht
         - Sicherstellen das die Slavekopplung aktiv ist
      *)
      rlGlasgewicht := ( GlasGewichtErmitteln( rpGlaslaenge  := pAuftrag.rAuftragsLaenge,
                                               rpGlasbreite  := pAuftrag.rAuftragsHoehe,
                                               rpGlasstaerke := pAuftrag.rAuftragsDicke ) );

      blReduzierteGeschwindigkeit := ( rlGlasgewicht > rgReduzierteGeschwindigkeitGlasGewicht );

      IF ( blAntriebsKopplungAktiv  )
      THEN
        steplVortransport := STEP_5_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_5_E:

      IF (  NOT bpSensorAuslaufVorab
           AND pAuftrag.rModellVersatzVorne = 0.0 )
      THEN
        rlAntriebIstPositionBeiStart  := Antrieb.rpIstPosition;

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit20;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpGeschwindigkeit := rgGeschwindigkeit30;
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDPLUS;

        steplVortransport := STEP_10_E;
      ELSE
        steplVortransport := STEP_1000_E;

      END_IF

      (* Fehlerbehandlung:
         - Auslaufsensor belegt (wie Basic_Glastransport)
      *)
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplVortransport := STEP_900_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_10_E:
      (* Hinweis:
         - Glas auf den VorStop- Sensor vorpositionieren
      *)
      IF ( bpSensorAuslaufVorab ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        steplVortransport := STEP_20_E;
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Auslaufsensor
      *)
      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUFVORAB_SCHALTET_NICHT;
        steplVortransport := STEP_900_E;
      END_IF

      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_BELEGT;
        steplVortransport := STEP_900_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_20_E:
      (* Hinweis:
         - Pruefen ob das Glas zuweit gefahren wurde und den Auslaufsensor nun belegt ist.
            ggf. das Glas wider zurueck fahren
      *)
      IF (  NOT Antrieb.bpAntrieblaeuft
           AND NOT toflAuslaufsensor.Q )
      THEN
        steplVortransport := STEP_1000_E;
      END_IF

      IF ( toflAuslaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitVerySlow;

        IF ( blReduzierteGeschwindigkeit ) THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
        ELSE
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        END_IF

        Antrieb.wpBetriebsart     := HANDMINUS;
      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
      END_IF

      (* Fehlerbehandlung:
         - Sensor
         - Wegueberwachung: Auslaufsensor wird nicht frei
      *)
      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_EINLAUF_BELEGT;
        steplVortransport := STEP_900_E;
      END_IF

      IF ( ABS(rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition) > ppParameterBaustein.rLaengeStation ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_VORTRANSPORT_SENSOR_AUSLAUF_NICHT_FREI;
        steplVortransport := STEP_900_E;
      END_IF

    // VORTRANSPORT ==============================
    STEP_900_E:
      (* Fehlerbehandlung:
      *)
      bpFehler := TRUE;

    // VORTRANSPORT ==============================
    STEP_1000_E:
      bpDone := TRUE;

  // VORTRANSPORT ==============================
  END_CASE
ELSE
  IF (steplVortransport > STEP_0_E) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplVortransport := STEP_0_E;
  END_IF
END_IF
END_ACTION