(* METADATA
{
	"v3Meta": {
		"objectGuid": "c49e37bf-a253-4691-9610-12ec51ad1d15"
	}
}
*)
FUNCTION_BLOCK ZylinderPneumatik_FB
VAR_INPUT

  (* BOOLEAN *)
  bpReset            : BOOL;
  bpAktivieren       : BOOL;
  bpStartAusfahren   : BOOL; (* BETRIEBTYP: Zylinder wird ausgefahren *)
  bpStartEinfahren   : BOOL; (* BETRIEBTYP: Zylinder wird eingefahren *)
  bpVariablen_Mappen : BOOL;
  
  
  (* HARDWARE EINGAENGE *)
  inStatusZylinderAusgefahren          : BOOL; (* STATUS: Sensor meldt ausgfahren  [Oben] *)
  inStatusZylinderEingefahren          : BOOL; (* STATUS: Sensor meldt eingefahren [Unten] *)

  in_bStatusZylinderAusgefahren   : BOOL; (* STATUS: Sensor meldt ausgfahren  [Oben] *)
  in_bStatusZylinderEingefahren   : BOOL; (* STATUS: Sensor meldt eingefahren [Unten] *)
  

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpFehler                       : BOOL;
  bpDone                         : BOOL;

  (* WORD *)
  wpFehlerNr       : WORD;

  (* ENUM *)
  epStatusZylinder : PneumatikZylinderStatus_EN;

END_VAR
VAR

  (* STEPS *)
  steplAusfahren   : Steps_TE;
  steplEinfahren   : Steps_TE;

  (* TIMER *)
  tonZylinderEingefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonZylinderAusgefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben *)

END_VAR
VAR


  (* HARDWARE AUSGAENGE *)
  out_bZylinderAusfahren    : BOOL; (* AKTION: Zylinder ausfahren *)
  out_bZylinderEinfahren    : BOOL; (* AKTION: Zylinder einfahren *)

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
    IF NOT bpVariablen_Mappen THEN
      inStatusZylinderAusgefahren := in_bStatusZylinderAusgefahren;
      inStatusZylinderEingefahren := in_bStatusZylinderEingefahren;
    END_IF
    
    Ausfahren();
    Einfahren();

    (* Ausgang:
       - Status des Zylinders
    *)  
    IF (      inStatusZylinderAusgefahren
      AND NOT inStatusZylinderEingefahren )
    THEN
      epStatusZylinder := eZylinderAusgefahren;

    ELSIF(    inStatusZylinderEingefahren
      AND NOT inStatusZylinderAusgefahren )
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