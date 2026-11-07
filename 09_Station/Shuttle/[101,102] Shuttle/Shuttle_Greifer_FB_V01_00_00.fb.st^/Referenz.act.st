(* METADATA
{
	"v3Meta": {
		"objectGuid": "399ec2fe-7160-47ab-ae27-c11bec0a5ba0"
	}
}
*)
ACTION Referenz
//-------------------------------------------------------------------------------------------------
// AKTION: REFERENZFAHRT GREIFERACHSE
//-------------------------------------------------------------------------------------------------
(* Hinweis:
   - Greifer einfahren, belegte Endschalter frei fahren, referenzieren, danach Grundstellungsfahrt
*)
IF ( bpFahreReferenz ) THEN

  (* Hinweis:
     - Zeitueberwachung der Wartestellen: Timer bei jedem Schrittwechsel neu starten
  *)
  IF ( steplReferenz <> steplReferenzMerker ) THEN
    tonlUeberwachungReferenz( IN := FALSE );
    steplReferenzMerker := steplReferenz;
  END_IF

  CASE steplReferenz OF
    // REFERENZ ==============================
    STEP_0_E:
      (* Hinweis:
         - Timer zuruecksetzen
         - Greifer einfahren, damit die Achse ohne Glaskontakt verfahren kann
      *)
      bpDone := FALSE;

      tofHardwareEndschalterFrei( IN := FALSE );
      tonlEndschalterFreifahren( IN := FALSE );
      tonlWarteSchrittEndschalterFreifahren( IN := FALSE );

      GreiferHub.bpStartAusfahren := FALSE;
      GreiferHub.bpStartEinfahren := TRUE;

      steplReferenz := STEP_5_E;

    // REFERENZ ==============================
    STEP_5_E:
      tonlUeberwachungReferenz( IN := TRUE, PT := ppParameterGreifer.tUeberwachungZylinder );

      IF ( GreiferHub.bpDone ) THEN
        GreiferHub.bpStartEinfahren := FALSE;
        steplReferenz := STEP_7_E;
      END_IF

      IF ( tonlUeberwachungReferenz.Q OR GreiferHub.bpFehler ) THEN
        GreiferHub.bpStartEinfahren := FALSE;
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_NICHT_EINGEFAHREN;
        steplReferenz := STEP_900_E;
      END_IF

    // REFERENZ ==============================
    STEP_7_E:
      (* Hinweis:
         - Antrieb bereit, Reset am Antrieb
      *)
      tonlUeberwachungReferenz( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( tonlAntriebFreigegeben.Q ) THEN
        Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.RESET;
        steplReferenz := STEP_10_E;
      END_IF

      IF ( tonlUeberwachungReferenz.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ANTRIEB_NICHT_BEREIT;
        steplReferenz := STEP_900_E;
      END_IF

    // REFERENZ ==============================
    STEP_10_E:
      tonlUeberwachungReferenz( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( NOT Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_20_E;
      END_IF

      IF ( tonlUeberwachungReferenz.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
        steplReferenz := STEP_900_E;
      END_IF

    // REFERENZ ==============================
    STEP_20_E:
      (* Hinweis:
         - Sicherstellen, dass kein Endschalter belegt ist
      *)
      IF (     NOT Antrieb.bpMinSchalterBelegt
           AND NOT Antrieb.bpMaxSchalterBelegt )
      THEN
        steplReferenz := STEP_100_E;
      ELSE
        steplReferenz := STEP_30_E;
      END_IF

    // REFERENZ ==============================
    STEP_30_E:
      (* Hinweis:
         - Endschalter mindestens 1 s frei fahren
      *)
      tonlEndschalterFreifahren( IN := TRUE, PT := T#10S );
      tofHardwareEndschalterFrei( IN := ( Antrieb.bpMinSchalterBelegt OR Antrieb.bpMaxSchalterBelegt ),
                                  PT := T#1S );

      IF ( Antrieb.bpMinSchalterBelegt ) THEN
        M_Fahren( epBetriebsart := HANDPLUS, rpZielPosition := 0.0, rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren );
      ELSIF ( Antrieb.bpMaxSchalterBelegt ) THEN
        M_Fahren( epBetriebsart := HANDMINUS, rpZielPosition := 0.0, rpGeschwindigkeit := rgGeschwindigkeitSensorenFreifahren );
      END_IF

      IF ( NOT tofHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_40_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q ) THEN
        IF ( Antrieb.bpMinSchalterBelegt ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_MINIMUM_ENDSCHALTER_NICHT_FREI;
        ELSIF ( Antrieb.bpMaxSchalterBelegt ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_MAXIMUM_ENDSCHALTER_NICHT_FREI;
        ELSE
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ENDSCHALTER_NICHT_FREI;
        END_IF
        steplReferenz := STEP_900_E;
      END_IF

      IF ( Antrieb.bpFehler ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
        steplReferenz := STEP_900_E;
      END_IF

    // REFERENZ ==============================
    STEP_40_E:
      (* Hinweis:
         - Pause, damit der Antrieb nach dem Freifahren wieder sauber schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren( IN := TRUE, PT := T#2S );

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        steplReferenz := STEP_100_E;
      END_IF

    // REFERENZ ==============================
    STEP_100_E:
      (* Hinweis:
         - Antrieb referenzieren
      *)
      M_Fahren( epBetriebsart     := AntriebsBetriebsart_EN.REFERENZ,
                rpZielPosition    := Antrieb.rpIstPosition,
                rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit );

      steplReferenz := STEP_110_E;

    // REFERENZ ==============================
    STEP_110_E:
      tonlUeberwachungReferenz( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_500_E;
      END_IF

      IF ( Antrieb.bpFehler ) THEN
        wpFehlerNr := cMELDUNG_ANTRIEB_GREIFER_STOESSEL;
        steplReferenz := STEP_900_E;
      END_IF

      IF ( tonlUeberwachungReferenz.Q ) THEN
        wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_POSITION_NICHT_ERREICHT;
        steplReferenz := STEP_900_E;
      END_IF

    // REFERENZ ==============================
    STEP_500_E:
      (* Hinweis:
         - Grundstellungsfahrt
      *)
      bpStartGrundstellungsfahrt := TRUE;
      steplReferenz := STEP_510_E;

    // REFERENZ ==============================
    STEP_510_E:
      (* Hinweis:
         - Die Grundstellungsfahrt ueberwacht ihre Wartestellen selbst und meldet Fehler ueber bpFehler
      *)
      tonlUeberwachungReferenz( IN := TRUE, PT := ppParameterGreifer.tUeberwachungBewegung );

      IF ( bpGrundstellungsfahrtAbgeschlossen ) THEN
        bpStartGrundstellungsfahrt := FALSE;
        steplReferenz := STEP_1000_E;
      END_IF

      IF ( bpFehler OR tonlUeberwachungReferenz.Q ) THEN
        IF ( NOT bpFehler ) THEN
          wpFehlerNr := cMELDUNG_GREIFER_STOESSEL_ABLAUF_ZEITUEBERSCHREITUNG;
        END_IF
        bpStartGrundstellungsfahrt := FALSE;
        steplReferenz := STEP_900_E;
      END_IF

    // REFERENZ ==============================
    STEP_900_E:
      Antrieb.wpBetriebsart := KEINE_FUNKTION;
      bpFehler := TRUE;

    // REFERENZ ==============================
    STEP_1000_E:
      bpDone := TRUE;

  // REFERENZ ==============================
  END_CASE

ELSE

  IF ( steplReferenz > STEP_0_E ) THEN
    bpDone := FALSE;
    bpStartGrundstellungsfahrt  := FALSE;
    GreiferHub.bpStartEinfahren := FALSE;
    Antrieb.wpBetriebsart       := KEINE_FUNKTION;
    tonlUeberwachungReferenz( IN := FALSE );
    steplReferenz       := STEP_0_E;
    steplReferenzMerker := STEP_0_E;
  END_IF

END_IF
END_ACTION