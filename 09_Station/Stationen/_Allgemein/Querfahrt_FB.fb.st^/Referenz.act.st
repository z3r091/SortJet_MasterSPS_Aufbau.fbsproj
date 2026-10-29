(* METADATA
{
	"v3Meta": {
		"objectGuid": "a42a2f22-2173-4d2c-80b1-969457765003"
	}
}
*)
ACTION Referenz
(***************************************************************************************************)
(* REFERENZ *)
(***************************************************************************************************)
IF ( bpReferenz ) THEN
  
  // Ausnahmesituation
  IF ( Antrieb.bpFehler ) THEN
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    wpFehlerNr := cMELDUNG_ANTRIEB_QUERFAHRT;
    steplReferenz := STEP_900_E;
  END_IF

  CASE steplReferenz OF
(*REFERENZ ==================================*)
    STEP_0_E:
      (* Hinweis:
         - Timer zuruecksetzen
      *)
      tonlEndschalterFreifahren(IN := FALSE);
      toflHardwareEndschalterFrei(IN:=FALSE);

      IF ( Antrieb.bpReglerBereit ) THEN
        Antrieb.wpBetriebsart :=  KEINE_FUNKTION;
        steplReferenz := STEP_20_E;
      END_IF

(*REFERENZ ==================================*)
    STEP_20_E:
      IF (  NOT Antrieb.bpMaxSchalterBelegt
        AND NOT Antrieb.bpMinSchalterBelegt )
      THEN
        steplReferenz := STEP_50_E;
      ELSE
        steplReferenz := STEP_30_E;
      END_IF

(*REFERENZ ==================================*)
    STEP_30_E:
      (* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ENDSCHALTER FREI FAHREN >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  
         Hinweis:
         - Versuchen den jeweiligen Endschlater frei zu fahren          
      *) 
      tonlEndschalterFreifahren(IN := TRUE, PT:= T#10s);
      toflHardwareEndschalterFrei( IN := (  Antrieb.bpMaxSchalterBelegt
                                         OR Antrieb.bpMinSchalterBelegt),
                                   PT := t#1s);

      Antrieb.rpGeschwindigkeit := ppAntriebsInformationen.rpMaxGeschwindigkeit;
      Antrieb.rpBeschleunigung  := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung    := ppAntriebsInformationen.rpMaxVerzoegerung;

      IF ( Antrieb.bpMaxSchalterBelegt ) THEN
        Antrieb.wpBetriebsart := HANDMINUS;
      END_IF

      IF ( Antrieb.bpMinSchalterBelegt ) THEN
        Antrieb.wpBetriebsart := HANDPLUS;
      END_IF

      (* Hinweis:
         - Endschalter min. 1 sec freifahren 
      *)
      IF ( NOT toflHardwareEndschalterFrei.Q ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_40_E;
      END_IF

      (* Fehlerbehandlung:
         - Endschalter wird nicht frei
       *)
      IF ( tonlEndschalterFreifahren.Q
        AND ( Antrieb.bpMaxSchalterBelegt
          OR  Antrieb.bpMinSchalterBelegt ))
     THEN
       Antrieb.wpBetriebsart := KEINE_FUNKTION;
       wpFehlerNr := cMELDUNG_QUERFAHRT_ENDSCHALTER_NICHT_FREI;
       steplReferenz := STEP_900_E;
     END_IF


(*REFERENZ ==================================*)
    STEP_40_E:
      (* Hinweis:
         - Warten bis Antrieb steht
      *)
      IF ( NOT Antrieb.bpAntrieblaeuft ) THEN
        steplReferenz := STEP_50_E;
      END_IF

(*REFERENZ ==================================*)
    STEP_50_E:
      (* Antrieb Referenzieren *)
      Antrieb.rpGeschwindigkeit  := ppAntriebsInformationen.rpReferenzGeschwindigkeit;
      Antrieb.rpBeschleunigung   := ppAntriebsInformationen.rpMaxBeschleunigung;
      Antrieb.rpVerzoegerung     := ppAntriebsInformationen.rpMaxVerzoegerung;

      Antrieb.wpBetriebsart      := AntriebsBetriebsart_EN.REFERENZ;

      steplReferenz := STEP_60_E;


(*REFERENZ ==================================*)
    STEP_60_E:
      IF ( Antrieb.bpDone ) THEN
        Antrieb.wpBetriebsart := KEINE_FUNKTION;
        steplReferenz := STEP_1000_E;
      END_IF

(*REFERENZ ==================================*)
    STEP_900_E:
      bpFehler := TRUE;

(*REFERENZ ==================================*)
    STEP_1000_E:
      bpDone := TRUE;

(*REFERENZ ==================================*)
  END_CASE
ELSE
  IF ( steplReferenz > STEP_0_E ) THEN
    bpDone := FALSE;
    Antrieb.wpBetriebsart := KEINE_FUNKTION;
    steplReferenz := STEP_0_E;
  END_IF
END_IF
END_ACTION