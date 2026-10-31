(* METADATA
{
  "v3Meta": {
    "objectGuid": "32d63b77-62b3-4c1f-9a6d-0b9e7860b01c"
  }
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Transportsperre_Kipptisch_FB
VAR_INPUT

  (* BOOLEAN *)
  bpStartAusfahren    : BOOL; (* BETRIEBTYP: Zylinder wird ausgefahren *)
  bpStartEinfahren    : BOOL; (* BETRIEBTYP: Zylinder wird eingefahren *)
  bpReset             : BOOL; (* BETRIEBTYP: Zylinderbaustein wird zurueckgesetzt *)
  bpFreigabe          : BOOL; (* *)
  bpFreigabeEinfahren : BOOL; (* Freigabe von der Folgestation, dass die Sperre runter fahren darf *)

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpFehler            : BOOL;
  bpDone              : BOOL;
  bpFreigabeKippen    : BOOL;
  bpFreigabeTransport : BOOL;

  (* WORD *)
  wpFehlerNr       : WORD;

  (* ENUM *)
  wpStatusZylinder : PneumatikZylinderStatus_EN;

END_VAR
VAR
  (* STEPS *)
  steplAusfahren   : Steps_TE;
  steplEinfahren   : Steps_TE;
  steplReset       : Steps_TE;

  (* TIMER *)
  tonlZylinderEingefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlZylinderAusgefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tofEinfahren             : TOF;
  tofAusfahren             : TOF;

END_VAR

VAR

  (* HARDWARE EINGAENGE *)
  in_StatusZylinderAusgefahren   AT %I* : BOOL; (* STATUS: Sensor meldt ausgfahren  [Oben] *)
  in_StatusZylinderEingefahren   AT %I* : BOOL; (* STATUS: Sensor meldt eingefahren [Unten] *)

  (* HARDWARE AUSGAENGE *)
  out_ZylinderAusfahren   AT %Q* : BOOL; (* AKTION: Zylinder ausfahren *)
  out_ZylinderEinfahren   AT %Q* : BOOL; (* AKTION: Zylinder einfahren *)

END_VAR
(***************************************************************************************************)
(*  Aktionen *)
Ausfahren();

Einfahren();

Reset();

(***************************************************************************************************)
(*  Timer *)

tofEinfahren(IN:=bpStartEinfahren,pt:=t#1s);
tofAusfahren(IN:=bpStartAusfahren,pt:=t#1s);


(***************************************************************************************************)
(*  Ausgaenge *)

(* Ausgang:
   - Status des Zylinders
     => Ausgefahren
     => Eingefahren
     => Undefiniert
*)
IF (     in_StatusZylinderAusgefahren
     AND NOT in_StatusZylinderEingefahren )
THEN
  wpStatusZylinder := eZylinder1Ausgefahren;

ELSIF(   in_StatusZylinderEingefahren
     AND NOT in_StatusZylinderAusgefahren )
THEN
  wpStatusZylinder := eZylinder1Eingefahren;

ELSE
  wpStatusZylinder := eZylinderUndefiniert;

END_IF

bpFreigabeKippen    := ( wpStatusZylinder = eZylinder1Ausgefahren );
bpFreigabeTransport := ( wpStatusZylinder = eZylinder1Eingefahren );
END_FUNCTION_BLOCK