(* METADATA
{
  "v3Meta": {
    "objectGuid": "cc1aed73-8848-476c-92aa-37d2b4b58ed1"
  }
}
*)
ACTION Aufkippen
//-------------------------------------------------------------------------------------------------
// AKTION AUFKIPPEN
//-------------------------------------------------------------------------------------------------
IF ( bpStartKippenAuf
     AND NOT bpStartKippenAb
     AND bpFreigabe )
THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_KIPPEN;
    steplKippenAuf := STEP_900_E;
  END_IF


  CASE steplKippenAuf OF
    // KIPPEN AUF  ================
    STEP_0_E:
      bpDone := FALSE;

      IF Antrieb.bpReglerBereit THEN
        IF ( Antrieb.rpIstPosition = ppParameterBaustein.rPosition90Grad ) THEN
          steplKippenAuf := STEP_1000_E;
        ELSE
          steplKippenAuf := STEP_10_E;
        END_IF
      END_IF

      // Ueberwachung:
      //   - Antrieb muss in endlicher Zeit betriebsbereit sein
      tonlAntriebNichtFreigegeben( IN := NOT ( Antrieb.bpReglerBereit ),
                                   PT := T#5S );

      IF ( tonlAntriebNichtFreigegeben.Q ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_NICHT_BETRIEBSBEREIT;
        steplKippenAuf := STEP_900_E;
      END_IF

    // KIPPEN AUF ================
    STEP_10_E:
      (* Anmerkung [Sensoren]:
         - Einlauf- Auslauf- Sensoren duerfen nicht belegt sein beim Kippen
           Anmerkung [Antrieb]:
         - Geschwindigkeit muss in Grad/s angegeben werden
         - Rampe 2s [2000 ms]
      *)
      IF (  NOT bpSensorEinlauf
           AND NOT bpSensorAuslauf )
      THEN
        IF bpLangsamKippen THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReduzierteGeschwindigkeit;
          Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit * 10;
        ELSIF bpBetriebsartHand THEN
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpReduzierteBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpHandGeschwindigkeit;
          Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit * 2;
        ELSE
          Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
          Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpReduzierteVerzoegerung;
          Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
          Antrieb.rpRuckzeit        := ppAntriebsInformationen.rpMaxRuckzeit;
        END_IF
        
        Antrieb.rpZielPosition := ppParameterBaustein.rPosition90Grad;
        Antrieb.wpBetriebsart  := ABSOLUT;
        
        steplKippenAuf := STEP_20_E;
      END_IF

      // Fehlerbehandlung
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
        steplKippenAuf := STEP_900_E;
      END_IF

      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr :=  SEL( bpSensorAuslauf, cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT, cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT );
        steplKippenAuf := STEP_900_E;
      END_IF

    // KIPPEN AUF ================
    STEP_20_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        steplKippenAuf := STEP_1000_E;
      END_IF

      // Fehlerbehandlung
      IF ( bpSensorAuslauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_KIPPEN_AUSLAUFSENSOR_BELEGT;
        steplKippenAuf := STEP_900_E;
      END_IF

      IF ( bpSensorEinlauf ) THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        wpFehlerNr :=   cMELDUNG_KIPPEN_EINLAUFSENSOR_BELEGT;
        IF ( bpSensorAuslauf ) THEN
          wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
        END_IF
        steplKippenAuf := STEP_900_E;
      END_IF

    // KIPPEN AUF ================
    STEP_900_E:
      IF NOT Antrieb.bpAntrieblaeuft THEN
        steplKippenAuf := STEP_910_E;
      END_IF

    // KIPPEN AUF ================
    STEP_910_E:
      bpFehler := TRUE;

    // KIPPEN AUF ================
    STEP_1000_E:
      bpDone := TRUE;

  // KIPPEN AUF ================
  END_CASE
ELSE
  IF ( steplKippenAuf > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    tonlAntriebNichtFreigegeben( IN := FALSE );
    steplKippenAuf := STEP_0_E;
  END_IF
END_IF
END_ACTION