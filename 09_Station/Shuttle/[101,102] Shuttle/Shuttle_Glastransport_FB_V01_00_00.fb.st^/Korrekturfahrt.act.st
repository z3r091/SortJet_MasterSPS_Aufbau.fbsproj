(* METADATA
{
	"v3Meta": {
		"objectGuid": "d6b11d7c-fbd5-4eee-93cf-7ea9aca4b11c"
	}
}
*)
ACTION Korrekturfahrt
//-------------------------------------------------------------------------------------------------
// AKTION KORREKTURFAHRT GREIFER
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Sensor der Greiferseite frei fahren
     => Eintransport uebergrosser Scheiben: der Glastransport zieht den Rest der Scheibe auf das Shuttle
     => Nach dem Austransport mit dem Greifer
   - bpKorrekturfahrtRueckwaerts: TRUE = Auslaufsensor frei fahren (HANDMINUS), FALSE = Einlaufsensor (HANDPLUS)
*)
IF (     bpStarteKorrekturfahrt
     AND bpAutomatikAktiv )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_GLASTRANSPORT;
    steplKorrekturfahrt := STEP_900_E;
  END_IF

  CASE steplKorrekturfahrt OF
    // KORREKTURFAHRT ==============================
    STEP_0_E:
      (* Hinweis:
         - Antrieb bereit
      *)
      bpKorrekturfahrtAbgeschlossen := FALSE;

      IF (     Antrieb.bpReglerBereit
           AND blAntriebsKopplungAktiv )
      THEN
        rlAntriebIstPositionBeiStart := Antrieb.rpIstPosition;
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        tonlUeberwachungGreiferBetrieb( IN := FALSE );

        IF ( bpKorrekturfahrtRueckwaerts ) THEN
          steplKorrekturfahrt := STEP_10_E;
        ELSE
          steplKorrekturfahrt := STEP_20_E;
        END_IF
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlUeberwachungGreiferBetrieb( IN := NOT ( Antrieb.bpReglerBereit AND blAntriebsKopplungAktiv ),
                                   PT := cZEIT_UEBERWACHUNG_ANTRIEBSFREIGABE );

      IF ( tonlUeberwachungGreiferBetrieb.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplKorrekturfahrt := STEP_900_E;
      END_IF

    // KORREKTURFAHRT ==============================
    STEP_10_E:
      (* Hinweis:
         - Auslaufsensor frei fahren
      *)
      IF ( toflAuslaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDMINUS;
      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
          steplKorrekturfahrt := STEP_1000_E;
        END_IF
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Einlaufsensor belegt
      *)
      IF ( ABS( rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition ) > ppParameterBaustein.rWegUeberwachungSensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_NICHT_FREI;
        steplKorrekturfahrt := STEP_900_E;
      END_IF

      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_BELEGT;
        steplKorrekturfahrt := STEP_900_E;
      END_IF

    // KORREKTURFAHRT ==============================
    STEP_20_E:
      (* Hinweis:
         - Einlaufsensor frei fahren
      *)
      IF ( toflEinlaufsensor.Q ) THEN
        Antrieb.rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart     := HANDPLUS;
      ELSE
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
          steplKorrekturfahrt := STEP_1000_E;
        END_IF
      END_IF

      (* Fehlerbehandlung:
         - Wegueberwachung
         - Auslaufsensor belegt
      *)
      IF ( ABS( rlAntriebIstPositionBeiStart - Antrieb.rpIstPosition ) > ppParameterBaustein.rWegUeberwachungSensor ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_EINLAUF_NICHT_FREI;
        steplKorrekturfahrt := STEP_900_E;
      END_IF

      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_SENSOR_AUSLAUF_BELEGT;
        steplKorrekturfahrt := STEP_900_E;
      END_IF

    // KORREKTURFAHRT ==============================
    STEP_900_E:
      bpFehler := TRUE;

    // KORREKTURFAHRT ==============================
    STEP_1000_E:
      bpKorrekturfahrtAbgeschlossen := TRUE;

  // KORREKTURFAHRT ==============================
  END_CASE

ELSE

  IF ( steplKorrekturfahrt > STEP_0_E ) THEN
    bpKorrekturfahrtAbgeschlossen := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    tonlUeberwachungGreiferBetrieb( IN := FALSE );
    steplKorrekturfahrt := STEP_0_E;
  END_IF

END_IF
END_ACTION