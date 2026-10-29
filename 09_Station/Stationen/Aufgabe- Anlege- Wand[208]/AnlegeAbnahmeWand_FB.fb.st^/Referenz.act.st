(* METADATA
{
	"v3Meta": {
		"objectGuid": "7cf597d3-ce41-41c7-b266-cdc187d6fce4"
	}
}
*)
ACTION Referenz
(***************************************************************************************************)
(* AKTION REFERENZ *)
(***************************************************************************************************)
(* Referenzieren:
   - Die Station besitzt keinen Antrieb der Referenzieren muesste
*)
IF ( blBetriebsartReferenz OR BasisStationsParameter.dwHandfunktionen.5 )THEN
  CASE steplReferenz OF
(*REFERENZ ============================*)
    STEP_0_E:
      BasisStationsParameter.bReferenzAbgeschlossen := FALSE;

      IF BasisStationsParameter.bFreigabe THEN
       steplReferenz := STEP_5_E;
      END_IF

(*REFERENZ ============================*)
    STEP_5_E:

      Messachse.bpReferenz     := TRUE;
      Glastransport.bpReferenz := TRUE;
      steplReferenz := STEP_10_E;

(*REFERENZ ============================*)
    STEP_10_E:
      (* Hinweis:
         - Referenzierung Abgeschlossen
      *)
      IF ( Messachse.bpDone AND BasisStationsParameter.stMKs.stStationsAufbau.bMessachse)
       OR NOT BasisStationsParameter.stMKs.stStationsAufbau.bMessachse
       THEN
         Messachse.bpReferenz := FALSE;
         steplReferenz := STEP_100_E;
      END_IF

      (* Fehlerbehandlung
         - Hoehenkontrolle
      *)
      IF ( Messachse.bpFehler AND BasisStationsParameter.stMKs.stStationsAufbau.bMessachse) THEN
        Messachse.bpReferenz := FALSE;
        BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
        steplReferenz := STEP_900_E;
      END_IF


(*REFERENZ ============================*)
    STEP_100_E:
      IF ( Glastransport.bpDone ) THEN
        Glastransport.bpReferenz := FALSE;
        steplReferenz := STEP_1000_E;
      END_IF

      (* Fehlerbehandlung:
         - Glastransport 
      *)
      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpReferenz := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplReferenz := STEP_900_E;
      END_IF


(*REFERENZ ============================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*REFERENZ ============================*)
    STEP_1000_E:
      BasisStationsParameter.bReferenzAbgeschlossen := TRUE;

(*REFERENZ ============================*)
  END_CASE
ELSE
  IF ( steplReferenz > STEP_0_E ) THEN
    BasisStationsParameter.bReferenzAbgeschlossen := FALSE;
    Messachse.bpReferenz     := FALSE;
    Glastransport.bpReferenz := FALSE;
    steplReferenz := STEP_0_E;
  END_IF
END_IF
END_ACTION