(* METADATA
{
	"v3Meta": {
		"objectGuid": "03480e68-cdc5-4531-b68c-8ecf9892ea12"
	}
}
*)
FUNCTION_BLOCK Rollenleiste_FB
VAR_INPUT

  (* BOOLEAN *)
  bpStarteOeffnen    : BOOL;
  bpStarteSchliessen : BOOL;
  bpReset            : BOOL;
  bpAktivieren       : BOOL;

END_VAR
VAR_OUTPUT

  (* BOOLEAN *)
  bpDone    : BOOL;
  bpFehler  : BOOL;

  (* WORD *)
  wpFehlerNr  : WORD;

END_VAR
VAR

  (* STEPS *)
  steplSchrittketteOeffnen    : Steps_TE;
  steplSchrittketteSchliessen : Steps_TE;

  (* TIMER *)
  tonlRollenleisteGeoeffnet   : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben *)
  tonlRollenleisteGeschlossen : TON; (* EINSCHALTVERZOEGERUNG: Warten bis der Zylinder verfahren wurde. Sonst wird ein Fehlerausgegeben *)

  (* TRIGGER *)
  ftlDeaktivieren : F_TRIG;

END_VAR
VAR

  (* HARDWARE EINGAENGE *)
  in_bGeoeffnet     AT %I* : BOOL; (* STATUS: Sensor meldet geöffnet *)
  in_bGeschlossen   AT %I* : BOOL; (* STATUS: Sensor meldet geschlossen *)

  (* HARDWARE AUSGAENGE *)
  out_bOeffnen      AT %Q* : BOOL; (* AKTION: Verstellen der Wandoeffnung -> Maximal Geoeffnet *)
  out_bSchliessen   AT %Q* : BOOL; (* AKTION: Verstellen der Wandoeffnung -> Minimal Geoeffnet *)

END_VAR
VAR CONSTANT

  (* TIME *)
  cZEITWERT_UEBERWACHUNG_BEWEGUNG : TIME := T#5s;

END_VAR

(***************************************************************************************************)
(* BAUSTEIN: ABLAUF *)
(***************************************************************************************************)

IF ( bpReset ) THEN

  out_bOeffnen    := FALSE;
  out_bSchliessen := FALSE;

  bpStarteOeffnen    := FALSE;
  bpStarteSchliessen := FALSE;

  wpFehlerNr := cMELDUNG_NULL;
  bpFehler   := FALSE;
  bpDone     := FALSE;

  bpReset := FALSE;

ELSE

  IF ( bpAktivieren ) THEN
    Oeffnen();
    Schliessen();
  ELSE
    bpDone     := TRUE;
    bpFehler   := FALSE;
    wpFehlerNr := 0;
  END_IF

  (* Hinweis:
     - Deaktiveren Baustein zuruecksetzen
  *)
  ftlDeaktivieren( CLK := bpAktivieren );

  IF ( ftlDeaktivieren.Q ) THEN
    bpReset := TRUE;
  END_IF

END_IF
END_FUNCTION_BLOCK