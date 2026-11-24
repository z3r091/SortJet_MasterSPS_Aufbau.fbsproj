(* METADATA
{
	"v3Meta": {
		"objectGuid": "1d88a2e4-b296-458f-a9e0-c58bfb83ee53"
	}
}
*)
ACTION Positionieren
//-------------------------------------------------------------------------------------------------
// AKTION: POSITIONIEREN
//-------------------------------------------------------------------------------------------------

IF( bpPositionierung ) THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_MESSACHSE;
    steplPositionieren := STEP_900_E;
  END_IF


  CASE steplPositionieren OF
    // POSITIONIEREN ====================
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
         - Pruefen ob der Umrichter bereit zum verfahren ist
      *)
      bpDone := FALSE;

      tonlEndschalterFreifahren(IN := FALSE);
      tonlWarteSchrittEndschalterFreifahren(IN := FALSE);
      toflHardwareEndschalterFrei(IN:=FALSE);

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;

        IF (ABS (rpZielPosition - Antrieb.rpIstPosition) > 0.5) THEN

          IF (  Antrieb.bpMinSchalterBelegt ) THEN
            steplPositionieren := STEP_10_E;
          ELSE
            steplPositionieren := STEP_100_E;
          END_IF

        ELSE
          steplPositionieren := STEP_1000_E;
        END_IF

      END_IF

    // POSITIONIEREN ====================
    STEP_10_E:
      tonlEndschalterFreifahren(IN := TRUE, PT:= T#10s);

      toflHardwareEndschalterFrei( IN := (  Antrieb.bpMinSchalterBelegt
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
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplPositionieren := STEP_20_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei !
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND  Antrieb.bpMinSchalterBelegt )
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_MESSACHSE_MINIMUM_ENDSCHALTER_BELEGT;
        steplPositionieren := STEP_900_E;
      END_IF

      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_MESSACHSE;
        steplPositionieren := STEP_900_E;
      END_IF

    // POSITIONIEREN ====================
    STEP_20_E:
      (* Hinweis:
         - Erzwungene Pause, damit der Lenze Antrieb wieder ordnungsgemäß schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT:= T#2s);

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        steplPositionieren := STEP_100_E;
      END_IF

      (* Fehlerbehandlung:
         - Antrieb
      *)
      IF ( Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_ANTRIEB_MESSACHSE;
        steplPositionieren := STEP_900_E;
      END_IF

    // POSITIONIEREN ====================
    STEP_100_E:
      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< STARTEN DER POSITIONIERUNG >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      //
      //   Hinweis:
      //   - Starten der Positionierung
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;

      Antrieb.rpZielposition    := rpZielPosition;
      Antrieb.wpBetriebsart     := ABSOLUT ;

      steplPositionieren := STEP_110_E;

    // POSITIONIEREN ====================
    STEP_110_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplPositionieren := STEP_1000_E;
      END_IF

    // POSITIONIEREN ====================
    STEP_900_E:
      bpFehler := TRUE;

    // POSITIONIEREN ====================
    STEP_1000_E:
      bpDone := TRUE;

  // POSITIONIEREN ====================
  END_CASE
ELSE
  IF( steplPositionieren > STEP_0_E )THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    steplPositionieren := STEP_0_E;
  END_IF
END_IF
END_ACTION