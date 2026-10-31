(* METADATA
{
  "v3Meta": {
    "objectGuid": "32ae7418-4bd1-4583-a2cb-6d193e6fcca4"
  }
}
*)
FUNCTION_BLOCK Arretierung_FB_1
VAR_INPUT

  // BOOLEAN
  bpReset          : BOOL;
  bpAktivieren     : BOOL;
  bpStartAusfahren : BOOL; 
  bpStartEinfahren : BOOL; 
  
  in_bStatusZylinderAusgefahren : BOOL;
  in_bStatusZylinderEingefahren : BOOL;
  
END_VAR
VAR_OUTPUT

  // BOOLEAN 
  bpFehler               : BOOL;    
  bpDone                 : BOOL;
  
  out_bZylinderAusfahren : BOOL;
  out_bZylinderEinfahren : BOOL;

  // WORD
  wpFehlerNr       : WORD;

  // ENUM
  epStatusZylinder : PneumatikZylinderStatus_EN;

END_VAR
VAR

  // STEPS 
  steplAusfahren   : Steps_TE;
  steplEinfahren   : Steps_TE;

  // TIMER
  tonZylinderEingefahren  : TON; 
  tonZylinderAusgefahren  : TON; 

END_VAR

VAR CONSTANT

  (* TIME*)
  cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER : TIME := T#15s;

END_VAR
(***************************************************************************************************)
(* BNAUSTEIN: STEUERUNG *)
(***************************************************************************************************)
IF ( bpReset ) THEN

  bpFehler := FALSE;
  bpDone   := FALSE;

  out_bZylinderAusfahren := FALSE;
  out_bZylinderEinfahren := FALSE;

  tonZylinderAusgefahren( IN := FALSE );
  tonZylinderEingefahren( IN := FALSE );

  wpFehlerNr := cMELDUNG_NULL;

  bpReset := FALSE;

ELSE

  IF ( bpAktivieren ) THEN

    (* Hinweis:
       - Baustein- Aktionen
    *)
    Ausfahren();
    Einfahren();

    (* Ausgang:
       - Status des Zylinders
    *)  
    IF (      in_bStatusZylinderAusgefahren
      AND NOT in_bStatusZylinderEingefahren )
    THEN
      epStatusZylinder := eZylinderAusgefahren;

    ELSIF(    in_bStatusZylinderEingefahren
      AND NOT in_bStatusZylinderAusgefahren )
    THEN
      epStatusZylinder := eZylinderEingefahren;

    ELSE
      epStatusZylinder := eZylinderUndefiniert;

    END_IF

  ELSE
    bpDone   := TRUE;
    bpFehler := FALSE;

  END_IF

END_IF
END_FUNCTION_BLOCK