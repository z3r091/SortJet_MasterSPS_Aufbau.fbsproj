(* METADATA
{
  "v3Meta": {
    "objectGuid": "b6351526-9ed3-46f4-a7dd-669ea1e1d7fa"
  }
}
*)
ACTION Referenz
(***************************************************************************************************)
(* AKTION: REFERENZIERUNG *)
(***************************************************************************************************)
(* Referenzieren:
   - Antriebe referenzieren 
*)
IF ( blBetriebsartReferenz ) THEN  

  // Ausnahmesituation
  IF ( Messachse.bpFehler ) THEN
    Messachse.bpReferenz := FALSE;
    BasisStationsParameter.wFehlerNummer := Messachse.wpFehlerNr;
    steplReferenz := STEP_900_E;
  END_IF
  
  IF ( Glastransport.bpFehler ) THEN
    Glastransport.bpReferenz := FALSE;
    BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
    steplReferenz := STEP_900_E;
  END_IF

  
  CASE steplReferenz OF
    (*REFERENZ ============================*)
    STEP_0_E:
      BasisStationsParameter.bReferenzAbgeschlossen := FALSE;

      IF ( BasisStationsParameter.bFreigabe ) THEN
        steplReferenz := STEP_10_E;
      END_IF

    (*REFERENZ ============================*)
    STEP_10_E:
      Messachse.bpReferenz     := TRUE;
      Glastransport.bpReferenz := TRUE;

      steplReferenz := STEP_20_E;

    (*REFERENZ ============================*)
    STEP_20_E:
      (* Hinweis:
         - Referenzierung Abgeschlossen
      *)
      IF ( Messachse.bpDone ) THEN
        Messachse.bpReferenz := FALSE;
        steplReferenz := STEP_30_E;
      END_IF

    (*REFERENZ ============================*)
    STEP_30_E:
      IF ( Glastransport.bpDone  ) THEN
        Glastransport.bpReferenz := FALSE;
        steplReferenz := STEP_1000_E;
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