(* METADATA
{
  "v3Meta": {
    "objectGuid": "f23bddb1-63ca-4604-a6dc-29eecd32a79e"
  }
}
*)
ACTION Ausgaenge
//-------------------------------------------------------------------------------------------------
// AUSGAENGE
//-------------------------------------------------------------------------------------------------
// Kippen mit Schütz
IF ( bpKippenSchuetz ) THEN

  // Position als ENUM
  IF ( NOT in_bSensorNicht84Grad AND in_bSensorNicht90Grad ) THEN
    epKippStatus := eKippen_Position_84Grad;
  
  ELSIF ( NOT in_bSensorNicht90Grad AND in_bSensorNicht84Grad ) THEN
    epKippStatus := eKippen_Position_90Grad;

  ELSE
    epKippStatus := eKippen_Fehler;
  
  END_IF
  
  // Referenz ok
  bpInReferenz := TRUE;

// Kippen mit Motor
ELSE
  // Position als ENUM
  IF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition0Grad) <= ppParameterBaustein.rToleranz) THEN
    epKippStatus := eKippen_Position_0Grad;
  
  ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition84Grad) <= ppParameterBaustein.rToleranz) THEN
    epKippStatus := eKippen_Position_84Grad;
  
  ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition88_5Grad) <= ppParameterBaustein.rToleranz) THEN
    epKippStatus := eKippen_Position_88_5Grad;
    
  ELSIF ( ABS(Antrieb.rpIstPosition - ppParameterBaustein.rPosition90Grad) <= ppParameterBaustein.rToleranz) THEN
    epKippStatus := eKippen_Position_90Grad;
 
  ELSE
    epKippStatus := eKippen_Fehler;
  
  END_IF
   
  // Position
  rpAktuelleKippPosition := Antrieb.rpIstPosition;
  
  // Aktuelle Geschwindigkeit des Antriebs
  rpOutGeschwindigkeit := ABS(Antrieb.rpIstGeschwindigkeit);
  
  // Referenz ok
  bpInReferenz := Antrieb.bpIstReferenziert;

END_IF
END_ACTION