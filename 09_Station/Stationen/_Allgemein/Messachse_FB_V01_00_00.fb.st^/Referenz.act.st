(* METADATA
{
	"v3Meta": {
		"objectGuid": "ffd33cf6-3714-46f6-9be0-590bf1b57c8b"
	}
}
*)
ACTION Referenz
//-------------------------------------------------------------------------------------------------
// AKTION: REFERENZ
//-------------------------------------------------------------------------------------------------

IF ( bpReferenz
     OR bpHandReferenz )
THEN

  (* Hinweis:
     - Fehler
  *)
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_MESSACHSE;
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
      toflHardwareEndschalterFrei(IN:=FALSE);

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.RESET;
        steplReferenz := STEP_10_E;
      END_IF

    // REFERENZ =========================
    STEP_10_E:
      (* Hinweis:
         - Pruefen ob der Antrieb keinen fehler hat nach dem Reset
         - Pruefen ob ein Endschalter belegt ist [Oeffner- Kontakt]
      *)
      IF ( NOT Antrieb.bpFehler ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;

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
        steplReferenz := STEP_30_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei !
         - Antrieb
      *)
      IF ( tonlEndschalterFreifahren.Q
           AND Antrieb.bpMinSchalterBelegt )
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_MESSACHSE_MINIMUM_ENDSCHALTER_BELEGT;
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
      (* Hinweis:
         - Antrieb Referenzieren
      *)
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart :=  AntriebsBetriebsart_EN.REFERENZ;

      steplReferenz := STEP_110_E;

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