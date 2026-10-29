(* METADATA
{
	"v3Meta": {
		"objectGuid": "85c14a01-ee4c-4a24-bcca-8fef195064c0"
	}
}
*)
{attribute 'excludefrombuild'}
FUNCTION_BLOCK Transportsperre_Foerderbaender_FB
VAR_INPUT

  (* HARDWARE EINGAENGE *)
  in_bOben            : BOOL; (* STATUS: Sensor meldt ausgfahren  [Oben] *)

  (* BOOLEAN *)
  bpStartRunter       : BOOL; (* BETRIEBTYP: Zylinder wird ausgefahren *)
  bpStartHoch         : BOOL; (* BETRIEBTYP: Zylinder wird eingefahren *)
  bpReset             : BOOL; (* BETRIEBTYP: Zylinderbaustein wird zurueckgesetzt *)
  bpFreigabe          : BOOL;

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpFehler            : BOOL;
  bpDone              : BOOL;

  (* WORD *)
  wpFehlerNr          : WORD;

  (* ENUM *)
  wpStatus            : TransportsperrenStatus_EN;

END_VAR
VAR
  (* STEPS *)
  steplHoch         : Steps_TE;
  steplRunter       : Steps_TE;
  steplReset        : Steps_TE;

  (* TIMER *)
  tonlOben                 : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlUnten                : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tofHoch                  : TOF;
  tofRunter                : TOF;

END_VAR

VAR

  (* HARDWARE EINGAENGE *)
  in_bUnten     AT %I* : BOOL; (* STATUS: Sensor meldt eingefahren [Unten] *)

  (* HARDWARE AUSGAENGE *)
  out_bRunter   AT %Q* : BOOL; (* AKTION: Zylinder einfahren *)

END_VAR
(***************************************************************************************************)
(*  Aktionen *)
HochFahren();

RunterFahren();

Reset();

(***************************************************************************************************)
(*  Timer *)

tofHoch(IN:=bpStartHoch,pt:=t#1s);
tofRunter(IN:=bpStartRunter,pt:=t#1s);


(***************************************************************************************************)
(*  Ausgaenge *)

(* Ausgang:
   - Status des Zylinders
     => Ausgefahren
     => Eingefahren
     => Undefiniert
*)
IF (     in_bOben
     AND NOT in_bUnten )
THEN
  wpStatus := eTransportsperreOben;

ELSIF(   in_bUnten
     AND NOT in_bOben )
THEN
  wpStatus := eTransportsperreUnten;

ELSE
  wpStatus := eTransportsperreUndefiniert;

END_IF
END_FUNCTION_BLOCK