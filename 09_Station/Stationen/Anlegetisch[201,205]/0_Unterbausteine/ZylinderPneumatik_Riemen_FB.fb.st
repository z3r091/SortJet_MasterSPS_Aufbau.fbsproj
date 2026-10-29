(* METADATA
{
	"v3Meta": {
		"objectGuid": "4bd964be-8117-422d-b97f-60e1c4b0ab77"
	}
}
*)
FUNCTION_BLOCK ZylinderPneumatik_Riemen_FB
VAR_INPUT
  (* HARDWARE EINGAENGE *)
  in_bStatusZylinderAusgefahren : BOOL; (* STATUS: Sensor meldt ausgfahren  *)
  in_bStatusZylinderEingefahren : BOOL; (* STATUS: Sensor meldt eingefahren *)
  
  (* BOOLEAN *)
  bpStartAusfahren : BOOL; (* BETRIEBTYP: Zylinder wird ausgefahren *)
  bpStartEinfahren : BOOL; (* BETRIEBTYP: Zylinder wird eingefahren *)
  bpReset          : BOOL; (* BETRIEBTYP: Zylinderbaustein wird zurueckgesetzt *)

END_VAR
VAR_OUTPUT
  (* HARDWARE AUSGAENGE *)
  out_bZylinderAusfahren : BOOL; (* AUSGANG: (in Glasflussrichtung) Signal zum Ausfahren  [Federrueckstell- Ventiel] *)

  (* BOOLEAN *)
  bpFehler   : BOOL;
  bpDone     : BOOL;

  (* WORD *)
  wpFehlerNr : WORD;

  (* ENUM *)
  epStatusZylinder : PneumatikZylinderStatus_EN;

END_VAR
VAR
  (* STEPS *)
  steplAusfahren   : Steps_TE;
  steplEinfahren   : Steps_TE;
  steplReset       : Steps_TE;

  (* TIMER *)
  tonlZylinderEingefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder eingefahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlZylinderAusgefahren  : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder ausgefahren wurde. Sonst wird ein Fehlerausgegeben *)

END_VAR
(* Hinweis:
   - Es handelt sich bei diesem Baustein um eine Ansteuerung fuer ein Federrueckstell- Ventiel
*)


(***************************************************************************************************)
(* Betriebstypen [Ausfahren, Einfahren] *)
(***************************************************************************************************)
Ausfahren();
Einfahren();
Reset();

(***************************************************************************************************)
(* S T A R T - Ausgaenge *)
(***************************************************************************************************)

(* Ausgang:
   - Status des Zylinders
     => Ausgefahren
     => Eingefahren
     => Undefiniert
*)
IF (         in_bStatusZylinderAusgefahren
     AND NOT in_bStatusZylinderEingefahren )
THEN
  epStatusZylinder := eZylinderAusgefahren;

ELSIF(       in_bStatusZylinderEingefahren
     AND NOT in_bStatusZylinderAusgefahren )
THEN
  epStatusZylinder := eZylinderEingefahren;

ELSE
  epStatusZylinder := eZylinderUndefiniert;

END_IF
END_FUNCTION_BLOCK