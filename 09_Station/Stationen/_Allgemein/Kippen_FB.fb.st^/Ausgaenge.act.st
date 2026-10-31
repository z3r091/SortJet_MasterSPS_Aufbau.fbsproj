(* METADATA
{
  "v3Meta": {
    "objectGuid": "3d0a21cb-dd53-430c-a29a-fad3375a245a"
  }
}
*)
ACTION Ausgaenge
(***************************************************************************************************)
(* BAUSTEIN: AUSGAENGE  *)
(***************************************************************************************************)
(* Hinweis:
  - Bremse lösen
  - Phoenix Contact Schuetz resetten 
*)
out_bBremseLoesen := out_bKippen84Grad OR out_bKippen90Grad;
out_bReset := toflReset.Q;

(* Ausgang:
   - Status- Referenz
*)
bpInReferenz := Antrieb.bpIstReferenziert OR ppParameterBaustein.bKippenMitSchuetz;

(* Anmerkung:
  - Realisierung durch ein ENUM
*)
IF ppParameterBaustein.bKippenMitSchuetz THEN

  IF ( NOT bpSensorNicht90Grad AND bpSensorNicht84Grad ) THEN
    epKippStatus := eKippen_Position_90Grad;
  ELSIF ( NOT bpSensorNicht84Grad AND bpSensorNicht90Grad ) THEN
    epKippStatus := eKippen_Position_84Grad;
  ELSIF ( NOT bpSensorNicht90Grad AND NOT bpSensorNicht84Grad ) THEN
    epKippStatus := eKippen_Default;
  ELSE
    epKippStatus := eKippen_Fehler;
  END_IF
  
ELSE
	
 IF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition0Grad) < ppParameterBaustein.rToleranz ) THEN
  epKippStatus := eKippen_Position_0Grad;
 ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition84Grad) < ppParameterBaustein.rToleranz ) THEN
  epKippStatus := eKippen_Position_84Grad;
 ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition90Grad) < ppParameterBaustein.rToleranz ) THEN
  epKippStatus := eKippen_Position_90Grad;
 ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition96Grad) < ppParameterBaustein.rToleranz ) THEN
  epKippStatus := eKippen_Position_96Grad;
 ELSE
  epKippStatus := eKippen_Fehler;
 END_IF
 
END_IF
END_ACTION