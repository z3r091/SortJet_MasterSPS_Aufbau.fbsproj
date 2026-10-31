(* METADATA
{
	"v3Meta": {
		"objectGuid": "1a2ebc48-f89f-4395-b64c-a4e0130d646b"
	}
}
*)
ACTION Referenz
(***************************************************************************************************)
(* AKTION: REFERENZ *)
(***************************************************************************************************)
(* Hinweis:
    - Antrieb Referenzfahrt starten
*)
IF ( bpStartReferenz ) THEN

   (* Ausnahmefehler:
      - ANTRIEB
   *)
   IF ( Antrieb.bpFehler ) THEN
     Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
     wpFehlerNr := cMELDUNG_ANTRIEB;
     steplReferenz := STEP_900_E;
  END_IF

  (* Hinweis:
     - Starten der Schrittkette
  *)
  CASE steplReferenz OF
(*REFERENZ ==================================*)
    STEP_0_E:
      tonlEndschalterFreifahren(IN := FALSE);
      tonlWarteSchrittEndschalterFreifahren(IN := FALSE);
      toflHardwareEndschalterFrei(IN := FALSE);

      IF (  bpFreigabe
        AND bpVerfahrfreigabe )
      THEN
        Antrieb.bpFreigabe := blFreigabeGesetzt := TRUE;
        steplReferenz := STEP_10_E;
      END_IF

(*REFERENZ ==================================*)
    STEP_10_E:
      (* Hinweis:
        - Endschalter kontrollieren, ob der Antrieb auf einem steht,
           wenn ja diesen erst freifahren
      *)
      IF (  NOT Antrieb.bpMinSchalterBelegt
        AND NOT Antrieb.bpMaxSchalterBelegt )
      THEN
        steplReferenz := STEP_200_E;
      ELSE
        steplReferenz := STEP_100_E;
      END_IF

(*REFERENZ ==================================*)
    STEP_100_E:
      tonlEndschalterFreifahren(IN := TRUE, PT := T#10s);
      toflHardwareEndschalterFrei( IN := (  Antrieb.bpMinSchalterBelegt
                                        OR Antrieb.bpMaxSchalterBelegt),
                                  PT := t#1s);
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpRuckzeit         := ppAntriebsInformationen.rpMaxRuckzeit;

      IF ( Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart := HANDPLUS;
      END_IF
      IF ( Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart := HANDMINUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplReferenz := STEP_110_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter
      *)
      IF ( tonlEndschalterFreifahren.Q
        AND ( Antrieb.bpMinSchalterBelegt OR Antrieb.bpMaxSchalterBelegt ) )
      THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        wpFehlerNr := cMELDUNG_QUERFAHRT_ENDSCHALTER_NICHT_FREI;
        steplReferenz := STEP_900_E;
      END_IF

(*REFERENZ ==================================*)
    STEP_110_E:
      (*
        erzwungene Pause, damit der Lenze Antrieb wieder ordnungsgemÃ¤ÃŸ schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT := T#2s);
      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        steplReferenz := STEP_200_E;
      END_IF

(*REFERENZ ==================================*)
    STEP_200_E:
      (*
        Antrieb Referenzieren
      *)
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
      Antrieb.rpRuckzeit         := ppAntriebsInformationen.rpMaxRuckzeit;

      Antrieb.wpBetriebsart := AntriebsBetriebsart_EN.REFERENZ;

      steplReferenz := STEP_210_E;

(*REFERENZ ==================================*)
    STEP_210_E:
      (* Hinweis:
         - Fuer die Zielpunktkontrolle muss im ersten Zyklus (und nach jeder Referenzierung)
           die Zielposition initialisiert werden
      *)
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart  := KEINE_FUNKTION;
        Antrieb.rpZielPosition := Antrieb.rpIstPosition;
        steplReferenz := STEP_1000_E;
      END_IF

(*REFERENZ ==================================*)
    STEP_900_E:
      bpFehler := TRUE;
      blFreigabeGesetzt  := FALSE;

(*REFERENZ ==================================*)
    STEP_1000_E:
      bpDone := TRUE;
      blFreigabeGesetzt  := FALSE;

(*REFERENZ ==================================*)
  END_CASE
ELSE

  IF ( steplReferenz > STEP_0_E ) THEN
    bpDone             := FALSE;
    blFreigabeGesetzt  := FALSE;

    Antrieb.wpBetriebsart := KEINE_FUNKTION;

    tonlWarteSchrittEndschalterFreifahren( IN := FALSE );
    steplReferenz := STEP_0_E;
  END_IF

END_IF
END_ACTION