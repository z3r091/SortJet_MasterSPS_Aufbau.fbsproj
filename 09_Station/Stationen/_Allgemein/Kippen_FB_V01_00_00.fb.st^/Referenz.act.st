(* METADATA
{
	"v3Meta": {
		"objectGuid": "2ed0377a-c005-41a2-ad7e-3f2bcd1b7fac"
	}
}
*)
ACTION Referenz
//-------------------------------------------------------------------------------------------------
// REFERENZ
//-------------------------------------------------------------------------------------------------
IF ( bpReferenz ) THEN

  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_KIPPEN;
    steplReferenz := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplReferenz OF
    // REFERENZ =========================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
      *)
      bpDone := FALSE;
      tonlEndschalterFreifahren(IN := FALSE);
      tonlWarteSchrittEndschalterFreifahren(IN := FALSE);
      tofHardwareEndschalterFrei(IN:=FALSE);

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;

        (* Hinweis:
           - Pruefen ob ein Endschalter belegt ist [Oeffner- Kontakt]
        *)
        IF ( Antrieb.bpMinSchalterBelegt
             OR Antrieb.bpMaxSchalterBelegt )
        THEN
          steplReferenz := STEP_20_E;

        ELSE
          steplReferenz := STEP_100_E;

        END_IF
      END_IF

    // REFERENZ =========================
    STEP_20_E:
      (* Hinweis:
         - Endschalter freifahren
      *)
      tonlEndschalterFreifahren(IN := TRUE, PT:= T#10s);

      tofHardwareEndschalterFrei( IN := (  Antrieb.bpMinSchalterBelegt
                                          OR Antrieb.bpMaxSchalterBelegt ),
                                  PT := t#1s);

      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;

      IF (  Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDPLUS;
      END_IF

      IF (  Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart :=  HANDMINUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT tofHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplReferenz := STEP_30_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei !
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND ( Antrieb.bpMinSchalterBelegt
                 OR Antrieb.bpMaxSchalterBelegt ))
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_KIPPEN_ENDSCHALTER_NICHT_FREI;
        steplReferenz := STEP_900_E;
      END_IF

    // REFERENZ =========================
    STEP_30_E:
      (* Hinweis:
         - Erzwungene Pause, damit der Lenze Antrieb wieder ordnungsgemäß schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT:= T#2s);

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        steplReferenz := STEP_100_E;
      END_IF

    // REFERENZ =========================
    STEP_100_E:
      // ---------------------------------------------------------------------------------------
      //  STARTEN DER REFERENZ
      //
      //  Hinweis:
      // - Einlauf- und Auslaufsensor muessen frei sein
      // - Referenzgeschwindigkeit
      // ---------------------------------------------------------------------------------------
      IF (  NOT bpSensorEinlauf
           AND NOT bpSensorAuslauf )
      THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpZielPosition    := 0.01;
        Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;
        steplReferenz := STEP_110_E;
      ELSE
        wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
        steplReferenz := STEP_900_E;
      END_IF

    // REFERENZ =========================
    STEP_110_E:
      (* Hinweis:
         - Referenzieren abgeschlossen
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        bpInReferenz := TRUE;
        steplReferenz := STEP_1000_E;
      END_IF

    // REFERENZ =========================
    STEP_900_E:
      bpFehler := TRUE;

    // REFERENZ =========================
    STEP_1000_E:
      bpDone := TRUE;

  // REFERENZ =========================
  END_CASE
ELSE

  IF ( steplReferenz > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    steplReferenz := STEP_0_E;
  END_IF

END_IF
END_ACTION