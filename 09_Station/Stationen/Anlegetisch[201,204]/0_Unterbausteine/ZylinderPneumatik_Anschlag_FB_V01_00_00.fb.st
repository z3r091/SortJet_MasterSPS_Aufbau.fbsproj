(* METADATA
{
  "v3Meta": {
    "objectGuid": "73b344ea-77d6-4df9-8490-b74a4c5cebf9"
  }
}
*)
FUNCTION_BLOCK ZylinderPneumatik_Anschlag_FB_V01_00_00
VAR_INPUT

  // EINGAENGE 
  in_bStatusZylinderAusgefahren : BOOL; 
  in_bStatusZylinderEingefahren : BOOL; 

  // BOOLEAN 
  bpReset                       : BOOL;
  bpAktivieren                  : BOOL;
  bpStartAusfahren              : BOOL; 
  bpStartEinfahren              : BOOL; 
  

END_VAR
VAR_OUTPUT
  // AUSGAENGE 
  out_bZylinderAusfahren        : BOOL; 
  out_bZylinderEinfahren        : BOOL; 
                            
  // BOOLEAN              
  bpFehler                      : BOOL;
  bpDone                        : BOOL;

  // WORD 
  wpFehlerNr                    : WORD;

  // ENUM 
  epStatusZylinder : PneumatikZylinderStatus_EN;

END_VAR
VAR

  // STEPS 
  steplAusfahren   : Steps_TE;
  steplEinfahren   : Steps_TE;

  // TIMER 
  tonZylinderEingefahren  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben
  tonZylinderAusgefahren  : TON; // EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben

END_VAR

VAR CONSTANT

  // TIME
  cZEITLICHE_UEBERWACHUNG_BEWEGUNG_ZYLINDER : TIME := T#15s;

END_VAR
//-------------------------------------------------------------------------------------------------
// BNAUSTEIN: STEUERUNG
//-------------------------------------------------------------------------------------------------

IF ( bpReset ) THEN

  bpFehler := FALSE;
  bpDone   := FALSE;

  out_bZylinderAusfahren    := FALSE;
  out_bZylinderEinfahren    := FALSE;

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

    // Ausgang:
    //   - Status des Zylinders
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