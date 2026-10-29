(* METADATA
{
	"v3Meta": {
		"objectGuid": "c0aa1156-83db-44a0-bed4-e5c414c71a01"
	}
}
*)
ACTION Referenz
(***************************************************************************************************)
(* AKTION REFERENZ *)
(***************************************************************************************************)
IF ( bpReferenz ) THEN

  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart:=  KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_KIPPEN;
    steplReferenz := STEP_900_E;
  END_IF
  
  // Ausnahmesituation
  IF ( Antriebseinheit.bpFehler ) THEN
    Antriebseinheit.bpHeben  := FALSE;
    Antriebseinheit.bpSenken := FALSE;
    wpFehlerNr := Antriebseinheit.wpFehlerNr;
    steplReferenz := STEP_900_E;
  END_IF
  
  CASE steplReferenz OF
(*REFERENZ =============================*)
    STEP_0_E:
      (* Hinweis:
         - Variablen zuruecksetzen
           => Timer  
      *)
      tonlEndschalterFreifahren( IN := FALSE );
      tofHardwareEndschalterFrei( IN := FALSE );
      tonlWarteSchrittEndschalterFreifahren( IN := FALSE);

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit  := REAL#0;
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart      := KEINE_FUNKTION;

        steplReferenz := STEP_10_E;
      END_IF

(*REFERENZ =========================*)
    STEP_10_E:
      (* Hinweis
         - Antriebseinheit muss oben sein        
      *)
      IF ( Antriebseinheit.bpFreigabeKippen ) THEN
        Antriebseinheit.bpHeben := FALSE;
        steplReferenz := STEP_20_E;
      ELSE
        Antriebseinheit.bpHeben := TRUE;
      END_IF 

(*REFERENZ =========================*)
    STEP_20_E:
      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.rpGeschwindigkeit  := REAL#0;
        Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.wpBetriebsart      := KEINE_FUNKTION;

        steplReferenz := STEP_30_E;
      END_IF

(*REFERENZ =========================*)
    STEP_30_E:
      tonlEndschalterFreifahren(IN := TRUE, PT:= T#10s);

      tofHardwareEndschalterFrei( IN := (  Antrieb.bpMaxSchalterBelegt
                                        OR Antrieb.bpMinSchalterBelegt),
                                  PT := t#1s);

      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;

      IF ( Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart:=  HANDMINUS;
      END_IF
      IF ( Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart:=  HANDPLUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren
      *)
      IF ( NOT tofHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart:=  KEINE_FUNKTION;
        steplReferenz := STEP_40_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei !
         - Antrieb
       *)
      IF ( tonlEndschalterFreifahren.Q
        AND ( Antrieb.bpMaxSchalterBelegt
        OR Antrieb.bpMinSchalterBelegt ))
     THEN
       Antrieb.wpBetriebsart:=  KEINE_FUNKTION;
       wpFehlerNr := cMELDUNG_MESSACHSE_ENDSCHALTER_NICHT_FREI;
       steplReferenz := STEP_900_E;
     END_IF

(*REFERENZ =========================*)
    STEP_40_E:
      (* Hinweis:
         - Erzwungene Pause, damit der Lenze Antrieb wieder ordnungsgemäß schaltet
      *)
      tonlWarteSchrittEndschalterFreifahren(IN := TRUE, PT:= T#2s);

      IF ( tonlWarteSchrittEndschalterFreifahren.Q ) THEN
        steplReferenz := STEP_50_E;
      END_IF


(*REFERENZ =============================*)
    STEP_50_E:

      IF (  NOT bpSensorEinlauf
        AND NOT bpSensorAuslauf )
      THEN
        Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
        Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
        Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;
        Antrieb.rpZielPosition    := 0.01;
        Antrieb.wpBetriebsart     := AntriebsBetriebsart_EN.REFERENZ;
        steplReferenz := STEP_60_E;
      ELSE
        wpFehlerNr := cMELDUNG_KIPPEN_EINLAUF_AUSLAUF_SENSOR_BELEGT;
        steplReferenz := STEP_900_E;
      END_IF

(*REFERENZ =============================*)
    STEP_60_E:
      (* Hinweis:
         - Prozess abgeschlossen
      *)
      IF( Antrieb.bpDone )THEN
        Antrieb.wpBetriebsart:= KEINE_FUNKTION;
        steplReferenz := STEP_1000_E;
      END_IF

(*REFERENZ =============================*)
    STEP_900_E:
      bpFehler :=TRUE;

(*REFERENZ =============================*)
    STEP_1000_E:
      bpDone := TRUE;

(*REFERENZ =============================*)
 END_CASE
ELSE
  IF( steplReferenz > STEP_0_E )THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart:= KEINE_FUNKTION;
    Antriebseinheit.bpHeben := FALSE;
    steplReferenz := STEP_0_E;
  END_IF

END_IF
END_ACTION