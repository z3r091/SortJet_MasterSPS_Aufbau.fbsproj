(* METADATA
{
  "v3Meta": {
    "objectGuid": "b2af587c-0d32-447c-a5c9-96380651afc9"
  }
}
*)
FUNCTION_BLOCK ZylinderPneumatik_Federrueck_FB
VAR_INPUT

  (* BOOLEAN *)
  bpStartAusfahren : BOOL; (* BETRIEBTYP: Zylinder wird ausgefahren *)
  bpStartEinfahren : BOOL; (* BETRIEBTYP: Zylinder wird eingefahren *)
  bpReset          : BOOL; (* BETRIEBTYP: Zylinderbaustein wird zurueckgesetzt *)

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpFehler   : BOOL;
  bpDone     : BOOL;

  (* WORD *)
  wpFehlerNr : WORD;

  (* ENUM *)
  epStatusZylinder : PneumatikZylinderStatus_EN;

END_VAR
VAR

  (* HARDWARE EINGAENGE *)
  in_bStatusZylinderAusgefahren   AT %I* : BOOL; (* STATUS: Sensor meldt ausgfahren  *)
  in_bStatusZylinderEingefahren   AT %I* : BOOL; (* STATUS: Sensor meldt eingefahren *)

  (* HARDWARE AUSGAENGE *)
  out_bZylinderAusfahren          AT %Q* : BOOL; (* AUSGANG: (in Glasflussrichtung) Signal zum Ausfahren  [Federrueckstell- Ventiel] *)

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
(* S T A R T - Betriebstypen [Ausfahren, Einfahren] *)
(***************************************************************************************************)

Ausfahren();
Einfahren();

(***************************************************************************************************)
(* E N D E - Betriebstypen [Ausfahren, Einfahren] *)
(***************************************************************************************************)

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


(***************************************************************************************************)
(* E N D E - Ausgaenge *)
(***************************************************************************************************)
END_FUNCTION_BLOCK