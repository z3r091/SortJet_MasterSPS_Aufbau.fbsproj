(* METADATA
{
  "v3Meta": {
    "objectGuid": "e4a9e99a-5da2-4703-bfbe-ba0d105ea792"
  }
}
*)
ACTION Steuerung_OptionaleLuftabfragen
(***************************************************************************************************)
(* AKTION: OPTIONALE LUFTABFRAGEN *)
(***************************************************************************************************)

(* Hinweis:
   - Schmale-Luftabfragen
*)
IF NOT bpOptionSensorEinlauf THEN

  IF ( out_bScheibenKontrolleEinlaufSeiteAuf ) THEN
    bpSensorScheibenKontrolleEinlaufSeiteOben  := TRUE;
    bpSensorScheibenKontrolleEinlaufSeiteUnten := FALSE;
  ELSE
    bpSensorScheibenKontrolleEinlaufSeiteOben  := FALSE;
    bpSensorScheibenKontrolleEinlaufSeiteUnten := TRUE;
  END_IF

END_IF


IF NOT bpOptionSensorAuslauf THEN

  IF ( out_bScheibenKontrolleAuslaufSeiteAuf ) THEN
    bpSensorScheibenKontrolleAuslaufSeiteOben  := TRUE;
    bpSensorScheibenKontrolleAuslaufSeiteUnten := FALSE;
  ELSE
    bpSensorScheibenKontrolleAuslaufSeiteOben  := FALSE;
    bpSensorScheibenKontrolleAuslaufSeiteUnten := TRUE;
  END_IF

END_IF
END_ACTION