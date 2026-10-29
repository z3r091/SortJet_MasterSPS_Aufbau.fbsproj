(* METADATA
{
	"v3Meta": {
		"objectGuid": "11724a0e-d574-46c7-9adc-dd36baaee6ee"
	}
}
*)
ACTION Referenz
(***************************************************************************************************)
(* AKTION REFERENZ *)
(***************************************************************************************************)
IF ( BasisStationsParameter.bReferenz ) THEN
  CASE steplReferenz OF
(*REFERENZ ==============================*)
    STEP_0_E:
      steplReferenz := STEP_10_E;

(*REFERENZ ==============================*)
    STEP_10_E:
      Querfahrt.bpStartReferenz := NOT Querfahrt.bpInReference;
      Glastransport.bpFahreReferenz := TRUE;
      steplReferenz := STEP_20_E;

(*REFERENZ ==============================*)
    STEP_20_E:;
      IF ( Querfahrt.bpDone OR NOT Querfahrt.bpStartReferenz ) AND ( Glastransport.bpDone ) THEN
        Querfahrt.bpStartReferenz := FALSE;
        Glastransport.bpFahreReferenz := FALSE;
        steplReferenz := STEP_1000_E;
      END_IF

      IF ( Querfahrt.bpFehler ) THEN
        Querfahrt.bpStartReferenz := FALSE;
        BasisStationsParameter.wFehlerNummer := Querfahrt.wpFehlerNr;
        steplReferenz := STEP_900_E;
      END_IF

      IF ( Glastransport.bpFehler ) THEN
        Glastransport.bpFahreReferenz := FALSE;
        BasisStationsParameter.wFehlerNummer := Glastransport.wpFehlerNr;
        steplReferenz := STEP_900_E;
      END_IF

(*REFERENZ ==============================*)
    STEP_900_E:
      BasisStationsParameter.bFehler := TRUE;

(*REFERENZ ==============================*)
    STEP_1000_E:
      BasisStationsParameter.bReferenzAbgeschlossen := TRUE;

(*REFERENZ ==============================*)
 END_CASE
ELSE
  IF ( steplReferenz > STEP_0_E ) THEN
    BasisStationsParameter.bReferenzAbgeschlossen := FALSE;
    Querfahrt.bpStartReferenz := FALSE;
    Glastransport.bpFahreReferenz := FALSE;
    steplReferenz := STEP_0_E;
  END_IF
END_IF
END_ACTION